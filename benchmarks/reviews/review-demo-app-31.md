approve

- **Blocker:** None.
- **Should-fix:** None.
- **Nit:** None.

### Contract compliance

Fetched [api-conventions.md](C:/PROJECTS/ai-workspace-kit/projects/taskflow-api-docs/api-conventions.md) through doc-search `get_doc`. Its Pagination clause requires: “Out-of-range `cursor`/`limit` values are clamped, never an error”.

In `main.py`, `_clamp_pagination()` preserves the existing expressions exactly: `cursor >= 0` and `1 <= limit <= 200`. Default limit 50, status filtering, and response shape remain unchanged.

Tests are unchanged; existing pagination coverage exercises the extracted behavior. At PR head `94e5aed`, 88 tests passed across two runs, including 21 conformance tests rerun with `TASKFLOW_SPEC_PATH` configured. Ruff passed.

### Pre-existing issues (not introduced by this PR)

No additional issues identified. Recorded accepted risks are not re-raised; the earlier pagination-bounds issue remains resolved.

### Review state update

Proposed bullet for `projects/code-reviewer/projects/demo-app.md`:

- 2026-11-13 — PR #31 reviewed: **approve**, no findings. Pagination helper preserves contract-compliant clamping; contract fetched via doc-search. Validation: 88 tests passed, Ruff clean. No new accepted risks.
