# Playbook — Retrospective

> The ordered sequence the Conductor runs to turn accumulated run records into
> approved improvements. This is how the team learns: evidence → proposals →
> **your approval** → applied skills and standing rules. Nothing self-modifies.

**Trigger:** roughly every 5 completed run records, after any circuit-breaker
escalation, or on demand ("what keeps going wrong?"). With fewer than 3 records
the analyst has anecdotes, not patterns — wait.

**Owner:** the Conductor (`CLAUDE.md`) drives every step; the user is the gate.

## Sequence

1. **Analyze** → dispatch `team-analyst`.
   It queries the memory database (`.ai/bin/mem` / read-only SQL), reads the
   current agents/skills/standards and prior proposals, then writes an
   evidence-backed proposal report to `.ai/memory/proposals/YYYY-MM-DD.md`.
   Output: the report path and a numbered one-line summary per proposal.

2. **Review** → Conductor, with the user.
   Present each proposal's one-liner with its evidence counts and confidence.
   The user approves selectively, by number. **No approval, no change** — a
   declined proposal stays on file so it isn't re-proposed.

3. **Execute** → dispatch `skill-builder` with the report path and the approved
   numbers only.
   It applies each approved proposal verbatim — new skills in
   `.claude/skills/`, standing rules in the organization files — and appends a
   build note to the proposal report.
   Output: files changed and the build note.

4. **Record** → Conductor.
   Append one line to `.ai/memory/INDEX.md` for the retrospective (report path,
   N approved / M proposed). New skills and rules take effect on the next
   dispatch — agents load them like everything else.

## Done means
Every approved proposal is applied and noted, every declined one is marked, and
the retrospective is indexed. The team's next run works under the improved
rules. Nothing was changed that the user didn't approve.
