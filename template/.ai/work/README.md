# Work Directory — {{PROJECT_NAME}}

> In-flight task artifacts. One directory per task. Every plan, report, and
> verdict is a **file here**, so handoffs are paths (not pasted context), a
> retry never re-derives prior work, and any interrupted task can be resumed
> from its artifacts alone.

## Layout

```
.ai/work/{NNN}-{slug}/          # NNN = zero-padded sequence (001, 002, ...)
├── brief.md                    # Conductor — clarified intent, if the request needed it
├── plan.md                     # tech-lead — the implementation plan (the contract)
├── report-{agent}.r{N}.md      # each builder's report, per round (r1, r2, ...)
├── verdict-qa.r{N}.md          # QA's structured verdict, per round
└── verdict-{agent}.r{N}.md     # other verdicts when a role reviews (security,
                                #   performance, database on schema reviews)
```

To open a new task: scan `.ai/work/` for the highest existing `{NNN}-*`
directory and increment. If none exist, start at `001`.

## Rules

- **Rounds append — never overwrite a prior round's file.** Round history is how
  the Conductor detects the same finding category recurring (the circuit-breaker
  in `CLAUDE.md` reads tags across `verdict-*.r*.md`).
- **Reports follow the reporting protocol** in `organization/coding_standards.md`
  and end with **Agent Notes** — assumptions made and where you struggled. Write
  "None." rather than leaving either out; the notes are raw material for
  improving standards and skills.
- **Return paths, not prose.** An agent that wrote an artifact returns the file
  path plus a one-paragraph summary — the next agent reads the file itself.
- **Resuming:** the artifacts are the state. If a work directory exists for a
  task, re-enter at the first missing artifact — don't restart, don't re-plan
  what `plan.md` already settles. `brief.md` is optional (only written when
  clarification happened), so resume decisions key off `plan.md` onward.

## Verdict format

Verdict files are structured so the Conductor can judge and track them
mechanically:

```markdown
# Verdict — {NNN}-{slug} · {agent} · round {N}

**Verdict:** PASS | FAIL (or the role's own vocabulary — e.g.
`security-review` reports PASS | CHANGES REQUIRED)
**Evidence:** the command run and its summary line, quoted verbatim

## Findings
- [TAG] file:line — description (severity, where the role grades one)

_(or "None.")_ Tags come from `organization/finding_vocabulary.md` — exact
strings, one tag per finding.

## Agent Notes
**Assumptions made:** … _(or "None.")_
**Where I struggled:** … _(or "None.")_
```

## Lifecycle

When the task completes, the Conductor records the outcome to
`.ai/memory/INDEX.md` (and `memory/` notes for anything significant). After
that, the work directory may be archived or deleted — **memory is the durable
record; `work/` is scratch.** Keeping recent directories around is useful for
recurrence analysis; pruning old ones keeps the tree navigable.
