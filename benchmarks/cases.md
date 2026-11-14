# Benchmark answer key

Fixed in advance on 2026-11-13, before any review ran; held outside the repos
until scoring was complete. Planted in cynthiawang109-sudo/demo-app.

| PR | Case | Planted defect / clean change | Contract |
|----|------|-------------------------------|----------|
| #22 | D1 | Access log records the raw request path instead of the route template | PII/user content in logs is severity-1; observability.md requires the route template or `<unmatched>` |
| #23 | D2 | /health adds a "version" field; degraded returns HTTP 200 instead of 503 | Health contract: 200 `{"status":"ok"}` only; 503 when degraded; no version details |
| #24 | D3 | 404 message reworded ("does not exist" → "not found") | Invalid case: the shipped message already contained the id and the contract makes wording non-normative — see RESULTS.md |
| #25 | D4 | GET /v1/tasks next_cursor never null (set on the final page too) | next_cursor is null at the end of the list |
| #26 | D5 | Comment revision may supersede a non-head revision (201 instead of 409) | Chain-head rule; stale supersede returns 409 `conflict` |
| #27 | D6 | POST /v1/tasks accepts an arbitrary "status" from the request body | Task status ∈ todo/doing/done; violations return 422 `invalid_status` |
| #28 | D7 | Digest dead-letters after 3 attempts instead of 5 | Jobs dead-letter after exactly 5 attempts |
| #29 | D8 | TaskStore.ping() probes only the tasks table | The health probe must cover the comments table too (demo-app PR #8 lesson) |
| #30 | C1 | Clean: tests only for existing behaviour (97 tests pass) | Should pass |
| #31 | C2 | Clean: behaviour-identical refactor, pagination clamping helper (88 pass) | Should pass |
| #32 | C3 | Clean: httpx dev dependency 0.27 → 0.27.2 (88 pass) | Should pass |

Branches: bench-d1-raw-path-log, bench-d2-health-version, bench-d3-echo-id,
bench-d4-cursor, bench-d5-supersede-any, bench-d6-status-body,
bench-d7-digest-retries, bench-d8-ping-tasks-only, bench-c1-more-tests,
bench-c2-clamp-helper, bench-c3-dev-dep. All closed unmerged and deleted
after scoring.
