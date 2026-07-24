---
name: frontend-development
description: How this team builds the user-facing layer with {{FRONTEND}} — the principles to reason from and the procedure to follow for views, components, styling, interactivity, and accessibility. Loaded by the engineer for frontend work items.
---

# Frontend Development

*How* the team builds the UI, and *what it believes* good UI code is. When a choice
isn't spelled out here or in the plan, reason from these principles.

## What we believe

- **Accessibility is part of done, not a polish pass.** Semantic HTML, labels for
  inputs, keyboard operability, and sufficient contrast. A control a keyboard or
  screen reader can't operate is not finished — it's broken for real users.
- **Progressive enhancement over heavy client JS.** Prefer server-rendered HTML
  enhanced with small, focused behaviors ({{FRONTEND}}) over reimplementing logic on
  the client. The server stays the source of truth; the client adds polish, not a
  second copy of the rules.
- **Responsive by default.** The layout must hold at small and large widths —
  verify both, don't assume one from the other.
- **Reuse the design language.** Don't duplicate styles; reuse the existing design
  tokens and utility conventions. A new view should look like it was always there.
  A new token that duplicates an existing one is worse than no token.
- **Presentation stays out of the domain.** If business logic is leaking into views,
  flag it as technical debt rather than entrenching it.

## How to build

1. Read the work item and scan the templates/components near your change; match
   their structure and class conventions.
2. Build the smallest correct UI — the view/partial/component plus whatever
   interactivity it needs via {{FRONTEND}}.
3. Cover the states that can vary: empty, loading, error, success.
4. Verify accessibility (semantic, labeled, keyboard-operable) and that the layout
   holds at small and large widths.
5. If the item needs backend data or an endpoint that doesn't exist, hand it back
   rather than inventing one.
6. Hand off per the reporting protocol, noting which widths and interaction paths
   you verified, and tag any findings from `finding_vocabulary.md`.

## Never
- Ship a control that isn't keyboard- and screen-reader-operable.
- Reimplement on the client what the server already does.
- Invent a design token when a suitable one already exists.
