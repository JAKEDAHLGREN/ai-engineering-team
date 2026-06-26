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

<!-- Add project-specific rules below during onboarding. -->
