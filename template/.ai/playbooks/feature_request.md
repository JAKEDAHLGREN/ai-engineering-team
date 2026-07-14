# Playbook — Feature Request

> The ordered sequence the Conductor runs when the user asks for a new feature.
> This is the v1 vertical slice that proves the whole team wiring end to end.

**Trigger:** a user requests new behavior or a change to existing behavior.

**Express lane:** a trivial fix — **one work item, one owner, no schema, auth,
or user-facing surface change** — skips this playbook: dispatch the owning
engineer, then `qa-engineer`, findings tagged as usual. Clean PASS → one INDEX
line, nothing else. Any FAIL, any finding, a second owner, or a second round →
it was never trivial: open the work directory and run the full sequence below.

**Owner:** the Conductor (`CLAUDE.md`) drives every step; specialists execute.

**Artifacts:** every output below is a file in `.ai/work/{NNN}-{slug}/` (see
`.ai/work/README.md`). Handoffs are paths, and an interrupted run resumes at the
first missing artifact.

## Sequence

1. **Clarify** → Conductor, with the user.
   Building the wrong thing correctly is the most expensive failure, so before
   planning: if the request is ambiguous about **who it's for, what "done"
   looks like, or what's out of scope**, ask the user 2–3 targeted questions —
   one or two at a time, not a form. Capture what was settled (including
   directions considered and rejected) in `brief.md` in the work directory.
   If the request is already precise, skip the questions and the file — don't
   interview someone who's told you what they want.
   Output: `brief.md` when clarification happened; otherwise nothing.

2. **Plan** → dispatch `tech-lead`.
   Output: `plan.md` in the work directory — work items, owners, dependencies,
   and **acceptance criteria** (including which tests must pass). If the Tech
   Lead surfaces an open question that's genuinely the user's call, the
   Conductor asks the user before proceeding.

3. **Build** → dispatch the engineer who owns each work item, running the
   `add-feature` skill against the plan and the coding standards:
   - `rails-engineer` — backend: models, controllers, services, jobs, business logic.
   - `frontend-engineer` — UI: views, components, styling, interactivity, a11y.
   - `database-engineer` — non-trivial migrations, indexes, and constraints; and
     **reviews any schema change** another engineer produces before it ships.

   Dispatch independent work items in parallel (e.g. backend and UI often proceed
   together once the data contract is set); dependent items wait on their blockers.
   A work item that touches the schema is not complete until `database-engineer`
   has reviewed the migration and written `verdict-database.r{round}.md` — a
   schema review is a verdict, so its tags count toward the circuit-breaker.
   Output: implemented changes, plus each builder's report at
   `report-{agent}.r{round}.md` — "ready for QA," files and risks per the
   reporting protocol.

4. **Verify** → dispatch `qa-engineer`.
   QA runs the `run-tests` skill (`{{TEST_COMMAND}}`), checks the change against the
   acceptance criteria, and adds regression coverage for new behavior. Every
   failure or gap is tagged with a category from
   `.ai/organization/finding_vocabulary.md`.
   Output: `verdict-qa.r{round}.md` — a structured **PASS/FAIL** verdict with
   real test output and tagged findings (format in `.ai/work/README.md`).

5. **Integrate & judge** → Conductor.
   - FAIL → return to step 3 with the specific failure; do not declare done.
   - PASS → the feature is done.

   **Circuit-breaker:** track failing categories across the round verdict files
   (`verdict-*.r*.md`).
   - Same category fails in **two consecutive rounds** → name it explicitly in the
     re-dispatch (quote both rounds' findings); never silently re-route.
   - Same category fails a **third round** → **stop and escalate to the user.**
     Three rounds of the same failure means the plan, the standards, or the
     acceptance criteria are wrong — not the engineer. Do not burn a fourth round.

6. **Record** → Conductor.
   Distill the work directory into a run record at `.ai/memory/runs/` (verdicts,
   tagged findings, decisions with expected → observed outcomes, Agent Notes —
   format in the runs README). Append a one-line entry to `.ai/memory/INDEX.md`.
   For anything architecturally significant, add a dated note under
   `.ai/memory/decisions/` and log it in `organization/decision_log.md`.

## Done means
The `tech-lead`'s acceptance criteria are met and `qa-engineer` reported PASS with
the suite green. Nothing less.
