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
  "default_drive": "<drive>",
  "dev_tools_root": "<dev_tools_root>",
  "formal_repo": "<formal_repo>",
  "owner_handoff_root": "<owner_handoff_root>",
  "safe_copy": "<safe_copy>",
  "handoff_root": "<handoff_root>",
  "reports_dir": "<reports_dir>",
  "install_policy": "plan_then_confirm"
}
```

Treat config as convenience, not as final authority. Confirm paths with the user unless the current request explicitly says the saved config is already approved. If `dev_tools_root` is missing, ask the user to provide a directory outside system/default install locations before installing reusable external development tools.

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

Do not silently use `C:`, the current working drive, the current volume, the home directory, or another default root when the user has not confirmed the project paths.

## Required Path Confirmation Prompt

Use a direct prompt before creating, cloning, copying, deleting, or writing project files:

```text
I need confirmation before changing the filesystem.

Reusable tools root: <dev_tools_root>
Formal repository: <formal_repo>
Owner handoff root: <owner_handoff_root>
Safety copy: <safe_copy>
Handoff root: <handoff_root>
Reports/output path: <reports_dir>

Please confirm these paths, or provide corrected paths.
```

For Windows users, include the drive letter. For macOS/Linux users, include the mounted volume or absolute root path. Do not continue until the paths are confirmed.

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

If setup automation is authorized and non-secret tools are missing, first generate a plan:

```powershell
& "<skill_dir>\scripts\inspect_environment.ps1" -ProjectName "<project_name>" -DefaultDrive "F:" -InstallMissing -Json
```

Do not use `-InstallMissing` for secrets, credentials, private keys, API tokens, production data, browser logins, or destructive actions. Treat `-InstallMissing` as plan generation unless a user-confirmed `dev_tools_root` and explicit install confirmation are present.

## Install Location Policy

When tools are missing:

1. Classify the install scope before installing:
   - **System-required tool**: may install to a system/default location only when it is an OS component, driver, platform SDK, system runtime, system package manager, or a tool that truly cannot be redirected. Explain why.
   - **General development tool**: install to the user-confirmed `dev_tools_root`, not a silent system/default location.
   - **Project-specific tool**: install inside the project, for example `.tools`, `.bin`, `.vendor`, `.deps`, `tools`, `vendor`, `.venv`, `node_modules`, or the ecosystem's standard project-local directory.
   - **Temporary tool**: install or unpack in a temporary working directory and clean it when appropriate.
2. Do not default external tools to system/default locations such as:
   - Windows: `C:\Program Files`, `C:\Program Files (x86)`, `%APPDATA%`, `%LOCALAPPDATA%`, `%USERPROFILE%\.xxx`, or another unconfirmed `C:` location.
   - macOS: `/Applications`, `/usr/local`, `/opt/homebrew`, `$HOME/Library`, `$HOME/.xxx`, or unconfirmed Homebrew/global locations.
   - Linux: `/usr`, `/usr/local`, `/opt`, `$HOME/.local`, `$HOME/.cache`, `$HOME/.xxx`, or unconfirmed package-manager/global locations.
3. Before installation, present a plan that states:
   - what will be installed
   - purpose
   - install directory
   - whether it writes to a system/default location
   - why any system/default write is unavoidable
   - whether cache/global directories can be moved to the confirmed tool root or project
   - whether the install is project-level or reusable/global
4. Configure caches and global directories away from system/default locations when the tool supports it, including npm, pnpm, pip, uv, conda, cargo, Gradle, Maven, Go, Docker, and model caches.
5. Prefer project-local installs, virtual environments, portable archives, or project `.tools`/`.vendor` directories over global installs.
6. Only after the user confirms the plan, install non-secret developer tools. On Windows, `winget` package IDs may be used with a target location when supported:
   - `Git.Git`
   - `GitHub.cli`
   - `Python.Python.3.12`
   - `BurntSushi.ripgrep.MSVC`
   - `Microsoft.PowerShell`
7. If the installer ignores custom locations, requires admin UI, writes unavoidable state to a system/default location, or fails, stop and provide the exact command and risk summary for the user to approve.
8. After installation, re-run environment detection and record the result in the state file.

## Required Install Plan Prompt

Use a direct prompt before running install commands:

```text
I need confirmation before installing tools.

Tool: <tool>
Purpose: <purpose>
Scope: <system-required | reusable development tool | project-specific | temporary>
Target directory: <path>
System/default-location writes: <none | details>
Cache/global directory redirects: <details>
Command: <exact command>

Please confirm whether to proceed.
```

If the install plan includes unavoidable writes to a system/default location, explain why they are unavoidable and whether they can be redirected. Do not proceed without user confirmation.

## Windows Path Confirmation Prompt Example

Use a short confirmation prompt like:

```text
我检测到/建议使用以下目录，请确认后我再创建或写入：

默认盘符：<drive>
通用开发工具目录：<confirmed-dev-tools-root>
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
- Confirmed `dev_tools_root`.
- Confirmed formal repo path.
- Confirmed owner handoff root.
- Confirmed safety copy path.
- Confirmed handoff root.
- Tool detection result.
- Install plan and user confirmation status, if missing tools were found.
- Tool installation actions, if any.
- Any unavoidable system/default-location writes and cache/global-directory redirects.
- GitHub auth status if checked.
- Remaining manual setup, if any.
