# Playbook — Feature Request

> The ordered sequence the Conductor runs when the user asks for a new feature.
> This is the v1 vertical slice that proves the whole team wiring end to end.

**Trigger:** a user requests new behavior or a change to existing behavior.

**Owner:** the Conductor (`CLAUDE.md`) drives every step; specialists execute.

## Sequence

1. **Plan** → dispatch `tech-lead`.
   Output: an implementation plan with work items, owners, dependencies, and
   **acceptance criteria** (including which tests must pass). If the Tech Lead
   surfaces an open question that's genuinely the user's call, the Conductor asks
   the user before proceeding.

2. **Build** → dispatch the engineer who owns each work item, running the
   `add-feature` skill against the plan and the coding standards:
   - `rails-engineer` — backend: models, controllers, services, jobs, business logic.
   - `frontend-engineer` — UI: views, components, styling, interactivity, a11y.
   - `database-engineer` — non-trivial migrations, indexes, and constraints; and
     **reviews any schema change** another engineer produces before it ships.

   Dispatch independent work items in parallel (e.g. backend and UI often proceed
   together once the data contract is set); dependent items wait on their blockers.
   A work item that touches the schema is not complete until `database-engineer`
   has reviewed the migration.
   Output: implemented changes, "ready for QA," with files and risks reported.

3. **Verify** → dispatch `qa-engineer`.
   QA runs the `run-tests` skill (`{{TEST_COMMAND}}`), checks the change against the
   acceptance criteria, and adds regression coverage for new behavior.
   Output: a **PASS/FAIL** verdict with real test output.

4. **Integrate & judge** → Conductor.
   - FAIL → return to step 2 with the specific failure; do not declare done.
   - PASS → the feature is done.

5. **Record** → Conductor.
   Append a one-line entry to `.ai/memory/INDEX.md`. For anything architecturally
   significant, add a dated note under `.ai/memory/decisions/` and log it in
   `organization/decision_log.md`.

## Done means
The `tech-lead`'s acceptance criteria are met and `qa-engineer` reported PASS with
the suite green. Nothing less.
