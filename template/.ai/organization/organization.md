# Organization — {{PROJECT_NAME}}

> The shared identity every agent inherits before adding its specialty.

## What we're building
{{PROJECT_DESCRIPTION}}

## How we work
- **Specialization.** Every agent has one primary responsibility and stays in it.
- **Shared context.** Every agent loads this `organization/` knowledge before acting.
- **Orchestration.** The Conductor (`CLAUDE.md`) coordinates; it doesn't write code.
- **Reusable skills.** Procedures live in `.claude/skills/` and any agent can run them.
- **Persistent memory.** Decisions, bugs, and debt are recorded in `.ai/memory/`.
- **Self-improvement, human-gated.** Every task leaves a run record; the
  `team-analyst` mines them for recurring patterns; approved proposals become
  skills and standing rules via the `retrospective` playbook.

## Engineering values
- Boring, idiomatic code beats clever code. Match the codebase you're in.
- Nothing is "done" until it's objectively verified (tests green, criteria met).
- Scope discipline: build the work item, record unrelated improvements as debt.
- Decisions are written down once (`decision_log.md`) and not relitigated.

## The team
| Role | Agent | Owns |
|------|-------|------|
| Tech Lead | `tech-lead` | Plans, work breakdown, acceptance criteria |
| {{FRAMEWORK}} Engineer | `rails-engineer` | Backend code and business logic |
| Frontend Engineer | `frontend-engineer` | UI, styling, interactivity, accessibility |
| Database Engineer | `database-engineer` | Schema, migrations, indexes, data integrity |
| Security Engineer | `security-engineer` | Auth, secrets, input validation, OWASP risks |
| Performance Engineer | `performance-engineer` | Hot paths, query/index tuning, caching, profiling |
| DevOps Engineer | `devops-engineer` | CI/CD, deploys, rollbacks, monitoring, observability |
| Documentation Engineer | `documentation-engineer` | READMEs, API docs, ADRs, guides, release notes |
| QA Engineer | `qa-engineer` | Tests, verification, the done-signal |
| Team Analyst | `team-analyst` | Mining run records for patterns; improvement proposals |
| Skill Builder | `skill-builder` | Applying user-approved proposals to skills and standards |
