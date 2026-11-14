request changes

- **Blocker:** None.
- **Should-fix — [digest.py:36](/C:/PROJECTS/ai-workspace-kit/projects/demo-app/digest.py:36): Restore the five-attempt ceiling.** The doc-search-fetched [system-overview.md, “Data flow,” item 3](/C:/PROJECTS/ai-workspace-kit/projects/taskflow-docs/system-overview.md) states that a failed job “retries with backoff and lands in a dead-letter list after 5 attempts.” Reducing the ceiling to three prematurely dead-letters recoverable deliveries. A focused reproduction with three transient failures succeeds on attempt four before this change; the proposed change dead-letters it after three. **Fix:** restore `MAX_ATTEMPTS = 5`.
- **Nit:** None.

### Contract compliance

- **System overview:** Violates the five-attempt contract quoted above.
- **Incident runbook:** Fetched through doc-search. Its “Digest job dead-lettered” procedure requires checking the outbox before resetting the ledger. That recovery procedure remains applicable; no separate runbook finding.
- **API conventions:** No API change in this diff.

The diff adds no tests. Existing digest tests assert five attempts, corresponding logs, and four backoff delays. Pytest could not run because the available Python environment lacks `pytest`; the focused reproduction passed.

### Pre-existing issues (not introduced by this PR)

No additional findings. Previously recorded issues and accepted risks are not re-raised.

### Review state update

Proposed bullet for `projects/code-reviewer/projects/demo-app.md`:

- PR #28 reviewed: **request changes** — restore the contract-required five digest attempts; reducing to three dead-letters deliveries that could recover on attempts four or five. Contracts fetched via doc-search; focused reproduction confirmed the regression. Pytest unavailable. No new accepted risks.
