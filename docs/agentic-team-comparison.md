# Agentic Team Comparison: `ai-engineering-team` vs `rails-agentic-engineering-team`

**Date:** 2026-07-13
**Scope:** Full read of both repos. Analysis of architecture, self-learning, token efficiency, and concrete improvements for `ai-engineering-team`. Recommendations only — no code changed.

---

## 1. TL;DR

| | Your repo (`ai-engineering-team`) | Robert's repo (`rails-agentic-engineering-team`) |
|---|---|---|
| **Mental model** | Org chart — 9 role-based specialists coordinated by a Conductor | Assembly line — 9 stage-based agents in a fixed pipeline |
| **Orchestration** | Conductor in `CLAUDE.md` (main thread), playbooks define sequences | Orchestrator agent adopted via `/feature` command; artifact-gated stages |
| **State/handoffs** | In-conversation context (ephemeral) | Numbered artifact files in `docs/briefs/{NNN}-*/` (persistent, resumable) |
| **Self-learning** | Manual markdown memory (`.ai/memory/` + INDEX) | SQLite flight recorder → log-analyst → human approval → skill-builder (closed loop) |
| **Done-signal** | QA Engineer runs test suite → PASS/FAIL | 3 parallel reviewers → combined verdict, round tracking, 3-round escalation |
| **Distribution** | `bin/ait` installer with merge, update, backups, smoke tests, CI | Manual copy; no installer, no update path, no tests |
| **Models** | `opus` on every agent | `sonnet` on every agent |
| **Biggest strength** | Distribution engineering + clean conceptual model | The learning loop + artifact-driven resumability |
| **Biggest gap** | No self-learning; ephemeral state; token-heavy defaults | Heavy per-agent logging ritual; leftover writer-app residue; no install/update story |

The two repos are almost perfect complements. Yours is a **product** (installable, updatable, tested) with no learning loop. Robert's is a **learning system** with no product packaging. The best version of your repo steals his loop; the best version of his steals your installer.

---

## 2. Architecture of Robert's Repo (outline)

### 2.1 The pipeline

Nine agents, fixed sequence, each stage gated on the previous stage's artifact file:

```
/feature → discovery (in-session interview) → brief
         → architect (codebase audit)       → spec
         → design (view/UX spec)            → design spec
         → engineer (TDD)                   → code + engineer report
         → code-review ┐
         → security-review ├─ parallel      → 3 verdict reports
         → performance-review ┘
         → all PASS? done : back to engineer (new sequence numbers)
```

Plus two out-of-pipeline **learning agents**: `log-analyst` (mines the database, proposes changes) and `skill-builder` (executes human-approved proposals).

### 2.2 Key design decisions worth understanding

- **Artifacts as pipeline state.** Every stage writes `{NNN}.{SS}-{agent}-{feature}.md` into one feature directory. The orchestrator resumes any pipeline by listing which files exist and re-entering at the first missing one. Rounds append (eng at seq 04, 08, 12...; reviews at +1/+2/+3) — history is never destroyed. This makes the pipeline **crash-proof and auditable**, and it means a resumed session pays zero tokens re-deriving where it was.
- **The SQLite flight recorder** (`bin/agent-log`, ~400 lines of dependency-free Ruby calling the `sqlite3` CLI). Five tables: `runs`, `decisions` (with `expected_outcome` vs `observed_outcome`), `events`, `findings` (with a **standardized category vocabulary** — `N+1`, `AUTH_SCOPE`, `MISSING_TEST`, `COMPETING_PATTERN`...), and `reflections` (struggles, skill gaps). Every agent starts a run, logs decisions/findings, and closes the run.
- **The learning loop.** After 10–15 features, `log-analyst` runs six pattern queries: (1) decisions repeated 3+ times → promote to standing rules; (2) alternatives rejected 2+ times → document as anti-patterns; (3) engineer decisions that should have been architect decisions → spec template gaps; (4) expected vs observed outcome deltas → correct agent reasoning; (5) practices correlated with high quality scores; (6) finding categories recurring across 3+ features → build a prevention skill. Output is a proposal report; a **human approves**; `skill-builder` writes the skill files and wires agent frontmatter. Confidence thresholds are explicit (≥5 features = pre-approved, 3–4 = per-item confirmation, ≤2 = deferred).
- **Structured handoff sections.** Every artifact ends with a "For the {next agent}" section (Situation / Assessment / Recommendation) plus "Agent Notes" (assumptions made, where I struggled). Downstream agents are told to read *that section first*. This is targeted context transfer — the reviewer reads the engineer's confession of uncertainty before reading the code.
- **Round tracking with escalation.** The orchestrator greps `[CATEGORY]` tags across rounds. Same category in two consecutive rounds → named explicitly, never silently re-routed. Three rounds → escalate to the human ("the spec or the skill is wrong, not the engineer"). This is a **token circuit-breaker**: it caps the expensive fail→retry loop at 3.
- **The engineer report grades the spec.** The "Spec Quality Assessment" section (1–10 score, what was vague, was the domain model accurate) makes feedback flow *upstream* — the architect gets graded by the engineer, and the log-analyst mines those grades.
- **Skills carry project decisions, not general knowledge.** `rails-principles` is 221 lines of *opinions the team already settled* (no service objects, 3-method concern rule, "design for addition not modification", the jbuilder-by-default YAGNI exception). The skill-builder's test is explicit: *"What would an agent have to guess from training data if this skill didn't exist? If training data would get it right, the skill isn't needed."* That is the single best line in the repo, and it's the standard your skills should be held to.

