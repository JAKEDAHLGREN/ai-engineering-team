#!/usr/bin/env bash
#
# Smoke test for bin/ait. Exercises a real install/update against temp dirs and
# asserts the invariants we care about. Exits non-zero on the first failure so it
# can gate merges in CI.
#
# Run from anywhere: bash test/ait-smoke.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AIT="$REPO_ROOT/bin/ait"

EXPECT_AGENTS=11
EXPECT_SKILLS=5
EXPECT_PLAYBOOKS=5

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

pass() { printf '  ok   %s\n' "$1"; }
fail() { printf '  FAIL %s\n' "$1" >&2; exit 1; }

# default answers: accept every prompt (Enter x7)
answers() { printf '\n\n\n\n\n\n\n'; }

echo "== syntax =="
bash -n "$AIT" && pass "bin/ait parses"

echo "== roster consistency =="
# The agent files are the single source of truth. Every agent must appear in the
# Conductor's dispatch table, the organization.md team table, and the README tree
# — and every agent named in those tables must have a file. Stale-roster bugs
# have shipped twice; this check makes the drift impossible to merge.
for f in "$REPO_ROOT"/template/.claude/agents/*.md; do
  a=$(basename "$f" .md)
  grep -q "\`$a\`" "$REPO_ROOT/template/CLAUDE.md" \
    || fail "agent '$a' missing from template/CLAUDE.md dispatch table"
  grep -q "\`$a\`" "$REPO_ROOT/template/.ai/organization/organization.md" \
    || fail "agent '$a' missing from organization.md team table"
  grep -q "$a\.md" "$REPO_ROOT/README.md" \
    || fail "agent '$a' missing from README tree"
done
for src in "$REPO_ROOT/template/CLAUDE.md" "$REPO_ROOT/template/.ai/organization/organization.md"; do
  while IFS= read -r nm; do
    printf '%s' "$nm" | grep -Eq '^[a-z][a-z0-9-]*$' || continue
    [ -f "$REPO_ROOT/template/.claude/agents/$nm.md" ] \
      || fail "'$nm' listed in ${src##*/} but no agent file exists"
  done < <(awk -F'|' 'NF>=4 && $3 ~ /`/ { gsub(/[` ]/, "", $3); print $3 }' "$src")
done
pass "roster: agent files, CLAUDE.md, organization.md, and README agree"

for f in "$REPO_ROOT"/template/.ai/playbooks/*.md; do
  p=$(basename "$f")
  grep -q "$p" "$REPO_ROOT/README.md" || fail "playbook '$p' missing from README tree"
done
pass "playbooks all listed in README"

echo "== case: greenfield install =="
G="$WORK/green"; mkdir -p "$G"
answers | "$AIT" init "$G" >/dev/null

a=$(find "$G/.claude/agents" -name '*.md' | wc -l | tr -d ' ')
s=$(find "$G/.claude/skills" -name 'SKILL.md' | wc -l | tr -d ' ')
p=$(find "$G/.ai/playbooks" -name '*.md' | wc -l | tr -d ' ')
[ "$a" = "$EXPECT_AGENTS" ]    || fail "expected $EXPECT_AGENTS agents, got $a"
[ "$s" = "$EXPECT_SKILLS" ]    || fail "expected $EXPECT_SKILLS skills, got $s"
[ "$p" = "$EXPECT_PLAYBOOKS" ] || fail "expected $EXPECT_PLAYBOOKS playbooks, got $p"
pass "counts: $a agents, $s skills, $p playbooks"

grep -rlF '{{' "$G" >/dev/null 2>&1 && fail "unrendered {{placeholders}} remain" || pass "no leftover placeholders"

# every agent/skill frontmatter name must equal its file/dir identity
while IFS= read -r f; do
  nm=$(grep -m1 '^name:' "$f" | sed 's/name:[[:space:]]*//')
  want=$(basename "$f" .md)
  [ "$nm" = "$want" ] || fail "agent name '$nm' != filename '$want'"
