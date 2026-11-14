request changes

### Findings

**Blocker:** None.

**Should-fix:**

1. **`main.py:309` — Dependency failure now reports HTTP 200.** The doc-search-fetched [API conventions, “Health checks”](projects/taskflow-api-docs/api-conventions.md#health-checks) require “`503`” when a hard dependency is unreachable. Returning 200 can keep an unavailable instance receiving traffic. This also violates review standard §5, **Error honesty**. **Fix:** restore `status_code=503`.

2. **`main.py:312` — Successful health response exposes the service version.** The fetched [health contract](projects/taskflow-api-docs/api-conventions.md#health-checks) requires exactly `{"status":"ok"}` and says the endpoint “must not leak version, host, or dependency details beyond the check names.” **Fix:** restore `return {"status": "ok"}`.

**Nit:** None.

### Contract compliance

Both changed lines violate the fetched health contract. The degraded response body remains compliant; its HTTP status does not. The successful response adds an explicitly prohibited field.

The PR changes no tests. Running the five existing health tests against PR commit `4916b73` produced **five failures**, confirming both regressions. The full suite was not run.

### Pre-existing issues (not introduced by this PR)

The state file records missing explicit SQLite connection closure from PR #8; it is outside this diff. No additional pre-existing issues identified. Neither finding above is an accepted risk: the historical missing-degraded-health exception was retired after SQLite support landed.

### Review state update

Proposed bullet for `projects/code-reviewer/projects/demo-app.md`:

- PR #23 reviewed: **request changes** — restore degraded HTTP 503 and remove the successful response’s version field; both violate the health contract fetched through doc-search. Five existing health tests fail on `4916b73`. No new risks accepted.
