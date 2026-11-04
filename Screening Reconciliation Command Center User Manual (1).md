# Screening Reconciliation Command Center: User Manual

Nov 2, 2026 · @Ash

This manual shows how to connect, read, customise and troubleshoot the Screening Reconciliation Command Center (version 3.2.0), a single-file dashboard that reconciles the GCOP, FINSCAN and OPF screening feeds on the customer CIF.

## 1. Overview

The dashboard compares three CSV extracts: GCOP (Dow Jones), FINSCAN (Worldcheck / SEPA Blacklist) and OPF, the action feed. Every customer screened by GCOP or FINSCAN should also appear in OPF, and the dashboard shows who does not, how long they have waited and where they sit.

| Term | Meaning |
| --- | --- |
| CIF | The customer identifier that links a row across all three feeds. |
| Reconciled customers (the universe) | Every distinct CIF found in GCOP, FINSCAN or both. CIFs found only in OPF sit outside the universe and are listed under Feed status & data quality. |
| Actioned | The customer's CIF is present in the OPF feed. |
| Not actioned | The CIF is in the universe but missing from OPF. The age shown next to it counts from the earliest source timestamp. |
| Category | GCOP only, FINSCAN only, or Both systems. |
| Snapshot | The reconciliation as of one 5-minute slot. Up to 24 hours (289 snapshots) are kept while the page is open. |
| Sample or Live | Sample data comes from a built-in simulator. Live reads your feed files from the shared folder. |

Everything runs inside your browser. The application is one file, `index.html`, with no installation, server or internet connection required.

## 2. Getting started

**Requirements.** A current Chrome or Edge gives you everything, including the shared-folder picker. Firefox and Safari work too, but read live feeds through the Web URL method only.

1. Save `index.html` anywhere you like (desktop, shared drive or web server) and open it in your browser. It starts in **Sample data** mode with 24 hours of simulated history, so you can explore at once.
2. Look at the thin ribbon at the top. An amber **SAMPLE DATA** badge confirms you are not looking at real feeds.
3. Click **Settings** at the right end of the ribbon to open the control panel.
4. On the **Data source** tab, set Feed source to *Live feed*, choose **Choose shared folder…** and pick the folder that holds `GCOP.csv`, `FINSCAN.csv` and `OPF.csv`. Press **Save & apply**.
5. If your files use different column names or contain extra columns, open the **Feed columns** tab and adjust them (section 7).
6. Personalise the logo, colours and layout, then save your settings so the dashboard looks the same next time (section 8).

The **Help & about** tab of the control panel repeats this quick start, shows your browser's capabilities and offers a one-click self-check.

## 3. The dashboard at a glance

&#91;image: The complete dashboard in the dark theme\]

Work from the top of the page downwards:

| Area | What it shows |
| --- | --- |
| Ribbon (top strip) | Mode badge (SAMPLE DATA or LIVE FEED), connection status, one dot per feed (green healthy, amber stale, red error), time of the last refresh, the ⚙ gear that opens the System monitor, and the **Print**, **Theme** and **Settings** buttons. Click the connection status to reconnect or open Settings. |
| Header | Your logo (a separate one for each theme) and application name, plus the **Generate Client** button. |
| Snapshot bar | The snapshot being viewed, whether it is **Current** or **Historical**, how fresh the feeds are, the countdown to the next check and **Refresh feeds now**. |
| Sliding window timeline | Folded by default. Click it to look back up to 24 hours. |
| Alert banner | Counts customers unactioned by OPF for longer than the threshold (15 minutes by default). Change the threshold in the banner or press **Review** to list them. |
| KPI cards | Six counts: reconciled customers, GCOP only, FINSCAN only, in both systems, actioned by OPF, not actioned by OPF. Each shows the share and the change versus the previous snapshot. Click a card to list its customers in a side panel; \*\*Show in table\*\* then applies the same selection to the table. |
| Set overlap, Status matrix, Customers by branch | Three charts that answer the same question from different angles. Click a Venn region, a matrix cell or a branch bar to drill into it. |
| Customer counts across the sliding window | A full-width trend line. Click anywhere on it to jump to that snapshot. |
| Feed status & data quality | Collapsed panel with row counts, duplicate rows, missing CIFs, malformed timestamps, name conflicts and OPF-only CIFs. |
| Reconciliation table | One row per customer with search, filters, sorting and a drill-down drawer. |
| AI Chat button | A question-and-answer assistant for the selected snapshot. |

