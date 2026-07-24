# Roadmap — Next Big Changes

> A reference for the larger structural moves still ahead, from Robert Evans'
> feedback. These are deliberately **deferred** — Robert's own guidance: don't
> attempt them until you fully understand where the current single-team design is
> strong and weak, and you're comfortable with how it behaves and where it breaks.
> Dogfood the current team on real work first (Vozey is the proving ground).

Everything shipped so far — the learning loop, file-based handoffs, the memory
database, the engineer/skills collapse with a beliefs layer — was groundwork. The
two items below are a different scale: they change the *shape* of the org, not just
its wiring.

---

## 1. Grow evaluation/ops roles into sub-teams

### The idea
Today one agent owns each of QA, security, devops, and design(-adjacent) work. But
each of those is really a *domain* with many distinct checks, not a single job.
Robert's example for QA: "did the page load, did the form work, is the design
consistent, is it accessible, is the copy correct and consistent across the app."
Those are separate competencies, each its own agent with its own skills, coordinated
by one orchestrating agent for that domain.

### The distinction that drives it
- **Construction roles** (backend, frontend) → collapse into one `engineer` + skills.
  *(Done — see the current roster.)*
- **Evaluation / ops roles** (QA, security, devops) → *expand* into sub-teams, because
  each covers many independent checks that benefit from focused context.

The test for "agent vs. sub-team": is this role *making* one thing (one engineer,
many skills), or *judging/operating* across many independent dimensions (a team)?

### What a QA sub-team might look like
- A `qa-orchestrator` that coordinates and combines verdicts.
- Focused agents underneath, e.g. `qa-functional` (does it work / tests),
  `qa-accessibility`, `qa-visual-consistency`, `qa-copy` (wording correct and
  consistent app-wide). Each has narrow skills and a narrow context window.
- The Conductor dispatches the QA orchestrator; the orchestrator fans out to its
  agents and returns one combined PASS/FAIL. Security and devops follow the same
  pattern.

### Why it's hard / why to wait
- Subagents can't spawn subagents in Claude Code — so a "sub-team orchestrator"
  can't itself use the Task tool to fan out. This is the core constraint to solve
  first: likely the Conductor still does the fan-out, or the domain orchestrator runs
  on the main thread the way discovery does. Prototype the wiring on **one** domain
  (QA is the natural first) before touching the others.
- More agents = more dispatch cost and more coordination surface. The payoff is
  sharper output per check; the cost is orchestration complexity. Only worth it once
  a single QA agent is demonstrably too coarse on real work.
- Roster/counts, the smoke roster-consistency assertion, and the playbooks all need
  to understand a two-level hierarchy.

### First concrete step (when ready)
Split **only QA** into an orchestrator + 2–3 focused agents behind it, keep everything
else flat, run several real features through it, and compare output quality and cost
against the single-QA baseline. Promote the pattern to security/devops only if QA
proves it out.

---

## 2. Per-project team specialization

### The idea
The common approach — one generic agentic team reused across every project — is, in
Robert's view, wrong: "The more specific your team is, the better it performs. The
more generic it is, the worse it performs." Build the team for the work in front of
it. Agents may be reused, but the **skills and orchestration** can differ per project
based on that project's needs.

### The model: global base + project-specific layer
- **Global (reusable across projects):** the core agents and cross-cutting skills —
  the stuff `ait` ships today.
- **Project-specific (per repo):** skills and orchestration tuned to that codebase —
  its domain vocabulary, its architectural rules, its recurring risks. These give
  tighter control over output for that project.

The good news: the framework is already shaped for this. `.ai/organization/` and
project-added agents/skills are project-owned and untouched by `ait update`. And the
**learning loop already produces project-specific skills by construction** — every
skill the `retrospective` playbook generates exists to prevent a mistake that
actually recurred *in that project*. So specialization can grow organically from
real runs rather than being designed up front.

### The tension to resolve
This pulls against the installer's current "one team, any project" value prop. The
reconciliation: reframe `ait init` as shipping a **base scaffold** that each project
is *expected* to specialize — not a finished product. That's a documentation and
positioning change as much as a code one.

### Why it's hard / why to wait
- Deciding the global/project boundary per skill is a judgment call that's easier
  after you've run several different kinds of project and seen what actually diverges.
- Vozey is one project; you need at least a second, different one before "what's
  generic vs. specific" is answerable from evidence rather than guesswork.

### First concrete step (when ready)
On Vozey, let the `retrospective` loop run for a while and watch which generated
skills are clearly Vozey-specific vs. broadly reusable. That real split is the data
that tells you where the global/project line actually sits — then formalize it (e.g.
a documented convention for "global skills" vs. "project skills," and an `ait`
note that project skills are expected, not exceptional).

---

## Suggested order

1. **Dogfood first.** Run the current single-team design on real Vozey work until you
   can name its rough edges. Nothing below is worth doing before this.
2. **QA sub-team prototype** (item 1, QA only) — smaller, self-contained, and it
   directly tests whether the sub-team pattern earns its complexity.
3. **Per-project specialization** (item 2) — best driven by data from the learning
   loop and from a second project, so it naturally comes later.

## Guardrails to keep whatever you build

The framework already enforces these; don't lose them in a restructure:
- Roster consistency is CI-checked (`test/ait-smoke.sh`) — a two-level hierarchy will
  need that assertion updated, not bypassed.
- Findings stay tagged from `finding_vocabulary.md`; the circuit-breaker and the
  memory database depend on it.
- Improvements remain **human-gated** through the `retrospective` playbook — more
  agents must not mean more unattended self-modification.
