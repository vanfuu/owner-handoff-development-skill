# Implementer Task Template

Use this template for tasks executed by Claude, DeepSeek, or another implementation agent in a safety copy.

## File Name

Prefer a sortable ID and concise slug:

```text
<handoff_root>/tasks/IMPLEMENTER-TASK-001-short-slug.md
```

For an existing convention, keep that convention, for example `CLAUDE-TASK-085-*`.

## Task File Template

```markdown
# IMPLEMENTER-TASK-001: Short Title

## Read First

- <handoff_root>/MEMORY_BRIDGE_PROTOCOL.md
- <handoff_root>/CURRENT_STATE.md
- <formal_repo>/README.md
- <formal_repo>/docs/... relevant specs ...

## Context

Explain the product/architecture reason for this task and what previous task it builds on.

## Goal

State the concrete outcome in one paragraph.

## Allowed Scope

- List files or modules that may be changed.
- Prefer narrow scope.

## Forbidden Scope

- Do not modify <formal_repo>.
- Do not commit, push, open PRs, or call external services.
- Do not write secrets, tokens, real .env files, raw private logs, or credentials.
- Do not introduce unrelated refactors or future-phase runtime features.
- Do not change public contracts unless this task explicitly requires it.

## Required Implementation

- Itemize required behavior.
- Include CLI/API contracts, schema changes, docs, tests, and error handling.

## Acceptance Criteria

- Observable behavior that must be true.
- Expected files or outputs.
- Backward compatibility requirements.

## Required Verification

Record exact commands and results in verification.md.

```powershell
.\.venv\Scripts\python.exe -m ruff check .
.\.venv\Scripts\python.exe -m pytest <focused tests>
.\.venv\Scripts\python.exe -m pytest
git diff --check
```

Adjust commands to the project.

## Delivery

Place delivery in:

```text
<handoff_root>/outgoing-from-implementer/IMPLEMENTER-TASK-001/
```

Required files:

- summary.md
- changed-files.txt
- verification.md
- patch.diff

## Rework Triggers

Return a rework report instead of forcing a patch if:

- The requested architecture appears wrong.
- The safe copy is too stale to patch cleanly.
- Tests fail and the fix requires broad redesign.
- The task requires secrets, external services, destructive actions, or production data.
- The implementation would exceed the allowed scope.
```

## Copyable Instruction Template

Paste this in the user chat after creating the task file:

```text
请读取并执行这个任务文件：

<handoff_root>\tasks\IMPLEMENTER-TASK-001-short-slug.md

严格遵守任务要求：
1. 只修改安全副本：<safe_copy>
2. 不要修改正式项目：<formal_repo>
3. 不要提交 git commit，不要 push，不要创建 PR
4. 不要执行真实外部服务、云同步、API key 写入、生产数据读取或破坏性操作
5. 完成后把交付物放到：

<handoff_root>\outgoing-from-implementer\IMPLEMENTER-TASK-001\

必须包含：
- summary.md
- changed-files.txt
- verification.md
- patch.diff

请先阅读任务文件列出的 Read First 文件，再开始实现。
如果遇到架构方向错误、大面积测试失败、安全风险或安全副本基线落后，请输出返工报告，不要硬改。
```

