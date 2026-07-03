---
name: owner-handoff-development
description: Manage delegated software development where Codex acts as the single engineering Owner, another coding agent such as Claude or DeepSeek implements in a safe copy, and Codex bootstraps the environment, confirms formal/safety paths, reviews patches, tests, integrates, commits, pushes, opens PRs, updates handoff state, and gives copyable implementer instructions. Use when the user asks for a reusable Owner handoff workflow, safe-copy development, new-machine setup, Claude handoff tasks, patch delivery review, staged GitHub integration, or multi-agent engineering execution.
---

# Owner Handoff Development

## Purpose

Use this skill to run an engineering workflow where Codex owns architecture, task breakdown, review, verification, integration, GitHub delivery, and project memory, while implementation agents only modify a controlled safety copy.

The standard is complete delivery: read context first, make durable fixes, test before shipping, document state changes, and never treat an implementer's self-reported verification as final.

## New Machine Bootstrap

On an unfamiliar computer, bootstrap before creating tasks or editing code:

1. Read any existing project config or bridge state. Prefer, in order: a user-provided config path, `<cwd>/owner-handoff.config.json`, `<cwd>/.owner-handoff/config.json`, then the user's home-level config.
2. Detect OS, shell, Git, GitHub CLI, Python, ripgrep, and other project-required tools. Use `scripts/inspect_environment.ps1` on Windows/PowerShell when available.
3. If required tools are missing, classify each install before acting: system-required tool, general development tool, project-specific tool, or temporary tool.
4. Do not install external development tools into system/default locations by default. Ask the user to confirm a reusable `dev_tools_root`; put project-only tools inside the project; and list unavoidable system, home-directory, registry, or package-manager writes before proceeding.
5. Generate an install plan with purpose, target directory, scope, expected system/default-location writes, cache/global-directory settings, and whether user confirmation is required. Do not install until the user confirms the plan.
6. Ask the user to confirm the default drive and the resolved formal/safety directories before creating, cloning, deleting, copying, or writing project files.
7. Only after path and install-plan confirmation, create missing folders, clone/copy repositories, create the bridge protocol, and continue with the Owner workflow.

Do not guess drives, volumes, project roots, or handoff paths silently. If no project config has explicit paths, ask the user to confirm them before creating, copying, cloning, deleting, or writing.

## Required Confirmation Gates

Before installing, configuring, initializing, cloning, copying, or writing project files, ask for confirmation when the value is not already explicitly approved in project config or the current user request.

Confirm these paths first:

- reusable development tools root, such as `dev_tools_root`
- formal repository path
- owner handoff root
- safety copy path
- handoff root
- report/output paths when the workflow will write reports

For every install, present a plan before acting:

- package/tool name
- purpose
- install scope: system-required, reusable development tool, project-specific, or temporary
- target directory
- system/default-location writes and whether they are avoidable
- cache/global-directory redirects
- exact command to run
- whether user confirmation has already been received

If confirmation is missing, stop and ask. Do not treat inferred defaults as approval.

## Interruption And Resume Policy

If work is interrupted by quota exhaustion, time-window limits, rate limits, model/session cutoff, tool failure, or any similar external stop, do not claim the task is complete unless the requested outcome was actually finished and freshly verified.

Before stopping, record a checkpoint in the project state file or handoff notes:

- current task ID and objective
- current repository, branch, and `git status`
- files changed or suspected changed
- commands already run and their results
- validation not yet run or not yet trusted
- unresolved work
- exact next action to resume
- any user confirmation still required

Tell the user the true status plainly: completed, partially completed, blocked, or interrupted. If interrupted, state that the next conversation can continue from the recorded checkpoint after quota/session availability returns.

When the user returns, first read the checkpoint/current state, report the resumable task and next action, then continue from that point. Never use an interruption as a reason to mark work complete, skip tests, omit docs, or hide uncertainty.

## Core Roles

- **User**: states goals, principles, priorities, product ideas, and final product decisions.
- **Codex Owner**: converts goals into tasks, writes acceptance criteria, gives copyable implementer instructions, reviews delivery, fixes small integration issues, runs verification, commits, pushes, opens PRs, and updates state.
- **Implementer agent**: writes code only in the safety copy, does not commit or push, and returns a delivery packet.

Do not let implementer agents directly modify the formal repository or publish changes.

## Project Lanes

Establish these paths before generating tasks:

