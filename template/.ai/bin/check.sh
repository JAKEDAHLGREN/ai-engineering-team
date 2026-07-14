#!/usr/bin/env bash
#
# check.sh — validates the team's runtime artifacts against framework conventions.
#
# The framework's conventions (exact finding tags, run-record sections, verdict
# lines) are what make recurrence detection and the learning loop work — and
# they are otherwise enforced only by prompt. This script makes them mechanical.
#
# Run from the project root. The Conductor runs it at close-out (before writing
# the run record is fine too); fix anything it flags before closing the task.
# Exits non-zero listing every violation.

set -uo pipefail

VOCAB=".ai/organization/finding_vocabulary.md"
fails=0
flag() { echo "FAIL: $*" >&2; fails=$((fails + 1)); }

[ -f "$VOCAB" ] || { echo "FAIL: $VOCAB not found — run from the project root" >&2; exit 1; }

# Known tags = backticked SCREAMING_SNAKE tokens in the vocabulary.
known_tags=$(grep -o '`[A-Z][A-Z0-9_]*`' "$VOCAB" | tr -d '`' | sort -u)

# 1. Every [TAG] used in verdicts, reports, and run records must exist in the
#    vocabulary. A typo'd or invented tag silently breaks recurrence detection.
while IFS=: read -r file tag; do
  [ -z "${tag:-}" ] && continue
  printf '%s\n' "$known_tags" | grep -qx "$tag" \
    || flag "$file uses unknown tag [$tag] — not in $VOCAB"
done < <(grep -rHo '\[[A-Z][A-Z0-9_]*\]' \
           .ai/work/*/verdict-*.md .ai/work/*/report-*.md \
           .ai/memory/runs/[0-9]*.md \
           2>/dev/null | sed 's/\[\([A-Z0-9_]*\)\]$/\1/')

# 2. Every verdict file must carry an explicit verdict line.
for f in .ai/work/*/verdict-*.md; do
  [ -e "$f" ] || continue
  grep -q '^\*\*Verdict:\*\*' "$f" || flag "$f has no '**Verdict:**' line"
done

# 3. Every run record must have a final verdict and the required sections.
for f in .ai/memory/runs/[0-9]*.md; do
  [ -e "$f" ] || continue
  grep -q 'Final verdict:' "$f" || flag "$f missing 'Final verdict:'"
  for section in '## Findings' '## Consequential decisions' \
                 '## Struggles & assumptions' '## Escalations'; do
    grep -q "^$section" "$f" || flag "$f missing section '$section'"
  done
done

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
