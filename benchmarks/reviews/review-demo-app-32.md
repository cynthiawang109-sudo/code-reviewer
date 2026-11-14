approve

- **Blocker:** None.
- **Should-fix:** None.
- **Nit:** None.

`requirements-dev.txt:2` raises HTTPX’s minimum from `0.27` to `0.27.2`; it continues to allow later releases. No tests change, and no new application behavior requires coverage. Locally, with HTTPX 0.27.2 installed, **88 tests passed** and Ruff passed.

### Contract compliance

Fetched `projects/taskflow-docs/deployment.md` through doc-search `get_doc`. Its **Release mechanics §1** states: “Merge to `main` triggers CI: tests, lint, container build.” The existing workflow retains all three jobs; this dependency change introduces no conflict. The container build was not run locally.

No endpoint, error, health, or data contract changes are introduced, so API contract documents are outside this diff’s scope.

### Pre-existing issues (not introduced by this PR)

The previously recorded SQLite connection-close concern remains outside scope. Accepted risks are not re-raised.

### Review state update

Proposed bullet for `projects/code-reviewer/projects/demo-app.md`:

- PR #32 reviewed: **approve**, no findings. HTTPX development minimum raised to 0.27.2; deployment contract fetched via doc-search; 88 tests passed with HTTPX 0.27.2, Ruff passed. No new accepted risks.