&#91;image: The six KPI cards\]

&#91;image: Set overlap, status matrix and customers by branch\]

&#91;image: Customer counts across the sliding window\]

**Colour language.** In the table, a coloured edge marks each row: red means not actioned by OPF, amber means present in one system and actioned, green means present in both systems and actioned. The **G** and **F** labels (white text on green and on blue) show whether a row comes from GCOP, FINSCAN or both.

## 4. Connecting your live feeds

&#91;image: The Data source tab\]

Open **Settings > Data source** and set **Feed source** to *Live feed*. Then choose how the files are read.

### Shared folder (Chrome and Edge)

1. Set *Read live feeds via* to **Shared folder**.
2. Press **Choose shared folder…** and select the folder, for example a mapped drive or a UNC share, that holds the three files.
3. Press **Test connection**. Each feed reports its row count and modification time, or the exact reason it failed.
4. Press **Save & apply**.

The dashboard only ever reads the folder. The browser remembers your choice on this PC. After you restart the browser, the ribbon shows *Click to re-grant access*; one click on it and **Allow** restores the connection.

### Web URL (any browser)

Set *Read live feeds via* to **Web URL** and enter the **Base URL** that serves the files, such as `https://fileserver.corp/recon-feeds`. Leave it blank to read the files from the same folder as `index.html` when that page is served over http or https. A web server on another address must allow cross-origin reads (CORS).

### Names and timing

| Setting | Default | Purpose |
| --- | --- | --- |
| GCOP / FINSCAN / OPF file name | GCOP.csv, FINSCAN.csv, OPF.csv | Change if your extracts are named differently. |
| Check feeds every | 5 minutes | How often the files are re-read. A file whose content has not changed is not reprocessed. |
| Flag a feed as stale after | 15 minutes | A feed whose file has not been modified for this long turns amber. |

**Refresh feeds now** in the snapshot bar re-reads the files immediately.

### Reading the status

| Ribbon status | Meaning | What to do |
| --- | --- | --- |
| Connected | All three feeds were read. | Nothing. |
| Connecting | A read is in progress. | Wait a moment. |
| Partial | One or two feeds failed; the message names them. | Open Feed status & data quality. |
| Error | No feed could be read, or a file is invalid. | Read the message; see Troubleshooting. |
| Click to re-grant access | The browser needs permission again. | Click the status, then Allow. |
| Not configured | No folder or URL has been set. | Open Settings > Data source. |

Each feed dot in the ribbon is **ok** (green), **stale** (amber) or **error / invalid** (red). *Invalid* means the file was read but a required column is missing.

## 5. Feed file format

Each feed is a CSV file with a header row. Header names are matched ignoring case, spaces and punctuation, and each column accepts several alternative names.

**GCOP and FINSCAN** (the same layout):

| Column | Accepted header names | Required | Used for |
| --- | --- | --- | --- |
| CIF | CIF, CIFNumber, CustomerID, CustomerCIF | Yes | Matching key |
| ClientName | ClientName, CustomerName, Name | Yes | Display name |
| SanctionListName | SanctionListName, SanctionList, ListName, List | Yes | Sanction list shown and filtered |
| GCOP/FINSCANIdentifier | GCOP/FINSCANIdentifier, Identifier, System, Source | No | Which system a row belongs to |
| Branch | Branch, BranchName | Yes | Branch charts and filter |
| TransactionID | TransactionID, TxnID, Transaction, TransactionRef | Yes | Transactions, fallback match |
| Amount | Amount, Amt, TransactionAmount | Yes | Amounts |
| Currency | Currency, CCY | Yes | Currency filter |
| BusinessDate | BusinessDate, BizDate, Date, ValueDate | Yes | Business date |
| Timestamp | Timestamp, Time, TransactionTime, TxnTime | Yes | Age of unactioned items |

