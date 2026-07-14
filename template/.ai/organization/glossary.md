# Glossary — {{PROJECT_NAME}}

> Shared vocabulary so agents and humans mean the same thing.

## Framework terms
- **Conductor** — the main thread (`CLAUDE.md`). Plans and dispatches; writes no
  application code.
- **Agent** — a specialist identity in `.claude/agents/`. Defines *who* does work.
- **Skill** — a reusable procedure in `.claude/skills/`. Defines *how* work is done;
  any agent can run one.
- **Playbook** — an ordered sequence of skills across agents, in `.ai/playbooks/`.
  Defines *the process* for a recurring situation.
- **Memory** — durable project knowledge in `.ai/memory/`, indexed by `INDEX.md`.
- **Done-signal** — the objective verification (test suite green + acceptance
  criteria met) that authorizes calling work complete.
- **Work directory** — `.ai/work/{NNN}-{slug}/`, one task's in-flight artifacts:
  brief, plan, reports, verdicts. Handoffs are paths; an interrupted task
  resumes at the first missing artifact.
- **Finding tag** — a category from `organization/finding_vocabulary.md`, e.g.
  `[AUTH_SCOPE]`. Exact strings, one per finding — what makes recurrence
  detectable.
- **Circuit-breaker** — the same tag failing two consecutive rounds is named
  explicitly; a third round stops the loop and escalates to the user.
- **Run record** — the durable distillation of a completed task in
  `.ai/memory/runs/`: rounds, verdicts, tagged findings, expected → observed
  decisions. The `team-analyst`'s dataset.
- **Proposal** — an evidence-backed improvement written by the `team-analyst`
  to `.ai/memory/proposals/`; the `skill-builder` applies it only after the
  user approves.

## Domain terms
<!-- Add project-specific terms during onboarding so agents don't guess meanings. -->

_TODO._