done < <(find "$G/.claude/agents" -name '*.md')
pass "agent frontmatter names match filenames"

while IFS= read -r f; do
  nm=$(grep -m1 '^name:' "$f" | sed 's/name:[[:space:]]*//')
  want=$(basename "$(dirname "$f")")
  [ "$nm" = "$want" ] || fail "skill name '$nm' != dir '$want'"
done < <(find "$G/.claude/skills" -name 'SKILL.md')
pass "skill frontmatter names match directories"

[ "$(grep -cF 'ai-engineering-team:start' "$G/CLAUDE.md")" = "1" ] \
  || fail "greenfield CLAUDE.md should have exactly one conductor block"
pass "greenfield CLAUDE.md has one conductor block"

echo "== case: artifact checker =="
[ -f "$G/.ai/bin/check.sh" ] || fail "check.sh not installed"
mkdir -p "$G/.ai/work/001-fix" "$G/.ai/memory/runs"
cat > "$G/.ai/work/001-fix/verdict-qa.r1.md" <<'FIX'
# Verdict — 001-fix · qa-engineer · round 1
**Verdict:** PASS
## Findings
- [MISSING_TEST] app/models/x.rb:10 — example
FIX
cat > "$G/.ai/memory/runs/2026-07-14-001-fix.md" <<'FIX'
# Run — 001-fix
**Final verdict:** PASS
## Findings (all rounds)
- [MISSING_TEST] r1 · app/models/x.rb:10 — example
## Consequential decisions
None.
## Struggles & assumptions
None.
## Escalations
None.
FIX
(cd "$G" && bash .ai/bin/check.sh >/dev/null) || fail "checker rejected valid artifacts"
pass "checker accepts valid artifacts"

printf -- '- [NOT_A_REAL_TAG] r1 · x — bad\n' >> "$G/.ai/work/001-fix/verdict-qa.r1.md"
(cd "$G" && bash .ai/bin/check.sh >/dev/null 2>&1) && fail "checker passed an unknown tag" \
  || pass "checker catches an unknown tag"

sed -i.bak '/^## Escalations/d' "$G/.ai/memory/runs/2026-07-14-001-fix.md"
(cd "$G" && bash .ai/bin/check.sh >/dev/null 2>&1) && fail "checker passed a run record missing a section" \
  || pass "checker catches a missing run-record section"
rm -rf "$G/.ai/work/001-fix" "$G/.ai/memory/runs/2026-07-14-001-fix.md" "$G/.ai/memory/runs/2026-07-14-001-fix.md.bak"

echo "== case: mem structured memory =="
[ -f "$G/.ai/bin/mem" ] || fail "mem not installed"
if command -v sqlite3 >/dev/null 2>&1; then
  (
    cd "$G"
    bash .ai/bin/mem init >/dev/null || exit 1
    rid=$(bash .ai/bin/mem log-run --slug feat-a --verdict PASS | tail -1)
    [ "$rid" = "1" ] || { echo "log-run did not return id 1 (got '$rid')"; exit 1; }
    bash .ai/bin/mem log-finding --run "$rid" --tag MISSING_TEST --file app/x.rb --desc t || exit 1
    # unknown tag must be rejected at write time
    bash .ai/bin/mem log-finding --run "$rid" --tag NOPE --desc t >/dev/null 2>&1 && exit 2
    # a tag across 3 features must surface in recurring-tags; a one-off must not
    for s in feat-b feat-c; do
      r=$(bash .ai/bin/mem log-run --slug "$s" --verdict PASS | tail -1)
      bash .ai/bin/mem log-finding --run "$r" --tag MISSING_TEST --desc t
    done
    r=$(bash .ai/bin/mem log-run --slug feat-d --verdict PASS | tail -1)
    bash .ai/bin/mem log-finding --run "$r" --tag N_PLUS_ONE --desc once
    out=$(bash .ai/bin/mem recurring-tags --min 3)
    grep -q 'MISSING_TEST' <<<"$out" || exit 3
    grep -q 'N_PLUS_ONE'  <<<"$out" && exit 4
    exit 0
  )
  case "$?" in
    0) pass "mem: log/query works, unknown tag rejected, recurrence aggregates" ;;
    2) fail "mem accepted an unknown tag" ;;
    3) fail "mem recurring-tags missed a tag across 3 features" ;;
    4) fail "mem recurring-tags surfaced a one-off tag" ;;
    *) fail "mem CLI failed a basic operation" ;;
  esac
  rm -f "$G/.ai/memory/agent_log.sqlite3"
