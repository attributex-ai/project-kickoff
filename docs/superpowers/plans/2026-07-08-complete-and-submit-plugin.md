# Project Kickoff — Complete & Submit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Take the already-assembled project-kickoff plugin from "validates locally with one failing check" to "published on GitHub and submitted to Anthropic's community plugin marketplace."

**Architecture:** The plugin is complete in structure (8 skills, /kickoff command, SessionStart nudge hook, co-located marketplace catalog). Remaining work is verification and shipping: fix one structural defect, verify the behavioral chain per the PRD's acceptance criteria, publish the repo, submit. No new skills or components are built.

**Tech Stack:** Claude Code plugin system (plugin.json / marketplace.json / SKILL.md / hooks.json), bash, git, GitHub (`gh` CLI).

## Global Constraints

Copied from PRD.md ("Unchanged non-negotiables" + acceptance criteria):

- `version` stays **absent** from both `plugin.json` and the marketplace entry (git-SHA versioning; the community catalog SHA-pins and auto-bumps on push). Do not "fix" the validate warning about version.
- Plugin, not template: no plugin file ever enters a generated project.
- No pinned dependency versions anywhere in skills or manifests.
- Generated projects must run with the plugin uninstalled.
- Marketplace `name` is `project-kickoff-marketplace` (kebab-case, not in Anthropic's reserved list). Plugin `name` is `project-kickoff` (kebab-case — required; claude.ai marketplace sync rejects non-kebab-case names).
- The behavioral/structural boundary and Given/When/Then format are defined once in `skills/spec-authoring/SKILL.md`; if any skill misbehaves, change descriptions/instructions, never duplicate that definition.

## Critical Path Correction (vs the PRD's stated target)

The PRD targets "submission to the Claude official marketplace." Per the current official docs (code.claude.com/docs/en/plugins, "Submit your plugin to the community marketplace"):

- **`claude-plugins-official` is curated by Anthropic at its discretion. There is no application process.** The submission form does not feed it.
- The submittable target is **`claude-community`** (repo: `anthropics/claude-plugins-community`). Approved plugins are pinned to a commit SHA of **your public GitHub repo**, and CI bumps the pin as you push.
- Submission forms:
  - **Console (use this one — works for individual accounts):** https://platform.claude.com/plugins/submit
  - claude.ai form (https://claude.ai/admin-settings/directory/submissions/plugins/new) requires a Team/Enterprise org with directory management access.
- The review pipeline runs `claude plugin validate` plus automated safety screening. The public catalog syncs nightly after approval.

This plan therefore ships to the **community marketplace**. Getting into `claude-plugins-official` later is Anthropic's call (that's how superpowers got there), not a step you can take.

## Current State (verified 2026-07-08)

| Check | Status |
| --- | --- |
| All 8 skills present, valid frontmatter, trigger-worded descriptions | ✅ |
| `claude plugin validate .` | ✅ passes (2 warnings: no `version` — intentional; no `author` — fix in Task 2) |
| `npm test` (smoke test) | ❌ 1 failure: `hooks/greenfield-nudge.sh` not executable |
| LICENSE / marketplace owner personalized ("Prashanth Kolishetti") | ✅ |
| Git repository | ❌ not initialized — blocks distribution and submission |
| Name collision in community catalog (2,199 plugins checked) | ✅ `project-kickoff` is free |
| Local install test, nudge behavior, behavioral chain (PRD criteria) | ⬜ not yet verified |

---

### Task 1: Make the nudge hook executable → smoke test green

**Files:**
- Modify (mode only): `hooks/greenfield-nudge.sh`

**Interfaces:**
- Produces: a green `npm test`, which Tasks 3 and 9 rely on.

- [ ] **Step 1: Confirm the failing check (red)**

Run: `npm test`
Expected: `FAIL - hook script is executable`, final line `SOME CHECKS FAILED`, exit code 1.

- [ ] **Step 2: Set the executable bit**

```bash
chmod +x hooks/greenfield-nudge.sh
```

- [ ] **Step 3: Verify green**

Run: `npm test`
Expected: every line starts with `ok   -`, final line `ALL CHECKS PASSED`, exit code 0.

(No commit yet — the repo isn't a git repo until Task 3. Git records the +x bit, so the mode survives the initial commit.)

---

### Task 2: Add `author` to plugin.json (clear the fixable validate warning)

**Files:**
- Modify: `.claude-plugin/plugin.json`

**Interfaces:**
- Produces: a `plugin.json` whose only remaining validate warning is the intentional missing `version`.

- [ ] **Step 1: Add the author block**

`.claude-plugin/plugin.json` becomes exactly:

```json
{
  "name": "project-kickoff",
  "description": "Interview-driven, test-driven project generator. Runs a dynamic questionnaire, then builds a self-verifying starter repo through spec -> plan -> execution, with TDD and a verification gate enforced. No golden reference and no pinned versions in the plugin; variance is controlled by the staged chain and the gate.",
  "author": {
    "name": "Prashanth Kolishetti",
    "email": "kolishetti@gmail.com"
  },
  "hooks": "./hooks/hooks.json"
}
```

Do **not** add `version` (see Global Constraints).

- [ ] **Step 2: Re-validate**

Run: `claude plugin validate .`
Expected: `✔ Validation passed with warnings` with exactly one warning (the `version` one). The author warning is gone.

- [ ] **Step 3: Re-run smoke test (JSON still valid)**

Run: `npm test`
Expected: `ALL CHECKS PASSED`.

---

### Task 3: Initialize git and make the initial commit

**Files:**
- Create: `.gitignore`

**Interfaces:**
- Produces: a committed repo at `main`; every later task assumes it exists.

- [ ] **Step 1: Remove macOS junk and create `.gitignore`**

```bash
find . -name .DS_Store -delete
```

Create `.gitignore` with exactly:

```
.DS_Store
node_modules/
```

- [ ] **Step 2: Initialize and commit everything**

```bash
git init -b main
git add -A
git status --short   # confirm: no .DS_Store, greenfield-nudge.sh staged (git preserves +x)
git commit -m "feat: project-kickoff plugin v1 — 8-skill chain, kickoff command, greenfield nudge

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

Expected: one commit on `main`; `git ls-files` lists all plugin files including `docs/superpowers/plans/`.

- [ ] **Step 3: Confirm the executable bit is recorded**

Run: `git ls-files -s hooks/greenfield-nudge.sh`
Expected: mode `100755` (not `100644`).

---

### Task 4: Install locally through the marketplace flow (PRD `[STRUCT]` criterion)

**Files:** none modified.

**Interfaces:**
- Consumes: committed repo from Task 3.
- Produces: an installed `project-kickoff@project-kickoff-marketplace` that Tasks 5–7 exercise.

- [ ] **Step 1: Add the marketplace and install**

```bash
claude plugin marketplace add /Users/prashanth/Documents/github-repos/project-kickoff
claude plugin install project-kickoff@project-kickoff-marketplace
```

Expected: both commands succeed; no schema or path errors.

- [ ] **Step 2: Verify registration**

```bash
claude plugin marketplace list
```

Expected: `project-kickoff-marketplace` listed with a local path source.

- [ ] **Step 3: Verify the command surface in a session**

Start `claude` anywhere, run `/help`.
Expected: `/project-kickoff:kickoff` appears under the plugin namespace.

---

### Task 5: Verify the SessionStart nudge (PRD `[STRUCT]` criterion)

**Files:** none modified (unless the hook misbehaves — see Step 4).

**Interfaces:**
- Consumes: installed plugin from Task 4.

- [ ] **Step 1: Script-level check — empty dir fires**

```bash
mkdir -p /tmp/kickoff-nudge-test && cd /tmp/kickoff-nudge-test
bash /Users/prashanth/Documents/github-repos/project-kickoff/hooks/greenfield-nudge.sh; echo "exit=$?"
```

Expected: the nudge message ("This directory looks nearly empty... run /kickoff...") and `exit=0`.

- [ ] **Step 2: Script-level check — populated dir stays silent**

```bash
cd /Users/prashanth/Documents/github-repos/project-kickoff
bash hooks/greenfield-nudge.sh; echo "exit=$?"
```

Expected: no output, `exit=0`.

- [ ] **Step 3: Session-level check**

Start `claude` inside `/tmp/kickoff-nudge-test` (empty dir).
Expected: the nudge text appears in session-start context. Then start `claude` in a populated repo: no nudge.

- [ ] **Step 4: Fallback if Claude Code rejects the hook**

Only if validation or session start errors on the hook (PRD's documented escape hatch): delete the `"hooks"` line from `.claude-plugin/plugin.json`, `git rm -r hooks/`, remove the two hook checks from `tests/smoke-test.sh` (lines 21, 27–28), re-run `npm test` to green, commit `fix: drop SessionStart hook (rejected by validator)`. Everything else works without it.

---

### Task 6: Verify the spine — /kickoff → spec.md → plan.md (PRD `[TDD-equivalent]` criteria)

**Files:** none in this repo; artifacts land in a scratch dir.

**Interfaces:**
- Consumes: installed plugin.
- Produces: confidence that questionnaire → spec-authoring → planning hand-offs work. **Stop before execution** (PRD build order: "prove the spine first").

- [ ] **Step 1: Run the interview**

```bash
mkdir -p /tmp/kickoff-spine-test && cd /tmp/kickoff-spine-test && claude
```

Run `/project-kickoff:kickoff`. Use the README's suggested input: SaaS, auth yes, Postgres, payments yes, multi-tenant yes, admin yes, no AI, no mobile, Vercel.
Expected: the questionnaire skill fires (branching questions, prunes irrelevant ones, no code written), then hands off to spec-authoring.

- [ ] **Step 2: Check spec.md**

Expected in `/tmp/kickoff-spine-test/spec.md`: Given/When/Then acceptance criteria for behavioral features (auth, payments, tenancy) **plus** structural presence checks, each with a stable ID.

- [ ] **Step 3: Check plan.md**

Expected in `/tmp/kickoff-spine-test/plan.md`: ordered tasks tagged `[TDD]` (one per behavioral criterion) and `[STRUCT]` (one per presence check), IDs matching spec.md, security/payment work ordered first. Stop the session here.

- [ ] **Step 4: If a hand-off fails to fire**

Per CLAUDE.md: sharpen the non-firing skill's `description` in its SKILL.md (name the triggering situation more explicitly), run `/reload-plugins`, re-test from Step 1. Commit any description change: `fix(<skill>): sharpen trigger description`.

---

### Task 7: End-to-end execution on one simple input + standalone check (PRD final criteria)

**Files:** none in this repo (unless skills need sharpening, as in Task 6 Step 4).

**Interfaces:**
- Consumes: proven spine from Task 6.
- Produces: the last two PRD acceptance boxes — disciplines engage; generated project stands alone.

- [ ] **Step 1: Run the full chain on a small input**

```bash
mkdir -p /tmp/kickoff-e2e-test && cd /tmp/kickoff-e2e-test && claude
```

Run `/project-kickoff:kickoff` with a deliberately small project (e.g., a REST API with auth, Postgres, **no** payments/tenancy/admin) so execution finishes in one sitting. Let execution run.
Expected: test-driven-development fires on every `[TDD]` task (failing test shown before implementation); verification-before-completion writes and runs a verify script before "done" is claimed; systematic-debugging fires if the gate goes red.

- [ ] **Step 2: Standalone check — no plugin files leaked**

```bash
cd /tmp/kickoff-e2e-test
grep -ril "project-kickoff\|SKILL.md\|claude-plugin" --exclude-dir=node_modules --exclude-dir=.git . ; echo "leak-scan exit=$?"
```

Expected: no matches (exit 1 from grep). Only spec.md, plan.md, code, tests, and the verify script exist.

- [ ] **Step 3: Standalone check — runs with the plugin uninstalled**

```bash
claude plugin uninstall project-kickoff@project-kickoff-marketplace
cd /tmp/kickoff-e2e-test && bash <the generated verify script>   # e.g. ./verify.sh or npm run verify, whatever the build produced
```

Expected: verify script runs green with the plugin gone. Then reinstall for daily use:

```bash
claude plugin install project-kickoff@project-kickoff-marketplace
```

---

### Task 8: Publish to GitHub (public — required for community-catalog SHA pinning)

**Files:** none modified.

**Interfaces:**
- Consumes: committed repo (Task 3) with any fixes from Tasks 5–7 committed.
- Produces: the public `https://github.com/<owner>/project-kickoff` URL Task 10 submits.

- [ ] **Step 1: Commit any outstanding fixes**

Run: `git status --short`
Expected: clean tree. If not, commit with a descriptive message first.

- [ ] **Step 2: Create the public repo and push**

```bash
gh auth status                      # must be logged in
gh repo create project-kickoff --public --source=. --push
```

Expected: repo created under your account, `main` pushed. Note the URL: `https://github.com/$(gh api user --jq .login)/project-kickoff`.

- [ ] **Step 3: Prove remote installability (what reviewers and users will do)**

```bash
claude plugin marketplace remove project-kickoff-marketplace
claude plugin marketplace add $(gh api user --jq .login)/project-kickoff
claude plugin install project-kickoff@project-kickoff-marketplace
```

Expected: installs from GitHub cleanly. (Removing the local marketplace first matters: one marketplace per name, and the GitHub source is the one users get.)

---

### Task 9: Pre-submission gate

**Files:** none modified.

- [ ] **Step 1: Final validation (the pipeline runs this exact check)**

Run: `claude plugin validate .`
Expected: passes; only the intentional `version` warning remains.

- [ ] **Step 2: Final smoke test**

Run: `npm test` → `ALL CHECKS PASSED`.

- [ ] **Step 3: Re-confirm the name is still free**

```bash
curl -sL https://raw.githubusercontent.com/anthropics/claude-plugins-community/main/.claude-plugin/marketplace.json | grep -c '"project-kickoff"'
```

Expected: `0`. (Checked 2026-07-08: free; 2,199 plugins in catalog.)

- [ ] **Step 4: Content sanity for reviewers**

README explains install + usage (✅ already), LICENSE is MIT and personalized (✅), no secrets or tokens anywhere in the repo: `git grep -iE "api[_-]?key|token|secret" -- ':!PRD.md' ':!docs'` returns nothing sensitive.

---

### Task 10: Submit to the community marketplace and track approval

**Files:** none modified. **This task is user-driven (web form).**

- [ ] **Step 1: Submit via the Console form**

Open https://platform.claude.com/plugins/submit (works for individual accounts; the claude.ai form requires a Team/Enterprise org). Provide the GitHub repo URL from Task 8 and the plugin name `project-kickoff`.

- [ ] **Step 2: What the pipeline does**

Runs `claude plugin validate` + automated safety screening. On approval, the plugin is added to `anthropics/claude-plugins-community` pinned to a commit SHA; CI auto-bumps the pin as you push new commits. The public catalog syncs nightly — expect a delay between approval and appearance.

- [ ] **Step 3: Verify listing**

Periodically check:

```bash
curl -sL https://raw.githubusercontent.com/anthropics/claude-plugins-community/main/.claude-plugin/marketplace.json | grep '"project-kickoff"'
```

Expected (eventually): one match. Then the public install path is:

```
/plugin marketplace add anthropics/claude-plugins-community
/plugin install project-kickoff@claude-community
```

- [ ] **Step 4: Post-listing follow-ups (optional, later)**

Update README's Distribute section with the `@claude-community` install line; keep pushing commits freely (SHA pinning auto-bumps, no version field to maintain). `claude-plugins-official` inclusion is Anthropic-curated with no application — nothing to do there.

---

## Self-Review (performed at write time)

- **Spec coverage:** every PRD acceptance criterion maps to a task — smoke test (T1), validate (T2/T9), manifests (T2, pre-verified), marketplace add/install (T4, T8), nudge behavior + removal escape hatch (T5), /kickoff → questionnaire (T6), spec.md format (T6), plan.md format (T6), execution + disciplines + verify loop (T7), standalone rule (T7). PRD build order (validate → nudge → spine → execution → other harnesses) is preserved; "other harnesses" is an explicit PRD non-goal for v1 and stays out.
- **Placeholder scan:** the one soft reference is the generated verify script's filename in T7 Step 3 — unknowable before generation; the step says how to identify it.
- **Type consistency:** names used across tasks (`project-kickoff`, `project-kickoff-marketplace`, file paths) match the actual manifests verified above.
