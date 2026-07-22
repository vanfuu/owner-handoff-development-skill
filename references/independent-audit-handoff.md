# Independent Audit, Candidate Acceptance, And Handoff

Use this reference when the Owner must inspect a fixed repository snapshot or candidate package without drifting into implementation. The output is a source-aware audit package, an explicit gate decision, and a copy-ready handoff—not a patch.

## 1. Freeze The Contract

Record before inspection:

- objective and decision the audit must support
- authoritative source root and exact output root
- allowed reads and writes
- forbidden actions, including source edits, installs, formal imports, pushes, or release changes
- phase gates and materials that must remain unread until findings are frozen
- required deliverables, severity vocabulary, gate vocabulary, and stopping condition

Treat placeholder or permission-gate tasks literally. If the user asks for one exact acknowledgement before audit access, do only that.

## 2. Prove Snapshot Identity

Capture the baseline before substantive review:

- repository and worktree paths
- `git worktree list --porcelain`
- `git rev-parse HEAD`
- branch or detached-HEAD state
- `git status --porcelain` and `git diff --exit-code`
- Git common directory and the relationship between audit worktree and formal repository
- relevant tool/runtime versions and any reused environment path

Bind every conclusion to this snapshot. Recheck mutable state before release or gate decisions.

## 3. Build Coverage And Evidence Ledgers

Create a coverage matrix from the governing requirements, ACRs, ADRs, schemas, contracts, security boundaries, lifecycle/state machines, tests, packaging, and release evidence. For each area, record inspected sources, executed checks, evidence location, conclusion, and remaining limitation.

Keep raw command output when it materially supports a finding. Record command, working directory, exit code, timestamp, and output path. Use relative paths in final artifacts and scan for credentials, private absolute paths, raw logs, and unrelated generated files.

## 4. Inspect Independently

Inspect source and current-source behavior before trusting generated reports, fixtures, prebuilt binaries, implementer summaries, or self-checks. Treat those as evidence, not proof.

For each material finding, include:

- stable ID and severity
- affected requirement or boundary
- exact file and line evidence, or candidate field/path evidence
- reproduction, failed test, command evidence, or strong logic proof for HIGH/CRITICAL findings
- actual impact and confidence
- classification: `confirmed`, `partially_confirmed`, or `hypothesis`
- smallest viable remediation direction, kept separate from the audit result

For candidate acceptance, independently validate syntax/schema, allowed enum values, candidate-only or no-formal-write flags, provenance, status transitions, and path/privacy hygiene. Apply minor Owner corrections only when the task explicitly permits them; otherwise return rework.

## 5. Verify Without Weakening Boundaries

Run project checks in the audited snapshot when permitted. A timeout is inconclusive: rerun with a controlled longer limit or record it as unverified. If installs are forbidden, prefer no-install inspection such as source import checks, `git archive`, wheel/sdist content validation, static contract checks, and existing-environment tests.

Do not claim current-source E2E coverage from fixtures or prebuilt artifacts. Label unavailable GUI, external service, model, platform, authentication, or hardware checks as `not verified` with the reason.

## 6. Decide The Gate

State the gate separately from finding severity:

- `allowed`: required evidence passed and no blocking condition remains
- `allowed_with_limitations`: known limitations are explicit and do not invalidate the decision
- `blocked`: one or more named conditions prevent advancement
- `awaiting_manual_verification`: release depends on a real UI, hardware, authentication, or other user-observed checklist

Never advance a gate from generated evidence alone when the contract requires observed manual evidence. Do not change a release state, formal dataset, or installed product unless explicitly authorized.

## 7. Close The Package

Use the smallest artifact set that supports the decision.

For a candidate acceptance review, prefer:

- Owner audit note
- accepted or rejected candidate package
- verification commands/results
- boundary and privacy scan result
- main-thread handoff paragraph

For a full repository or architecture audit, prefer:

- scope and baseline evidence
- executive summary and full audit
- findings index in human- and machine-readable form
- coverage/traceability and risk matrices
- verification evidence and explicit limitations
- remediation roadmap kept separate from findings
- readiness/release gate decision
- completion status and copy-ready Owner handoff
- manifest of formal deliverables

Generate the manifest last. Include each formal deliverable's relative path, SHA-256, and size; exclude the manifest itself, temporary/cache files, and raw private paths. Re-run manifest validation after final edits.

## 8. Final Integrity Check

Before claiming closure:

1. Recheck audit worktree and formal repository identity and cleanliness.
2. Confirm all required artifacts exist and no forbidden files were written.
3. Validate machine-readable artifacts and the manifest.
4. Confirm every HIGH/CRITICAL finding has sufficient evidence.
5. Confirm limitations and unverified checks are explicit.
6. Confirm the gate decision names every blocking or manual condition.
7. Provide a concise, copy-ready handoff containing snapshot, verdict, delivery directory, next allowed action, and prohibited advancement.

Stop only when the evidence package is internally consistent, the manifest matches the final files, the source boundary remains intact, and the next conversation can act without reconstructing hidden context.
