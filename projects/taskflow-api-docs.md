# taskflow-api-docs — review state

Thin state file: established facts, previously flagged issues, and
accepted risks for the API documentation repo. The facts below are
the ground truth the review-docs skill checks against; if a fact here
is wrong, fix it here first — reviews inherit it.

## Established facts

- Errors are JSON in the envelope
  `{ "error": { "code": "...", "message": "..." } }`. Clients branch
  on `code`, never on `message`. Never return 200 with an error body.
  The one exception to the envelope is the `GET /health` 503 body,
  which follows the health contract below.
- Error codes in use: `validation_error` (422; messages never echo
  submitted values), `invalid_status` (422, task status filter),
  `task_not_found` / `project_not_found` / `user_not_found` /
  `comment_not_found` (404), `email_already_registered` (409),
  `conflict` (409), `rate_limited` (429, honor `Retry-After`),
  `store_unavailable` (503, hard dependency unreachable),
  `internal_error` (500), `unauthorized` (401), `forbidden` (403).
- Pagination is cursor-based only (offset is not used): default limit
  50, max 200, `next_cursor` is null at the end, out-of-range
  cursor/limit values are clamped and never an error.
  `GET /v1/tasks` accepts a `status` filter (`todo` / `doing` /
  `done`); an unknown value is 422 `invalid_status`.
- Health contract (every service): `GET /health` returns 200
  `{ "status": "ok" }`, or 503
  `{ "status": "degraded", "checks": { "<dependency>": "down" } }`.
  It requires no authentication, is exempt from rate limiting, and
  leaks no version, host, or dependency detail beyond check names.
- Versioning is URL-prefixed major versions (`/v1/...`); a breaking
  change ships as a new major version.
- Data model: `users.email` is unique and stored lower-cased, and is
  the only PII column in the system. A project has exactly one owner;
  ownership transfer is an explicit audited action. `tasks.status` is
  one of `todo` / `doing` / `done`; transitioning to `done` sets
  `completed_at` in the same transaction, and reopening clears it.
  Comments are append-only; an edit is a new revision row carrying
  `supersedes_id`. Deletes are soft (`deleted_at`) on `projects` and
  `tasks`; the application never hard-deletes them.
- Rate limits: session token 600/min, API token 300/min, unauthenticated
  60/min per IP, login and password-reset 10/min per IP.
- Webhooks: delivered by `worker` under the standard job policy
  (backoff, dead-letter after 5 attempts); payloads carry IDs only;
  deliveries are signed HMAC-SHA256 (`X-TaskFlow-Signature`) and are
  at-least-once — receivers dedupe on the event `id`.

## Verified demo surface (checked against the running app, 2026-11-12)

- `demo-app` implements exactly: `GET /health`, `GET /v1/tasks`,
  `POST /v1/tasks` (201), `GET /v1/tasks/{task_id}`. There is no
  PATCH or DELETE, and no projects, users, or comments endpoints.
- The demo task shape is the reduced (`id`, `title`, `status`); list
  responses are `{ "items": [...], "next_cursor": <id|null> }` with an
  integer cursor. Production invariants (project ownership, soft
  deletes, `completed_at`) are NOT implemented by the demo store.
- The demo carries the worker's `digest_sends` ledger (`user_id`,
  `week`, `status`, `attempts`, `last_error`, `sent_at`); recipients
  are user IDs only, and `last_error` holds a sanitized error code
  (exception class name), never the exception message.
- The curated OpenAPI spec for the demo is `openapi.yaml` in this
  repo (generated from the app, then curated). GitBook republishes it
  as the interactive API reference.

## Previously flagged

- 2026-11-12 — whole-corpus consistency audit (two passes, run
  manually before this skill existed): findings touching this repo,
  all fixed:
  - `security.md` (taskflow-docs) required `validation_error` for all
    validation failures, conflicting with the explicit `invalid_status`
    contract; the specific code now wins where the catalog assigns
    one (fixed in taskflow-docs 6a5d2e3).
  - `errors.md` claimed every error response uses the envelope; the
    health 503 exception is now stated (a5b0052).
- 2026-11-12 — writing `endpoints.md` marked PATCH and DELETE on
  tasks as demo-implemented; they are not (see the verified demo
  surface above). Corrected in 4331e79, which also added
  `store_unavailable` to the error catalog — the code the demo
  actually returns when its store is down.

## Accepted risks

- None recorded yet.
