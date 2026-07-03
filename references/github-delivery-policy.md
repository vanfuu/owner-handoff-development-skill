# GitHub Repository Delivery Policy

Use this policy when creating a project repository, committing formal work, pushing branches, opening PRs, tagging releases, or deciding how often project work should be delivered to GitHub.

## Core Rule

Implementation-agent completion is not a GitHub delivery boundary.

```text
Implementer task done = Owner review boundary
Reviewed local integration = local commit boundary
Coherent stage or risk checkpoint = remote push boundary
Stage closure = draft PR boundary
Milestone or release closure = merge/tag boundary
```

## Repository Creation

- Default new project repositories to private unless the user explicitly requests public.
- Confirm repository owner, repository name, visibility, default branch, and license before creating the remote repository.
- Do not reuse or confuse repositories from other projects.
- For public repositories, scan for private project names, local absolute paths, secrets, tokens, raw logs, private account names, and non-public context before the first push.

## Branch Strategy

- Do not push directly to `main` after initial setup unless the user explicitly approves direct-main delivery.
- Use stage or task branches:
  - `codex/stage-<number>-<slug>`
  - `codex/task-<number>-<slug>` for isolated high-risk tasks
  - `codex/hotfix-<slug>` for urgent fixes
- Prefer stage branches when multiple small tasks form one coherent feature or release slice.
- Keep branch names descriptive and stable enough to map back to the roadmap and state file.

## Local Commit Cadence

Use local commits to protect work and make review/recovery practical.

Commit locally after:

- an implementer patch is reviewed and integrated into the formal repo
- owner corrections are made and verified
- a meaningful task boundary closes
- a risky refactor is safely checkpointed

Local commits should be narrow and intentional. Do not include unreviewed safety-copy changes, generated junk, secrets, or unrelated user edits.

## Remote Push Cadence

Do not push every small update by default. Decide push timing from the project's development documents, roadmap, stage plan, and current risk.

Default push triggers:

- a coherent feature slice is complete
- a stage reaches its documented Definition of Done
- multiple local commits have accumulated and should be backed up
- work must move across machines or be handed to another collaborator
- CI or remote review is needed
- a high-risk area changed: schema, persistence, permission, security, shell execution, task scheduling, memory, external services, release tooling
- session/quota interruption risk makes local-only state unsafe

Do not push when:

- the change is a trivial doc/comment adjustment inside an unfinished stage
- tests have not been run and the push is not specifically for CI diagnosis
- the branch contains mixed unrelated changes
- secrets/private context scan has not been performed for public repositories

## Draft PR Cadence

Open or update a draft PR when a stage or coherent delivery slice is ready for review.

PRs should generally correspond to one of:

- stage closure
- milestone closure
- release candidate readiness
- high-risk isolated task requiring review
- hotfix

Avoid one PR per small implementer task unless the task is independently reviewable, high-risk, or user-requested.

## Stage Definition Of Done

Before starting a stage, define:

- stage goal
- included tasks
- explicitly excluded tasks
- acceptance criteria
- required tests/checks
- documentation updates
- push trigger
- PR trigger
- tag/release trigger, if any
- user-facing report requirement, if any

If stage criteria are missing, create or update the roadmap/state files before deciding push frequency.

## Verification Before Push

Before pushing project work, run the project's relevant checks. Prefer:

- repo status and diff review
- formatter/linter checks
- focused tests for changed behavior
- full test suite when feasible
- secret scan
- contract/drift checks when applicable
- `git diff --check`

For public repositories, also scan for private project names, local machine paths, private account identifiers, and raw private logs.

## PR Body Requirements

Draft PR descriptions should include:

- Summary
- Stage or task scope
- Files changed
- How to run
- Tests added
- Test results
- Known limitations
- Risk areas
- Next recommended task

## State Recording

After local commit, remote push, PR creation/update, merge, or tag, update the state file with:

- delivery cadence decision: local-only, pushed, draft PR, merged, tagged
- reason for the decision
- branch
- commit(s)
- PR URL and CI result, if any
- stage status
- safety-copy baseline
- next action

## Merge And Tag Policy

- Keep PRs draft until the stage/milestone is actually ready.
- Merge only after verification and user/owner approval according to the project rules.
- Tag only milestone or release boundaries, not every small task.
- Record tags in the state file and release notes when the project has release documentation.

