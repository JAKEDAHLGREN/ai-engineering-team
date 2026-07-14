# AI Engineering Team

> Build your own AI software engineering organization — and actually run it.

A modular framework for a collaborative team of specialized AI software engineers,
coordinated by a central **Conductor**, that plan, build, and verify changes
together. It runs on **Claude Code's native primitives** (subagents, skills, and
`CLAUDE.md`) so there's no custom orchestrator to operate — and it installs into any
project with a single command.

Rather than one general-purpose assistant doing everything, work is distributed
across specialists who share the same organizational knowledge, coding standards,
and project memory.

---

## How it actually works

This is the load-bearing part, so it's stated plainly:

- **The Conductor is the main thread** (`CLAUDE.md`). In Claude Code, only the main
  thread can spawn subagents, so orchestration lives there. The Conductor plans,
  dispatches, integrates results, judges done-ness, and records memory. **It does
  not write application code.**
- **Agents are real Claude Code subagents** (`.claude/agents/*.md`). They define
  *who* does the work and are dispatched via the Task tool.
- **Skills are real Claude Code skills** (`.claude/skills/*/SKILL.md`). They define
  *how* a piece of work is done, and any agent can run one.
- **Playbooks** (`.ai/playbooks/*.md`) define *the ordered sequence* of skills
  across agents for a recurring situation.
- **The shared brain and memory** live in `.ai/` and are *referenced* by the
  Conductor and agents — there is no parallel agent tree that nothing reads.
- **Work is handed off as files, not pasted context.** Plans, reports, and
  verdicts live in `.ai/work/{NNN}-{slug}/`; agents pass paths, and interrupted
  tasks resume from their artifacts.
- **The team learns, with you as the gate.** Every completed task is distilled
  into a run record; the `team-analyst` mines them for recurring patterns and
  the `skill-builder` applies only the proposals you approve.

The boundary, in one line: **agents = who, skills = how, playbooks = the sequence.**

---

## Quick start — add the team to any project

The framework lives in its own repo and installs into your project with one
command. You only clone this repo once; from then on you can `ait init` it into as
many projects as you like.

