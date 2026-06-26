# Playbook — Production Incident

> The ordered sequence the Conductor runs when production is broken.
> Stabilize first, diagnose from evidence, fix minimally, verify objectively,
> then write it down so it can't happen the same way twice.

**Trigger:** production is degraded or down — errors, an outage, a slow or
unresponsive system, data corruption, or a suspected security breach.

**Owner:** the Conductor (`CLAUDE.md`) drives every step; specialists execute.

## Sequence

1. **Triage** → Conductor, pulling in the specialist whose domain matches the
   symptom to scope blast radius (`performance-engineer` for slow/resource
   issues, `database-engineer` for data, `security-engineer` for a suspected
   breach). Assess severity and impact: who's affected, how badly, is data at
   risk. **Stabilize first** — when a mitigation or rollback can stop the
   bleeding, do that *before* root-causing; a fast recovery beats a slow,
   perfect diagnosis.
   Output: a severity call, the blast radius, and whether a mitigation is in place.

2. **Diagnose** → dispatch the specialist whose domain matches the symptom:
   - `performance-engineer` — latency, timeouts, memory/CPU, saturation.
   - `database-engineer` — bad data, slow queries, locks, migrations gone wrong.
   - `rails-engineer` — incorrect business logic or application behavior.
   - `security-engineer` — a breach, vulnerability, or exposed data.

   Diagnose from **evidence** — logs, metrics, query plans, traces — not
   guesswork. The output is a root cause that explains the observed symptom, not
   a plausible theory.
   Output: a named root cause backed by the evidence that confirms it.

3. **Fix** → dispatch the engineer who owns that root cause.
   Implement the **minimal correct fix** for the root cause — not a refactor, not
   a redesign. Anything larger than the fix is captured as follow-up, not done now.
   Output: the implemented fix, "ready for QA," with files and risks reported.

4. **Verify** → dispatch `qa-engineer`.
   QA **reproduces the failure first** so the bug is captured, confirms the fix
   resolves that exact failure, then runs the `run-tests` skill (`{{TEST_COMMAND}}`)
   and adds regression coverage so it can't recur silently. If the incident was
   security-related, `security-engineer` validates that the impact is closed.
   Output: a **PASS/FAIL** verdict with real test output and a repro that now passes.

5. **Resolve & restore** → Conductor.
   - FAIL → return to step 2 with the specific failure; do not declare resolved.
   - PASS → confirm production is healthy (metrics nominal, errors cleared, any
     temporary mitigation safely removed or made permanent). The incident is over.

6. **Record + postmortem** → Conductor.
   Append a one-line entry to `.ai/memory/INDEX.md`, then write a **blameless**
   postmortem note under `.ai/memory/` — what happened, root cause, the fix, and
   prevention. Capture a concrete follow-up to stop recurrence: the regression
   test from step 4, or a `technical_debt` entry for the deeper work. Log any
   decision in `.ai/memory/decisions/` and `organization/decision_log.md`.

## Done means
Production is healthy, `qa-engineer` reported PASS with the suite green and the
failure reproduced-then-fixed, and the postmortem plus a recurrence-prevention
follow-up are written down. Nothing less.
