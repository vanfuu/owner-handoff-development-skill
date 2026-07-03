<p align="right">
  <a href="#english"><kbd>English</kbd></a>
  <a href="#中文"><kbd>中文</kbd></a>
</p>

<a id="english"></a>

# Owner Handoff Development Skill

A Codex skill for running delegated software development with a clear engineering owner, an isolated implementation copy, patch-based delivery, independent review, fresh verification, and GitHub integration.

This skill is useful when you want Codex to act as the final engineering owner while another coding agent, such as Claude or DeepSeek, implements changes in a safety copy. It helps keep architecture decisions, code review, testing, release notes, and repository publishing in one controlled lane.

## What It Provides

- New-machine bootstrap guidance for detecting tools and confirming paths.
- Default Windows path layout for a formal repository, project-level handoff container, safety copy, and handoff area.
- Task-file template for delegated coding work.
- Copyable implementer instructions.
- Delivery packet requirements: `summary.md`, `changed-files.txt`, `verification.md`, and `patch.diff`.
- Owner review and formal integration checklist.
- GitHub repository delivery policy with local commit, remote push, draft PR, merge, and tag cadence.
- Bridge protocol and current-state templates.
- PowerShell environment inspection script.
- Interruption and resume policy for quota, rate-limit, or session cutoffs.

## Default Layout

After the user confirms the drive and project name, the skill proposes:

```text
Formal repository:
<drive>\codex\<project_name>

Owner handoff container:
<drive>\Claude code\<project_name>_OwnerHandoff

Safety copy:
<drive>\Claude code\<project_name>_OwnerHandoff\<project_name>_Safety copy

Handoff root:
<drive>\Claude code\<project_name>_OwnerHandoff\<project_name>_codex_handoff
```

Paths are proposals, not silent defaults. The skill instructs Codex to confirm the drive and directories with the user before creating, cloning, copying, deleting, or writing project files.

## Install

Clone this repository into your Codex skills directory with the skill folder name:

```powershell
git clone https://github.com/vanfuu/owner-handoff-development-skill.git "$env:USERPROFILE\.codex\skills\owner-handoff-development"
```

Restart or refresh Codex so the skill metadata is rediscovered.

## Usage

Ask Codex:

```text
Use $owner-handoff-development to bootstrap the environment, confirm formal and safety paths, then run delegated development with Owner review, tests, and GitHub integration.
```

For a new project, Codex should first read `references/environment-bootstrap.md`, run environment detection where appropriate, ask the user to confirm paths, then create the project bridge files.

## Validate

If you have the Codex skill validation helper available, run:

```powershell
python path\to\quick_validate.py path\to\owner-handoff-development
```

The included PowerShell environment inspector can be run directly:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\inspect_environment.ps1 -ProjectName "Demo Project" -DefaultDrive "F:" -Json
```

Use `-InstallMissing` only after the user has authorized automatic setup of non-secret developer tools.

The skill requires explicit confirmation before installing tools or writing project folders. Reusable external developer tools should target a user-confirmed tools directory outside system/default locations; project-specific tools should stay inside the project. Formal repository, safety copy, handoff, and report paths must be confirmed before filesystem changes.

## License

MIT. This license is intentionally permissive for a workflow/tooling skill: people can use it, modify it, fork it, and adopt it in commercial or private projects while preserving the copyright notice and disclaimer.

---

<p align="right">
  <a href="#english"><kbd>English</kbd></a>
  <a href="#中文"><kbd>中文</kbd></a>
</p>

<a id="中文"></a>

# Owner Handoff Development Skill（中文）

这是一个面向 Codex 的开发流程 Skill，用于管理“主工程 Owner + 安全副本实现 + Patch 交付 + 独立审查 + 新鲜验证 + GitHub 集成”的委托式软件开发流程。

当你希望 Codex 负责最终工程判断，而让 Claude、DeepSeek 或其他代码 Agent 只在安全副本中实现具体改动时，这个 Skill 可以帮助你把架构决策、任务拆解、代码审查、测试验证、发布说明和仓库同步放进一条受控流程里。

## 它提供什么

- 新电脑环境启动流程：检测工具、读取配置、确认路径。
- 默认 Windows 目录布局：正式仓库、项目级协作容器、安全副本、交接区。
- 委托式代码任务单模板。
- 可直接复制给实现 Agent 的任务指令。
- 交付包要求：`summary.md`、`changed-files.txt`、`verification.md`、`patch.diff`。
- Owner 审查与正式集成清单。
- GitHub 仓库交付策略，区分本地提交、远端推送、draft PR、合并和 tag 的节奏。
- 记忆桥协议与当前状态模板。
- PowerShell 环境检查脚本。
- 针对额度、限流或会话中断的断点记录与恢复规则。

## 默认目录结构

在使用者确认盘符和项目名称后，Skill 会建议：

```text
正式项目：
<drive>\codex\<project_name>

Owner 协作容器：
<drive>\Claude code\<project_name>_OwnerHandoff

安全副本：
<drive>\Claude code\<project_name>_OwnerHandoff\<project_name>_Safety copy

交接区：
<drive>\Claude code\<project_name>_OwnerHandoff\<project_name>_codex_handoff
```

这些路径只是建议，不会被静默采用。Skill 会要求 Codex 在创建、克隆、复制、删除或写入项目文件之前，先让使用者确认盘符和目录。

## 安装

将仓库克隆到 Codex skills 目录，并保持 skill 文件夹名为 `owner-handoff-development`：

```powershell
git clone https://github.com/vanfuu/owner-handoff-development-skill.git "$env:USERPROFILE\.codex\skills\owner-handoff-development"
```

然后重启或刷新 Codex，让它重新发现 Skill metadata。

## 使用方式

对 Codex 说：

```text
Use $owner-handoff-development to bootstrap the environment, confirm formal and safety paths, then run delegated development with Owner review, tests, and GitHub integration.
```

对于新项目，Codex 应先读取 `references/environment-bootstrap.md`，在合适情况下运行环境检测，要求使用者确认路径，然后再创建项目交接文件。

## 验证

如果你有 Codex skill 校验工具，可以运行：

```powershell
python path\to\quick_validate.py path\to\owner-handoff-development
```

也可以直接运行内置的 PowerShell 环境检查脚本：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\inspect_environment.ps1 -ProjectName "Demo Project" -DefaultDrive "F:" -Json
```

只有在使用者明确授权自动安装非敏感开发工具后，才使用 `-InstallMissing`。

安装工具或写入项目目录之前必须先得到明确确认。可复用的外部开发工具应安装到使用者确认过的工具目录，避免默认系统目录；项目专用工具应放在项目内部。正式仓库、安全副本、交接区和报告目录都必须确认后再继续。

## 许可证

MIT。这个许可证对流程类和工具类 Skill 很友好：别人可以自由使用、修改、fork，并用于商业或私有项目，同时保留版权声明和免责声明。
