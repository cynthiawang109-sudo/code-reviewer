request changes

- **Blocker:** None.
- **Should-fix — [main.py:172](/C:/PROJECTS/ai-workspace-kit/projects/demo-app/main.py:172): terminal pagination never signals completion.** The doc-search-fetched [api-conventions.md, “Pagination”](/C:/PROJECTS/ai-workspace-kit/projects/taskflow-api-docs/api-conventions.md) requires: “Responses include `next_cursor` (null at the end).” The change returns the last ID even when no further rows exist, then repeats the incoming cursor on empty pages. Clients that stop on null can loop indefinitely. This affects both filtered and unfiltered task listings. **Fix:** restore `items[-1]["id"] if len(rows) > limit else None`; add coverage for empty results and cursors beyond the last task.
- **Nit:** None.

### Contract compliance

Pagination violates the fetched terminal-cursor requirement and [review-standards.md, “Always check,” rule 1](/C:/PROJECTS/ai-workspace-kit/projects/code-reviewer/review-standards.md). Status filtering and bounds clamping remain unchanged.

The PR changes no tests. Running the existing suite with the exact one-line change applied in memory produced **3 failures, 85 passes**. The failures cover unfiltered pagination, status-filtered pagination, and a terminal page after bounds clamping.

### Pre-existing issues (not introduced by this PR)

The recorded connection-cleanup issue remains outside this change. No accepted risks are re-raised.

### Review state update

Proposed bullet for `projects/code-reviewer/projects/demo-app.md`:

- PR #25 reviewed: **request changes** — restore null terminal cursors for task listings per api-conventions.md §Pagination. Exact diff tested in memory: 3 failed, 85 passed; no new accepted risks.
