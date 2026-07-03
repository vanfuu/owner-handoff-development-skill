# Delivery Review And Formal Integration Checklist

Use this checklist when an implementer says a task is complete.

## 1. Intake

- Confirm the delivery directory exists.
- Confirm required files exist:
  - `summary.md`
  - `changed-files.txt`
  - `verification.md`
  - `patch.diff`
- Read the task file, current state file, and delivery notes.
- Check both repositories:
  - `<formal_repo>` status, branch, latest commit
  - `<safe_copy>` status, branch, latest commit

## 2. Patch Review

- Inspect `patch.diff` before applying it.
- Compare changed files with allowed scope.
- Look for accidental formal repo paths, private paths, credentials, `.env`, API keys, raw logs, generated junk, or unrelated churn.
- Evaluate architecture fit, not just test pass/fail.
- Check whether docs, tests, contracts, changelog, and state ledgers are consistent with the behavior change.

## 3. Owner Decision

Apply owner fixes directly when:

- The correction is small and local.
- The intent is obvious from the task.
- The fix improves correctness, security, path consistency, docs, or tests.

Request rework when:

- The patch changes the wrong architecture layer.
- Runtime behavior is broad or risky beyond the task.
- Schema, persistence, permission, shell, memory, scheduling, or external-service changes are under-designed.
- The safe copy is stale enough that the patch is unreliable.
- Tests are missing for behavior changes.
- The delivery omits required files or cannot be trusted.

## 4. Formal Integration

- Create or checkout a formal integration branch.
- Apply the reviewed patch to `<formal_repo>`.
- Resolve conflicts manually and preserve unrelated user changes.
- Make owner corrections with clear intent.
- Update docs, task ledger, changelog, and current state as required by the project.

## 5. Verification

Run fresh checks in `<formal_repo>`. Prefer this order:

```powershell
.\.venv\Scripts\python.exe -m ruff check .
.\.venv\Scripts\python.exe -m pytest <focused tests>
.\.venv\Scripts\python.exe scripts\check_contract_registry.py --json
.\.venv\Scripts\python.exe scripts\scan_secrets.py
git diff --check
.\.venv\Scripts\python.exe -m pytest
```

Use project-specific equivalents when these commands do not exist. Do not report checks as passed unless they were run in the current integration state.

## 6. GitHub Delivery

- Commit only reviewed formal repo changes.
- Decide delivery cadence using the project roadmap/stage plan and `references/github-delivery-policy.md`.
- Keep reviewed task-level changes as local commits when the stage is not closed and no risk checkpoint requires remote backup.
- Push the branch only at a coherent feature slice, risk checkpoint, cross-machine handoff point, CI need, or stage closure.
- Create or update a draft PR when a stage/coherent delivery slice is ready for review.
- Include Summary, Files changed, How to run, Tests added, Test results, Known limitations, and Next recommended task.
- Inspect GitHub Actions status when available.
- Request PR-level review only for high-risk changes.

## 7. State Update

Update `<state_file>` after:

- task generation
- implementer delivery
- owner review
- formal integration
- commit/push/PR
- rejection or rework
- stage report generation

Record:

- task ID and status
- current owner/responsible party
- formal branch and commit
- delivery cadence decision and reason
- PR URL and CI result
- verification commands and results
- safety copy baseline
- next task and risks

## 8. Safe Copy Refresh

Refresh `<safe_copy>` from the formal baseline after meaningful integration, especially before giving another code task. This prevents stacked stale patches and lowers review cost.
