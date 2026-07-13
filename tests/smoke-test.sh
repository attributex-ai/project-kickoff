#!/usr/bin/env bash
# Project Kickoff -- plugin smoke test
# Validates the plugin's own structure before you install it. This does NOT test
# a generated project; it tests that the plugin is shaped correctly.
#
# Run from the plugin root:  bash tests/smoke-test.sh
# Schema validation is separate: npm run validate (requires the claude CLI).

set -uo pipefail
fail=0
root="$(cd "$(dirname "$0")/.." && pwd)"

# check <name> <command...>  — passes when the command succeeds
check() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "ok   - $name"; else echo "FAIL - $name"; fail=1; fi
}
# check_not <name> <command...>  — passes when the command fails
check_not() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "FAIL - $name"; fail=1; else echo "ok   - $name"; fi
}

# Manifests exist and are valid JSON
check "plugin.json exists"             test -f "$root/.claude-plugin/plugin.json"
check "marketplace.json exists"        test -f "$root/.claude-plugin/marketplace.json"
check "plugin.json is valid JSON"      python3 -c "import json;json.load(open('$root/.claude-plugin/plugin.json'))"
check "marketplace.json is valid JSON" python3 -c "import json;json.load(open('$root/.claude-plugin/marketplace.json'))"
check "hooks.json is valid JSON"       python3 -c "import json;json.load(open('$root/hooks/hooks.json'))"
check_not "plugin.json does not declare hooks (loads by convention)" grep -q '"hooks"' "$root/.claude-plugin/plugin.json"

# Entry command
check "kickoff command exists"          test -f "$root/commands/kickoff.md"
check "kickoff command has description" grep -q '^description:' "$root/commands/kickoff.md"

# Hook script exists, is executable, and parses
check "hook script exists"        test -f "$root/hooks/greenfield-nudge.sh"
check "hook script is executable" test -x "$root/hooks/greenfield-nudge.sh"
check "hook script parses"        bash -n "$root/hooks/greenfield-nudge.sh"
check "smoke test parses"         bash -n "$root/tests/smoke-test.sh"

# Every skill in the chain is present with a SKILL.md.
# This list is the assertion — each named skill MUST exist — so add new skills here.
expected_skills=(using-project-kickoff questionnaire design-import spec-authoring planning
                 test-driven-development execution verification-before-completion systematic-debugging)
for s in "${expected_skills[@]}"; do
  check "skill '$s' has SKILL.md" test -f "$root/skills/$s/SKILL.md"
done

# No skill exists that this list doesn't assert (adding a skill must update the list above)
actual_count=$(find "$root/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
check "skill count matches assertion list (${#expected_skills[@]})" test "$actual_count" -eq "${#expected_skills[@]}"

# Every SKILL.md: frontmatter description present and <=1024 chars; name matches its directory
while IFS= read -r f; do
  dir="$(basename "$(dirname "$f")")"
  check "$dir frontmatter has description" grep -q '^description:' "$f"
  check "$dir description <= 1024 chars"   test "$(grep -m1 '^description:' "$f" | wc -c | tr -d ' ')" -le 1024
  check "$dir frontmatter name matches directory" grep -q "^name: $dir$" "$f"
done < <(find "$root/skills" -name SKILL.md)

# Chain-drift guard: every restatement of the chain must include the conditional
# design-import link (this drifted once; see feature/performance-improvements).
for f in README.md skills/spec-authoring/SKILL.md skills/planning/SKILL.md skills/execution/SKILL.md; do
  check "$f chain line mentions design-import" grep -q design-import "$root/$f"
done

echo
if [ "$fail" -eq 0 ]; then echo "ALL CHECKS PASSED"; else echo "SOME CHECKS FAILED"; fi
exit $fail
