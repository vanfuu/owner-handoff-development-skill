[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [string]$ConfigPath,
    [string]$ProjectName,
    [string]$DevToolsRoot,
    [string]$FormalRepo,
    [string]$OwnerHandoffRoot,
    [string]$SafeCopy,
    [string]$HandoffRoot,
    [string]$ReportsDir,
    [switch]$ConfirmedPaths,
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
        if (-not (Test-Path -LiteralPath $ExplicitPath)) {
            throw "Explicit config path does not exist: '$ExplicitPath'"
        }
        return (Resolve-Path -LiteralPath $ExplicitPath).Path
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

function Get-PathValue {
    param(
        [string]$ExplicitValue,
        [object]$Config,
        [string]$ConfigName
    )
    if ($ExplicitValue) {
        return [string]$ExplicitValue
    }
    return Get-ConfigValue -Config $Config -Name $ConfigName -Fallback $null
}

function Test-AbsolutePathInput {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }
    try {
        return [System.IO.Path]::IsPathRooted($Path)
    } catch {
        return $false
    }
}

function Normalize-AbsolutePathInput {
    param([string]$Path)
    if (-not (Test-AbsolutePathInput -Path $Path)) {
        return $Path
    }
    try {
        return [System.IO.Path]::GetFullPath($Path)
    } catch {
        return $Path
    }
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

$DevToolsRoot = Get-PathValue -ExplicitValue $DevToolsRoot -Config $config -ConfigName "dev_tools_root"
$FormalRepo = Get-PathValue -ExplicitValue $FormalRepo -Config $config -ConfigName "formal_repo"
$OwnerHandoffRoot = Get-PathValue -ExplicitValue $OwnerHandoffRoot -Config $config -ConfigName "owner_handoff_root"
$SafeCopy = Get-PathValue -ExplicitValue $SafeCopy -Config $config -ConfigName "safe_copy"
$HandoffRoot = Get-PathValue -ExplicitValue $HandoffRoot -Config $config -ConfigName "handoff_root"
$ReportsDir = Get-PathValue -ExplicitValue $ReportsDir -Config $config -ConfigName "reports_dir"

$pathInputs = [ordered]@{
    formal_repo = $FormalRepo
    owner_handoff_root = $OwnerHandoffRoot
    safe_copy = $SafeCopy
    handoff_root = $HandoffRoot
    reports_dir = $ReportsDir
}
$missingOrInvalidPathInputs = @()
$normalizedPaths = [ordered]@{}
foreach ($entry in $pathInputs.GetEnumerator()) {
    if (-not (Test-AbsolutePathInput -Path $entry.Value)) {
        $missingOrInvalidPathInputs += $entry.Key
        $normalizedPaths[$entry.Key] = $entry.Value
        continue
    }
    $normalizedPaths[$entry.Key] = Normalize-AbsolutePathInput -Path $entry.Value
}

$devToolsRootIsAbsolute = Test-AbsolutePathInput -Path $DevToolsRoot
if ($devToolsRootIsAbsolute) {
    $DevToolsRoot = Normalize-AbsolutePathInput -Path $DevToolsRoot
}

$allRequiredPathsAreAbsolute = ($missingOrInvalidPathInputs.Count -eq 0)
$pathsConfirmed = [bool]$ConfirmedPaths -and $allRequiredPathsAreAbsolute
$pathConfirmationRequired = -not $pathsConfirmed
$filesystemChangesAllowed = $pathsConfirmed

$toolSpecs = @(
    [pscustomobject]@{ name = "git"; command = "git"; winget = "Git.Git"; versionArgs = @("--version"); scope = "reusable_development_tool"; installDirName = "Git" },
    [pscustomobject]@{ name = "gh"; command = "gh"; winget = "GitHub.cli"; versionArgs = @("--version"); scope = "reusable_development_tool"; installDirName = "GitHub CLI" },
    [pscustomobject]@{ name = "python"; command = "python"; winget = "Python.Python.3.12"; versionArgs = @("--version"); scope = "reusable_development_tool"; installDirName = "Python312" },
    [pscustomobject]@{ name = "rg"; command = "rg"; winget = "BurntSushi.ripgrep.MSVC"; versionArgs = @("--version"); scope = "reusable_development_tool"; installDirName = "ripgrep" },
    [pscustomobject]@{ name = "pwsh"; command = "pwsh"; winget = "Microsoft.PowerShell"; versionArgs = @("--version"); scope = "reusable_development_tool"; installDirName = "PowerShell" }
)

$wingetAvailable = Test-CommandAvailable "winget"
$tools = @()
$installResults = @()
$installPlan = @()

foreach ($spec in $toolSpecs) {
    $available = Test-CommandAvailable $spec.command
    $version = Get-ToolVersion -Command $spec.command -Arguments $spec.versionArgs
    $proposedInstallDir = $null
    if ($devToolsRootIsAbsolute) {
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
        requires_confirmed_paths = $true
        requires_user_install_confirmation = $true
        system_location_review = @(
            "Review installer side effects separately from the requested target directory.",
            "Package managers may write registry entries, shortcuts, logs, user config, caches, or package-manager state to system-managed locations."
        )
        cache_or_global_dir_note = "Ask the user to confirm tool-specific cache and global directories when the tool supports relocation."
    }
}

$installExecutionAuthorized = [bool]$ConfirmedInstallPlan -and $pathsConfirmed -and $devToolsRootIsAbsolute

if ($InstallMissing) {
    foreach ($plan in $installPlan) {
        if (-not $pathsConfirmed) {
            $installResults += [pscustomobject]@{
                tool = $plan.tool
                status = "blocked_path_confirmation_required"
                reason = "Installation requires explicit absolute paths and current user confirmation. Review the path plan and rerun with -ConfirmedPaths only after approval."
            }
            continue
        }
        if (-not $ConfirmedInstallPlan) {
            $installResults += [pscustomobject]@{
                tool = $plan.tool
                status = "planned_not_installed"
                reason = "Installation requires separate user confirmation. Review install_plan and rerun with -ConfirmedInstallPlan only after approval."
            }
            continue
        }
        if (-not $devToolsRootIsAbsolute) {
            $installResults += [pscustomobject]@{
                tool = $plan.tool
                status = "blocked_tools_root_required"
                reason = "An explicit absolute DevToolsRoot is required before installing reusable developer tools."
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

        $operation = "Install $($plan.tool) to '$($plan.proposed_install_dir)'"
        if (-not $PSCmdlet.ShouldProcess($plan.proposed_install_dir, $operation)) {
            $installResults += [pscustomobject]@{
                tool = $plan.tool
                status = "what_if_not_installed"
                command = $plan.candidate_command
            }
            continue
        }

        try {
            & winget install --id $plan.package_id -e --source winget --location $plan.proposed_install_dir --accept-package-agreements --accept-source-agreements
            $installResults += [pscustomobject]@{
                tool = $plan.tool
                status = "attempted"
                command = $plan.candidate_command
                note = "Verify the actual install location and any system-managed writes after installation."
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
    paths_confirmed = $pathsConfirmed
    path_confirmation_required = $pathConfirmationRequired
    filesystem_changes_allowed = $filesystemChangesAllowed
    missing_or_invalid_path_inputs = $missingOrInvalidPathInputs
    install_missing_requested = [bool]$InstallMissing
    confirmed_install_plan = [bool]$ConfirmedInstallPlan
    install_execution_authorized = $installExecutionAuthorized
    what_if = [bool]$WhatIfPreference
    os = [pscustomobject]@{
        platform = [System.Environment]::OSVersion.Platform.ToString()
        version = [System.Environment]::OSVersion.VersionString
        is_64_bit = [System.Environment]::Is64BitOperatingSystem
    }
    paths = [pscustomobject]@{
        project_name = $ProjectName
        dev_tools_root = $DevToolsRoot
        dev_tools_root_is_absolute = $devToolsRootIsAbsolute
        formal_repo = $normalizedPaths.formal_repo
        owner_handoff_root = $normalizedPaths.owner_handoff_root
        safe_copy = $normalizedPaths.safe_copy
        handoff_root = $normalizedPaths.handoff_root
        reports_dir = $normalizedPaths.reports_dir
    }
    path_gate = [pscustomobject]@{
        rule = "No path may be inferred from a drive letter, current directory, home directory, memory, prior project, example, or another user's convention."
        required_confirmation = "Show every resolved absolute target path and obtain current user confirmation before filesystem-changing work."
        config_is_authority = $false
        confirmation_switch = "-ConfirmedPaths"
    }
    tools = $tools
    install_plan = $installPlan
    install_results = $installResults
    notes = @(
        "Configuration supplies candidate values only; it does not authorize filesystem changes.",
        "Confirm formal_repo, owner_handoff_root, safe_copy, handoff_root, and reports_dir as absolute paths before creating or writing folders.",
        "Confirm an absolute dev_tools_root before installing reusable external developer tools.",
        "Installation requires both -ConfirmedPaths and the separate -ConfirmedInstallPlan gate.",
        "Record installer side effects and cache/global-directory decisions without assuming a preferred drive or folder convention."
    )
}

if ($Json) {
    $result | ConvertTo-Json -Depth 7
} else {
    $result | Format-List
}
