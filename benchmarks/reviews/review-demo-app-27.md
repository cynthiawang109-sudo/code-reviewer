request changes

- **Blocker:** None.
- **Should-fix — `main.py:335`, `create_task`:** Removing the guard allows arbitrary status strings to be persisted. The doc-search-fetched [data-model.md](C:/PROJECTS/ai-workspace-kit/projects/taskflow-api-docs/data-model.md) requires `status ∈ todo / doing / done`; [api-conventions.md § Errors](C:/PROJECTS/ai-workspace-kit/projects/taskflow-api-docs/api-conventions.md) requires “422 validation.” With this diff, posting `{"title":"fictional task","status":"bogus"}` returns **201**. Restore the guard and its `422 invalid_status` response. Valid initial statuses and the omitted-status default already work before this change.
- **Nit:** None.

## Contract compliance

Both contracts above were fetched through doc-search `get_doc`. The change violates the task-status invariant and accepts invalid input instead of returning a validation error. The data model explicitly exempts the demo from implementing `completed_at`; no finding applies there.

Tests are unchanged. Running the suite against a temporary copy with the supplied diff applied produced **86 passed, 2 failed**: `test_create_task_rejects_invalid_status` and `test_documented_errors[create_task-invalid_status]`, both observing 201 instead of 422.

## Pre-existing issues (not introduced by this PR)

No additional findings. Previously recorded risks are not re-raised.

## Review state update

Proposed bullet for `projects/code-reviewer/projects/demo-app.md`:

- PR #27 reviewed: **request changes** — removing create-task validation permits invalid persisted statuses; restore `422 invalid_status`. Contracts fetched via doc-search; patched-copy suite: 86 passed, 2 failed. No new risks accepted.
