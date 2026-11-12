# demo-app — review state

Thin state file: only previously flagged issues and accepted risks live
here. System knowledge lives in the documentation repos.

## Previously flagged

- (none yet — first review pending, milestone M3)

## Accepted risks

- In-memory storage loses tasks on restart. Accepted: demo data only,
  documented in the repo README. Do not re-raise.

- /health degraded branch (503 + checks) not implemented. Accepted for now: demo-app has no hard dependencies yet (in-memory store), so no dependency can be down; the dependency check and the 503 branch must land together with the first real dependency. Found by the M1 cross-repo acceptance test, 2026-11-12.