### 2.3 What works well

- The learning loop is real, closed, and human-gated. Recurrence detection over a **standard category vocabulary** is what makes it work — free-text findings can't be aggregated; `[AUTH_SCOPE]` appearing on 5 features can.
- Artifact-gated stages: resumable, auditable, cheap to re-enter, and each subagent gets file paths instead of pasted context.
- `sonnet` everywhere — reviews and orchestration don't need opus, and the pipeline runs many agent-sessions per feature.
- The two-tier pattern test in code-review ("Does Rails provide this?" / "Does it look like Rails built it?") and "a competing pattern is always NEEDS WORK" — this is review criteria specifically designed for a codebase LLMs write, where pattern-count is a compounding tax on every future agent.
- Explicit outcome recording (`expected_outcome` at decision time, `observed` after the pipeline closes) — the only genuine hypothesis→result signal in either repo.
- Terse orchestrator comms spec ("Nothing else. The engineer has the reports — they don't need a summary of what's in them").

### 2.4 What could be improved (Robert's repo)

- **Logging ritual is heavy.** Every agent carries ~60–80 lines of near-identical lifecycle boilerplate (run start → decisions → events → reflections → gap-query → run end), and logging `file_read` events is noise that costs a Bash call each. The `agent-log` skill exists; the lifecycle text should live there once, not be repeated in 9 agent files. Event logging could be dropped entirely — decisions, findings, and reflections carry nearly all the analytical signal.
- **No install/update story.** "Copy these files, chmod the script" — no merge behavior, no version manifest, no way to ship framework improvements to installed projects, no smoke tests, no CI. Your `bin/ait` solves exactly this.
- **Incomplete generalization.** Writer-app residue everywhere: `writer-design-system` skill, `bp-app-layout` classes in design.md, "you are designing a focused writing tool", hard-coded `bin/rails test`/Minitest/Solid-Stack/no-Devise assumptions. Fine for his projects; anyone else installs a team with someone else's product decisions baked in.
- **Identity-adoption hack.** `/feature` says "read orchestrator.md and adopt its identity"; discovery is run the same way. It works because interactive stages can't be subagents, but it's fragile — the main thread juggles `$NNN`/`$SEQ`/`$FEATURE_DIR` arithmetic in prose, and one missed increment mis-numbers a round. (Artifacts make it recoverable, which is the saving grace.)
- **No independent test gate.** The engineer runs their own tests and code-review re-runs the suite, but there's no equivalent of your QA Engineer as a dedicated, adversarial done-signal owner. The reviewer who checks 10 categories is also the one verifying the suite — the verification is a line item, not an owner.
- **The learning loop needs 10–15 cycles before it pays anything**, and outcome recording depends on agents reliably doing homework after the pipeline "feels" done. If outcome coverage is low, Pattern Type 4 (the best signal) is empty — the log-analyst even has to warn about this.

---

## 3. Your Repo: What's Already Strong

Don't lose these while borrowing from Robert:

- **`bin/ait` is genuinely good engineering.** Managed conductor block with idempotent replace, file-by-file merge that never clobbers, project-owned trees (`organization/`, `memory/`) never touched on update, timestamped backups, install manifest, gitignore detection with the exact fix, portable sed, and a real smoke test in CI asserting invariants. Robert has nothing like this.
- **The conceptual boundary is crisp and teachable:** agents = who, skills = how, playbooks = sequence. Robert's repo conflates these (commands adopt agent identities; agents embed their own procedures).
- **Index-first memory discipline** ("read `INDEX.md`, then pull only relevant entries, never load the whole tree") is the correct token-shape for memory retrieval. The problem is what feeds it (see 4.1), not the retrieval design.
- **Objective done-signal owned by a dedicated role** (QA Engineer, "never report PASS without having run the suite in this session") — stronger than Robert's reviewer-verifies-as-line-item.
- **Stack-parameterized templates** — `{{FRAMEWORK}}`, `{{TEST_COMMAND}}` etc. make yours installable beyond Rails; his is Rails-and-his-preferences only.
- **Playbooks for incident and release** — Robert's pipeline only covers feature work; you have runbooks for the other two situations that actually happen.