- `<formal_repo>`: authoritative project repository that Codex Owner integrates and commits.
- `<owner_handoff_root>`: project-level collaboration container under the implementer workspace root.
- `<safe_copy>`: disposable or refreshable implementation copy used by Claude, DeepSeek, or another implementer.
- `<handoff_root>`: shared handoff area containing task files, outgoing delivery packets, rejected work, and state files.
- `<state_file>`: current state ledger for task status, branches, commits, PRs, verification, and next action.
- `<reports_dir>`: optional user-facing stage reports.

Default Windows layout after drive confirmation:

- `<formal_repo>`: `<drive>\codex\<project_name>`
- `<owner_handoff_root>`: `<drive>\Claude code\<project_name>_OwnerHandoff`
- `<safe_copy>`: `<owner_handoff_root>\<project_name>_Safety copy`
- `<handoff_root>`: `<owner_handoff_root>\<project_name>_codex_handoff`
- `<reports_dir>`: `<formal_repo>\reports\stage-reports`

If a project already has a bridge protocol, read it before acting. Otherwise create a lightweight project-specific protocol using `references/state-template.md`.

## Workflow

1. **Bootstrap environment**: read config, detect tools, generate any required install plan, confirm reusable tool directories and formal/safety paths, then act only after user confirmation. Use `references/environment-bootstrap.md`.
2. **Rebuild context**: read the bridge protocol, current state, README, roadmap/spec files, and repo status for both formal repo and safe copy.
3. **Decide the next task**: choose the smallest coherent unit that advances the project without leaving architecture debt.
4. **Write the task file**: include background, goal, allowed scope, forbidden scope, acceptance criteria, required tests, delivery directory, and rework triggers. Use `references/task-template.md`.
5. **Give copyable instructions**: paste a concise command-style prompt in the chat for the user to give the implementer. Do not create a separate copy-to-implementer file unless requested.
6. **Review delivery**: require `summary.md`, `changed-files.txt`, `verification.md`, and `patch.diff`; inspect the patch and compare it with the task. Use `references/review-checklist.md`.
7. **Choose owner action**: apply small safe corrections directly; send large rewrites or wrong architecture back as a rework report.
8. **Integrate formally**: apply reviewed changes to `<formal_repo>`, run fresh verification, scan for secrets, and make reviewed local commits when appropriate.
9. **Deliver to GitHub by cadence**: decide whether to push/open PR now based on the project's development docs, roadmap, stage boundaries, risk level, and `references/github-delivery-policy.md`.
10. **Update state**: record task status, stage status, formal branch, local commit, push/PR decision, verification results, risks, and next task in `<state_file>`.
11. **Refresh safe copy**: after important formal integration, refresh `<safe_copy>` from the new formal baseline to avoid stale patch conflicts.

## Repository Delivery Cadence

Do not push every small update by default. Use a layered cadence:

- Local commit after reviewed task-level integration.
- Remote push after a coherent feature slice, risk checkpoint, cross-machine handoff need, or stage closure.
- Draft PR after a stage closes against its documented Definition of Done.
- Merge/tag only after milestone, release, or user-approved closure.

Project development documents, roadmap, and stage task plans define the normal push/PR frequency. If those documents are missing, create or update them before deciding the delivery cadence.

Push early only for explicit exceptions: security fixes, high-risk persistence/schema/permission changes, machine migration, collaboration handoff, CI-only verification needs, or interruption risk.

## Review Policy

Codex Owner must maintain global architecture judgment. If the implementer chooses the easiest local implementation but it weakens future architecture, correct it or request rework.

Apply owner fixes directly when the change is small, localized, and clearly safer than round-tripping. Request implementer rework when changes are broad, directionally wrong, under-tested, security-sensitive, or likely to hide defects.

Trigger an additional PR-level review only for high-risk changes: schema or persistence changes, permissions/security/secrets/shell/external services, large refactors, task scheduling, memory, decision flow, insufficient tests, or unstable behavior.

## Verification Policy

Never claim completion from implementer notes alone. Run the project's canonical checks in the formal repo after integration. At minimum, prefer:

- formatter/linter checks
- focused tests for changed behavior
- full test suite when feasible
- contract/registry/drift checks if the project has them
- secret scan
- `git diff --check`
- GitHub Actions status after PR creation, when available

Record exact commands and results in the state file.

## Reference Files

- Read `references/environment-bootstrap.md` before first use on a new machine or when paths/tools are unknown.
- Read `references/github-delivery-policy.md` before creating a repository, pushing project work, opening PRs, tagging, or deciding delivery cadence.
- Read `references/task-template.md` when creating a new implementer task.
- Read `references/review-checklist.md` when reviewing a delivery packet or integrating code.
- Read `references/state-template.md` when setting up this workflow in a new project.
