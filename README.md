# code-reviewer

AI-assisted code review for the ai-workspace-kit projects. Reviews apply the
shared standards in this repo and pull system background from the
documentation repos on demand — the same reviewer works interactively (ask in
an agent session) and, from milestone M3, on GitHub pull requests.

Part of [ai-workspace-kit](https://github.com/cynthiawang109-sudo/ai-workspace-kit).

## Structure

| Path | Purpose |
|---|---|
| `review-standards.md` | Global review rules for every project |
| `context/doc-repos.md` | Index of the documentation repos — where each kind of fact lives |
| `projects/<app>.md` | Per-app review state only: previously flagged issues and accepted risks, so they are not re-raised |
| `skills/review-pr/` | The review process as an agent skill (SKILL.md) — usable interactively from Codex or Claude Code |
| `scripts/review-pr.ps1` / `.sh` | One-command runner for the skill: composes standards, state, contract docs, and the PR diff, runs the review, and (only with an explicit flag) posts it |
| `skills/review-docs/` | The documentation review process as an agent skill: checks a docs PR against the whole documentation corpus and the established facts for that repo |
| `scripts/review-docs.ps1` / `.sh` | One-command runner for the docs skill, for `taskflow-docs` and `taskflow-api-docs` PRs; same draft-first rule |

## How a review works

1. Read `review-standards.md` and the app's file under `projects/`.
2. Use `context/doc-repos.md` to fetch the specific documentation the diff
   touches (API contracts, data-model invariants, runbook rules).
3. Report in two sections — issues introduced by this change, and
   pre-existing issues in the touched code — severity-ordered.
4. Anything the author marks as an accepted risk is appended to
   `projects/<app>.md` and not raised again.

Documentation pull requests get their own mode: the review-docs skill
checks a docs change against the whole corpus and the established facts
recorded in `projects/taskflow-docs.md` / `projects/taskflow-api-docs.md`
— contradictions, broken cross-references, and index drift — instead of
against contracts.

Documentation repos are read-only inputs: reviews never edit them. System
knowledge lives there; this repo holds only standards and review state.
