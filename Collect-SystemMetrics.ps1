<#
.SYNOPSIS
  Writes SystemMetrics.json for the Screening Reconciliation Command Center "System monitor" window.

.DESCRIPTION
  A web page cannot read the server's CPU, memory, disks, network, processes, IP addresses or Windows Event IDs.
  This script collects them with CIM / Get-WinEvent and writes one JSON file (atomically) into the shared feeds
  folder. The dashboard reads that file; nothing is sent anywhere else and nothing is installed.

  Works in Windows PowerShell 5.1 and PowerShell 7 on Windows. Reading the Security event log needs an
  elevated session (or a service account in the "Event Log Readers" group); logs that cannot be read are skipped.

.PARAMETER OutFile
  Full path of the JSON file, normally the shared feeds folder, e.g. \\fileserver\recon-feeds\SystemMetrics.json

.PARAMETER Loop
  Keep running and refresh the file every -IntervalSeconds (otherwise it runs once; use Task Scheduler).

.PARAMETER EventLogs / EventHours / MaxEvents / EventIds
  Which logs to read, how far back, how many events to keep, and extra Event IDs to always include at any level
  (for example 4625 failed logon, 4740 account lockout, 7045 new service).

.EXAMPLE
  .\Collect-SystemMetrics.ps1 -OutFile \\fileserver\recon-feeds\SystemMetrics.json -Loop -IntervalSeconds 30

.EXAMPLE
  # Task Scheduler, every minute, as SYSTEM
  schtasks /Create /SC MINUTE /MO 1 /RU SYSTEM /TN "ReconMetrics" /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Tools\Collect-SystemMetrics.ps1 -OutFile D:\feeds\SystemMetrics.json"
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$OutFile,
  [switch]$Loop,
  [ValidateRange(5, 3600)][int]$IntervalSeconds = 30,
  [string[]]$EventLogs = @('System', 'Application', 'Security'),
  [ValidateRange(1, 168)][int]$EventHours = 24,
  [ValidateRange(5, 100)][int]$MaxEvents = 60,
  [int[]]$EventIds = @(4625, 4740, 7045, 41, 6008),
  [ValidateRange(3, 25)][int]$TopProcesses = 15
)

$ErrorActionPreference = 'Stop'
$script:EventCacheAt = [datetime]::MinValue
$script:EventCache = @()

function Get-OneLine([string]$Text, [int]$Max) {
  if ([string]::IsNullOrEmpty($Text)) { return '' }
  $first = $Text.Split([char[]]@(13, 10))[0]
  if ($first.Length -gt $Max) { return $first.Substring(0, $Max) }
  return $first
}

function Get-Events {
  # Reading event logs is the slow part: refresh at most once a minute.
  if (([datetime]::Now - $script:EventCacheAt).TotalSeconds -lt 60) { return $script:EventCache }
  $start = (Get-Date).AddHours(-$EventHours)
  $levelName = @{ 1 = 'Critical'; 2 = 'Error'; 3 = 'Warning'; 4 = 'Information'; 0 = 'Information' }
  $found = New-Object System.Collections.ArrayList
  foreach ($log in $EventLogs) {
    $queries = @(@{ LogName = $log; StartTime = $start; Level = 1, 2, 3 })
    if ($EventIds.Count -gt 0) { $queries += @{ LogName = $log; StartTime = $start; Id = $EventIds } }
    foreach ($q in $queries) {
      try {
        Get-WinEvent -FilterHashtable $q -MaxEvents $MaxEvents -ErrorAction Stop | ForEach-Object {
          [void]$found.Add([pscustomobject]@{
              id      = [int]$_.Id
              level   = $levelName[[int]$_.Level]
              source  = [string]$_.ProviderName
              log     = $log
              time    = $_.TimeCreated.ToUniversalTime().ToString('o')
              message = Get-OneLine $_.Message 200
            })
        }
      }
      catch {
        # "No events were found" is normal; permission problems on a log just skip that log.
        if ($_.Exception.Message -notmatch 'No events were found') { Write-Verbose ("Event log {0}: {1}" -f $log, $_.Exception.Message) }
      }
    }
  }
  $script:EventCache = @($found | Sort-Object time -Descending | Group-Object { '{0}|{1}|{2}' -f $_.log, $_.id, $_.time } |
      ForEach-Object { $_.Group[0] } | Select-Object -First $MaxEvents)
  $script:EventCacheAt = [datetime]::Now
  return $script:EventCache
}

