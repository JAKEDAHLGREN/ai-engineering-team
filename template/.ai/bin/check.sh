#!/usr/bin/env bash
#
# check.sh — validates the team's runtime artifacts against framework conventions.
#
# The framework's conventions (exact finding tags, verdict lines, and the
# integrity of the memory database) are what make recurrence detection and the
# learning loop work — and are otherwise enforced only by prompt. This script
# makes them mechanical.
#
# Run from the project root. The Conductor runs it at close-out; fix anything it
# flags before closing the task. Exits non-zero listing every violation.

set -uo pipefail

VOCAB=".ai/organization/finding_vocabulary.md"
fails=0
flag() { echo "FAIL: $*" >&2; fails=$((fails + 1)); }

[ -f "$VOCAB" ] || { echo "FAIL: $VOCAB not found — run from the project root" >&2; exit 1; }

# Known tags = backticked SCREAMING_SNAKE tokens in the vocabulary.
known_tags=$(grep -o '`[A-Z][A-Z0-9_]*`' "$VOCAB" | tr -d '`' | sort -u)

# 1. Every [TAG] used in the live work-directory artifacts must exist in the
#    vocabulary. A typo'd or invented tag silently breaks recurrence detection.
#    (Run records live in the database now — mem validates their tags at write
#    time; the database integrity check below covers them.)
while IFS=: read -r file tag; do
  [ -z "${tag:-}" ] && continue
  printf '%s\n' "$known_tags" | grep -qx "$tag" \
    || flag "$file uses unknown tag [$tag] — not in $VOCAB"
done < <(grep -rHo '\[[A-Z][A-Z0-9_]*\]' \
           .ai/work/*/verdict-*.md .ai/work/*/report-*.md \
           2>/dev/null | sed 's/\[\([A-Z0-9_]*\)\]$/\1/')

# 2. Every verdict file must carry an explicit verdict line.
for f in .ai/work/*/verdict-*.md; do
  [ -e "$f" ] || continue
  grep -q '^\*\*Verdict:\*\*' "$f" || flag "$f has no '**Verdict:**' line"
done

# 3. Memory database integrity (only if it exists and sqlite3 is available).
#    mem enforces these at write time; this catches hand-edits and corruption.
DB=".ai/memory/agent_log.sqlite3"
if [ -f "$DB" ] && command -v sqlite3 >/dev/null 2>&1; then
  bad_tags=$(sqlite3 "$DB" "SELECT DISTINCT tag FROM findings;" 2>/dev/null \
    | while read -r t; do printf '%s\n' "$known_tags" | grep -qx "$t" || echo "$t"; done)
  [ -n "$bad_tags" ] && flag "database has findings with unknown tag(s): $(echo $bad_tags)"
  no_verdict=$(sqlite3 "$DB" \
    "SELECT COUNT(*) FROM runs WHERE final_verdict IS NULL OR final_verdict='';" 2>/dev/null)
  [ "${no_verdict:-0}" -gt 0 ] && flag "database has $no_verdict run(s) with no final_verdict"
fi

# 4. INDEX size nudge (warning only — does not fail the check).
if [ -f .ai/memory/INDEX.md ]; then
  entries=$(grep -cE '^- [0-9]{4}-[0-9]{2}-[0-9]{2}' .ai/memory/INDEX.md || true)
  if [ "${entries:-0}" -gt 50 ]; then
    echo "WARN: INDEX.md has $entries entries (>50) — run the memory_consolidation playbook" >&2
  fi
fi

if [ "$fails" -gt 0 ]; then
  echo "check.sh: $fails violation(s) — fix before closing the task" >&2
  exit 1
fi
echo "check.sh: all artifact conventions hold"
