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

On a new machine, read config first, detect required tools, and confirm every affected absolute path before creating or writing folders. A config, remembered drive, prior project layout, current working directory, or example is candidate information only and never authorizes filesystem changes.

Record the config source, exact confirmed paths, confirmation scope, tool detection result, and any separately confirmed installation actions in `CURRENT_STATE.md`.

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
- Path confirmation: `<pending | confirmed>`
- Confirmation scope: `<exact operations covered>`
- Confirmed at: `<timestamp or unknown>`
- Formal repo confirmed by user: `<formal_repo>`
- Dev tools root confirmed by user: `<dev_tools_root>`
- Owner handoff root confirmed by user: `<owner_handoff_root>`
- Safety copy confirmed by user: `<safe_copy>`
- Handoff root confirmed by user: `<handoff_root>`
- Reports path confirmed by user: `<reports_dir or not applicable>`
- Tool status: `<summary>`
- Install plan: `<none | pending confirmation | separately confirmed | summary>`
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

Repository delivery cadence:

```text
local-only | pushed | draft-pr | merged | tagged
reason: <why this cadence was chosen based on roadmap/stage/risk>
```

Stage boundary:

```text
stage: <stage id or none>
definition_of_done: <met | not met | not defined>
push_trigger: <stage closure | risk checkpoint | handoff | CI need | user request | none>
```

Next action:

```text
<next concrete action>
```

Risks / Notes:

```text
- <risk>
```

### Interruption / Resume Checkpoint

Use this section only when work stops before completion because of quota exhaustion, time-window limits, rate limits, tool failure, session cutoff, or another external interruption.

Status:

```text
not_interrupted | interrupted | blocked
```

Reason:

```text
<quota exhausted | rate limit | tool failure | session cutoff | other>
```

Last known repository state:

```text
<branch, commit, git status summary>
```

Completed before interruption:

```text
- <completed item>
```

Not yet completed:

```text
- <remaining item>
```

Verification status:

```text
<commands run and commands still required>
```

Resume instruction:

```text
When the user returns, read this checkpoint first and continue with: <next concrete action>
```

## Historical Snapshots

Move older snapshots below this line. The top snapshot is authoritative.
```
