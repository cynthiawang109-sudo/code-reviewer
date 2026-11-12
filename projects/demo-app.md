# demo-app — review state

Thin state file: only previously flagged issues and accepted risks live
here. System knowledge lives in the documentation repos.

## Previously flagged

- 2026-11-12 — demo-app PR #1 (TF-101, /health 503): first review, verdict **request changes**; both should-fixes resolved in PR follow-ups:
  - Error responses were wrapped in FastAPI `detail` instead of the contract's top-level `error` envelope (pre-existing in main.py; the PR's new tests had asserted the wrapped shape). Fixed via an `_error()` helper; tests now assert the exact envelope including `message`.
  - New `task_store: down` failure mode had no runbook guidance. Fixed in taskflow-docs `incident-runbook.md`.
  - /health 200/503 shapes verified compliant against api-conventions.md (fetched via doc-search during the review).

## Accepted risks

- In-memory storage loses tasks on restart. Accepted: demo data only,
  documented in the repo README. Do not re-raise.

- /health degraded branch (503 + checks) not implemented. Accepted for now: demo-app has no hard dependencies yet (in-memory store), so no dependency can be down; the dependency check and the 503 branch must land together with the first real dependency. Found by the M1 cross-repo acceptance test, 2026-11-12. Update 2026-11-12: the TaskStore seam and the 503 contract behavior landed in demo-app PR #1 (reviewed, fixes applied, awaiting a human merge decision); TF-101 itself stays open until the first real dependency lands, per its own completion condition.
