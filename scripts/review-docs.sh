#!/usr/bin/env bash
# Run the workspace code-reviewer's documentation mode over a GitHub
# pull request in taskflow-docs or taskflow-api-docs.
# See skills/review-docs/SKILL.md for the process this automates.
#
# Usage: ./review-docs.sh <owner>/<repo> <pr-number> [--post]
# Without --post the review is only written to a file (draft-first).
set -euo pipefail

repo="${1:?usage: review-docs.sh <owner>/<repo> <pr-number> [--post]}"
pr="${2:?usage: review-docs.sh <owner>/<repo> <pr-number> [--post]}"
post="${3:-}"
app="${repo##*/}"

case "$app" in
    taskflow-docs|taskflow-api-docs) ;;
    *) echo "review-docs only reviews the documentation repos (taskflow-docs, taskflow-api-docs); got $app" >&2; exit 1 ;;
esac

# This script lives in <root>/projects/code-reviewer/scripts.
root="$(cd "$(dirname "$0")/../../.." && pwd)"

diff="$(gh pr diff "$pr" --repo "$repo")"
title="$(gh pr view "$pr" --repo "$repo" --json title --jq .title)"

prompt="You are acting as the code-reviewer for this workspace in documentation mode, following the review-docs skill in projects/code-reviewer/skills/review-docs/SKILL.md.

1. Read projects/code-reviewer/review-standards.md and projects/code-reviewer/projects/${app}.md. The \"Established facts\" in the state file are ground truth; previously flagged items marked fixed, and accepted risks, must NOT be re-raised.
2. Read every Markdown file under projects/taskflow-docs/ (including adr/) and projects/taskflow-api-docs/ from disk. That corpus is the baseline: review the diff against all of it, not only the files the PR touches.
3. Review the diff below: repo ${repo}, PR #${pr}, \"${title}\". Check for: contradictions with the corpus or the established facts (quote both sides, with files); self-contradictions inside the PR; cross-references to files, sections, or headings that do not exist; index drift (SUMMARY.md and the README contents table of ${app} versus files the PR adds, removes, or renames); and demo-implementation claims checked against the verified demo surface in projects/code-reviewer/projects/taskflow-api-docs.md. A claim that is merely more detailed than another document is NOT a contradiction.

Output a Markdown review with: a one-line verdict (approve / approve with nits / request changes); findings ordered by severity (blocker / should-fix / nit), each contradiction quoting both conflicting passages with their files and a concrete fix (state explicitly when a level has none); a \"Checks performed\" section; a \"Pre-existing issues (not introduced by this PR)\" section; and a \"Review state update\" section proposing bullets for projects/code-reviewer/projects/${app}.md. If there are no contradictions, say so in one sentence. An accurate short review beats a padded one.

The diff:

\`\`\`diff
${diff}
\`\`\`"

out="${root}/review-docs-${app}-${pr}.md"
printf '%s' "$prompt" | codex exec --sandbox "${SANDBOX:-read-only}" -C "$root" \
    -c 'model_reasoning_effort="medium"' - > "$out"

echo "Review written to $out"
cat "$out"

if [ "$post" = "--post" ]; then
    comment="$(mktemp)"
    { printf '## Documentation review - code-reviewer (via the review-docs skill)\n\n'; cat "$out"; } > "$comment"
    gh pr comment "$pr" --repo "$repo" --body-file "$comment"
    rm -f "$comment"
    echo "Posted as a comment on ${repo}#${pr}"
fi