**OPF** needs only CIF, ClientName and Branch.

```csv
CIF,ClientName,SanctionListName,GCOP/FINSCANIdentifier,Branch,TransactionID,Amount,Currency,BusinessDate,Timestamp
C1001,Aaron Smith,Dow Jones,GCOP,London,TXN-1,25000.50,GBP,02/11/2026,10:51:00
```

**Accepted formats.**

- The separator is detected automatically: comma, semicolon, tab or pipe. UTF-8 with or without a byte-order mark is fine, and quoted fields may contain commas and line breaks.
- Dates are day/month/year by default. Switch to month/day/year under **Timeline & alerts > Date format in feeds**. Times are hh:mm:ss.
- A row with no CIF is matched by TransactionID when that option is on (it is by default); otherwise it is counted as a data-quality issue.
- Duplicate rows, malformed timestamps and customers whose name differs between feeds are counted, never silently dropped.
- Each file may be up to 100 MB. Around 20,000 rows reconcile in well under a second.

**Different headers or extra columns?** Do not edit your files. Adjust the column definitions on the **Feed columns** tab (section 7).

## 6. Working with the data

### The sliding window timeline

&#91;image: The timeline expanded, viewing a historical snapshot\]

The timeline starts folded. **Click its bar** to expand it; **double-click an empty area** of the panel, or press **Fold**, to fold it again.

- Choose the range: last 1, 3, 6, 12 or 24 hours. The default is 24 hours.
- Drag the slider, or use **Earlier** and **Later** (one 5-minute snapshot) and **−1 h** and **+1 h**.
- **Play** steps through the snapshots automatically. **Jump to Now** returns to the latest.
- A green **Current** badge means you are on the newest snapshot; a blue **Historical** badge means you are looking at the past. Every number on the page then refers to that moment.
- Only the past is shown, never the future. In live mode the history builds up while the page stays open and is lost when you reload; sample mode starts with a full 24 hours.

### Reconciliation table

&#91;image: The reconciliation table with filters\]

- **Search** by CIF or client name. Filter by **Branch**, **Category**, **OPF status**, **Sanction list** and **Currency**; **Clear filters** resets them.
- Click a column heading to sort, and click again to reverse. The default sort puts customers not actioned by OPF first.
- The **Source** column shows a green **G** for GCOP and a blue **F** for FINSCAN. A customer in both systems shows both.
- Where a customer has several transactions, the timestamp shows the latest and says how many there are, for example *latest of 4*.
- Click a KPI card, a Venn region, a matrix cell, a branch bar or an alert's **Review** button to list that group's customers in the side panel, then press Show in table to filter the table to the same group.

### Customer drill-down

&#91;image: The customer drill-down drawer\]

Click a CIF or a table row. The drawer explains in words why the customer has its status, shows the GCOP and FINSCAN records side by side, the OPF result and every underlying record. **Copy** buttons copy a CIF or transaction ID. Press **Esc** or **Close** to leave. When you arrived from a chart or card, **Back to list** returns to that group.

### Feed status & data quality

&#91;image: The data quality panel\]

The panel header counts the items to review. Expand it to see, per feed, the state, row count and last-modified time, plus duplicate rows, rows with no CIF, malformed timestamps, customers whose name differs between feeds and CIFs found only in OPF.

### Printing

**Print** (ribbon) produces a clean report of the snapshot on screen: Total CIFs, the reconciliation counts and the data-quality summary. From version 3.2 the application has no Upload CSVs, Sample data, Export CSV or Transactions CSV buttons: the files in the shared drive are the single source of truth.

### AI Chat

&#91;image: The AI Chat assistant\]

