# Bridge Protocol And State Templates

Use these templates when setting up the Owner handoff workflow for a new project.

## MEMORY_BRIDGE_PROTOCOL.md Template

```markdown
# Codex / Implementer Memory Bridge Protocol

更新时间：YYYY-MM-DD

## Purpose

This file defines the fixed handoff rules for this project. Codex is the single engineering Owner. Implementer agents work only in the safety copy and return delivery packets. No conversation should assume hidden context from another conversation.

## Completion Standard

- Read context before building.
- Prefer durable fixes over workarounds.
- Add tests for behavior changes.
- Add docs for user-facing or workflow changes.
- Do not claim completion without fresh verification.
- Never commit secrets, tokens, real `.env`, credentials, or raw private logs.

## Fixed Paths

Formal repository:

```text
<formal_repo>
```

Safety copy:

```text
<safe_copy>
```

Owner handoff root:

```text
<owner_handoff_root>
```

Handoff root:

```text
<handoff_root>
```

Current state:

```text
<state_file>
```

Stage reports:

```text
<reports_dir>
```

## Environment Bootstrap

On a new machine, read config first, detect required tools, and confirm paths before creating or writing folders.

Default Windows path proposal after the user confirms `<drive>`:

```text
Formal repository: <drive>\codex\<project_name>
Owner handoff:     <drive>\Claude code\<project_name>_OwnerHandoff
Safety copy:       <drive>\Claude code\<project_name>_OwnerHandoff\<project_name>_Safety copy
Handoff root:      <drive>\Claude code\<project_name>_OwnerHandoff\<project_name>_codex_handoff
Reports:           <drive>\codex\<project_name>\reports\stage-reports
```

Record the config source, confirmed drive, confirmed paths, tool detection result, and any installation actions in `CURRENT_STATE.md`.

## Roles

### User

- Defines goals, product principles, priorities, and acceptance preferences.
- Provides concept documents and change requests.
- Makes product decisions when engineering tradeoffs require owner input.

### Codex Owner

- Rebuilds context.
- Breaks down tasks.
- Writes acceptance criteria.
- Generates copyable implementer instructions.
- Reviews delivery packets.
- Runs fresh tests.
- Fixes small integration issues.
- Commits, pushes, opens PRs.
- Updates state and stage reports.

### Implementer Agent

- Modifies only `<safe_copy>`.
- Does not modify `<formal_repo>`.
- Does not commit, push, create PRs, or call real external services.
- Delivers `summary.md`, `changed-files.txt`, `verification.md`, and `patch.diff`.

## Standard Workflow

```text
User goal
-> Codex Owner task breakdown and task file
-> User gives copyable instruction to implementer
-> Implementer works in safety copy
-> Implementer returns delivery packet
-> Codex Owner reviews and verifies
-> Codex Owner integrates formal repo
-> Codex Owner commits/pushes/opens PR
-> Codex Owner updates current state
```

## Startup Checklist

Before work:

1. Read this protocol.
2. Read `<state_file>`.
3. Check formal repo status.
4. Check safety copy status.
5. Confirm target task and current owner.
6. Treat implementer verification as evidence, not proof.

## Forbidden

- No implementer edits in formal repo.
- No unreviewed safety-copy code in formal repo.
- No secrets or private credentials in handoff files.
- No real external actions unless explicitly approved and in scope.
- No stacked unreviewed code tasks unless the Owner deliberately accepts the risk.
```

## CURRENT_STATE.md Template

```markdown
# Project Current State

更新时间：YYYY-MM-DD

## Current Rules

Read:

- `<handoff_root>/MEMORY_BRIDGE_PROTOCOL.md`
- this file

## Fixed Paths

- Formal repo: `<formal_repo>`
- Owner handoff root: `<owner_handoff_root>`
- Safety copy: `<safe_copy>`
- Handoff root: `<handoff_root>`
- Reports: `<reports_dir>`

## Environment Snapshot

- Config source: `<path or none>`
- Default drive confirmed by user: `<drive>`
- Dev tools root confirmed by user: `<dev_tools_root>`
- Owner handoff root confirmed by user: `<owner_handoff_root>`
- Tool status: `<summary>`
- Install plan: `<none or summary>`
- System/default-location writes: `<none or documented unavoidable writes>`
- Cache/global directory redirects: `<none or summary>`
- Setup actions: `<none or commands>`
- Remaining manual setup: `<none or list>`

## Latest Snapshot: YYYY-MM-DD / TASK-XXX STATUS

### Current Task

Status:

```text
generated | handed-to-implementer | delivered | owner-reviewing | integrated | rejected | blocked
```

Task file:

```text
<handoff_root>/tasks/TASK-XXX-short-slug.md
```

Delivery directory:

```text
<handoff_root>/outgoing-from-implementer/TASK-XXX/
```

Formal branch:

```text
<branch>
```

Formal commit:

```text
<commit or none>
```

PR:

```text
<url or none>
```

Verification:

```text
- command: result
```

Next action:

```text
<next concrete action>
```

Risks / Notes:

```text
- <risk>
```

## Historical Snapshots

Move older snapshots below this line. The top snapshot is authoritative.
```
