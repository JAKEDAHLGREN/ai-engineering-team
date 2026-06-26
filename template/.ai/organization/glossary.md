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

## Domain terms
<!-- Add project-specific terms during onboarding so agents don't guess meanings. -->

_TODO._
