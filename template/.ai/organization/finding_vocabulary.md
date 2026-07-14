# Finding Vocabulary — {{PROJECT_NAME}}

> The controlled category vocabulary for review findings and QA failures.
> **Every finding gets exactly one tag, using these exact strings.** Consistent
> tags are what make recurrence detectable across features — free-text findings
> cannot be aggregated; `[AUTH_SCOPE]` appearing on five features can.

## How to use

- Reviewers (`qa-engineer`, `security-engineer`, `performance-engineer`,
  `database-engineer` when reviewing) tag every finding in their **verdict
  file**: `[CATEGORY] file:line — description`. Builders tag risks the same
  way in their **reports**.
- The Conductor tracks **verdict** tags across review rounds (see the
  circuit-breaker in `CLAUDE.md`): same tag failing two rounds is named
  explicitly; three rounds escalates to the user. All tags — verdicts and
  reports — are collected into the run record at close-out.
- A tag that recurs across **3+ features** is a signal that a standing rule or
  skill should exist to prevent it — record it in `.ai/memory/` when noticed.

## Code quality

| Tag | What it flags |
|-----|---------------|
| `MISSING_TEST` | New behavior without a test — happy path, sad path, edge case, or branch |
| `CONVENTION` | {{FRAMEWORK}} or house convention violated (structure, callbacks, idioms) |
| `NAMING` | Unclear, abbreviated, or inconsistent naming on any identifier |
| `COMPETING_PATTERN` | A second way of solving a problem the codebase already solves |
| `FAT_CONTROLLER` | Business logic in a controller/handler instead of the domain layer |
| `DEAD_CODE` | Debug artifact, commented-out code, or TODO/FIXME left in the change |
| `SCOPE_CREEP` | Change beyond the assigned work item that wasn't handed back |

## Security

| Tag | What it flags |
|-----|---------------|
| `AUTH_SCOPE` | Record lookup or action not scoped to the acting user's authorization |
| `INJECTION` | SQL/command/template injection — untrusted input reaching a sink unescaped |
| `XSS` | Unescaped user content in rendered output |
| `MASS_ASSIGNMENT` | Parameter allow-listing missing or too permissive |
| `SECRET_EXPOSURE` | Credential, key, or token in code, config, logs, or output |
| `CSRF` | CSRF protection weakened or bypassed without a documented reason |
| `VULN_DEPENDENCY` | Known-vulnerable or unmaintained dependency introduced or retained |

## Performance & data

| Tag | What it flags |
|-----|---------------|
| `N_PLUS_ONE` | Association or query fired inside a loop instead of batched/eager-loaded |
| `MISSING_INDEX` | Foreign key or frequently-filtered column without an index |
| `UNSCOPED_QUERY` | Collection loaded without scoping or pagination |
| `BLOCKING_CALL` | Long-running work on the request path that belongs in a background job |
| `DATA_INTEGRITY` | Data rule enforced only in the app — no constraint at the database |
| `UNSAFE_MIGRATION` | Migration that locks large tables, rewrites data, or has no rollback path |

## Rules

- One tag per finding; pick the most specific. If two genuinely apply, file two
  findings.
- Severity still gates "done" as each agent's rules define — the tag classifies
  *what kind* of problem, not *how bad*.
- Missing a category? Add it below during onboarding or when a real finding
  doesn't fit — keep names SCREAMING_SNAKE, specific, and stable once used
  (renaming a tag breaks recurrence history).

## Project-specific tags

<!-- Add project-specific categories here. -->

_None yet._
