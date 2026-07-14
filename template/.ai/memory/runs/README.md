# Run Records

One file per completed multi-agent task, written by the Conductor at close-out
by distilling the task's `.ai/work/{NNN}-{slug}/` artifacts. **This is the
durable dataset the `team-analyst` mines** — the work directory is prunable
scratch; the run record survives it. Each record gets one line in `../INDEX.md`.

File name: `YYYY-MM-DD-{NNN}-{slug}.md`

## Format

Keep the line shapes exact — the analyst greps them.

```markdown
# Run — {NNN}-{slug}

**Date:** YYYY-MM-DD · **Playbook:** feature_request · **Rounds:** N ·
**Final verdict:** PASS | ESCALATED
**Agents:** tech-lead, rails-engineer, qa-engineer, ...

## Findings (all rounds)
One line per finding, tags copied exactly from the verdicts **and the builder
reports** (builders tag risks too — those belong in the dataset even though
only verdict tags gate rounds):
- [TAG] r{N} · file:line — description

_(or "None.")_

## Consequential decisions
- {what was decided} — alternative: {what was rejected} — expected: {the bet} →
  observed: {what actually happened, filled at close-out}

_(or "None.")_

## Struggles & assumptions
From every report's Agent Notes:
- {agent}: {assumption or struggle}

_(or "None.")_

## Escalations
Circuit-breaker escalations, with the category that persisted:
- [TAG] escalated after round 3 — {why}

_(or "None.")_
```

## Rules

- **Append-only.** Never rewrite a past record — the history is the signal.
- **Copy tags verbatim** from the verdict files. A retyped tag that drifts from
  `organization/finding_vocabulary.md` breaks recurrence detection.
- **Fill `observed:` honestly at close-out** — an expected outcome with no
  observed result is a hypothesis nobody checked, and expectation *misses* are
  the most valuable line in the whole record.
