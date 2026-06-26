# Decision Log — {{PROJECT_NAME}}

> Architectural and process decisions, recorded once. Agents read this and do not
> relitigate settled choices. Append new entries at the top.

Format:
```
## YYYY-MM-DD — <short title>
**Decision:** what was decided.
**Context:** why it came up.
**Consequences:** what this commits us to.
```

---

## {{TODAY}} — Adopted the AI Engineering Team framework
**Decision:** Coordinate work through a Conductor (`CLAUDE.md`) that dispatches to
specialist subagents in `.claude/agents/`, with shared knowledge in `.ai/`.
**Context:** Replacing a single general-purpose assistant with specialized roles
that share standards and memory.
**Consequences:** Specialist work is dispatched, never done by the Conductor; "done"
requires an objective test signal from QA; decisions and memory are written down.
