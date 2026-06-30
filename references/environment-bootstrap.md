# Environment Bootstrap

Use this reference before using the Owner handoff workflow on a new computer, after changing machines, or when project paths/tools are uncertain.

## Config Discovery

Read configuration in this order:

1. Config path explicitly provided by the user.
2. `<cwd>/owner-handoff.config.json`
3. `<cwd>/.owner-handoff/config.json`
4. `%USERPROFILE%/.codex/owner-handoff-development/config.json` on Windows, or the equivalent home path on other systems.

If no config exists, infer a proposal and ask the user to confirm it before creating or writing folders.

## Suggested Config Shape

```json
{
  "project_name": "My Project",
  "default_drive": "F:",
  "formal_repo": "F:\\codex\\My Project",
  "owner_handoff_root": "F:\\Claude code\\My Project_OwnerHandoff",
  "safe_copy": "F:\\Claude code\\My Project_OwnerHandoff\\My Project_Safety copy",
  "handoff_root": "F:\\Claude code\\My Project_OwnerHandoff\\My Project_codex_handoff",
  "reports_dir": "F:\\codex\\My Project\\reports\\stage-reports",
  "install_policy": "auto_when_authorized"
}
```

Treat config as convenience, not as final authority. Confirm paths with the user unless the current request explicitly says the saved config is already approved.

## Default Path Proposal

Ask the user to confirm the default drive. After confirmation, propose:

```text
Formal repository: <drive>\codex\<project_name>
Owner handoff:     <drive>\Claude code\<project_name>_OwnerHandoff
Safety copy:       <drive>\Claude code\<project_name>_OwnerHandoff\<project_name>_Safety copy
Handoff root:      <drive>\Claude code\<project_name>_OwnerHandoff\<project_name>_codex_handoff
Reports:           <drive>\codex\<project_name>\reports\stage-reports
```

Use the user's actual project name. Quote paths in shell commands when they contain spaces.

Do not silently use `C:` or the current working drive when the user has not confirmed the default drive.

## Environment Detection

Detect:

- OS and architecture.
- Current shell and PowerShell availability on Windows.
- `git`
- `gh`
- Python, preferably the version required by the project.
- `rg` / ripgrep.
- Project-specific runtime tools, for example Node.js, pnpm, uv, Docker, or language SDKs.
- Git authentication status when GitHub delivery is required.

On Windows/PowerShell, run:

```powershell
& "<skill_dir>\scripts\inspect_environment.ps1" -ProjectName "<project_name>" -DefaultDrive "F:" -Json
```

If setup automation is authorized and non-secret tools are missing:

```powershell
& "<skill_dir>\scripts\inspect_environment.ps1" -ProjectName "<project_name>" -DefaultDrive "F:" -InstallMissing -Json
```

Do not use `-InstallMissing` for secrets, credentials, private keys, API tokens, production data, browser logins, or destructive actions.

## Auto-Install Policy

When tools are missing:

1. Prefer project-local setup first, for example `.venv`, package restore, or repo scripts.
2. Install non-secret developer tools when the user authorized automatic setup.
3. On Windows, prefer `winget` package IDs:
   - `Git.Git`
   - `GitHub.cli`
   - `Python.Python.3.12`
   - `BurntSushi.ripgrep.MSVC`
   - `Microsoft.PowerShell`
4. If install requires admin UI, license interaction, or fails, stop and provide the exact command for the user to run.
5. After installation, re-run environment detection and record the result in the state file.

## Path Confirmation Prompt

Use a short confirmation prompt like:

```text
我检测到/建议使用以下目录，请确认后我再创建或写入：

默认盘符：<drive>
正式项目：<drive>\codex\<project_name>
协作容器：<drive>\Claude code\<project_name>_OwnerHandoff
安全副本：<drive>\Claude code\<project_name>_OwnerHandoff\<project_name>_Safety copy
交接区：<drive>\Claude code\<project_name>_OwnerHandoff\<project_name>_codex_handoff

请确认这些路径是否正确，尤其是默认盘符。
```

Do not proceed with folder creation, copying, cloning, or deletion until the user confirms.

## State Recording

After bootstrap, record in the project state file:

- Config source used.
- Confirmed formal repo path.
- Confirmed owner handoff root.
- Confirmed safety copy path.
- Confirmed handoff root.
- Tool detection result.
- Tool installation actions, if any.
- GitHub auth status if checked.
- Remaining manual setup, if any.
