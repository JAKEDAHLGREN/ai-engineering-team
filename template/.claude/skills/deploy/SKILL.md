---
name: deploy
description: Procedure for shipping a verified change to production safely — confirm the done-signal, line up a rollback, release through CI/CD, and watch production health. Use to deploy a change that has passed QA.
---

# Deploy

A reusable procedure — *how* to ship to production without breaking it. Any agent
with the access can run it; it usually falls to the `devops-engineer`. The pipeline
going green is not the same as production being healthy — this procedure closes
that gap.

## Steps

1. **Confirm the done-signal.** The change must carry a green `qa-engineer` PASS.
   No verified PASS, no deploy — stop and send it back instead.

2. **Confirm the rollback path.** Know exactly how to revert *before* you ship. A
   release you can't undo is a risk, not a release. Write the rollback step down.

3. **Pre-flight migrations and config.** If the release includes a schema change,
   confirm the `database-engineer` reviewed it and it's production-safe (no
   blocking locks or risky data rewrites). Verify required config and secrets are
   present in the target environment.

4. **Ship through CI/CD.** Release via the pipeline — never hand-mutate production.
   Prefer a fail-safe strategy: health-checked and gradual where available, so a
   bad release stops itself.

5. **Watch production health.** After the deploy completes, watch logs, metrics,
   and error rates for the new behavior. The deploy is finished only when
   monitoring shows production nominal — not when the pipeline turns green.

6. **Roll back on regression.** If health degrades, execute the rollback from
   step 2 *first*, then diagnose. Don't wait and hope it settles.

7. **Report the outcome.** State what shipped, the rollback path, and the
   post-deploy health evidence (errors clear, key metrics steady), plus any
   residual risk.

## Rule
Never deploy a change QA hasn't passed, and never ship without a rollback you've
confirmed. A green pipeline proves the build; only monitoring proves the release.
