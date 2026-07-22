# Environment Bootstrap

Use this reference before using the Owner handoff workflow on a new computer, after changing machines, or when project paths or tools are uncertain.

## Universal Path Rule

Treat every filesystem location as user-specific until confirmed. Never convert a drive letter, mount point, home-directory layout, folder name, tool root, repository layout, cache path, or naming convention from memory, previous sessions, the current machine, an example, or another user into a default.

Read-only discovery may identify existing directories and help formulate a question. Discovery does not authorize creation, cloning, copying, deletion, installation, or writing.

The path gate opens only when all of the following are true:

1. Every affected target is an explicit absolute path.
2. Placeholders, relative paths, unresolved environment variables, and inferred roots have been eliminated.
3. The user has seen the resolved paths and confirmed them for the stated operation scope.
4. The machine, workspace, paths, and operation scope still match what was confirmed.

If any item changes, ask again. Path confirmation does not authorize an installation command; installation has a separate gate.

## Config Discovery

Read configuration in this order:

1. Config path explicitly provided by the user.
2. `<cwd>/owner-handoff.config.json`
3. `<cwd>/.owner-handoff/config.json`
4. `%USERPROFILE%/.codex/owner-handoff-development/config.json` on Windows, or the equivalent home path on other systems.

A discovered config supplies candidate values only. It is never proof that the current user approved those paths for the current machine or operation.

## Suggested Config Shape

```json
{
  "project_name": "My Project",
  "dev_tools_root": "<absolute_dev_tools_root>",
  "formal_repo": "<absolute_formal_repo>",
  "owner_handoff_root": "<absolute_owner_handoff_root>",
  "safe_copy": "<absolute_safe_copy>",
  "handoff_root": "<absolute_handoff_root>",
  "reports_dir": "<absolute_reports_dir>",
  "install_policy": "plan_then_confirm"
}
```

Do not add a default drive or default mount to the config template. Do not derive missing values by appending personal folder names to a root. Ask the user for the missing absolute paths.

## Required Path Confirmation Prompt

Before a filesystem-changing action, show only paths relevant to that action. A complete Owner-handoff bootstrap normally uses:

```text
I need confirmation before changing the filesystem.

Operation scope: <create | clone | copy | write | delete | install | other>
Reusable tools root: <absolute_dev_tools_root or not applicable>
Formal repository: <absolute_formal_repo>
Owner handoff root: <absolute_owner_handoff_root>
Safety copy: <absolute_safe_copy>
Handoff root: <absolute_handoff_root>
Reports/output path: <absolute_reports_dir or not applicable>

Please confirm these exact paths for the stated operation, or provide corrected absolute paths.
```

For Windows, show complete absolute paths including drive letters or UNC roots. For macOS/Linux, show complete absolute paths including mounted volumes when applicable. Do not continue until the user confirms the displayed values.

The user's earlier personal preference may be mentioned as a candidate only when it is relevant and clearly labeled as unconfirmed. Never imply that it is a standard layout.

## Environment Detection

Detect read-only facts before asking the path question when useful:

- OS and architecture.
- Current shell and PowerShell availability on Windows.
- `git`
- `gh`
- Python, preferably the version required by the project.
- `rg` / ripgrep.
- Project-specific runtime tools, for example Node.js, pnpm, uv, Docker, or language SDKs.
- Git authentication status when GitHub delivery is required.

On Windows/PowerShell, safe read-only inspection can run without path inputs:

```powershell
& "<skill_dir>\scripts\inspect_environment.ps1" -ProjectName "<project_name>" -Json
```

To inspect candidate paths from a config without authorizing writes:

```powershell
& "<skill_dir>\scripts\inspect_environment.ps1" -ConfigPath "<absolute_config_path>" -Json
```

After the user confirms every displayed absolute path, record the confirmation for this run:

```powershell
& "<skill_dir>\scripts\inspect_environment.ps1" -ConfigPath "<absolute_config_path>" -ConfirmedPaths -Json
```

If non-secret tools are missing, generate an install plan without executing it:

