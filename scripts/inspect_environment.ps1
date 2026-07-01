param(
    [string]$ConfigPath,
    [string]$ProjectName,
    [string]$DefaultDrive,
    [string]$DevToolsRoot,
    [switch]$InstallMissing,
    [switch]$ConfirmedInstallPlan,
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

function Test-IsCDrivePath {
    param([string]$Path)
    if (-not $Path) {
        return $false
    }
    try {
        $root = [System.IO.Path]::GetPathRoot($Path)
        return ($root.TrimEnd("\").ToUpperInvariant() -eq "C:")
    } catch {
        return $false
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
if (-not $DevToolsRoot) {
    $DevToolsRoot = Get-ConfigValue -Config $config -Name "dev_tools_root" -Fallback $null
}

$toolSpecs = @(
    [pscustomobject]@{ name = "git"; command = "git"; winget = "Git.Git"; versionArgs = @("--version"); scope = "general_development_tool"; installDirName = "Git" },
    [pscustomobject]@{ name = "gh"; command = "gh"; winget = "GitHub.cli"; versionArgs = @("--version"); scope = "general_development_tool"; installDirName = "GitHub CLI" },
    [pscustomobject]@{ name = "python"; command = "python"; winget = "Python.Python.3.12"; versionArgs = @("--version"); scope = "general_development_tool"; installDirName = "Python312" },
    [pscustomobject]@{ name = "rg"; command = "rg"; winget = "BurntSushi.ripgrep.MSVC"; versionArgs = @("--version"); scope = "general_development_tool"; installDirName = "ripgrep" },
    [pscustomobject]@{ name = "pwsh"; command = "pwsh"; winget = "Microsoft.PowerShell"; versionArgs = @("--version"); scope = "general_development_tool"; installDirName = "PowerShell" }
)

$wingetAvailable = Test-CommandAvailable "winget"
$tools = @()
$installResults = @()
$installPlan = @()
$devToolsRootIsUsable = [bool]$DevToolsRoot -and (-not (Test-IsCDrivePath -Path $DevToolsRoot))

foreach ($spec in $toolSpecs) {
    $available = Test-CommandAvailable $spec.command
    $version = Get-ToolVersion -Command $spec.command -Arguments $spec.versionArgs
    $proposedInstallDir = $null
    if ($DevToolsRoot) {
        $proposedInstallDir = Join-Path $DevToolsRoot $spec.installDirName
    }
    $tools += [pscustomobject]@{
        name = $spec.name
        command = $spec.command
        available = $available
        version = $version
        winget_id = $spec.winget
        install_scope = $spec.scope
        proposed_install_dir = $proposedInstallDir
    }
}

foreach ($tool in $tools | Where-Object { -not $_.available }) {
    $candidateCommand = $null
    if ($wingetAvailable -and $tool.proposed_install_dir) {
        $candidateCommand = "winget install --id $($tool.winget_id) -e --source winget --location `"$($tool.proposed_install_dir)`""
    }
    $installPlan += [pscustomobject]@{
        tool = $tool.name
        purpose = "Required developer tool for repository setup, verification, or GitHub handoff."
        install_scope = $tool.install_scope
        proposed_install_dir = $tool.proposed_install_dir
        package_id = $tool.winget_id
        candidate_command = $candidateCommand
        requires_user_confirmation = $true
        c_drive_write_risk = @(
            "Installer may write registry entries, Start Menu shortcuts, logs, user config, or package-manager state under C: even when a target location is supplied.",
            "Verify whether the package respects --location before treating the install as fully non-C."
        )
        cache_or_global_dir_note = "Configure tool-specific caches/global directories to a confirmed non-system location when supported."
    }
}

if ($InstallMissing) {
    foreach ($plan in $installPlan) {
        if (-not $ConfirmedInstallPlan) {
            $installResults += [pscustomobject]@{
                tool = $plan.tool
                status = "planned_not_installed"
                reason = "Installation requires user confirmation. Review install_plan and rerun with -ConfirmedInstallPlan only after approval."
            }
            continue
        }
        if (-not $devToolsRootIsUsable) {
            $installResults += [pscustomobject]@{
                tool = $plan.tool
                status = "skipped"
                reason = "A non-C DevToolsRoot is required before installing reusable developer tools."
            }
            continue
        }
        if (-not $wingetAvailable) {
            $installResults += [pscustomobject]@{
                tool = $plan.tool
                status = "skipped"
                reason = "winget is not available"
            }
            continue
        }
        try {
            & winget install --id $plan.package_id -e --source winget --location $plan.proposed_install_dir --accept-package-agreements --accept-source-agreements
            $installResults += [pscustomobject]@{
                tool = $plan.tool
                status = "attempted"
                command = $plan.candidate_command
                note = "Verify actual install location and any C: writes after installation."
            }
        } catch {
            $installResults += [pscustomobject]@{
                tool = $plan.tool
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
    confirmed_install_plan = [bool]$ConfirmedInstallPlan
    os = [pscustomobject]@{
        platform = [System.Environment]::OSVersion.Platform.ToString()
        version = [System.Environment]::OSVersion.VersionString
        is_64_bit = [System.Environment]::Is64BitOperatingSystem
    }
    paths = [pscustomobject]@{
        project_name = $ProjectName
        default_drive = $DefaultDrive
        dev_tools_root = $DevToolsRoot
        dev_tools_root_is_non_c = $devToolsRootIsUsable
        formal_repo = $formalRepo
        owner_handoff_root = $ownerHandoffRoot
        safe_copy = $safeCopy
        handoff_root = $handoffRoot
        reports_dir = $reportsDir
    }
    tools = $tools
    install_plan = $installPlan
    install_results = $installResults
    notes = @(
        "Confirm default_drive, formal_repo, owner_handoff_root, safe_copy, and handoff_root with the user before creating or writing folders.",
        "Confirm a non-C dev_tools_root before installing reusable external developer tools on Windows.",
        "Use -InstallMissing as install-plan generation unless -ConfirmedInstallPlan is supplied after user approval.",
        "Record unavoidable C: writes and cache/global-directory redirects in the state file."
    )
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
} else {
    $result | Format-List
}
