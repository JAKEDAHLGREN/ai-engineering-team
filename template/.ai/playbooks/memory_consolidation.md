# Playbook — Memory Consolidation

> The ordered sequence the Conductor runs to keep project memory small, current,
> and trustworthy. Memory that accumulates without pruning stops being read —
> and stale entries actively mislead. Consolidate; never silently delete.

**Trigger:** `.ai/memory/INDEX.md` exceeds ~50 entries, a stale or contradicted
entry is noticed mid-task, or on demand after several retrospectives.

**Owner:** the Conductor (`CLAUDE.md`) drives; `documentation-engineer` executes.

## Sequence

1. **Audit** → dispatch `documentation-engineer`.
   Read `INDEX.md` and scan the scope folders for: duplicate entries saying the
   same thing, decisions superseded by later decisions, technical debt already
   paid down, and entries contradicted by the current code (verify against the
   code before judging). Output: a consolidation list — each item marked
   *merge*, *supersede*, or *prune*, with the evidence.

2. **Review** → Conductor, with the user when in doubt.
   Anything ambiguous — "is this decision still live?" — is the user's call,
   not a guess. Confirm the list before touching memory.

3. **Consolidate** → dispatch `documentation-engineer`.
   - **Merge** duplicates into one authoritative entry; the survivors keep the
     richest content.
   - **Supersede, don't delete, decisions:** mark the old entry "superseded by
     {newer entry}" so the history of *why* remains traceable.
   - **Prune** paid-down debt and stale entries whose content is captured
     elsewhere; note in the commit/summary what was pruned and why.
   - Rewrite `INDEX.md` to match — every surviving note indexed, nothing
     orphaned, newest first.
   - **Leave `runs/` and `proposals/` alone** — they are the analyst's
     append-only dataset, not prose memory.

4. **Verify** → Conductor.
   Every pruned line is either superseded, merged, or genuinely obsolete —
   spot-check against the code. An INDEX entry pointing at a deleted note, or a
   note missing from the INDEX, fails the consolidation.

5. **Record** → Conductor.
   One INDEX line for the consolidation itself: date, entries before → after,
   anything superseded worth naming.

## Done means
The INDEX is shorter than it started, every entry it lists exists and is
current, superseded decisions still trace to their replacements, and the
analyst's datasets were untouched.
