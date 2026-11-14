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

## TypeScript and Next.js reviews

1. **Type safety** — strict mode stays on; explicit `any` and `any` leaking
   through API boundaries need justification. Validate and type API responses
   at the client boundary; do not trust response bodies blindly.
2. **API contract discipline** — branch on the error envelope's `code`,
   never on `message` wording. Cursor pagination follows the published
   contract in `taskflow-api-docs`; no invented endpoints or client-side
   faking of operations the API does not offer (such as status changes or
   deletes).
3. **Rendering boundaries** — secrets and non-public environment variables
   never reach client components. Browser code may reference only
   `NEXT_PUBLIC_*` values; check that those values contain nothing sensitive.
   Server/client component boundaries are deliberate.
4. **Data fetching** — handle loading, empty, and error states. Slow or
   sleeping backends (cold starts) get an explicit pending state, not an
   endless spinner or a false error.
5. **Accessibility & semantics** — interactive elements are real buttons or
   links with labels; status is not conveyed by colour alone.
6. **Tests** — client/API-mapping logic and non-trivial components carry
   tests with the network mocked. Tests must not call live services.