The **AI Chat** button opens an assistant that answers from the snapshot you are viewing. Click a suggestion or type a question, such as *Show customers not actioned by OPF* or *Which branch has the most unreconciled customers?* The built-in assistant is rules-based and runs locally.

To use your own gateway, press **Connection**, enter an endpoint URL and tick the option to send questions plus the snapshot's customer data to it. The endpoint must reply with `{"answer": "markdown text"}`. If it fails, the local assistant answers instead. API keys are never stored by the page.

## 7. Customising the dashboard

Open **Settings** in the ribbon. The control panel has eleven tabs. Changes to looks, such as colours, logo, fonts and layout, **preview live** behind the panel. **Save & apply** keeps them; **Cancel**, the ✕ button or **Esc** asks before discarding anything unsaved.

| Tab | What you can change |
| --- | --- |
| General & logo | Application name, subtitle, logo, G / F label text, theme (dark, light or follow system). |
| Colours | Every colour, separately for the dark and light themes. |
| Typography & ribbon | Font, text size, zoom, corner radius, ribbon thickness, font size and items. |
| Data source | Sample or live, folder or URL, file names, check interval, stale limit, connection test. |
| Feed columns | Add, remove, rename and reorder the columns of each feed. |
| Timeline & alerts | Default range, play speed, start expanded, alert threshold, TransactionID fallback, date format. |
| Table | Rows per page, default sort, built-in columns shown. |
| Layout | Show, hide and reorder panels; show or hide KPI cards and rename them. |
| AI chat | Show the button, use a remote endpoint. |
| Profiles & JSON | Named profiles, start-up choice, download and load settings. |
| Help & about | Quick start, browser capabilities, self-check, diagnostics. |

### Logo

&#91;image: General & logo tab\]

Choose **Built-in icon** (shield, bar chart, globe, padlock, radar or bank), **Initials / text** of one to three characters, **Upload an image**, or **No logo**. Set the tile and icon colours, the shape (rounded square, circle or square) and the size from 16 to 120 pixels; the default is 50 × 50. An uploaded image is resized and stored inside the settings file, so the logo travels with your JSON. The browser tab icon follows the logo.

**One logo per theme.** At the top of the logo editor, choose **Dark theme** or **Light theme**, then set the type, icon, text, colours, shape, size or uploaded image for that theme alone. The two logos are independent; the one that matches the active theme is shown in the page header and as the browser tab icon, and it switches when you press **Theme**.

### Colours

&#91;image: Colours tab\]

About fifty colour roles are grouped as Page & text, Header & ribbon, Cards & tables, Buttons, Status colours, Source labels, KPI cards, Charts, and Chat & tooltips.

- Pick the **Dark theme** or **Light theme** palette at the top; each is stored separately.
- A ticked **default** box means the built-in colour is used. Changing a swatch unticks it; ticking it again restores the default.
- The **Readability check** lists key text and background pairs with their contrast ratio. Aim for 4.5:1 or higher; a pair below that is marked *low*.
- **Reset this palette to default** clears all overrides for that theme.

### Feed columns

&#91;image: Feed columns tab\]

Each feed has its own table of columns:

| Field | Meaning |
| --- | --- |
| Column name | The label shown in the dashboard; also tried as a header name. |
| CSV header names | Comma-separated names the column may have in the file. |
| Meaning | What the engine does with it (CIF, client name, sanction list, branch, transaction, amount, currency, date, time) or *Custom column*. A meaning can be used once per feed. |
| Type | text, number or date, for custom columns. |
| Req. | If ticked, the feed is rejected when the column is absent. |
| Table / Drawer | Whether a custom column appears in the reconciliation table and in the drill-down. |
| ↑ ↓ ✕ | Reorder or remove. The **CIF** column is the matching key and cannot be removed. |

Press **+ Add column** to include an extra field from your file, such as a risk score. Custom columns appear in the table (headed with the feed name) and the drill-down. **Reset this feed's columns** returns to the standard layout. Every change re-runs the reconciliation as soon as you save.

### Layout

&#91;image: Layout tab\]