---

## 4. Recommendations for `ai-engineering-team`

Ordered by impact. Items 1–3 address your two stated goals directly (self-learning, token burn).

### 4.1 Build the learning loop (the big one)

Your memory system records what agents *choose* to write down, in prose, and nothing reads it systematically. That's a diary, not a feedback loop. What's missing, in order of importance:

1. **A standardized finding vocabulary.** Define ~15 category tags (borrow Robert's: `MISSING_TEST`, `N+1`, `AUTH_SCOPE`, `FAT_CONTROLLER`, `COMPETING_PATTERN`, `DATA_INTEGRITY`...). Require QA / security / performance / database engineers to tag every finding. **This is the prerequisite for everything else** — recurrence is only detectable over a controlled vocabulary.
2. **Structured, append-only run records.** You don't need SQLite on day one. A `.ai/memory/runs/` directory of JSONL or per-feature markdown with a fixed schema (agent, feature, verdict, findings-with-tags, decisions with expected outcomes, struggles) gets you 80% of Robert's signal with zero tooling. If you want queryability, port `bin/agent-log` — it's dependency-free and MIT-simple; template `db/agent_log.sqlite3` → `.ai/memory/agent_log.sqlite3`.
3. **A `retrospective` playbook + `log-analyst`-style agent.** After N features, an agent reads the run records, finds recurring finding categories and repeated decisions, and writes a proposal report to `.ai/memory/`. Steal Robert's six pattern types and his confidence thresholds (3+ recurrences = propose; 5+ = high confidence; 1 = never).
4. **Human-gated application.** A `skill-builder` equivalent that only executes proposals you approve, writing new skills into `.claude/skills/` and appending standing rules to `coding_standards.md`. Never let the loop self-modify unattended — Robert got this right.
5. **Expected vs observed outcomes.** When tech-lead or an engineer makes a consequential call, record what they expect to be true; after QA passes, record what happened. This is the highest-quality learning signal and the one thing prose memory can never give you.

One caveat: this loop pays off proportional to volume. If a project ships 2 features a month, thresholds of 3–5 recurrences take a year to trigger. Consider lowering thresholds (2 recurrences = propose) or scoping the loop to your highest-traffic projects first.

### 4.2 Cut the token burn

Current defaults are expensive in four specific places:

1. **`model: opus` on all nine agents.** This is your single largest cost lever. Robert runs everything on sonnet. Suggested split: keep opus for `tech-lead` (planning quality compounds downstream) and optionally `security-engineer`; move the rest to sonnet. Better: make it an `ait init` prompt (`{{AGENT_MODEL}}`) so it's per-project configurable.
2. **Every agent loads the whole brain.** Each agent is told to read `coding_standards.md` + `architecture.md` (+ `decision_log.md` + INDEX) before acting. On a mature project these files grow, and you pay their full weight × 9 agents × every dispatch. Fixes:
   - Give each agent a **minimal context contract**: QA needs the test command and acceptance criteria, not the architecture doc; documentation-engineer doesn't need `decision_log` history, etc. Trim each agent's "before you act" list to what that role actually consumes.
   - Add a size discipline note to each organization file (like your INDEX has): "keep under ~100 lines; move detail to linked per-topic files."
   - Longer term: adopt Robert's per-agent `skills:` frontmatter pattern — knowledge is loaded because a role declares it needs it, not because a prose instruction says "read everything."
3. **Deduplicate agent boilerplate.** All nine agents repeat near-identical "Before writing code" and "Definition of done" scaffolding (~15 lines each). Extract the shared protocol into one place (e.g., a `team-protocol` skill or a section in `organization.md` every agent already loads) and leave only role-specific deltas in each agent file. Cuts every dispatch and makes protocol changes one-file edits. (Robert has the same disease with his logging boilerplate — don't copy that part.)
4. **Persist handoffs as files, not context.** This is Robert's best token idea. Have tech-lead write the plan to a file (e.g., `.ai/work/{NNN}-{slug}/plan.md`), engineers write short reports next to it, QA writes the verdict. The Conductor then dispatches with *paths* instead of pasting plan sections, retries don't re-derive anything, an interrupted feature is resumable, and the run records for 4.1 fall out for free. Add Robert's "For the next agent" (Situation/Assessment/Recommendation) footer to each artifact so downstream agents read one targeted section instead of the whole document.

### 4.3 Adopt the retry circuit-breaker

Your `feature_request` playbook loops FAIL → step 2 forever. Add Robert's rule: track which acceptance criterion / finding category failed each round; if the same one fails twice, name it explicitly; **three times → stop and escalate to the user** — persistent failure means the plan or the standards are wrong, not the engineer. This caps your most expensive failure mode (an unbounded build→fail→rebuild loop) and doubles as a learning signal.

### 4.4 Fix the Conductor's agent table (bug)

`template/CLAUDE.md` lists only **3 of the 9 agents** (tech-lead, rails-engineer, qa-engineer) in "The agents you dispatch to." The README and `organization.md` both advertise the full nine-role roster. The Conductor is the dispatcher — an agent missing from its table is an agent that mostly won't get used. Add the other six rows (frontend, database, security, performance, devops, documentation).

### 4.5 Strengthen review outputs into structured verdicts

Your `security-review` skill has PASS / CHANGES REQUIRED, and QA has PASS/FAIL, but findings evaporate into conversation. Require every review verdict to be written as a small structured block (verdict + tagged findings + severity) into the feature's work directory (per 4.2.4). This is what makes 4.1's recurrence detection possible and gives the Conductor something greppable to judge against.

### 4.6 Raise the bar on skill content

Apply Robert's test to your five skills: *"What would an agent have to guess from training data if this skill didn't exist?"* Honest answer: `run-tests`, `add-feature`, and `deploy` are mostly well-written restatements of what a competent model already does — their per-dispatch token cost buys process discipline but little knowledge. Keep them (the discipline has value, especially the honest-verdict rules), but the *growth* direction for skills should be project-specific settled decisions: your equivalent of "no service objects", "the 3-method concern rule", "always jbuilder". Those are exactly what the 4.1 learning loop should generate — which is the elegant part: the loop's output is skills that pass this test by construction, because each one exists to prevent a mistake that actually recurred.

### 4.7 Smaller items

- **Add "Agent Notes" (assumptions / struggles) to every agent's report format.** Cheap to produce, and it's the raw material for skill-gap detection. Robert requires "None." rather than blank — copy that; it forces the reflection.
- **Consider a discovery/interview step.** Your pipeline starts at tech-lead planning against the raw user request. Robert's discovery interview (one or two questions at a time, confirm before writing, explicit out-of-scope section) measurably improves spec quality and prevents the most expensive failure: building the wrong thing correctly. Even a lightweight version — the Conductor asking 2–3 clarifying questions before dispatching tech-lead — is worth it.
- **Adopt "Directions Rejected" in plans.** The tech-lead plan records what was chosen; recording what was *rejected and why* prevents downstream agents (and future sessions) from relitigating — same purpose as your decision_log, but at feature grain.
- **Memory consolidation playbook.** INDEX says "prune or supersede stale entries" but nothing owns doing it. Add a small `memory-consolidation` playbook (merge duplicates, supersede stale decisions, cap INDEX size) run every N features or when INDEX exceeds ~50 lines.
- **Offer Robert your installer.** `bin/ait`'s managed-block + manifest + smoke-test machinery is exactly what his repo lacks; his agents + learning loop are what yours lacks. There's an obvious joint move here: his pipeline content shipped through your distribution mechanism.

---

## 5. Suggested Sequencing

| Phase | Work | Why first |
|---|---|---|
| 1 (hours) | 4.4 fix Conductor table · 4.3 retry circuit-breaker · define finding vocabulary (4.1.1) | Bug fix + cheap guardrails; vocabulary unblocks everything |
| 2 (a day) | 4.2 model split, minimal context contracts, boilerplate dedup | Immediate, permanent token savings on every dispatch |
| 3 (1–2 days) | 4.2.4 file-based handoffs + 4.5 structured verdicts + Agent Notes | Creates the persistent substrate; resumability falls out |
| 4 (2–3 days) | 4.1 run records + retrospective agent + human-gated skill-builder | The learning loop, built on phases 1–3 |
| 5 (ongoing) | 4.6/4.7 discovery step, memory consolidation, skill quality bar | Compounding refinement |

---

## 6. Bottom Line

Robert's repo answers your exact question — "how do I make this self-learn and burn fewer tokens" — with three transferable mechanisms: **a controlled finding vocabulary + structured run records** (learning becomes queryable), **artifact-file handoffs** (context becomes resumable and cheap), and **a human-gated analyst→builder loop** (improvement becomes systematic). None of them require abandoning your architecture; they slot into your Conductor/playbook model cleanly. Meanwhile your installer, update path, smoke tests, and role-based done-signal are things his repo would be better for adopting. Steal the loop; keep the product.