function Get-Metrics {
  $os = Get-CimInstance Win32_OperatingSystem
  $cs = Get-CimInstance Win32_ComputerSystem
  $cores = [int]$cs.NumberOfLogicalProcessors
  if ($cores -lt 1) { $cores = 1 }

  $cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
  $totalMB = [math]::Round($os.TotalVisibleMemorySize / 1024)
  $freeMB = [math]::Round($os.FreePhysicalMemory / 1024)
  $usedMB = $totalMB - $freeMB

  $disks = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Where-Object { $_.Size -gt 0 } | ForEach-Object {
      $used = $_.Size - $_.FreeSpace
      [pscustomobject]@{
        name    = [string]$_.DeviceID
        pct     = [math]::Round($used / $_.Size * 100, 1)
        usedGB  = [math]::Round($used / 1GB, 1)
        totalGB = [math]::Round($_.Size / 1GB, 1)
      }
    })

  $net = @()
  try {
    $net = @(Get-CimInstance Win32_PerfFormattedData_Tcpip_NetworkInterface | Where-Object { $_.CurrentBandwidth -gt 0 -and $_.Name -notmatch 'isatap|Loopback|Teredo|Pseudo' } | ForEach-Object {
        [pscustomobject]@{
          name      = [string]$_.Name
          rxMbps    = [math]::Round($_.BytesReceivedPersec * 8 / 1e6, 2)
          txMbps    = [math]::Round($_.BytesSentPersec * 8 / 1e6, 2)
          speedMbps = [math]::Round($_.CurrentBandwidth / 1e6)
        }
      })
  }
  catch { Write-Verbose "Network counters unavailable: $($_.Exception.Message)" }

  $ips = @()
  try { $ips = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop | Where-Object { $_.IPAddress -notmatch '^(127\.|169\.254\.)' } | ForEach-Object { [string]$_.IPAddress }) }
  catch { Write-Verbose "IP addresses unavailable: $($_.Exception.Message)" }

  $procs = @()
  try {
    $procs = @(Get-CimInstance Win32_PerfFormattedData_PerfProc_Process | Where-Object { $_.Name -notin @('_Total', 'Idle') } |
        Sort-Object PercentProcessorTime -Descending | Select-Object -First $TopProcesses | ForEach-Object {
        [pscustomobject]@{
          name  = [string]$_.Name
          pid   = [int]$_.IDProcess
          cpu   = [math]::Round([math]::Min(100, $_.PercentProcessorTime / $cores), 1)
          memMB = [math]::Round($_.WorkingSetPrivate / 1MB)
        }
      })
  }
  catch { Write-Verbose "Process counters unavailable: $($_.Exception.Message)" }

  [ordered]@{
    generated = (Get-Date).ToUniversalTime().ToString('o')
    collector = 'Collect-SystemMetrics.ps1 1.0'
    host      = [ordered]@{
      name      = $env:COMPUTERNAME
      os        = [string]$os.Caption
      uptimeSec = [int]((Get-Date) - $os.LastBootUpTime).TotalSeconds
      ips       = $ips
      cores     = $cores
    }
    cpu       = [ordered]@{ pct = [math]::Round([double]$cpu, 1) }
    memory    = [ordered]@{ pct = [math]::Round($usedMB / $totalMB * 100, 1); usedMB = $usedMB; totalMB = $totalMB }
    disks     = $disks
    network   = $net
    processes = $procs
    events    = @(Get-Events)
  }
}

function Write-Metrics {
  $json = Get-Metrics | ConvertTo-Json -Depth 6 -Compress
  $dir = Split-Path -Parent $OutFile
  if ($dir -and -not (Test-Path -LiteralPath $dir)) { throw "Folder not found: $dir" }
  $tmp = "$OutFile.tmp"
  # UTF-8 without BOM; write to a temp file first so the dashboard never reads a half-written file.
  [System.IO.File]::WriteAllText($tmp, $json, (New-Object System.Text.UTF8Encoding($false)))
  Move-Item -LiteralPath $tmp -Destination $OutFile -Force
}

do {
  try { Write-Metrics; Write-Verbose ("Wrote {0}" -f $OutFile) }
  catch { Write-Warning ("Could not write metrics: {0}" -f $_.Exception.Message); if (-not $Loop) { exit 1 } }
  if ($Loop) { Start-Sleep -Seconds $IntervalSeconds }
} while ($Loop)
