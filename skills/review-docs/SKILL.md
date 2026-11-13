---
name: review-docs
description: Review a documentation pull request in taskflow-docs or taskflow-api-docs for consistency — contradictions with the rest of the documentation corpus, with the established facts recorded for the repo, broken cross-references, and index drift. Use when asked to review a docs PR, audit documentation changes, or check docs for contradictions.
---

# Review a documentation pull request

You are acting as this workspace's code-reviewer, in documentation mode.
This skill turns the workspace's manual consistency audits into a
standing review: a docs change is checked against the *whole* corpus,
not just the files it touches, because a contradiction can hide in any
document.

## Inputs

- A PR reference in `taskflow-docs` or `taskflow-api-docs`:
  `<owner>/<repo>#<number>` or a PR URL.
- A synced workspace (if `projects/` looks stale, run the workspace
  root sync script first). The corpus is read from disk:
  `projects/taskflow-docs/` and `projects/taskflow-api-docs/`.

## Procedure

1. **Standards, facts, and state.** Read
   `projects/code-reviewer/review-standards.md` (for the style of
   findings) and the repo's state file
   `projects/code-reviewer/projects/<repo>.md`. Its **Established
   facts** are ground truth for the review; its **Previously flagged**
   items that are marked fixed, and its **Accepted risks**, must NOT
   be re-raised.
2. **The change.** Fetch the PR with `gh pr view <n> --repo
   <owner>/<repo>` and its diff with `gh pr diff <n> --repo
   <owner>/<repo>`.
3. **The corpus.** Read every Markdown file in both documentation
   repos (including `adr/`). Documentation is small on purpose; a
   partial read is how contradictions slip through.
4. **Check the diff** for:
   - **Contradictions** — a factual claim added or changed by the PR
     that conflicts with the corpus or the established facts (attempt
     counts, status codes, envelope shapes, pagination numbers, table
     invariants, PII rules, environment rules, stack facts). Quote
     both sides, with files.
   - **Self-contradictions** — the PR's own text disagreeing with
     itself.
   - **Broken cross-references** — links or mentions of files,
     sections, or headings that do not exist in the corpus.
   - **Index drift** — files the PR adds, removes, or renames must be
     reflected in that repo's `SUMMARY.md` and README contents table,
     and vice versa.
   - **Demo claims** — statements about what the demo implementation
     does, checked against the verified demo surface recorded in
     `projects/taskflow-api-docs.md`.
   A claim that is merely *more detailed* than another document is
   not a contradiction. Detail differences are not findings.
5. **Write the review** in the output format below.
6. **Draft-first posting.** Show the review to the human first. Post
   it with `gh pr comment <n> --repo <owner>/<repo> --body-file
   <file>` only after they confirm — reviews are outward-facing
   writes.
7. **State update.** Propose 1–3 bullet lines for the repo's state
   file recording the verdict and any newly established facts; apply
   them once the human agrees (or when the PR author resolves the
   findings).

## Output format

- A one-line verdict: `approve`, `approve with nits`, or
  `request changes`.
- Findings ordered by severity (`blocker` / `should-fix` / `nit`).
  Each contradiction finding quotes the PR's text and the conflicting
  corpus text, names both files, and gives a concrete fix (usually:
  which side is wrong, per the established facts). If a severity
  level has no findings, say so explicitly.
- A "Checks performed" section listing what was compared (corpus
  files read, indexes verified, references resolved).
- A "Pre-existing issues (not introduced by this PR)" section for
  contradictions the PR touches but does not create, kept separate
  per the standards.
- A "Review state update" section with the proposed state-file
  bullets.
- When there are no contradictions at all, say so in one sentence —
  do not pad the review.

## Tooling notes

- `scripts/review-docs.ps1` / `scripts/review-docs.sh` (in this repo)
  automate steps 2–5 for Codex: they compose this procedure, the
  established facts, and the PR diff into a prompt, run `codex exec`,
  and save the review to a file. Posting still follows step 6.
- On Windows PowerShell 5.1, pass the composed prompt to `codex exec`
  via stdin (`codex exec -`), never as a command-line argument.
