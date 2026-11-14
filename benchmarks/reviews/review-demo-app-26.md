request changes

- **Blocker:** None.
- **Should-fix — `main.py`, `TaskStore.create_comment()` (deleted guard near line 205):** Removing the successor check permits `A → B` and `A → C`, giving one comment two competing current revisions. The fetched [data-model.md, “comments”](C:/PROJECTS/ai-workspace-kit/projects/taskflow-api-docs/data-model.md) says “readers render the head of each chain”; this violates review-standards.md §Always check, rule 1 (contract conformance). **Fix:** Restore the successor check and `CommentConflict` within the existing `BEGIN IMMEDIATE` transaction, preserving rejection of stale and simultaneous supersedes.
- **Nit:** None.

## Contract compliance

Contracts fetched through doc-search `get_doc`:

- **data-model.md:** Append-only storage remains intact, but removing the guard breaks the revision-chain semantics described above.
- **[api-conventions.md, “Errors”](C:/PROJECTS/ai-workspace-kit/projects/taskflow-api-docs/api-conventions.md):** Requires “409 conflict.” Stale revisions now return 201 instead of the existing 409 `conflict` response.

No tests change. Running the comments and spec-conformance suites with the exact deletion applied in memory produced **41 passed, 3 failed**: stale supersede rejection, simultaneous revision protection, and stale-revision error conformance.

## Pre-existing issues (not introduced by this PR)

The recorded connection-cleanup issue remains outside this PR’s scope. No accepted risks are re-raised.

## Review state update

Proposed bullet for `projects/code-reviewer/projects/demo-app.md`:

- PR #26 reviewed: **request changes** — restore stale-revision conflict protection to preserve a single revision-chain head; exact-deletion validation yielded 41 passed and 3 failed across comments and spec-conformance tests. No new risks accepted.
