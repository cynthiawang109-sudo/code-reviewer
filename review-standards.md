# Review standards (global)

Small and org-wide on purpose. App-specific rules belong in
`projects/<app>.md`, not here.

## Always check

1. **Contract conformance** — endpoints, error shapes, and invariants match
   `taskflow-api-docs`. A deviation is a finding even if the code "works".
2. **Health & operability** — new services expose `/health` per contract;
   new failure modes are reflected in the runbook or flagged as missing.
3. **PII discipline** — logs and errors carry IDs, never raw emails or other
   PII (see `taskflow-docs/system-overview.md`).
4. **Data safety** — no hard deletes on soft-delete tables; migrations are
   backward-compatible (expand → migrate → contract).
5. **Error honesty** — no 200-with-error-body, no swallowed exceptions, no
   fallback defaults that hide a down dependency.

## Style of findings

- Severity first (`blocker / should-fix / nit`), each with the file, the
  rule it breaks, and a concrete fix.
- Cite the doc or standard behind every finding. "Feels wrong" is not a
  finding.
- Pre-existing problems in touched code are reported separately from issues
  the change introduces.

## Documentation changes

Pull requests in the documentation repos are reviewed with the
review-docs skill (`skills/review-docs/SKILL.md`): consistency with
the whole corpus and with the established facts recorded in
`projects/<repo>.md` takes the place of contract conformance. The
style of findings above applies unchanged.
