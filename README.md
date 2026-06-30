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
- Bridge protocol and current-state templates.
- PowerShell environment inspection script.

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

## License

MIT. This license is intentionally permissive for a workflow/tooling skill: people can use it, modify it, fork it, and adopt it in commercial or private projects while preserving the copyright notice and disclaimer.

