---
name: optimize-query
description: Procedure for diagnosing and fixing a slow query — measure the baseline, read the real plan, find the cause, apply the smallest fix, and prove the gain. Use when a query is slow and needs evidence-based tuning.
---

# Optimize Query

A reusable procedure — *how* to make a slow query fast without guessing. Any agent
with edit access can run it; it does not belong to one identity.

## Steps

1. **Reproduce and measure the baseline.** Run the slow query (or the request that
   triggers it) and record a real number — wall time, row count, query count. You
   cannot prove an improvement against a baseline you never took.

2. **Inspect the actual plan.** Run `EXPLAIN`/`ANALYZE` on the real query against
   representative data. Read what the engine actually does — seq scans, sort/spill,
   estimated vs. actual rows — not what you assume it does.

3. **Identify the cause from the plan, not a hunch.** Name it precisely: a missing
   index, an N+1 (many small queries where one would do), a bad join order, or
   over-fetching columns/rows you don't use. Diagnosis comes before any edit.

4. **Apply the smallest fix that addresses that cause.** Eager-load the N+1, select
   only needed columns, fix the join, or — if a schema/index change is needed —
   hand it to the database-engineer with your evidence rather than editing the
   schema yourself. Don't pile on speculative changes.

5. **Re-measure under the same conditions.** Re-run the baseline measurement from
   step 1 and the plan from step 2. Compare directly: before vs. after, same data,
   same method.

6. **Report the result.** State the baseline, the change, and the after number, plus
   the new plan if it changed. If the fix didn't measurably help, say so and revert
   it — a change with no proven gain is debt, not an optimization.

## Rule
Never claim an optimization without a before/after measurement taken in this session.
"It should be faster" is the failure this skill exists to eliminate — only the
numbers decide.
