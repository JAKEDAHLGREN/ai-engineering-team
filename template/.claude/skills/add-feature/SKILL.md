---
name: add-feature
description: Procedure for implementing a planned feature work item in a {{FRAMEWORK}} codebase, from reading the plan through leaving the change ready for QA. Use when an agent has been assigned a feature work item to build.
---

# Add Feature

A reusable procedure — *how* to build a feature work item. Any agent with edit
access can run it; it does not belong to one identity.

## Steps

1. **Anchor on the plan.** Read the assigned work item: its deliverable, the files
   it touches, and its acceptance criteria. If the item is ambiguous or wrong, stop
   and hand it back — do not guess your way into the wrong build.

2. **Load standards.** Read `.ai/organization/coding_standards.md` and the existing
   code in the area you're changing. Your code should be indistinguishable in style
   from what's already there.

3. **Implement the smallest correct change.** Build exactly the work item. Resist
   scope creep; note unrelated improvements as technical debt rather than doing them.

4. **Wire it in.** Routes, registrations, dependency injection — whatever makes the
   feature actually reachable, not just present.

5. **Self-check.** Confirm the code loads/boots and run any fast, relevant tests
   locally. Fix obvious breakage before handing off.

6. **Hand off to QA.** Report: files changed, what you verified, what remains. State
   "implemented; ready for QA" — the `run-tests` skill and QA Engineer own the final
   done-signal.

## Done means
The work item's acceptance criteria are achievable and the change is ready for
objective verification — not "it looks finished."