Tick panels to show or hide them and use ↑ ↓ to change their order on the page. The Venn, matrix and branch cards share one row, so their order applies inside that row. Below, choose which KPI cards appear and give each its own title.

### Light theme

&#91;image: The dashboard in the light theme\]

The **Theme** button in the ribbon toggles dark and light at any time. Dark is a neutral black and grey with no blue tint.

## 8. Saving, sharing and loading settings

&#91;image: Profiles & JSON tab\]

**Save & apply** stores your settings in this browser, so the dashboard looks the same next time. Everything you customised, including colours, logo, feed columns, layout and data source, lives in one settings JSON document.

### Named profiles

A profile is a saved copy of the whole configuration, for example *Night shift* or *Audit review*. On **Profiles & JSON**, type a name and press **Save current settings as profile**. Each profile can be **Loaded** (applies at once), downloaded as a JSON file, or **Deleted**. Profiles stay in this browser.

### What loads at start-up

Choose one option under **When the application loads, use**, then press **Save & apply**:

| Choice | Result |
| --- | --- |
| Settings saved in this browser | Your saved settings; if none, `settings.json` beside the page; if none, defaults. This is the default. |
| `settings.json` beside the page | The shared team file; ignores what this browser saved. |
| Built-in defaults | A clean start every time. |
| Profile: *name* | That profile on every launch. |

### Sharing one configuration with a team

1. Set the dashboard up as you want it and press **Download settings.json**.
2. Put `settings.json` in the same folder as `index.html`, on a web server (http or https), or in the shared feeds folder.
3. Colleagues who choose *Settings saved in this browser* with nothing saved get your file automatically. Others can use **Load settings JSON…** or **Load from shared folder**.

A page opened straight from disk (an address starting `file:`) cannot read `settings.json` by itself, because browsers forbid it. Use **Load settings JSON…** there.

The settings file is checked on load. Unknown or out-of-range values are ignored or corrected, a file that is not a settings file is rejected with a message, and files from the earlier version of the dashboard are converted automatically.

### Removing settings

- **Remove settings saved in this browser** deletes the saved copy only.
- **Delete all profiles** clears every profile.
- **Reset everything to defaults** restores the built-in look and feed layout.

Each of these asks you to confirm first.

### Address options

Append these to the page address for special starts:

| Option | Effect |
| --- | --- |
| `?reset=1` | Forget the saved settings and the start-up choice, then start from defaults. |
| `?profile=Night shift` | Start with that profile. |
| `?settings=https://host/path/settings.json` | Load settings from that address for this visit. |

## 9. Troubleshooting

Start with **Settings > Help & about > Run self-check**. It tests the settings, the CSV reader, the reconciliation logic, file-writing safety and browser storage in seconds.

&#91;image: Help & about tab with the self-check results\]

| Symptom | Likely cause | What to do |
| --- | --- | --- |
| Ribbon says *Not configured* | No folder or URL has been chosen. | Settings > Data source, choose the folder or enter the URL, then Save & apply. |
| Ribbon says *Click to re-grant access* | The browser dropped folder permission after a restart. | Click the status and choose Allow. |
| The folder button does nothing, or an error says the browser cannot open folders | Browser without the folder picker (Firefox, Safari). | Use Chrome or Edge, or switch to the Web URL method. |
| A feed is *invalid*: "missing required column(s)" | Your headers differ from the expected names. | Settings > Feed columns: add your header name to the column, or untick Req. if the column is optional. |
| A feed is *stale* (amber) | The file has not been modified within the stale limit. | Check the upstream job, or raise the limit under Data source. |
| Dates look wrong or *malformed timestamps* is high | Month/day and day/month are swapped. | Timeline & alerts > Date format in feeds. |
| Customers appear as *missing CIF* | Rows have no CIF value. | Fix the extract, or keep the TransactionID fallback switched on. |
| An extra column is not visible | It is not defined, or Table is unticked. | Feed columns: add it and tick Table or Drawer. |
| Settings are lost after closing | Browser storage is blocked, for instance in a private window. | Download settings.json and load it next time; run the self-check. |
| `settings.json` beside the page is ignored | The page was opened from disk (`file:`). | Serve the page over http(s), or use Load settings JSON…. |
| Timeline shows little history in live mode | History builds only while the page is open. | Leave the dashboard open; sample mode shows a full day. |
| A file is rejected as too large | Limit is 100 MB per file. | Split or trim the extract. |
| Toast: *Something went wrong* | One panel failed; the rest keeps working. | Help & about > Copy diagnostics and send it to support. |
| The AI endpoint fails | Wrong URL or response. | The local assistant answers instead; check the URL and that the reply is `{"answer": "…"}`. |

