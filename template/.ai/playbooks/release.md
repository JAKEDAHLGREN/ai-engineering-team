# Playbook — Release

> The ordered sequence the Conductor runs to ship accumulated, verified work to
> production as a deliberate release. Verify the whole, document it, deploy it
> safely, confirm it's healthy, then record what went out.

**Trigger:** a set of merged, individually-verified changes is ready to go to
production together — a version cut, a scheduled release, or a batched ship.

**Owner:** the Conductor (`CLAUDE.md`) drives every step; specialists execute.

**Artifacts:** use a work directory `.ai/work/{NNN}-{slug}/` (see
`.ai/work/README.md`) — the release scope, review verdicts, and deploy report
are files, and a stopped release resumes from its artifacts.

## Sequence

1. **Scope the release** → dispatch `tech-lead`.
   Determine exactly what's included, the version/label, and the risk profile —
   especially anything that needs special handling at deploy time (migrations,
   config changes, feature flags). Output: the release contents, version, and a
   short risk assessment with acceptance criteria for "shippable."

2. **Verify the whole** → dispatch the verifiers in parallel.
   Individual changes were checked on the way in; a release re-verifies them
   *together*, because the risk is in the interaction.
   - `qa-engineer` — runs the `run-tests` skill (`{{TEST_COMMAND}}`) against the
     full release; reports a **PASS/FAIL** verdict with real output.
   - `security-engineer` — runs `security-review` if the release touches auth,
     secrets, untrusted input, or dependencies.
   - `performance-engineer` — confirms no regression on known hot paths if the
     release touches them.
   A FAIL or an open critical/high finding stops the release here.

3. **Document the release** → dispatch `documentation-engineer`.
   Write the release notes (what changed, user-visible impact), update any docs the
   release affects, and record significant decisions as ADRs / `decision_log.md`.
   Output: release notes ready to ship with the version.

4. **Deploy** → dispatch `devops-engineer`, running the `deploy` skill.
   Ship only on the green QA signal from step 2, with a confirmed rollback path and
   reviewed migrations. Release through CI/CD, never by hand.
   Output: deploy completed, with the rollback path recorded.

5. **Confirm health** → `devops-engineer` + Conductor.
   - Production not nominal → roll back per the `deploy` skill, then return to the
     relevant step; the release is not done.
   - Production nominal (errors clear, metrics steady, new behavior observable) →
     the release is live.

6. **Record** → Conductor.
   Distill the work directory into the structured store with `.ai/bin/mem` —
   verdicts, tagged findings, decisions with expected → observed outcomes.
   Append a one-line entry to `.ai/memory/INDEX.md` and write a dated release note
   under `.ai/memory/releases/` — version, contents, deploy outcome, and any
   follow-up. Log any decision in `.ai/memory/decisions/` and
   `organization/decision_log.md`.

## Done means
The full release passed `qa-engineer` (suite green) with no open critical/high
security finding, release notes are written, `devops-engineer` deployed it with a
rollback path, production is confirmed healthy, and the release is recorded in
memory. Nothing less.
