# Memory Index — {{PROJECT_NAME}}

> **Read this first.** This is the retrieval entrypoint for project memory. Scan
> the index, then open only the specific entries relevant to your task. Never load
> the whole `memory/` tree into context.

## How memory works
- Every memory entry gets **one line here**: date, scope, slug, one-sentence summary.
- The full note lives in the matching scope folder as a dated, slugged markdown file
  (e.g. `decisions/2026-06-26-adopt-framework.md`).
- **Writes append a line here.** A note that isn't indexed is effectively invisible.
- Keep entries factual and short. Prune or supersede stale entries rather than
  letting them accumulate and mislead.
- **When this index exceeds ~50 entries, run the `memory_consolidation`
  playbook** — an index nobody can scan is an index nobody reads.

## Scopes
- `decisions/` — architectural and design decisions and their rationale.
- `technical_debt/` — known shortcuts, their cost, and where to pay them down.
- `releases/` — dated release notes: version, contents, and deploy outcome.
- `runs/` — one structured record per completed task: verdicts, tagged findings,
  decisions with expected → observed outcomes. Mined by the `team-analyst`.
- `proposals/` — the analyst's evidence-backed improvement proposals and the
  skill-builder's build notes. Nothing applies without your approval.

## Entries
_Newest first._

<!-- YYYY-MM-DD · scope · slug · one-line summary -->
- _(no entries yet — the first feature shipped through the team will add one)_
