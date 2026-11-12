# Documentation index

Where each kind of fact lives. Fetch the specific file you need; do not load
whole repos into context "just in case".

| Question type | Repo | Start with |
|---|---|---|
| How the system fits together, component boundaries | `taskflow-docs` | `system-overview.md` |
| How releases, environments, and rollbacks work | `taskflow-docs` | `deployment.md` |
| What to do when something breaks | `taskflow-docs` | `incident-runbook.md` |
| Endpoint shapes, errors, pagination, health contract | `taskflow-api-docs` | `api-conventions.md` |
| Table invariants, PII and delete rules | `taskflow-api-docs` | `data-model.md` |
| Release steps and change process | `release-assistant` | `release-checklist.md`, `change-process.md` |

Paths are workspace-relative: from this repo, the doc repos are siblings
(`../taskflow-docs/...`) when the full workspace is synced; otherwise use
their GitHub URLs from the root `repos.txt`.
