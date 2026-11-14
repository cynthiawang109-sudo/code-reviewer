request changes

### Findings

- **Blocker — [main.py:59](/C:/PROJECTS/ai-workspace-kit/projects/demo-app/main.py:59): raw paths expose PII in access logs.** The doc-search-fetched [observability contract](/C:/PROJECTS/ai-workspace-kit/projects/taskflow-docs/observability.md), “Demo implementation note,” requires “the logged path is the matched route template (or `<unmatched>`), never the raw path.” Logging `scope["path"]` records an email supplied in `/v1/tasks/fictional-person@example.invalid` or `/unknown/fictional-person@example.invalid`, even when the response is 422 or 404. This also violates review standard §3, PII discipline. **Fix:** restore `getattr(scope.get("route"), "path", "<unmatched>")`; use `request_id` to trace individual requests. Keep the existing privacy regression assertions.
- **Should-fix:** none.
- **Nit:** none.

### Contract compliance

- **Observability:** violates the explicit path-sanitization requirement and reintroduces the leak resolved in PR #11.
- **System overview:** fetched “Boundaries and rules” states “logs must use user IDs, never raw emails”; raw paths violate this rule.
- **API conventions:** fetched via doc-search; no endpoint, error-envelope, pagination, or health-contract change is introduced.

**Validation:** ran the suite with the exact one-line change applied in memory, leaving source files unchanged: **83 passed, 5 failed**. All failures concern path logging, including both privacy regression tests. The PR changes no tests.

### Pre-existing issues (not introduced by this PR)

No additional issues identified in scope. The recorded SQLite connection-cleanup issue remains separate; accepted risks are not re-raised.

### Review state update

Proposed bullet for `projects/code-reviewer/projects/demo-app.md`:

- PR #22 reviewed: **request changes** — blocker: raw access-log paths reintroduce PR #11’s resolved PII leak and violate observability.md. Restore route templates / `<unmatched>`. Contracts fetched via doc-search; exact diff tested in memory: 83 passed, 5 failed. No new risks accepted.
