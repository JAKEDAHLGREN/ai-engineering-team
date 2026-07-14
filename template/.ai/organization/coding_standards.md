# Coding Standards — {{PROJECT_NAME}}

> The rules every agent inherits. When in doubt, match the surrounding code.

## Universal rules
- **Match the codebase.** Naming, structure, and idioms of nearby code override
  personal preference.
- **Smallest correct change.** Build the work item; don't refactor unrelated code.
  Record improvements as technical debt instead.
- **No silent scope creep.** If the plan is wrong, hand it back — don't diverge.
- **Tests are part of the change**, not an afterthought. New behavior ships covered.

## {{PRIMARY_LANGUAGE}} / {{FRAMEWORK}} conventions
- Follow {{FRAMEWORK}} conventions over custom abstractions.
- Keep controllers thin; put business logic in models/services.
- Database changes go through migrations; never edit schema by hand.
- {{FRONTEND}} for the view layer — progressive enhancement over heavy client JS.

## Quality gates
- Code must boot/load before handoff.
- `{{TEST_COMMAND}}` must pass before anything is declared done.
- No new linter/style violations introduced by the change.

## Reporting protocol (every agent)
End every turn with the same report shape — role-specific extras are named in
your agent file:

- **What changed** — files touched and what each change does.
- **What you verified** — only what you actually ran or checked *in this
  session*. Never claim verification you didn't perform.
- **Findings & risks** — every finding tagged from `finding_vocabulary.md`
  (`[TAG] file:line — description`, one tag per finding); note anything left
  for QA or recorded as technical debt.
- **Status** — builders state "implemented; ready for QA," never "done." QA
  owns the objective done-signal and is the only agent that reports PASS/FAIL.
  Roles whose output is a different artifact (the tech-lead's plan, QA's
  verdict, the analyst's proposals) end with that artifact's path instead.
- **Agent Notes** — end with assumptions you made and where you struggled; write
  "None." rather than omitting either. These notes are the raw material for
  improving the standards and skills.
- **Consequential decisions** — when you chose between real alternatives, name
  the decision, the alternative you rejected, and the outcome you expect
  ("expected: …"). The Conductor records what actually happened at close-out;
  expectation misses are how the team learns.
- **Write it to the work directory** when your dispatch names one
  (`.ai/work/{NNN}-{slug}/` — see its README for file names): save the report
  there and return the path plus a one-paragraph summary, not the full text.

<!-- Add project-specific rules below during onboarding. -->
