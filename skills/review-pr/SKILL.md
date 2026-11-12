---
name: review-pr
description: Review a GitHub pull request for a project in this workspace, applying the code-reviewer standards and checking the change against the API contracts and docs in the documentation repos. Use when asked to review a PR, do a code review, or check a change for contract conformance.
---

# Review a pull request

You are acting as this workspace's code-reviewer. Follow this procedure
exactly; it is the process used for the demo-app reviews on file in
`projects/demo-app.md`.

## Inputs

- A PR reference: `<owner>/<repo>#<number>` or a PR URL.
- A synced workspace (if `projects/` looks stale, run the workspace root
  sync script first).

## Procedure

1. **Standards and state.** Read `projects/code-reviewer/review-standards.md`
   and the reviewed app's state file `projects/code-reviewer/projects/<app>.md`.
   Accepted risks recorded there must NOT be re-raised.
2. **The change.** Fetch the PR with `gh pr view <n> --repo <owner>/<repo>`
   and its diff with `gh pr diff <n> --repo <owner>/<repo>`.
3. **Contracts.** Using the index in `projects/code-reviewer/context/doc-repos.md`,
   fetch the specific documents the diff touches — for API changes, the
   conventions in `taskflow-api-docs` (via the doc-search MCP tool `get_doc`
   when available). Check conformance against the fetched text and cite it;
   never review against a remembered version of a contract.
4. **Tests.** If the repo has a test suite, note whether the change updates
   it and whether new behavior is covered. Run it when the environment
   allows; say so if you could not.
5. **Write the review** in the output format below.
6. **Draft-first posting.** Show the review to the human first. Post it with
   `gh pr comment <n> --repo <owner>/<repo> --body-file <file>` only after
   they confirm — reviews are outward-facing writes.
7. **State update.** Propose 1–3 bullet lines for the app's state file
   recording the verdict and any resolved or newly accepted items; apply
   them once the human agrees (or when the PR author resolves the findings).

## Output format

- A one-line verdict: `approve`, `approve with nits`, or `request changes`.
- Findings ordered by severity (`blocker` / `should-fix` / `nit`). Each
  finding names the file, the standard or contract clause it breaks (with a
  citation), and a concrete fix. If a severity level has no findings, say
  so explicitly instead of inventing some.
- A "Contract compliance" section covering each contract the diff touches.
- A "Pre-existing issues (not introduced by this PR)" section, kept separate
  from issues the change introduces, per the standards.
- A "Review state update" section with the proposed state-file bullets.

An accurate short review is better than a padded one.

## Tooling notes

- `scripts/review-pr.ps1` / `scripts/review-pr.sh` (in this repo) automate
  steps 2–5 for Codex: they compose this procedure and the PR diff into a
  prompt, run `codex exec`, and save the review to a file. Posting still
  follows step 6.
- On Windows PowerShell 5.1, pass the composed prompt to `codex exec` via
  stdin (`codex exec -`), never as a command-line argument: PS 5.1 mangles
  long multi-line arguments with embedded quotes.
