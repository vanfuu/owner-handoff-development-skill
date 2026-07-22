param(
    [string]$ScriptPath = (Join-Path (Split-Path -Parent $PSScriptRoot) "scripts\inspect_environment.ps1")
)

$ErrorActionPreference = "Stop"
$script:Failures = 0

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )
    if (-not $Condition) {
        $script:Failures += 1
        Write-Host "FAIL: $Message" -ForegroundColor Red
        return
    }
    Write-Host "PASS: $Message" -ForegroundColor Green
}

function Invoke-Inspector {
    param([string[]]$Arguments)

    $raw = & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Inspector exited with code $LASTEXITCODE. Output: $raw"
    }
    return ($raw | Out-String | ConvertFrom-Json)
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("owner-handoff-gates-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempRoot | Out-Null

try {
    $repositoryRoot = Split-Path -Parent $PSScriptRoot
    $contractFiles = @(
        (Join-Path $repositoryRoot "SKILL.md"),
        (Join-Path $repositoryRoot "README.md"),
        (Join-Path $repositoryRoot "references\environment-bootstrap.md"),
        (Join-Path $repositoryRoot "references\state-template.md"),
        $ScriptPath
    )
    $contractText = ($contractFiles | ForEach-Object { Get-Content -LiteralPath $_ -Raw -Encoding UTF8 }) -join "`n"
    Assert-True ($contractText -notmatch '\\codex\\<project_name>') "The skill does not encode a habitual repository folder layout."
    Assert-True ($contractText -notmatch '\\Claude code\\') "The skill does not encode a prior implementer-folder convention."
    Assert-True ($contractText -notmatch 'Test-IsCDrivePath|dev_tools_root_is_non_c') "The skill does not privilege or reject a drive letter by convention."
    Assert-True ($contractText -notmatch 'GetPathRoot\(\(Get-Location\)\.Path\)') "The script does not silently promote the current drive into a target root."

    $noPaths = Invoke-Inspector -Arguments @("-ProjectName", "Gate Test", "-Json")
    Assert-True ($noPaths.path_confirmation_required -eq $true) "Missing paths require confirmation."
    Assert-True ($noPaths.paths_confirmed -eq $false) "Missing paths are never treated as confirmed."
    Assert-True ($noPaths.filesystem_changes_allowed -eq $false) "Filesystem changes are blocked without explicit paths and confirmation."
    Assert-True (@($noPaths.missing_or_invalid_path_inputs).Count -ge 5) "The result identifies unresolved path inputs."

    $configPath = Join-Path $tempRoot "owner-handoff.config.json"
    $config = [ordered]@{
        project_name = "Gate Test"
        dev_tools_root = (Join-Path $tempRoot "tools")
        formal_repo = (Join-Path $tempRoot "formal")
        owner_handoff_root = (Join-Path $tempRoot "handoff-container")
        safe_copy = (Join-Path $tempRoot "safety-copy")
        handoff_root = (Join-Path $tempRoot "handoff")
        reports_dir = (Join-Path $tempRoot "reports")
        install_policy = "plan_then_confirm"
    }
    $config | ConvertTo-Json | Set-Content -LiteralPath $configPath -Encoding UTF8

    $unconfirmed = Invoke-Inspector -Arguments @("-ConfigPath", $configPath, "-Json")
    Assert-True ($unconfirmed.path_confirmation_required -eq $true) "Resolved paths still require current user confirmation."
    Assert-True ($unconfirmed.filesystem_changes_allowed -eq $false) "Supplying a config alone does not authorize writes."

    $confirmed = Invoke-Inspector -Arguments @("-ConfigPath", $configPath, "-ConfirmedPaths", "-Json")
    Assert-True ($confirmed.path_confirmation_required -eq $false) "Explicitly confirmed absolute paths satisfy the path gate."
    Assert-True ($confirmed.paths_confirmed -eq $true) "The result records explicit path confirmation."
    Assert-True ($confirmed.filesystem_changes_allowed -eq $true) "Confirmed valid paths authorize in-scope filesystem work."

    $planOnly = Invoke-Inspector -Arguments @("-ConfigPath", $configPath, "-ConfirmedPaths", "-InstallMissing", "-Json")
    Assert-True ($planOnly.install_execution_authorized -eq $false) "Path confirmation alone never authorizes installation."
    Assert-True (@($planOnly.install_results | Where-Object { $_.status -eq "attempted" }).Count -eq 0) "Unconfirmed install plans execute no installers."

    $relativeConfigPath = Join-Path $tempRoot "relative.config.json"
    $relativeConfig = [ordered]@{}
    foreach ($entry in $config.GetEnumerator()) {
        $relativeConfig[$entry.Key] = $entry.Value
    }
    $relativeConfig.formal_repo = ".\relative-formal-repo"
    $relativeConfig | ConvertTo-Json | Set-Content -LiteralPath $relativeConfigPath -Encoding UTF8
    $invalid = Invoke-Inspector -Arguments @("-ConfigPath", $relativeConfigPath, "-ConfirmedPaths", "-Json")
    Assert-True ($invalid.paths_confirmed -eq $false) "A confirmation flag cannot authorize unresolved relative paths."
    Assert-True ($invalid.filesystem_changes_allowed -eq $false) "Invalid paths keep the filesystem gate closed."
    Assert-True (@($invalid.missing_or_invalid_path_inputs) -contains "formal_repo") "The invalid path is reported by name."
} finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
}

if ($script:Failures -gt 0) {
    throw "$script:Failures path confirmation gate assertion(s) failed."
}

Write-Host "All path confirmation gate tests passed."
