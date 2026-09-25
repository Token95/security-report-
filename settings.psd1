@{
    # ------------------------------------------------------------------
    #  TMS (Times Microwave Systems) Internal - Vulnerability Report
    #  Settings for TMS-VulnReport.ps1
    # ------------------------------------------------------------------

    Organization    = 'TMS (Times Microwave Systems) Internal'
    ReportTitle     = 'Monthly Vulnerability Remediation Report'
    PreparedBy      = 'Devon Brown'
    PreparedByTitle = 'Network Security Engineer'
    LogoFile        = 'TMS_Logo.png'      # relative to the script folder

    Api = @{
        # NIST NVD 2.0 - CVSS score/vector and CVE -> CWE mapping
        NvdUrl    = 'https://services.nvd.nist.gov/rest/json/cves/2.0?cveId='
        # Leave blank and set the environment variable TMS_NVD_API_KEY instead,
        # so the key never lands in source control.
        NvdApiKey = ''

        # CIRCL Vulnerability-Lookup - description, vendor solution text,
        # and CISA "Vulnrichment" SSVC data (Exploitation/Automatable/Impact)
        CirclUrl  = 'https://cve.circl.lu/api/cve/'

        # CISA Known Exploited Vulnerabilities catalog (one download per run)
        KevUrl    = 'https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json'

        # MITRE CWE REST API - weakness name, description, potential mitigations
        CweUrl    = 'https://cwe-api.mitre.org/api/v1/cwe/weakness/'
    }

    # TMS remediation SLA (calendar days from first detection)
    RemediationSlaDays = @{
        Critical = 30
        High     = 45
        Medium   = 60
        Low      = 90
    }

    # CISA KEV entries are known to be exploited in the wild.
    # When $true they are held to the Critical window regardless of CVSS.
    KevEscalatesToCritical = $true

    # CISA BOD 26-04 top tier: KEV + publicly exposed + automatable + total
    # technical impact. Only applies to hosts listed as internet-facing below.
    CisaImmediateDays = 3

    # CVSS base-score cut-offs
    Thresholds = @{
        Critical = 9.0
        High     = 7.0
        Medium   = 4.0
    }

    # ---- "Does it affect the current network?" -----------------------
    # Leave both empty to treat every host in the exports as in scope.
    InScopeNetworks     = @()          # e.g. '10.0.0.0/8', '192.168.50.0/24'
    InScopeHostPatterns = @()          # e.g. '*.tms.local', 'TMS-*'

    # Internet-facing assets (used for the CISA BOD 26-04 exposure check)
    InternetFacingNetworks     = @()   # e.g. '203.0.113.0/28'
    InternetFacingHostPatterns = @()   # e.g. 'vpn*', 'www*'

    # A finding whose "last seen" is older than this is treated as stale.
    StaleAfterDays = 30

    # Name to use for the asset column on CodeQL rows (blank = CSV file name)
    CodeQLRepositoryName = ''

    # ---- API caching / pacing -----------------------------------------
    CacheHours = @{
        Kev   = 24
        Nvd   = 168
        Circl = 168
        Cwe   = 720
    }
    NvdDelaySeconds = @{
        WithKey    = 0.7
        WithoutKey = 6.5
    }

    # Report layout
    MaxHostsShownPerRow = 40
}
