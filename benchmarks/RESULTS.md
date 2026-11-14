# review-pr benchmark: planted-defect evaluation

Date: 2026-11-13. Subject: the `review-pr` skill reviewing pull requests in demo-app.
Tracker: issue #1 in this repo; Jira TF-1.

## Method

- 11 pull requests were planted in demo-app (branches `bench-*`): 8 carrying one
  planted contract defect each, and 3 clean changes that should pass review.
- The answer key (`cases.md`) was fixed before any review ran and held outside
  the repos until scoring was complete, so the reviewer could not see it.
- Each PR went through the standard review-pr flow. The raw review drafts are
  preserved in `reviews/`; no review was posted to the planted PRs themselves.
- Scoring: **caught** = a blocker or should-fix finding names the planted
  defect; **partial** = only a nit or a vague mention; **missed** = approve, or
  findings that never mention it. A clean PR receiving any blocker or
  should-fix finding counts as a **false positive**.
- After scoring, the planted PRs were closed unmerged and their branches
  deleted.

## Results

| PR | Case | Planted change | Outcome |
|----|------|----------------|---------|
| demo-app#22 | D1 | Access log records the raw request path | **Caught** (blocker) |
| demo-app#23 | D2 | /health adds a version field; degraded returns 200 | **Caught** (2 should-fix, both halves) |
| demo-app#24 | D3 | 404 message reworded | **Invalid case** — see below |
| demo-app#25 | D4 | next_cursor never null on the final page | **Caught** (should-fix) |
| demo-app#26 | D5 | Comment revision may supersede a non-head revision | **Caught** (should-fix) |
| demo-app#27 | D6 | Task creation accepts an arbitrary status | **Caught** (should-fix) |
| demo-app#28 | D7 | Digest dead-letters after 3 attempts instead of 5 | **Caught** (should-fix) |
| demo-app#29 | D8 | Store health probe ignores the comments table | **Caught** (should-fix) |
| demo-app#30 | C1 | Clean: tests only | Approve, no findings (correct) |
| demo-app#31 | C2 | Clean: behaviour-identical refactor | Approve, no findings (correct) |
| demo-app#32 | C3 | Clean: dev dependency patch bump | Approve, no findings (correct) |

**Catch rate: 7/7 valid defect cases (100%). False positives: 0/3 clean cases.**

Every catch cited the governing contract fetched through doc-search; two
catches (D1, D8) were explicitly connected to the historical fixes they
reintroduced (demo-app PR #11 and PR #8) via the reviewer state file.

## The invalid case (D3, demo-app#24)

D3 assumed the 404 message must not contain the submitted task id. That
premise was wrong: the shipped message already contains the id
("task 999999 does not exist"), the existing test expects that text, and
api-conventions.md makes message wording non-normative ("clients must branch
on `code`, never on `message`"). The plant only reworded the message. The
reviewer judged it correctly — the wording complies, and it flagged the one
real problem the plant created (the stale test expectation). D3 is excluded
from the catch-rate denominator; the error was in case design, not in the
reviewer.

## Caveats

- Small set (7 valid defects, 3 clean), one review run per PR. Treat the
  rates as indicative, not precise.
- All defects are regressions against documented contracts the reviewer is
  explicitly designed — and state-equipped — to check. This measures
  contract-regression detection, not arbitrary bug-finding.
- PR titles described the changes plainly; a stealthier set might score
  lower.
- Extra-finding check: the only finding not corresponding to a planted
  defect was PR #24's stale-test should-fix, a genuine defect the plant
  itself introduced.
