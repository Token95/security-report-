# Changelog

## [3.1.0] - 2026-09-25

### Changed
- The report is now a PDF (landscape Letter) instead of HTML. It is rendered by Microsoft Edge or Chrome running headless in a private temporary profile, so an open browser window is not affected.
- Every page carries the "TMS INTERNAL USE ONLY" marking and "Page X of Y"; the summary is page 1 and the action plan starts on page 2. Table headers repeat across pages.
- Host and user lists are printed in full (up to 40 per row, then a pointer to the CSV exports) since a PDF cannot expand hidden lists.

### Added
- `-KeepHtml` to also save the HTML version, and `-BrowserPath` for machines where Edge is not in its default location.
- If no browser is available, the report falls back to HTML with a console message instead of failing.

### Removed
- The `-Pdf` switch (PDF is now the default output).

## [3.0.0] - 2026-09-24

Rewritten in PowerShell as the TMS Vulnerability Remediation Report. Replaces the Python nmap scanner (`threat_intel.py`, `report.py`).

### Added
- Reads CSV exports from Nessus, CrowdStrike Falcon Spotlight, Blumira and CodeQL, detecting the source from each file's columns. Any number of files, folders, wildcards or piped paths per run.
- MITRE CWE REST API lookups (batched) for weakness names and mitigations. CWE IDs come from the scanners, NVD, CIRCL and CISA KEV; common CodeQL queries are mapped to their CWE.
- CISA SSVC decision points (exploitation, automatable, technical impact) read from the CIRCL record.
- TMS remediation SLA: Critical 30, High 45, Medium 60, Low 90 days. CISA KEV entries are held to the Critical window; optional CISA BOD 26-04 top tier for internet-facing assets.
- Network-impact check: closed status, configured TMS scope, and last-seen age.
- First-seen ledger so SLA clocks carry over between monthly reports, and a "New this month" flag.
- Grouping of hosts and users that share the same vulnerability and fix, plus an action plan that merges CVEs resolved by one fix.
- Meeting report with TMS branding and three CSV exports.
- `-Offline` mode and fail-fast handling when an API is unreachable.

### Changed
- NVD API key is read from the `TMS_NVD_API_KEY` environment variable instead of a committed settings file.
- Settings moved from `settings.ini` to `settings.psd1`.
- Existing `kev_cache.json` from the Python version is still read if present.

### Removed
- Live nmap scanning and the Python dependency installer.
