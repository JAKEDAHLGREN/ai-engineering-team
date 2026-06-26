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

The boundary, in one line: **agents = who, skills = how, playbooks = the sequence.**

---

## Install into a project

```bash
# from a clone of this repo:
/path/to/ai-engineering-team/bin/ait init /path/to/your/project
```

`ait init` copies the team shell into your project and interactively asks for the
project name, stack, and test command, filling those into the agent and
organization files. It refuses to overwrite an existing install.

After install, open the project in Claude Code and ask for a feature — the
Conductor (`CLAUDE.md`) takes it from there. Then fill in the `TODO`s in
`.ai/organization/` to onboard the team to your codebase.

---

## What gets installed

```
your-project/
├── CLAUDE.md                     # the Conductor (main-thread orchestrator)
├── .claude/
│   ├── agents/
│   │   ├── tech-lead.md          # plans work, sets acceptance criteria
│   │   ├── rails-engineer.md     # implements backend code
│   │   └── qa-engineer.md        # runs tests, owns the objective done-signal
│   └── skills/
│       ├── add-feature/SKILL.md
│       └── run-tests/SKILL.md
└── .ai/
    ├── organization/             # the shared brain every agent loads first
    │   ├── organization.md  architecture.md  coding_standards.md
    │   ├── roadmap.md  decision_log.md  glossary.md
    ├── playbooks/
    │   └── feature_request.md    # the end-to-end workflow
    └── memory/
        ├── INDEX.md              # read first; the retrieval entrypoint
        ├── decisions/
        └── technical_debt/
```

---

## The v1 workflow: `feature_request`

The one thing that runs end to end today, proving the wiring before the team scales:

```
User request
   ↓
Conductor (CLAUDE.md)  ── loads the brain, picks the playbook
   ↓
tech-lead          ── plan: work items, owners, acceptance criteria
   ↓
rails-engineer     ── builds the work items (add-feature skill)
   ↓
qa-engineer        ── runs the suite (run-tests skill) → PASS / FAIL
   ↓
Conductor          ── FAIL: send back · PASS: done, record to memory
```

**"Done" is objective, not vibes.** Code work is not complete until the QA Engineer
has run the test suite and reported it green against the Tech Lead's acceptance
criteria.

---

## Design principles

- **Specialization** — every agent has one responsibility and stays in it.
- **Shared context** — every agent loads `.ai/organization/` before acting.
- **Orchestration** — the Conductor coordinates; it doesn't do specialist work.
- **Reusable skills** — procedures are decoupled from identities.
- **Persistent memory** — decisions, bugs, and debt are recorded and indexed, and
  read via `memory/INDEX.md` so context never balloons.

---

## Roadmap (not yet built)

v1 is deliberately one vertical slice. Planned, explicitly *not* shipped yet:

- The remaining specialists: frontend, database, security, performance, devops,
  documentation.
- More skills and playbooks (review PR, optimize query, deploy, incident response,
  write migration, security review, release, dependency upgrade).
- **Event-driven triggers** (PR opened → review, CI failure → QA, etc.). These
  require GitHub Actions / webhook infrastructure and are real work, not markdown —
  added after the core loop is proven.
- Stack-agnostic agent templates beyond the current Rails-first defaults.

The objective isn't more agents — it's a more capable engineering organization,
grown one proven slice at a time.

---

## Contributing

New agents, skills, and playbooks should have a single well-defined responsibility,
reuse the shared organizational knowledge, minimize overlap, and integrate through
the Conductor rather than coordinating with each other directly.
