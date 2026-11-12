#!/usr/bin/env bash
# Run the workspace code-reviewer over a GitHub pull request.
# See skills/review-pr/SKILL.md for the process this automates.
#
# Usage: ./review-pr.sh <owner>/<repo> <pr-number> [--post]
# Without --post the review is only written to a file (draft-first).
set -euo pipefail

repo="${1:?usage: review-pr.sh <owner>/<repo> <pr-number> [--post]}"
pr="${2:?usage: review-pr.sh <owner>/<repo> <pr-number> [--post]}"
post="${3:-}"
app="${repo##*/}"

# This script lives in <root>/projects/code-reviewer/scripts.
root="$(cd "$(dirname "$0")/../../.." && pwd)"

diff="$(gh pr diff "$pr" --repo "$repo")"
title="$(gh pr view "$pr" --repo "$repo" --json title --jq .title)"

prompt="You are acting as the code-reviewer for this workspace, following the review-pr skill in projects/code-reviewer/skills/review-pr/SKILL.md.

1. Read projects/code-reviewer/review-standards.md and projects/code-reviewer/projects/${app}.md (accepted risks there must NOT be re-raised).
2. Use the doc-search MCP tool get_doc to fetch the contract documents this diff touches (start from the index in projects/code-reviewer/context/doc-repos.md; for API changes, projects/taskflow-api-docs/api-conventions.md). Cite the fetched text; do not review against a remembered contract.
3. Review the diff below: repo ${repo}, PR #${pr}, \"${title}\".

Output a Markdown review with: a one-line verdict (approve / approve with nits / request changes); findings ordered by severity (blocker / should-fix / nit), each with file, the cited standard or contract clause, and a concrete fix (state explicitly when a level has none); a \"Contract compliance\" section; a \"Pre-existing issues (not introduced by this PR)\" section; and a \"Review state update\" section proposing bullets for projects/code-reviewer/projects/${app}.md. An accurate short review beats a padded one.

The diff:

\`\`\`diff
${diff}
\`\`\`"

out="${root}/review-${app}-${pr}.md"
printf '%s' "$prompt" | codex exec --sandbox read-only -C "$root" \
    -c 'model_reasoning_effort="medium"' - > "$out"

echo "Review written to $out"
cat "$out"

if [ "$post" = "--post" ]; then
    comment="$(mktemp)"
    { printf '## Code review - code-reviewer (via the review-pr skill)\n\n'; cat "$out"; } > "$comment"
    gh pr comment "$pr" --repo "$repo" --body-file "$comment"
    rm -f "$comment"
    echo "Posted as a comment on ${repo}#${pr}"
fi
