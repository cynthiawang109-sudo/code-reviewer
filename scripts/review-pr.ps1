<#
.SYNOPSIS
  Run the workspace code-reviewer over a GitHub pull request (see
  skills/review-pr/SKILL.md for the process this automates).

.EXAMPLE
  .\review-pr.ps1 -Repo cynthiawang109-sudo/demo-app -Pr 2
  .\review-pr.ps1 -Repo cynthiawang109-sudo/demo-app -Pr 2 -Post

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
$codex = Join-Path $env:USERPROFILE 'AppData\Local\Programs\OpenAI\Codex\bin\codex.exe'
if (-not (Test-Path $codex)) { $codex = 'codex' }

$diff = gh pr diff $Pr --repo $Repo
if ($LASTEXITCODE -ne 0) { throw "gh pr diff failed for $Repo#$Pr" }
$meta = gh pr view $Pr --repo $Repo --json title --jq .title

$prompt = @"
You are acting as the code-reviewer for this workspace, following the review-pr skill in projects/code-reviewer/skills/review-pr/SKILL.md.

1. Read projects/code-reviewer/review-standards.md and projects/code-reviewer/projects/$app.md (accepted risks there must NOT be re-raised).
2. Use the doc-search MCP tool get_doc to fetch the contract documents this diff touches (start from the index in projects/code-reviewer/context/doc-repos.md; for API changes, projects/taskflow-api-docs/api-conventions.md). Cite the fetched text; do not review against a remembered contract.
3. Review the diff below: repo $Repo, PR #$Pr, "$meta".

Output a Markdown review with: a one-line verdict (approve / approve with nits / request changes); findings ordered by severity (blocker / should-fix / nit), each with file, the cited standard or contract clause, and a concrete fix (state explicitly when a level has none); a "Contract compliance" section; a "Pre-existing issues (not introduced by this PR)" section; and a "Review state update" section proposing bullets for projects/code-reviewer/projects/$app.md. An accurate short review beats a padded one.

The diff:

``````diff
$($diff -join "`n")
``````
"@

$outFile = Join-Path $root ("review-{0}-{1}.md" -f $app, $Pr)
# PS 5.1 mangles long multi-line native-command arguments; stdin is safe.
$prompt | & $codex exec --sandbox $Sandbox -C $root -c 'model_reasoning_effort="medium"' - |
    Out-File -Encoding utf8 $outFile

Write-Output "Review written to $outFile"
Get-Content $outFile

if ($Post) {
    $review = (Get-Content -Raw $outFile).TrimStart([char]0xFEFF).Trim()
    $commentFile = Join-Path $root 'review-comment.tmp.md'
    "## Code review - code-reviewer (via the review-pr skill)`n`n$review" |
        Out-File -Encoding utf8 $commentFile
    gh pr comment $Pr --repo $Repo --body-file $commentFile
    Remove-Item $commentFile
    Write-Output "Posted as a comment on $Repo#$Pr"
}
