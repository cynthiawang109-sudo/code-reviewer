<#
.SYNOPSIS
  Run the workspace code-reviewer's documentation mode over a GitHub
  pull request in taskflow-docs or taskflow-api-docs (see
  skills/review-docs/SKILL.md for the process this automates).

.EXAMPLE
  .\review-docs.ps1 -Repo cynthiawang109-sudo/taskflow-docs -Pr 2
  .\review-docs.ps1 -Repo cynthiawang109-sudo/taskflow-docs -Pr 2 -Post

  Without -Post the review is only written to a file (draft-first);
  -Post also publishes it as a PR comment after printing it.
#>
param(
    [Parameter(Mandatory = $true)][string]$Repo,
    [Parameter(Mandatory = $true)][int]$Pr,
    [switch]$Post,
    # If Codex reports "Failed to create unified exec process: timed out
    # ... connecting runner pipe-in", its sandboxed shell runner is
    # wedged on this machine; rerun with -Sandbox danger-full-access.
    [ValidateSet('read-only', 'workspace-write', 'danger-full-access')]
    [string]$Sandbox = 'read-only'
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

# This script lives in <root>/projects/code-reviewer/scripts.
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$app = ($Repo -split '/')[-1]
if ($app -notin @('taskflow-docs', 'taskflow-api-docs')) {
    throw "review-docs only reviews the documentation repos (taskflow-docs, taskflow-api-docs); got $app"
}
$codex = Join-Path $env:USERPROFILE 'AppData\Local\Programs\OpenAI\Codex\bin\codex.exe'
if (-not (Test-Path $codex)) { $codex = 'codex' }

$diff = gh pr diff $Pr --repo $Repo
if ($LASTEXITCODE -ne 0) { throw "gh pr diff failed for $Repo#$Pr" }
$meta = gh pr view $Pr --repo $Repo --json title --jq .title

$prompt = @"
You are acting as the code-reviewer for this workspace in documentation mode, following the review-docs skill in projects/code-reviewer/skills/review-docs/SKILL.md.

1. Read projects/code-reviewer/review-standards.md and projects/code-reviewer/projects/$app.md. The "Established facts" in the state file are ground truth; previously flagged items marked fixed, and accepted risks, must NOT be re-raised.
2. Read every Markdown file under projects/taskflow-docs/ (including adr/) and projects/taskflow-api-docs/ from disk. That corpus is the baseline: review the diff against all of it, not only the files the PR touches.
3. Review the diff below: repo $Repo, PR #$Pr, "$meta". Check for: contradictions with the corpus or the established facts (quote both sides, with files); self-contradictions inside the PR; cross-references to files, sections, or headings that do not exist; index drift (SUMMARY.md and the README contents table of $app versus files the PR adds, removes, or renames); and demo-implementation claims checked against the verified demo surface in projects/code-reviewer/projects/taskflow-api-docs.md. A claim that is merely more detailed than another document is NOT a contradiction.

Output a Markdown review with: a one-line verdict (approve / approve with nits / request changes); findings ordered by severity (blocker / should-fix / nit), each contradiction quoting both conflicting passages with their files and a concrete fix (state explicitly when a level has none); a "Checks performed" section; a "Pre-existing issues (not introduced by this PR)" section; and a "Review state update" section proposing bullets for projects/code-reviewer/projects/$app.md. If there are no contradictions, say so in one sentence. An accurate short review beats a padded one.

The diff:

``````diff
$($diff -join "`n")
``````
"@

$outFile = Join-Path $root ("review-docs-{0}-{1}.md" -f $app, $Pr)
# PS 5.1 mangles long multi-line native-command arguments; stdin is safe.
$prompt | & $codex exec --sandbox $Sandbox -C $root -c 'model_reasoning_effort="medium"' - |
    Out-File -Encoding utf8 $outFile

Write-Output "Review written to $outFile"
Get-Content $outFile

if ($Post) {
    $review = (Get-Content -Raw $outFile).TrimStart([char]0xFEFF).Trim()
    $commentFile = Join-Path $root 'review-comment.tmp.md'
    "## Documentation review - code-reviewer (via the review-docs skill)`n`n$review" |
        Out-File -Encoding utf8 $commentFile
    gh pr comment $Pr --repo $Repo --body-file $commentFile
    Remove-Item $commentFile
    Write-Output "Posted as a comment on $Repo#$Pr"
}
