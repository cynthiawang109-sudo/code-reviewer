# taskflow-docs — review state

Thin state file: established facts, previously flagged issues, and
accepted risks for the system documentation repo. The facts below are
the ground truth the review-docs skill checks against; if a fact here
is wrong, fix it here first — reviews inherit it.

## Established facts

- Stack: `web-app` Next.js / TypeScript; `api-service` FastAPI /
  Python (the demo implementation is `demo-app`); `worker` Python /
  RQ; PostgreSQL 16; Redis 7.
- Worker jobs retry with exponential backoff and land in a dead-letter
  list after exactly 5 attempts.
- `api-service` is the only component allowed to write to PostgreSQL.
  `worker` reads the read-replica and never calls the public API of
  `api-service`.
- Board presence runs over Redis pub/sub, is ephemeral, and is never
  persisted.
- Email addresses are the only PII in the system and live only in the
  `users` table; logs, metrics, and traces carry user IDs only. PII in
  logs is a severity-1 incident.
- Environments are `dev`, `staging`, `prod`. Staging is an anonymized
  snapshot of prod, refreshed monthly, and the refresh is performed
  as a restore drill. Promotion to prod is a manual pipeline approval,
  never automatic.
- Database migrations run before the new container starts and follow
  expand → migrate → contract; a column drop ships in two releases.
- Anonymization for staging rewrites only `users.email` — it is the
  only PII column, so it is the only column the anonymizer touches.
- The demo implementation's store is a local SQLite file
  (`TASKFLOW_DB_PATH`). Production procedures describe PostgreSQL;
  SQLite appears only where a passage is explicitly about the demo.

## Previously flagged

- 2026-11-12 — whole-corpus consistency audit (two passes over all
  files, run manually before this skill existed): 6 findings, all
  fixed in 6a5d2e3:
  - `environments.md` said anonymization "re-keys display names" while
    also saying email is the only column the anonymizer touches.
  - `incident-runbook.md`'s production 5xx procedure described the
    demo's local SQLite store without qualification (pre-existing;
    step 3 now separates production PostgreSQL from the demo store).
  - `authentication.md` called `/health` the only unauthenticated
    endpoint; login and password-reset endpoints are unauthenticated
    too, and the text now says so.
  - `environments.md` allowed direct DB writes in `dev`, against the
    sole-writer rule; dev writes now go through the local api-service.

## Accepted risks

- None recorded yet.
