#!/usr/bin/env bash
# Project Kickoff -- plugin smoke test
# Validates the plugin's own structure before you install it. This does NOT test
# a generated project; it tests that the plugin is shaped correctly.
#
# Run from the plugin root:  bash tests/smoke-test.sh

set -uo pipefail
fail=0
root="$(cd "$(dirname "$0")/.." && pwd)"

check() { if eval "$2"; then echo "ok   - $1"; else echo "FAIL - $1"; fail=1; fi; }

# Manifests exist
check "plugin.json exists"      "[ -f '$root/.claude-plugin/plugin.json' ]"
check "marketplace.json exists" "[ -f '$root/.claude-plugin/marketplace.json' ]"

# Manifests are valid JSON
check "plugin.json is valid JSON"      "python3 -c \"import json;json.load(open('$root/.claude-plugin/plugin.json'))\" 2>/dev/null"
check "marketplace.json is valid JSON" "python3 -c \"import json;json.load(open('$root/.claude-plugin/marketplace.json'))\" 2>/dev/null"
check "hooks.json is valid JSON"       "python3 -c \"import json;json.load(open('$root/hooks/hooks.json'))\" 2>/dev/null"
check "plugin.json does not declare hooks (loads by convention)" "! grep -q '\"hooks\"' '$root/.claude-plugin/plugin.json'"

# Entry command
check "kickoff command exists" "[ -f '$root/commands/kickoff.md' ]"

# Hook script exists and is executable
check "hook script exists"       "[ -f '$root/hooks/greenfield-nudge.sh' ]"
check "hook script is executable" "[ -x '$root/hooks/greenfield-nudge.sh' ]"

# Every skill in the chain is present with a SKILL.md.
# This list is the assertion — each named skill MUST exist — so add new skills here.
for s in using-project-kickoff questionnaire design-import spec-authoring planning \
         test-driven-development execution verification-before-completion systematic-debugging; do
  check "skill '$s' has SKILL.md" "[ -f '$root/skills/$s/SKILL.md' ]"
done

# Every SKILL.md has frontmatter with a description
while IFS= read -r f; do
  check "$(basename "$(dirname "$f")") frontmatter has description" "grep -q '^description:' '$f'"
done < <(find "$root/skills" -name SKILL.md)

# Chain-drift guard: every restatement of the chain must include the conditional
# design-import link (this drifted once; see feature/performance-improvements).
for f in README.md skills/spec-authoring/SKILL.md skills/planning/SKILL.md skills/execution/SKILL.md; do
  check "$f chain line mentions design-import" "grep -q 'design-import' '$root/$f'"
done

echo
if [ "$fail" -eq 0 ]; then echo "ALL CHECKS PASSED"; else echo "SOME CHECKS FAILED"; fi
exit $fail