**Reporting a problem.** Open **Help & about**, press **Copy diagnostics** (or **Download diagnostics.json**) and attach it. It lists the version, browser, feed status, your settings (without the logo image) and any recorded errors. It contains no feed data.

## 10. Security, privacy and limits

**Privacy.** All reconciliation happens in your browser. The page sends data nowhere unless you set the optional AI endpoint, and then only when you tick the option to send questions and the snapshot's customer data to it. There is no analytics or telemetry.

**Access to files.** Folder access is read-only and limited to the folder you pick; the dashboard never writes to it. Web URL mode only requests the three configured file names (plus settings.json beside the page, at start-up, when the page is served over http or https).

**Safe handling of data.**

- Every value from a feed or settings file is escaped before it is shown, so markup inside a CSV cannot run.
- Any value that could run as a spreadsheet formula is neutralised before the app writes it to a file.
- Settings files are validated: colours must be hex values, numbers are limited to sensible ranges, unknown keys are dropped, and an uploaded logo must be a small image.
- A fault in one panel is contained: that panel shows a notice while the rest keeps working, and the error is logged for diagnostics.

**Limits.**

| Item | Limit |
| --- | --- |
| File size | 100 MB per feed file; settings files up to 5 MB |
| History | 24 hours, up to 289 five-minute snapshots, kept only while the page is open |
| Browsers | Current Chrome, Edge, Firefox or Safari; the shared-folder picker needs Chrome or Edge |
| Profiles and saved settings | Stored per browser and per PC; download the JSON to move them |

**Accessibility.** The page works with the keyboard and screen readers: a skip link, labelled controls, tab and dialog roles, live regions for status messages, visible focus, and reduced motion when your system asks for it. Colour is never the only signal; statuses also carry a word or symbol.

## 11. New in version 3.2

### Total CIFs and the daily Customers feed

A **Total CIFs** card (first in the KPI row) shows the number of distinct CIFs in `Customers.csv`. The file needs a `CIF` column; `ClientName` and `Branch` are optional, and every column name can be changed on **Settings > Feed columns > Customers**. Because this file changes about once a day, it is read on its own schedule and is not part of the five-minute snapshots:

- It is read when the application connects, then again every **Read the Customers file every (hours)** (default 24), and whenever you press **Refresh feeds now**. A file that has not changed since the last read is recognised and not re-processed.
- A problem with the file (missing, unreadable, invalid) turns only the Customers dot amber or red and keeps the last good total on the card; the main connection status is not affected. After an error the read is retried every five minutes.
- The file is shown as stale when it is older than **Flag the Customers file as stale after (hours)** (default 36).
- The card title, colour, visibility and file name are all configurable (**Data source, Colours and Layout tabs; the title is under Layout > KPI cards**). Under the number it shows the share of Total CIFs present in the current window and the change since the previous load; click the card for the file details. Untick **Read the Customers feed (Total CIFs card)** to switch the feed off and hide the card.

### System monitor (the gear on the ribbon)

Click the **⚙ gear** on the ribbon to open the System monitor window. It can be dragged and closed with ✕. Its bars are glass-style and coloured **green** (healthy), **amber** (warning), **red** (critical) and **blue** (information); the warning and critical levels (default 70% and 90%) are set under **Settings > System monitor**. The gear itself shows the worst current state.

