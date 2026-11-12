# demo-app — review state

Thin state file: only previously flagged issues and accepted risks live
here. System knowledge lives in the documentation repos.

## Previously flagged

- 2026-11-12 — demo-app PR #1 (TF-101, /health 503): first review, verdict **request changes**; both should-fixes resolved in PR follow-ups:
  - Error responses were wrapped in FastAPI `detail` instead of the contract's top-level `error` envelope (pre-existing in main.py; the PR's new tests had asserted the wrapped shape). Fixed via an `_error()` helper; tests now assert the exact envelope including `message`.
  - New `task_store: down` failure mode had no runbook guidance. Fixed in taskflow-docs `incident-runbook.md`.
  - /health 200/503 shapes verified compliant against api-conventions.md (fetched via doc-search during the review).

- 2026-11-12 — demo-app PR #2 (TF-101, SQLite store): review via the review-pr skill, verdict **request changes**; all three should-fixes resolved in PR follow-ups:
  - `ping()` used `SELECT 1`, which passes against a corrupt database file. Fixed: ping probes the tasks table; corrupt-file health test added.
  - Task routes let `sqlite3.Error` escape as FastAPI's default 500. Fixed: an exception handler returns the contract envelope (503 `store_unavailable`); all three routes tested against a down store.
  - The new persistent table had no PII story. Fixed: demo-table PII note added to taskflow-api-docs `data-model.md`.
  - Pre-existing, recorded but not fixed in PR #2: `list_tasks()` lacks lower bounds for `cursor`/`limit`.

## Accepted risks

- In-memory storage loses tasks on restart. Accepted: demo data only,
  documented in the repo README. Do not re-raise. Retired by PR #2's SQLite-backed store (takes effect on merge).

- /health degraded branch (503 + checks) not implemented. Accepted for now: demo-app has no hard dependencies yet (in-memory store), so no dependency can be down; the dependency check and the 503 branch must land together with the first real dependency. Found by the M1 cross-repo acceptance test, 2026-11-12. Update 2026-11-12: the TaskStore seam and the 503 contract behavior landed in demo-app PR #1 (reviewed, fixes applied, awaiting a human merge decision); TF-101's real dependency landed in PR #2 (SQLite store, reviewed, fixes applied); the ticket closes when PR #2 merges.