**1. Clone this repo** (somewhere outside your project — it's a reusable tool):

```bash
git clone https://github.com/JAKEDAHLGREN/ai-engineering-team.git ~/tools/ai-engineering-team
```

**2. Run the scaffolder, pointing it at your project:**

```bash
~/tools/ai-engineering-team/bin/ait init /path/to/your/project
```

**3. Answer the prompts.** It asks for your project name, stack, and test command,
then fills those into the agent and organization files. Press Enter to accept a
default (defaults are Ruby / Rails / PostgreSQL / `bin/rails test`).

```
Project name [your-project]:
One-line description [A software project.]:
Primary language [Ruby]:
Framework [Rails]:
Database [PostgreSQL]:
Frontend [Hotwire/Stimulus + TailwindCSS]:
Test command [bin/rails test]:
```

**`ait init` merges cleanly — including into projects that already use Claude
Code.** The Conductor is added as a clearly-marked managed block inside your
`CLAUDE.md` (an existing `CLAUDE.md` is **preserved**, the block is appended). The
`.claude/` and `.ai/` trees are merged file-by-file: any file you already have is
**kept, never overwritten** — `ait` reports what it added and what it kept. Review
it with `git status` before committing.

**4. Onboard the team to your codebase.** Open `.ai/organization/` and fill in the
`TODO`s — at minimum `architecture.md` and any project-specific rules in
`coding_standards.md`. This is the shared context every agent loads before working;
the better it is, the better the team performs.

**5. Commit the team into your project** so it's versioned alongside your code:

```bash
cd /path/to/your/project
git add CLAUDE.md .claude .ai && git commit -m "Add AI Engineering Team"
```

> **`.gitignore` gotcha:** if your repo ignores `.claude/` (a common rule like
> `.claude/*`), the agents won't be committed — so Claude Code on the web and fresh
> clones won't see them, and the team will be incomplete. `ait init` detects this
> and prints the exact fix: add a negation such as `!.claude/agents/` after the
> ignoring rule, then `git add .claude/agents`. Verify with
> `git ls-files .claude/agents | wc -l` (expect 11).

**6. Use it.** Open the project in Claude Code and just ask for a feature — e.g.
*"Add CSV export to the invoices page."* The Conductor (`CLAUDE.md`) plans it,
dispatches the right specialists (Rails, Frontend, Database) in parallel, and won't
call it done until the QA Engineer reports the test suite green.

> **Tip:** put `ait` on your `PATH` to skip the long path —
> `ln -s ~/tools/ai-engineering-team/bin/ait /usr/local/bin/ait`, then just
> `ait init /path/to/your/project`.

### Updating an installed project later

Installs are a **snapshot** — they don't auto-sync. When the framework improves,
pull this repo and run `ait update` inside your project to adopt the changes:

```bash
cd ~/tools/ai-engineering-team && git pull        # get the latest framework
~/tools/ai-engineering-team/bin/ait update /path/to/your/project
```

`ait update` refreshes **only the framework-owned files** — the Conductor block in
`CLAUDE.md`, agents, skills, and shipped playbooks — re-rendered with the answers
you gave at install (saved in `.ai/.ait-manifest`). The Conductor block is replaced
in place between its markers, so the rest of your `CLAUDE.md` is left exactly as-is.
It explicitly **never touches** your project-owned knowledge:

- `.ai/organization/` — your architecture, standards, and decisions
- `.ai/memory/` — your recorded decisions, debt, run records, and history
- `.ai/work/` — your in-flight task artifacts
- any agents, skills, or playbooks **you** added

Overwritten files are backed up to `.ai/.ait-backups/<timestamp>/` first, and since
the team is committed in your project, `git diff` shows exactly what changed before
you commit it. Nothing you wrote is ever silently lost.

---

## What gets installed

```
your-project/
├── CLAUDE.md                     # the Conductor (main-thread orchestrator)
├── .claude/
│   ├── agents/
│   │   ├── tech-lead.md            # plans work, sets acceptance criteria
│   │   ├── rails-engineer.md       # implements backend code
│   │   ├── frontend-engineer.md    # UI, styling, interactivity, accessibility
│   │   ├── database-engineer.md    # schema, migrations, indexes, integrity
│   │   ├── security-engineer.md    # auth, secrets, input validation, OWASP risks
│   │   ├── performance-engineer.md # hot paths, query/index tuning, profiling
│   │   ├── devops-engineer.md      # CI/CD, deploys, rollbacks, observability
│   │   ├── documentation-engineer.md # READMEs, API docs, ADRs, release notes
│   │   ├── qa-engineer.md          # runs tests, owns the objective done-signal
│   │   ├── team-analyst.md         # mines run records; proposes improvements
│   │   └── skill-builder.md        # applies user-approved proposals
│   └── skills/
│       ├── add-feature/SKILL.md
│       ├── run-tests/SKILL.md
│       ├── security-review/SKILL.md
│       ├── optimize-query/SKILL.md
│       └── deploy/SKILL.md
└── .ai/
    ├── organization/             # the shared brain every agent loads first
    │   ├── organization.md  architecture.md  coding_standards.md
    │   ├── roadmap.md  decision_log.md  glossary.md
    │   └── finding_vocabulary.md # controlled tags for review findings
    ├── playbooks/
    │   ├── feature_request.md    # clarify, plan, build, verify — end-to-end
    │   ├── production_incident.md # stabilize, diagnose, fix, postmortem
    │   ├── release.md            # verify, document, deploy, confirm, record
    │   ├── retrospective.md      # run records → proposals → approval → skills
    │   └── memory_consolidation.md # merge, supersede, prune; keep memory scannable
    ├── work/                     # in-flight task artifacts: plans, reports, verdicts
    │   └── README.md             # the artifact naming + verdict format
    └── memory/
        ├── INDEX.md              # read first; the retrieval entrypoint
        ├── decisions/
        ├── technical_debt/
        ├── releases/
        ├── runs/                 # one structured record per completed task
        └── proposals/            # analyst proposals + build notes (human-gated)
```

---

## The core workflow: `feature_request`

The workflow that runs end to end, proving the wiring as the team scales:

```
User request
   ↓
Conductor (CLAUDE.md)  ── loads the brain, clarifies if ambiguous, opens .ai/work/
   ↓
tech-lead          ── plan.md: work items, owners, acceptance criteria
   ↓
rails-engineer  ┐
frontend-engineer ├─ build the work items in parallel (add-feature skill);
database-engineer ┘  database-engineer also reviews any schema change (verdict)
   ↓
qa-engineer        ── runs the suite (run-tests skill) → tagged PASS / FAIL verdict
   ↓
Conductor          ── FAIL: send back · PASS: done, distill run record to memory
```

**"Done" is objective, not vibes.** Code work is not complete until the QA Engineer
has run the test suite and reported it green against the Tech Lead's acceptance
criteria.

**Failure loops are capped, not infinite.** Findings are tagged with a controlled
vocabulary (`.ai/organization/finding_vocabulary.md`). If the same category fails
two rounds in a row, the Conductor names it explicitly; a third round stops the
loop and escalates to the user — three identical failures mean the plan or the
standards are wrong, not the engineer.

---

## Design principles

- **Specialization** — every agent has one responsibility and stays in it.
- **Shared context** — every agent loads the `.ai/organization/` knowledge its
  role needs before acting; no one is asked to carry the whole brain.
- **Orchestration** — the Conductor coordinates; it doesn't do specialist work.
- **Reusable skills** — procedures are decoupled from identities.
- **Persistent memory** — decisions, bugs, and debt are recorded and indexed, and
  read via `memory/INDEX.md` so context never balloons.
- **Artifacts over context** — plans, reports, and verdicts are files in
  `.ai/work/{NNN}-{slug}/`, so handoffs are paths, retries never re-derive prior
  work, and an interrupted task resumes at its first missing artifact.
- **Self-improvement, human-gated** — every task leaves a run record with tagged
  findings and expected-vs-observed decisions; the Team Analyst mines them for
  recurring patterns; nothing changes without your explicit approval.

---

## Roadmap

**Shipped:** the eleven-role roster (Tech Lead, Rails, Frontend, Database,
Security, Performance, DevOps, Documentation, QA, plus the Team Analyst and
Skill Builder learning loop); the `add-feature`, `run-tests`, `security-review`,
`optimize-query`, and `deploy` skills; the `feature_request` (clarify-first),
`production_incident`, `release`, `retrospective`, and `memory_consolidation`
playbooks; file-based handoffs in `.ai/work/`; tagged findings via a controlled
vocabulary; run records in `.ai/memory/runs/`; and the human-gated
self-improvement cycle.

**Planned, not yet shipped:**

- More skills (e.g. `review-pr`, `write-migration`) to give the remaining agents
  concrete reusable procedures.
- **Event-driven triggers** (PR opened → review, CI failure → QA, etc.). These
  require GitHub Actions / webhook infrastructure and are real work, not markdown —
  the natural next step now that the roster is complete.
- Stack-agnostic agent templates beyond the current Rails-first defaults.

The objective isn't more agents — it's a more capable engineering organization,
grown one proven slice at a time.

---

## Contributing

New agents, skills, and playbooks should have a single well-defined responsibility,
reuse the shared organizational knowledge, minimize overlap, and integrate through
the Conductor rather than coordinating with each other directly.

**The skill quality bar:** a skill must answer "what would an agent have to guess
from training data if this didn't exist?" If training data would get it right,
the skill isn't needed — write only settled, project-specific knowledge. The
`retrospective` playbook generates skills that pass this test by construction,
because each one exists to prevent a mistake that actually recurred.

**CI.** Every PR runs `test/ait-smoke.sh` via GitHub Actions — it does real
greenfield and brownfield installs against temp dirs and asserts the invariants
(agent/skill/playbook counts, no leftover placeholders, frontmatter names matching
filenames, conductor-block idempotency on update, project-owned files preserved,
and the gitignore warning). Run it locally before pushing:

```bash
bash test/ait-smoke.sh
```

To block merges on failure, make the **`ait smoke test`** check required in the
repo's branch-protection rule for `main`.
