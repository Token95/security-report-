# TMS Vulnerability Remediation Report

TMS (Times Microwave Systems) Internal
Author: Devon Brown, Network Security Engineer

`TMS-VulnReport.ps1` reads vulnerability exports from Nessus, CrowdStrike Falcon Spotlight, Blumira and CodeQL, works out which findings still affect the TMS network, assigns remediation due dates, and writes a PDF report for the monthly security meeting.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+
- Internet access to `services.nvd.nist.gov`, `cve.circl.lu`, `cwe-api.mitre.org` and `www.cisa.gov` (or run with `-Offline`)
- Microsoft Edge (built into Windows 10/11) or Google Chrome. The script uses it, invisibly, to render the PDF. On servers without Edge, point `-BrowserPath` at `msedge.exe` or `chrome.exe`.

No modules to install.

## Running it

```powershell
# One or more files
.\TMS-VulnReport.ps1 -Path .\exports\nessus.csv, .\exports\spotlight.csv, .\exports\blumira.csv

# A whole folder (add -Recurse for sub-folders)
.\TMS-VulnReport.ps1 -Path \\fileserver\SecOps\2026-09 -Recurse

# Pipeline
Get-ChildItem .\exports -Filter *.csv | .\TMS-VulnReport.ps1

# No arguments: opens a multi-select file picker
.\TMS-VulnReport.ps1
```

If Windows blocks the script, run `Unblock-File .\TMS-VulnReport.ps1` once.

If no browser can be found, the report is saved as HTML instead and the console says so; open it and choose Print > Save as PDF.

Other switches: `-ReportDate` (the "as of" date for SLA math), `-Offline`, `-SkipNvd`, `-SkipCircl`, `-SkipCwe`, `-IncludeInformational`, `-KeepHtml` (also save the HTML version), `-BrowserPath`, `-NoOpen`, `-OutputFolder`.

## What gets detected

The source of each CSV is identified from its columns, so file names don't matter.

| Source | Recognised by | Asset columns used |
|---|---|---|
| Nessus / Tenable | `Plugin ID` column | Host, IP, DNS/NetBIOS name, port |
| CrowdStrike Spotlight | `ExPRT rating`, `Exploit status`, or Hostname + CVE ID + Remediation | Hostname, Local IP, last logged-in user |
| Blumira | `Priority` plus Finding/Analysis/Workflow columns | Hostname, IP, Username |
| CodeQL | CLI `--format=csv` output (no header row) | Repository (file name or `CodeQLRepositoryName`), file:line |

Any other CSV with a CVE column is read as a generic export.

## Enrichment

| API | Used for |
|---|---|
| NIST NVD 2.0 | CVSS base score and vector (v3.1 preferred), CVE-to-CWE mapping |
| CIRCL CVE | Description, vendor solution text, CISA SSVC data (exploitation, automatable, technical impact) |
| MITRE CWE REST API | Weakness name and a recommended mitigation, looked up in batches |
| CISA KEV catalog | Known-exploited flag, CISA required action, federal due date, ransomware use |

Results are cached in `.\cache\` so repeat runs only query new CVEs. Without an NVD API key the script waits about 6.5 seconds between NVD calls. Request a free key at https://nvd.nist.gov/developers/request-an-api-key and set it as an environment variable rather than in a file:

```powershell
[Environment]::SetEnvironmentVariable('TMS_NVD_API_KEY', '<your key>', 'User')
```

## Remediation timelines

| Severity | CVSS | Fix within |
|---|---|---|
| Critical | 9.0 to 10.0, or on the CISA KEV catalog | 30 days |
| High | 7.0 to 8.9 | 45 days |
| Medium | 4.0 to 6.9 | 60 days |
| Low | 0.1 to 3.9 | 90 days |

The clock starts at the scanner's first-seen date. When the export has no date (standard Nessus CSVs), it starts on the first report the finding appeared in; `cache\first_seen_ledger.json` remembers that date between monthly runs, so don't delete it.

If you list internet-facing assets in `settings.psd1`, a KEV finding on one of them that CISA rates automatable with total technical impact gets the CISA BOD 26-04 top-tier deadline (3 days by default).

## Does it affect the current network?

A finding is left out of the counts, and listed in its own section of the report with the reason, when:

- the source marks it closed, fixed, resolved, dismissed or a false positive
- the host is outside `InScopeNetworks` / `InScopeHostPatterns` (when those are set)
- its last-seen date is more than `StaleAfterDays` (30) before the report date

Set `InScopeNetworks` to the TMS address ranges before the first real run. With both scope lists empty, every scanned host counts.

## Grouping

Findings are merged when they share the same vulnerability and the same fix, so one row lists every host and user that needs it. The action plan goes one step further and merges different CVEs that one fix resolves (for example, one Apache upgrade covering two CVEs). Generic advice, such as CISA's boilerplate required action or a CWE mitigation, is never used to merge unrelated vulnerabilities.

The remediation text comes from the first of these that exists: the scanner's own fix, CISA KEV required action, vendor solution via CIRCL, MITRE CWE mitigation, then the TMS policy fallback.

## Output

Each run writes to `.\Reports\`:

- `TMS_Vulnerability_Report_<month>_<timestamp>.pdf`: the meeting report, landscape Letter, with "TMS INTERNAL USE ONLY" and page numbers on every page. Page 1 is the summary, page 2 starts the action plan.
- `..._ActionPlan.csv`: one row per fix, with blank Owner, Target Date and Notes columns to fill in during the meeting
- `..._Findings.csv`: one row per vulnerability with CVSS, CWE, KEV and SSVC details
- `..._AllFindings.csv`: every parsed row, including excluded ones and why
- `operator.log`: audit log of each run

## Files

| File | Purpose |
|---|---|
| `TMS-VulnReport.ps1` | The script |
| `settings.psd1` | SLA days, CVSS thresholds, network scope, API URLs, cache lifetimes |
| `TMS_Logo.png` | Logo embedded in the report header |
| `samples\` | Small made-up exports, one per source, for trying the script |
| `Sample_Report.pdf` | What the report looks like, built from the sample exports |