else
  pass "mem installed (sqlite3 absent on runner — behavioral checks skipped)"
fi

echo "== case: brownfield install preserves existing files =="
B="$WORK/brown"; mkdir -p "$B/.claude/agents"
printf '# My Project\n\nKeep these instructions.\n' > "$B/CLAUDE.md"
printf '{"existing":true}\n' > "$B/.claude/settings.json"
printf 'my own agent\n' > "$B/.claude/agents/my-agent.md"
answers | "$AIT" init "$B" >/dev/null

grep -qF 'Keep these instructions.' "$B/CLAUDE.md" || fail "existing CLAUDE.md content lost"
[ "$(grep -cF 'ai-engineering-team:start' "$B/CLAUDE.md")" = "1" ] || fail "brownfield should append exactly one block"
grep -qF '"existing":true' "$B/.claude/settings.json" || fail "user settings.json was modified"
grep -qF 'my own agent' "$B/.claude/agents/my-agent.md" || fail "user custom agent was modified"
[ -f "$B/.claude/agents/tech-lead.md" ] || fail "team agents were not merged in"
pass "brownfield: existing CLAUDE.md, settings, and custom agent preserved; team merged"

echo "== case: update is idempotent and preserves project-owned files =="
printf 'REAL ARCH NOTES\n' > "$B/.ai/organization/architecture.md"
"$AIT" update "$B" >/dev/null
"$AIT" update "$B" >/dev/null
[ "$(grep -cF 'ai-engineering-team:start' "$B/CLAUDE.md")" = "1" ] || fail "repeated update duplicated the conductor block"
grep -qF 'Keep these instructions.' "$B/CLAUDE.md" || fail "update clobbered user CLAUDE.md content"
grep -qF 'REAL ARCH NOTES' "$B/.ai/organization/architecture.md" || fail "update overwrote project-owned brain"
[ -f "$B/.claude/agents/my-agent.md" ] || fail "update deleted a user-added file"
pass "two updates: one block, brain + user files preserved"

echo "== case: re-init is guarded =="
if answers | "$AIT" init "$B" >/dev/null 2>&1; then
  fail "re-init should error when already installed"
fi
pass "re-init refused on an existing install"

# The gitignore-detection feature may not be present in every version of ait, so
# assert it only when ait actually ships it. This keeps the test order-independent
# across PRs; it starts enforcing automatically once the feature is on the branch.
if grep -q 'check-ignore' "$AIT"; then
  echo "== case: gitignore exclusion is detected =="
  GI="$WORK/gitignored"; mkdir -p "$GI"; git -C "$GI" init -q
  printf '.claude/*\n!.claude/skills/\n' > "$GI/.gitignore"
  out="$(answers | "$AIT" init "$GI" 2>&1)"
  grep -q 'WARNING' <<<"$out" || fail "expected a gitignore WARNING"
  grep -q '.claude/agents' <<<"$out" || fail "warning should name .claude/agents"
  pass "gitignore exclusion warned with the fix"

  echo "== case: clean repo does not warn =="
  CR="$WORK/clean"; mkdir -p "$CR"; git -C "$CR" init -q
  printf 'node_modules/\n' > "$CR/.gitignore"
  out="$(answers | "$AIT" init "$CR" 2>&1)"
  grep -q 'WARNING' <<<"$out" && fail "clean repo should not warn" || pass "clean repo: no false warning"
else
  echo "== skip: gitignore-detection not present in this ait =="
fi

echo
echo "ALL SMOKE TESTS PASSED"
