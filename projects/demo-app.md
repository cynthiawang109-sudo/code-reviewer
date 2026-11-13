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

- 2026-11-12 — demo-app PR #2 merged: TF-101 is closed, and the in-memory storage risk and the /health accepted-risk note below are retired.

- 2026-11-12 — demo-app PR #3 (TF-102, board status pagination): review via the review-pr skill, verdict **request changes**; the should-fix and both reviewer corrections resolved in PR follow-ups:
  - The new `(status, id)` index was created lazily inside store operations; deployment.md §4 requires migrations to run before the service starts. Fixed: schema applies only via `main.migrate()` / `scripts/migrate.py` (pre-start, idempotent, tested against a populated database); /health now reports degraded against an unmigrated database instead of migrating mid-request.
  - The PR description claimed api-conventions.md already showed a `status` example; it did not. The filter is an additive extension, and the conventions doc now documents it (taskflow-api-docs, same change).
  - The recorded pagination-bounds item from PR #2 is addressed by clamping (`cursor >= 0`, `1 <= limit <= 200`).
  - Pre-existing, recorded but not fixed in PR #3: malformed pagination input (`?limit=abc`) returns FastAPI's `detail` envelope instead of the contract's `error` envelope. Needs a central `RequestValidationError` handler in a future change. **Resolved by PR #5 (TF-105).**

- 2026-11-12 — demo-app PR #3 merged: TF-102 is closed.

- PR #4 / TF-103 reviewed: **request changes** — sanitize sender diagnostics; serialize concurrent work and deduplication; add retry backoff, CLI attempt logging, and ledger recovery guidance.
  - Validation: 22 tests passed; focused reproductions exposed PII leakage, duplicate concurrent deliveries, lost attempt accounting, and missing CLI attempt logs. No new risks accepted.
  - All findings addressed in 9c545a0 (error codes only, never exception messages; SQL-side attempt increments and OS-locked outbox dedupe; bounded exponential backoff with an injected sleeper; CLI logs to stderr; runbook reset steps). 26 tests pass; awaiting a human merge decision.

- 2026-11-12 — demo-app PR #4 merged: TF-103 is closed. All four tickets (TF-101…TF-104) are now done.

- 2026-11-12 — PR #5 / TF-105 reviewed: **approve**; central request-validation handler resolves the framework `detail` envelope issue recorded after PR #3.
  - API contracts fetched via doc-search; 31 tests passed. No new accepted risks; awaiting merge.

- 2026-11-12 — demo-app PR #5 merged: TF-105 is closed.

- PR #6 reviewed: **request changes** — CI build job must build a container to satisfy deployment.md; compile/import checks alone are insufficient release evidence.
  - Validation: contracts fetched through doc-search; 31 tests, Ruff, and compile/import checks passed. No new risks accepted.
  - Addressed in the follow-up commit: Dockerfile + .dockerignore added; the build job now docker-builds the image and smoke-tests the running container's /health (CI run 43349313187, all three jobs green; smoke test received {"status":"ok"}). Awaiting a human merge decision.

- 2026-11-12 — demo-app PR #6 merged, and **v1.1.0 released**: release-check verdict GO (all seven gate items) for candidate 7abb11f; rollback tag `pre-v1.1.0` (3d7a37b, caveat recorded in issue #7); on-call Cynthia Wang; GitHub Release published and issue #7 closed.

- 2026-11-12 — PR #8 / TF-106 (comments) reviewed: **request changes**; both should-fixes resolved in follow-ups:
  - The new `comments` table had no PII story; data-model.md's reviewer rule requires one before a migration is approved. Fixed in taskflow-api-docs 715f6fd (bodies are fictional-data-only free text, never echoed in errors or logs; append-only retention stated).
  - `ping()` probed only `tasks`, so a pre-TF-106 database reported healthy while comments routes returned 503. Fixed in 4117668: ping probes both tables, and a legacy-schema upgrade test pins degraded-before / healthy-after migrate().
  - Validation: contracts fetched via doc-search; 54 tests passed, Ruff clean. Pre-existing, recorded but not fixed in PR #8: `TaskStore` connections rely on context-manager cleanup without explicit close (the store-wide pattern; caused a Windows temp-file cleanup error in a review reproduction).
  - Awaiting a human merge decision.

- 2026-11-12 — demo-app PR #8 merged: TF-106 is closed.

- 2026-11-12 — PR #9 / TF-107 (spec conformance) reviewed: **approve**, no findings.
  - Validation: contracts fetched via doc-search; 75 tests passed including 21 conformance cases; Ruff clean. The PR's own Actions run was the first live exercise of the new `spec` job — all four jobs (pytest, lint, build, spec) green.
  - Awaiting a human merge decision.

- 2026-11-12 — demo-app PR #9 merged: TF-107 is closed.

- 2026-11-12 — demo-app **v1.2.0 released**: release-check verdict GO (all seven gates) for candidate bc8e1bb; rollback tag `pre-v1.2.0` (7abb11f); on-call Cynthia Wang; GitHub Release published and issue #10 closed. Scope: TF-106 comments + TF-107 spec conformance; CHANGELOG.md introduced with this release.

## Accepted risks

- In-memory storage loses tasks on restart. Accepted: demo data only,
  documented in the repo README. Do not re-raise. Retired by PR #2's SQLite-backed store (takes effect on merge).

- /health degraded branch (503 + checks) not implemented. Accepted for now: demo-app has no hard dependencies yet (in-memory store), so no dependency can be down; the dependency check and the 503 branch must land together with the first real dependency. Found by the M1 cross-repo acceptance test, 2026-11-12. Update 2026-11-12: the TaskStore seam and the 503 contract behavior landed in demo-app PR #1 (reviewed, fixes applied, awaiting a human merge decision); TF-101's real dependency landed in PR #2 (SQLite store, reviewed, fixes applied); the ticket closes when PR #2 merges.