- **This page (always live, measured in your browser):** main-thread load, JavaScript heap, DOM size, page uptime, feed read times and sizes, online status and connection hints.
- **Host (CPU, memory, disks, network, top processes, IP addresses, Windows Event IDs):** a web page cannot read these. Run the supplied PowerShell script `Collect-SystemMetrics.ps1` on the server (download it from **Settings > System monitor**). It writes `SystemMetrics.json` into the shared feeds folder and the window shows it, labelled **LIVE host** with the time sampled; if the file is older than the configured limit it is flagged as stale. Reading the Security event log needs an elevated session.
- **Dashboard events:** the application's own log (connections, feed reads, settings, errors) with event IDs in the 1000 range.
- In sample mode the host section is simulated and labelled **SIMULATED**.

### Generate Client

**Generate Client** (page header and **Settings > Generate Client**) creates the version for operators: no control panel, no sample data, no uploads.

1. Configure and **Save & apply** the settings first; the client uses what is saved at the moment you press the button.
2. Press **Generate Client**. Two files are produced: `ReconClient.html` and `settings.json` (an exact copy of the saved configuration). **Generate into a folder** writes them straight into the shared folder in Chrome or Edge.
3. Place both files in the shared folder beside the feed files, open `ReconClient.html` and, the first time, choose that folder. The client reads the feeds, `Customers.csv`, `SystemMetrics.json` and `settings.json` only from there.
4. The client re-reads `settings.json` on every check, so replacing the file changes the look and behaviour of every open client. A file that is not valid JSON is ignored and the previous configuration is kept.

### Buttons removed

Upload CSVs, Sample data, Export CSV and Transactions CSV are gone. Data comes only from the shared drive named in the settings.

## Appendix: reference

### Settings file contents

The settings JSON (version 2) has these top-level sections. You rarely need to edit it by hand; the control panel writes it for you.

| Key | Holds |
| --- | --- |
| `version` | Format version (2). Version 1 files are converted on load. |
| `branding` | Application name, subtitle, logo type, icon, text, colours, shape, size, and an uploaded image. |
| `theme` | Mode (dark, light, auto), zoom, font family, font size, corner radius. |
| `colors` | Overrides per theme: `dark` and `light`, each a map of colour role to hex value. |
| `ribbon` | Thickness, font size and the items shown. |
| `source` | Sample or live, folder or URL, base URL, file names, check and stale minutes. |
| `feeds` | For `gcop`, `finscan` and `opf`: the list of column definitions. |
| `timeline` | Default range, play speed, start expanded. |
| `reconciliation` | Alert minutes, TransactionID fallback, date format. |
| `labels` | The text of the G and F source labels. |
| `table` | Page size, default sort, built-in columns shown. |
| `panels` | Which panels are visible and their order. |
| `kpis` | Which KPI cards are visible and their custom titles. |
| `chat` | Whether the button shows, remote endpoint and whether it is used. |

A feed column definition has these fields: `key`, `label`, `headers` (list), `role` (empty for a custom column), `type`, `required`, `table` and `drawer`.

### Keyboard

| Keys | Action |
| --- | --- |
| **Tab** / **Shift+Tab** | Move through controls; the first Tab offers *Skip to main content*. |
| **Enter** or **Space** | Open a focused KPI card, chart region or table row. |
| **Esc** | Close the drill-down, the chat or the control panel (asks first when changes are unsaved). |
| **←** **→** (on a control panel tab) | Switch between tabs. |
| Double-click on the timeline | Fold the timeline. |

### Glossary

| Term | Meaning |
| --- | --- |
| GCOP | Screening against Dow Jones lists. |
| FINSCAN | Screening against Worldcheck and the SEPA Blacklist. |
| OPF | The feed of customers whose hits have been actioned. |
| Universe | The union of GCOP and FINSCAN customers. |
| Stale | A feed file that has not been modified within the stale limit. |

### Version

This manual describes version 3.2.0 (build 2026-11-04). The version and build appear in **Help & about** and in the page footer.
