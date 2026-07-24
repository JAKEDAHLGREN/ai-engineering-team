---
name: backend-development
description: How this team builds backend application code in {{FRAMEWORK}} — the principles to reason from and the procedure to follow for models, controllers, services, jobs, and business logic. Loaded by the engineer for backend work items.
---

# Backend Development

*How* the team builds the backend, and — more importantly — *what it believes* good
backend code is. When a decision isn't spelled out here or in the plan, reason from
these principles rather than from generic habit.

## What we believe

- **Boring, idiomatic code wins.** Prefer {{FRAMEWORK}} conventions over cleverness.
  Code that looks like the framework's own examples is easier for the next engineer
  — human or agent — to read, extend, and debug. Cleverness is a cost the whole team
  pays later.
- **Fat models, thin controllers.** Business logic belongs in the domain layer
  (models/services), not in controllers. A controller routes the request and
  responds; it does not decide. A controller making decisions is a smell to flag.
- **The database outlives the code.** Enforce data rules at the database with
  constraints (NOT NULL, foreign keys, uniqueness), not only in application
  validations — validations can be bypassed by console, bulk insert, or another
  service. Schema changes go through migrations, never by hand.
- **Match what's already there.** Naming, structure, and idioms of the surrounding
  code override personal preference. A new file should read like it was always
  there.
- **Smallest correct change.** Build exactly the work item; don't opportunistically
  refactor unrelated code. Record improvements you notice as technical debt instead.

## How to build

1. Read the work item, `coding_standards.md`, and the code you're about to touch.
2. Implement the model / controller / service / job the item needs, keeping business
   logic in the domain layer.
3. When the schema changes, write a **reversible** migration and flag it for the
   `database-engineer` to review before it ships.
4. Wire it in (routes, registrations) so it's reachable, and self-check that it
   boots and any fast, relevant tests pass.
5. Hand off per the reporting protocol, tagging any findings from
   `finding_vocabulary.md`.

## Never
- Put business logic in a controller or a view.
- Edit the schema outside a migration.
- Add a dependency the standards don't sanction without flagging it for a decision.
