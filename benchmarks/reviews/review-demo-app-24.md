request changes

- **Blocker:** None.
- **Should-fix — `main.py:345` and `tests/test_main.py:186`:** The wording change breaks `test_get_missing_task_uses_contract_error_shape`, which still expects `"task 999999 does not exist"`. The [review skill, step 4](C:/PROJECTS/ai-workspace-kit/projects/code-reviewer/skills/review-pr/SKILL.md) requires checking tests for changed behavior. Update the expected message to `"task 999999 not found"`, preserving the envelope, code, and status assertions.
- **Nit:** None.

### Contract compliance

Fetched [api-conventions.md, “Errors”](C:/PROJECTS/ai-workspace-kit/projects/taskflow-api-docs/api-conventions.md) through doc-search `get_doc`: “`message` is human-facing and may change. Clients must branch on `code`, never on `message`.”

All four changes comply: they preserve HTTP 404, `task_not_found`, and the top-level `error` envelope. Both versions already include the task ID; this PR changes wording.

Validation at PR head `fbf69a6`: **1 failed, 66 passed, 21 skipped**. The skipped conformance tests could not locate the sibling OpenAPI specification in the isolated checkout. No tests were updated.

### Pre-existing issues (not introduced by this PR)

No additional issues identified within this diff’s scope. Recorded accepted risks are not re-raised.

### Review state update

Proposed bullet for `projects/code-reviewer/projects/demo-app.md`:

- PR #24 reviewed: **request changes** — error wording complies with the fetched API contract, but the missing-task test still expects the previous message; update its assertion. Validation: 1 failed, 66 passed, 21 skipped. No new accepted risks.