```powershell
& "<skill_dir>\scripts\inspect_environment.ps1" -ConfigPath "<absolute_config_path>" -ConfirmedPaths -InstallMissing -Json
```

Only after the user separately confirms the exact install plan may it execute:

```powershell
& "<skill_dir>\scripts\inspect_environment.ps1" -ConfigPath "<absolute_config_path>" -ConfirmedPaths -InstallMissing -ConfirmedInstallPlan -Json
```

Do not use installation automation for secrets, credentials, private keys, API tokens, production data, browser logins, or destructive actions.

## Install Location Policy

When tools are missing:

1. Classify the install scope before installing:
   - **System-required tool**: may need a system-managed location because it is an OS component, driver, platform SDK, system runtime, system package manager, or another non-relocatable dependency. Explain why.
   - **Reusable development tool**: ask the user to choose and confirm an absolute `dev_tools_root`.
   - **Project-specific tool**: use an ecosystem-standard project-local directory only after the project path is confirmed.
   - **Temporary tool**: show the temporary directory and cleanup behavior before use when it will change the filesystem.
2. Do not assume that a particular drive is good or bad. Evaluate the exact target, permissions, free space, portability, backup behavior, installer constraints, and user preference.
3. Treat system-managed or home-managed locations as review points, not automatic choices. Examples include:
   - Windows: Program Files, AppData, the user profile, registry, Start Menu, and package-manager state.
   - macOS: `/Applications`, system or Homebrew prefixes, `$HOME/Library`, home-level config, and package-manager state.
   - Linux: `/usr`, `/usr/local`, `/opt`, home-level local/cache/config directories, and package-manager state.
4. Before installation, present:
   - tool and purpose
   - install scope
   - exact target directory
   - exact command
   - expected system-managed or home-managed writes
   - why unavoidable writes cannot be redirected
   - cache/global-directory choices
   - whether administrator privileges or UI interaction are expected
5. Prefer project-local installs, virtual environments, portable archives, or project `.tools`/`.vendor` directories when they fit the tool and the user has confirmed the project path.
6. Configure caches and global directories only to user-confirmed paths. Do not relocate them to a remembered personal tools drive.
7. On Windows, `winget` package IDs may be included in a proposed plan when supported, but `--location` is not proof that every write will stay there. Verify actual behavior after installation.
8. If an installer ignores custom locations, requires admin UI, adds unapproved writes, or fails, stop and show the observed result before retrying.
9. After installation, re-run environment detection and record the result in the state file.

## Required Install Plan Prompt

Use a direct prompt before running install commands:

```text
I need separate confirmation before installing tools.

Tool: <tool>
Purpose: <purpose>
Scope: <system-required | reusable development tool | project-specific | temporary>
Target directory: <absolute_path>
System/home-managed writes: <none | details>
Cache/global directory choices: <details>
Administrator or UI interaction: <none | details>
Command: <exact command>

The target paths have been confirmed separately. Please confirm whether to execute this exact install plan.
```

Do not interpret path confirmation as install confirmation. Do not proceed without both gates.

## 中文路径确认示例

```text
在执行文件系统变更前，我需要你确认以下精确路径：

操作范围：<创建 / 克隆 / 复制 / 写入 / 删除 / 安装 / 其他>
通用开发工具目录：<绝对路径或不适用>
正式项目：<绝对路径>
协作容器：<绝对路径>
安全副本：<绝对路径>
交接区：<绝对路径>
报告目录：<绝对路径或不适用>

请确认这些路径仅用于上述操作；如果不正确，请提供修正后的绝对路径。
```

Do not insert a habitual drive letter or folder naming convention into this template.

## State Recording

After bootstrap, record in the project state file:

- Config source used.
- Exact paths displayed to the user.
- Path confirmation status, scope, and time.
- Confirmed `dev_tools_root`, when applicable.
- Confirmed formal repo, owner handoff, safety copy, handoff, and report paths.
- Tool detection result.
- Install plan and separate confirmation status, if missing tools were found.
- Tool installation actions, if any.
- Any unavoidable system/home-managed writes and cache/global-directory decisions.
- GitHub auth status if checked.
- Remaining manual setup, if any.
