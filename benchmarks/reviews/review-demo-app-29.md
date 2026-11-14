request changes

- **blocker:** None.
- **should-fix — `main.py:149`, `TaskStore.ping()`:** Restore `conn.execute("SELECT id FROM comments LIMIT 1")`. With a legacy database containing `tasks` but no `comments`, this change returns health 200 while comments requests fail. The fetched [API conventions, “Health checks”](projects/taskflow-api-docs/api-conventions.md) permit 200 only “when the service can serve traffic”; [review standard §1](projects/code-reviewer/review-standards.md) requires contract conformance. This reintroduces the defect fixed in PR #8.
- **nit:** None.

### Contract compliance

Fetched both documents through doc-search `get_doc`:

- **API conventions:** Health response shapes remain unchanged, but the healthy/degraded decision violates the clause above.
- **Incident runbook, “API returning 5xx across the board”:** Operators rely on `degraded` with `task_store: down` to diagnose store failures. The removed probe hides a missing comments schema from that signal.

**Validation:** No tests changed. Existing `test_health_degraded_until_comments_schema_is_migrated` passes on the baseline and fails with the proposed probe applied in memory: expected 503, received 200. Full suite not run.

### Pre-existing issues (not introduced by this PR)

The review state already records reliance on connection context managers without explicit close. This PR does not introduce it; no additional finding. Accepted risks are not re-raised.

### Review state update

Proposed bullet for `projects/code-reviewer/projects/demo-app.md`:

- PR #29 reviewed: **request changes** — removing the comments health probe reintroduces PR #8’s false-healthy legacy-schema defect. Restore both table probes; existing regression test passes on baseline and fails with the proposed change. Contracts fetched via doc-search; no new risks accepted.
