---
name: run-tests
description: Procedure for running the project's test suite and reporting an honest, objective pass/fail verdict. Use to produce the done-signal for any code change before it is declared complete.
---

# Run Tests

The procedure that turns "looks done" into "is done." This is the objective
done-signal the Conductor depends on.

## Steps

1. **Run the suite:** `{{TEST_COMMAND}}`.
   - For a targeted change, you may first run the relevant subset, but a final
     full run is what authorizes "done."

2. **Read the actual output.** Do not infer success from exit code alone — confirm
   the summary line (counts of runs/failures/errors).

3. **On failure:** capture the failing tests and their real output verbatim. Do not
   summarize a red suite as "mostly passing." A single failure means FAIL.

4. **Check coverage of the change.** If the new behavior has no test exercising it,
   that's a gap — flag it (or write the test) before declaring done.

5. **Report a verdict:**
   - **PASS** — full suite green and the change is covered. Quote the summary line.
   - **FAIL** — list what failed with output, and which acceptance criterion it
     violates. Tag each failure or gap with a category from
     `.ai/organization/finding_vocabulary.md` (e.g. `[MISSING_TEST]`) — exact
     strings, one tag per finding, so the Conductor can track recurrence across
     rounds.

## Rule
Never report PASS without having actually run the suite in this session and seen it
green. Reported-but-unrun is the failure this skill exists to eliminate.
