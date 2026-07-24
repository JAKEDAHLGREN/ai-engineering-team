# Run Records

The structured record of every completed multi-agent task now lives in a
queryable SQLite store, **not** in markdown files here. At close-out the
Conductor distills the task's `.ai/work/{NNN}-{slug}/` artifacts into rows via
`.ai/bin/mem` (see its `--help`). This is the durable dataset the `team-analyst`
mines — the work directory is prunable scratch; the database survives it.

Markdown run records were retired in favor of the database because grep over
flat files can't aggregate ("which tag recurs across ≥3 features?") and forced
agents to load whole files to answer narrow questions. The database queries and
loads only what's asked for.

## What the Conductor writes at close-out

Distilling one task into rows (see `.ai/bin/mem --help` for exact flags):

```bash
RID=$(mem log-run --slug {NNN}-{slug} --playbook feature_request --rounds N --verdict PASS)
mem log-finding    --run $RID --tag MISSING_TEST --round 1 --file app/x.rb --desc "..." --source verdict
mem log-decision   --run $RID --summary "..." --alternative "..." --expected "..." --observed "..."
mem log-reflection --run $RID --agent rails-engineer --type struggle --desc "..."
```

- **Findings** come from every verdict *and* every builder report — builders tag
  risks too. Tags are validated against `organization/finding_vocabulary.md` at
  write time, so a typo can't enter the dataset.
- **Decisions** carry the bet (`--expected`) and the result (`--observed`).
  Fill `--observed` honestly at close-out — an expected outcome with no observed
  result is a hypothesis nobody checked, and expectation *misses* are the most
  valuable signal in the dataset.
- **Escalations** are recorded as a run with `--verdict ESCALATED` plus the
  finding tag that persisted.

Then append one human-readable line to `../INDEX.md` so people keep a browsable
trail. `mem runs` prints the same list from the database.

## What still lives as markdown

The narrative brain — architecture, ADRs, postmortems, `decision_log.md`,
technical-debt notes, releases. Those are prose humans read and agents reason
from; only the structured, aggregatable learning data moved to the database.

## Database

`.ai/memory/agent_log.sqlite3`, created on first use by `mem init`. Requires the
`sqlite3` CLI (ships with macOS; `apt install sqlite3` on Linux) — the binary
only, unrelated to your application's database. Committed with the project so the
learning history travels to fresh clones. Override the path with `AGENT_LOG_DB`.
