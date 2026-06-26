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

EXPECT_AGENTS=9
EXPECT_SKILLS=5
EXPECT_PLAYBOOKS=3

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

pass() { printf '  ok   %s\n' "$1"; }
fail() { printf '  FAIL %s\n' "$1" >&2; exit 1; }

# default answers: accept every prompt (Enter x7)
answers() { printf '\n\n\n\n\n\n\n'; }

echo "== syntax =="
bash -n "$AIT" && pass "bin/ait parses"

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
