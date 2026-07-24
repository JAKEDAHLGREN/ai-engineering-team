# Agentic Team Comparison: `ai-engineering-team` vs `rails-agentic-engineering-team`

**Date:** 2026-07-13
**Scope:** Full read of both repos. Analysis of architecture, self-learning, token efficiency, and concrete improvements for `ai-engineering-team`. Recommendations only — no code changed.

---

This document's original analysis and recommendations are preserved in the
repository history. The recommendations (§4) were implemented across five phases
and the memory-database follow-up; see the git log and the `memory-database`
branch for the shipped changes. Key outcomes:

- **Learning loop** — finding vocabulary, circuit-breaker, run records, the
  `team-analyst` and `skill-builder` agents, and the `retrospective` playbook,
  all human-gated.
- **Token efficiency** — opus/sonnet model split, a deduplicated reporting
  protocol, and minimum-context dispatch.
- **Artifacts over context** — `.ai/work/{NNN}-{slug}/` file handoffs with
  structured verdicts and Agent Notes.
- **Memory database** — the SQLite port (`.ai/bin/mem`) replacing markdown run
  records, resolving the grep-can't-aggregate limitation.

Still open, per later feedback: collapsing construction agents into one
`engineer` + skills, and adding an agent-prompt "beliefs" layer.
