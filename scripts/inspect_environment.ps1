param(
    [string]$ConfigPath,
    [string]$ProjectName,
    [string]$DefaultDrive,
    [switch]$InstallMissing,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

function Test-CommandAvailable {
    param([Parameter(Mandatory=$true)][string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Resolve-ConfigPath {
    param([string]$ExplicitPath)

    $candidates = @()
    if ($ExplicitPath) {
        $candidates += $ExplicitPath
    }
    $cwd = (Get-Location).Path
    $homeDir = [Environment]::GetFolderPath("UserProfile")
    $candidates += (Join-Path $cwd "owner-handoff.config.json")
    $candidates += (Join-Path $cwd ".owner-handoff\config.json")
    if ($homeDir) {
        $candidates += (Join-Path $homeDir ".codex\owner-handoff-development\config.json")
    }

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }
    return $null
}

function Read-Config {
    param([string]$Path)
    if (-not $Path) {
        return $null
    }
    try {
        return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
    } catch {
        throw "Failed to read config JSON at '$Path': $($_.Exception.Message)"
    }
}

function Get-ConfigValue {
    param(
        [object]$Config,
        [string]$Name,
        [string]$Fallback
    )
    if ($Config -and ($Config.PSObject.Properties.Name -contains $Name) -and $Config.$Name) {
        return [string]$Config.$Name
    }
    return $Fallback
}

function Get-ToolVersion {
    param(
        [string]$Command,
        [string[]]$Arguments
    )
    if (-not (Test-CommandAvailable $Command)) {
        return $null
    }
    try {
        $output = & $Command @Arguments 2>$null | Select-Object -First 1
        return [string]$output
    } catch {
        return $null
    }
}

$configSource = Resolve-ConfigPath -ExplicitPath $ConfigPath
$config = Read-Config -Path $configSource

if (-not $ProjectName) {
    $ProjectName = Get-ConfigValue -Config $config -Name "project_name" -Fallback $null
}
if (-not $ProjectName) {
    $ProjectName = Split-Path -Leaf (Get-Location).Path
}

if (-not $DefaultDrive) {
    $DefaultDrive = Get-ConfigValue -Config $config -Name "default_drive" -Fallback $null
}
if (-not $DefaultDrive) {
    $DefaultDrive = ([System.IO.Path]::GetPathRoot((Get-Location).Path)).TrimEnd("\")
}
$DefaultDrive = $DefaultDrive.TrimEnd("\")

$formalRepo = Get-ConfigValue -Config $config -Name "formal_repo" -Fallback (Join-Path "$DefaultDrive\" "codex\$ProjectName")
$ownerHandoffRoot = Get-ConfigValue -Config $config -Name "owner_handoff_root" -Fallback (Join-Path "$DefaultDrive\" "Claude code\$ProjectName`_OwnerHandoff")
$safeCopy = Get-ConfigValue -Config $config -Name "safe_copy" -Fallback (Join-Path $ownerHandoffRoot "$ProjectName`_Safety copy")
$handoffRoot = Get-ConfigValue -Config $config -Name "handoff_root" -Fallback (Join-Path $ownerHandoffRoot "$ProjectName`_codex_handoff")
$reportsDir = Get-ConfigValue -Config $config -Name "reports_dir" -Fallback (Join-Path $formalRepo "reports\stage-reports")

$toolSpecs = @(
    [pscustomobject]@{ name = "git"; command = "git"; winget = "Git.Git"; versionArgs = @("--version") },
    [pscustomobject]@{ name = "gh"; command = "gh"; winget = "GitHub.cli"; versionArgs = @("--version") },
    [pscustomobject]@{ name = "python"; command = "python"; winget = "Python.Python.3.12"; versionArgs = @("--version") },
    [pscustomobject]@{ name = "rg"; command = "rg"; winget = "BurntSushi.ripgrep.MSVC"; versionArgs = @("--version") },
    [pscustomobject]@{ name = "pwsh"; command = "pwsh"; winget = "Microsoft.PowerShell"; versionArgs = @("--version") }
)

$wingetAvailable = Test-CommandAvailable "winget"
$tools = @()
$installResults = @()

foreach ($spec in $toolSpecs) {
    $available = Test-CommandAvailable $spec.command
    $version = Get-ToolVersion -Command $spec.command -Arguments $spec.versionArgs
    $tools += [pscustomobject]@{
        name = $spec.name
        command = $spec.command
        available = $available
        version = $version
        winget_id = $spec.winget
    }
}

if ($InstallMissing) {
    foreach ($tool in $tools | Where-Object { -not $_.available }) {
        if (-not $wingetAvailable) {
            $installResults += [pscustomobject]@{
                tool = $tool.name
                status = "skipped"
                reason = "winget is not available"
            }
            continue
        }
        try {
            & winget install --id $tool.winget_id -e --source winget --accept-package-agreements --accept-source-agreements
            $installResults += [pscustomobject]@{
                tool = $tool.name
                status = "attempted"
                command = "winget install --id $($tool.winget_id) -e --source winget"
            }
        } catch {
            $installResults += [pscustomobject]@{
                tool = $tool.name
                status = "failed"
                error = $_.Exception.Message
            }
        }
    }
}

$result = [pscustomobject]@{
    ok = $true
    config_source = $configSource
    requires_user_path_confirmation = $true
    install_missing_requested = [bool]$InstallMissing
    os = [pscustomobject]@{
        platform = [System.Environment]::OSVersion.Platform.ToString()
        version = [System.Environment]::OSVersion.VersionString
        is_64_bit = [System.Environment]::Is64BitOperatingSystem
    }
    paths = [pscustomobject]@{
        project_name = $ProjectName
        default_drive = $DefaultDrive
        formal_repo = $formalRepo
        owner_handoff_root = $ownerHandoffRoot
        safe_copy = $safeCopy
        handoff_root = $handoffRoot
        reports_dir = $reportsDir
    }
    tools = $tools
    install_results = $installResults
    notes = @(
        "Confirm default_drive, formal_repo, owner_handoff_root, safe_copy, and handoff_root with the user before creating or writing folders.",
        "Use -InstallMissing only for non-secret developer tooling after setup automation is authorized."
    )
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
} else {
    $result | Format-List
}
