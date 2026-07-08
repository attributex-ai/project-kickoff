# PRD: Project Kickoff Plugin (v3 — superpowers re-audit)

## Purpose of this version

v2 aligned the plugin to Anthropic's Claude Code plugin docs. v3 re-audits against the **actual superpowers repository** (obra/superpowers, read live) and folds in the structural patterns that repo proves in production. It also **corrects an error I made in v2**. Changes are tagged **[FIX]** (correcting a mistake) or **[ENHANCE]** (adopting a superpowers pattern).

The plugin is already assembled in this directory and its structural smoke test passes. This PRD is the build spec Claude Code should follow to finish, validate, and ship it.

---

## [FIX] Correction to v2: Codex plugins are real

In v2 I called `.codex-plugin` "fictional" and said Codex has no plugin system. That was wrong. The live superpowers repo ships `.claude-plugin`, `.codex-plugin`, `.cursor-plugin`, `.kimi-plugin`, `.opencode`, `.pi/extensions`, and a Gemini extension, and its README documents installing via an official Codex plugin marketplace. Codex, Cursor, Kimi, Gemini, and others each have their own plugin/extension formats.

The accurate position, and the one this repo now takes: **Claude Code's plugin format is the one fully specified in the docs available here, so it's the one built.** The other harnesses have real but separately-specified formats whose schemas aren't in hand, so this repo does **not** fabricate their manifests. Instead it keeps `skills/` at the repo root (harness-neutral) so any harness plugin can be added later pointing at the same skills. `AGENTS.md` documents that path. This is honest and extensible, rather than either pretending Codex doesn't exist (v2's error) or inventing a manifest I can't verify.

---

## [ENHANCE] Structure now mirrors superpowers

**Skills at the repo root, not nested under `plugins/`.** Superpowers puts `skills/` at the top level and each harness descriptor references it. v2 nested everything under `plugins/project-kickoff/`. Root-level skills make the multi-harness story natural and match the reference implementation. The marketplace entry uses `source: "./"` with `"skills": ["./skills/"]` to force a full skill scan under the root source (per the marketplace docs).

**Result:** one repo, skills at root, `.claude-plugin/` holding both `plugin.json` and the co-located `marketplace.json`. (Superpowers keeps its marketplace in a separate repo; this repo co-locates for drop-in local testing. Both are valid; the README notes the separate-repo option.)

---

## [ENHANCE] The skill set expanded from 4 to 8, following superpowers' composition

Superpowers is not a rigid 4-step chain — it's many small skills that trigger automatically, with cross-cutting disciplines (TDD, verification, debugging) invoked as needed. v2 embedded TDD and verification inside one big `execution` skill. That's exactly the monolith superpowers avoids. Split them out:

**Chain (staged, unchanged in spirit):**
1. `questionnaire` — dynamic branching interview (maps to nothing in superpowers; it's this plugin's front door)
2. `spec-authoring` — maps to superpowers `brainstorming` (Socratic refinement, chunked sign-off, saved design doc)
3. `planning` — maps to superpowers `writing-plans` (bite-sized tasks, exact steps)
4. `execution` — maps to superpowers `executing-plans`; now **slimmed to orchestrate**, delegating the disciplines below

**Disciplines (new, split out — this is the superpowers pattern):**
5. `test-driven-development` — maps to superpowers `test-driven-development` (RED-GREEN-REFACTOR, delete code written before tests). The reliability engine, now a standalone enforced skill.
6. `verification-before-completion` — maps to superpowers `verification-before-completion`. The gate (correctness + completeness), no longer buried in execution.
7. `systematic-debugging` — maps to superpowers `systematic-debugging` (root-cause process). Gives the verify loop a real recovery discipline instead of flailing.

**Orientation (new):**
8. `using-project-kickoff` — maps to superpowers `using-superpowers`. Bootstrap that explains the chain and when to start it.

**Deliberately NOT adopted from superpowers (scope control for v1):** `using-git-worktrees` and `finishing-a-development-branch` (this plugin builds greenfield into an empty dir, so branch isolation adds little); `requesting-code-review` / `receiving-code-review` (tests are the v1 gate); `subagent-driven-development` as a separate skill (v1 is single-agent with discipline; `execution` may dispatch per-task subagents later). Add these once the core chain is proven, the same way superpowers grew.

---

## [ENHANCE] Auto-trigger via a SessionStart hook

Superpowers' "magic" is that skills fire automatically — driven by a session-start hook that injects a bootstrap plus trigger-oriented skill descriptions. Adopted, but scoped to avoid noise: `hooks/greenfield-nudge.sh` runs at SessionStart and suggests `/kickoff` **only when the working directory is near-empty**. It's fully defensive and always exits 0. Combined with the `using-project-kickoff` bootstrap skill and trigger-worded descriptions, the chain can start without the user remembering a command — while staying silent in real repos.

This is the one piece most likely to need adjustment against a specific Claude Code version. If `claude plugin validate` objects, drop the `"hooks"` line from `plugin.json` and delete `hooks/`; the rest works unchanged. *(Superseded: the `"hooks"` line itself proved to be a load-blocking duplicate and was removed in commit 594da6d; `hooks/hooks.json` loads by convention.)*

---

## [ENHANCE] Packaging hygiene from superpowers

Added: `LICENSE` (MIT, matching superpowers), `package.json` with `npm test`, `tests/smoke-test.sh` (structural self-test — superpowers ships a `tests/` dir), root `CLAUDE.md` and `AGENTS.md` entry files (superpowers has per-harness entry files at root). Skill-behavior evals (superpowers uses a drill harness) are noted as a future addition, not built for v1.

---

## Unchanged non-negotiables

1. Plugin, not template — machinery never enters the generated project.
2. No golden reference, no pinned versions in the plugin — variance controlled by the staged chain + the gate.
3. Dynamic questionnaire only.
4. TDD enforced, split by the behavioral/structural boundary (defined once in `spec-authoring`).
5. Generated artifacts stand alone — the project runs with the plugin uninstalled.
6. Only generated artifacts persist in the project.

---

## Acceptance criteria for the plugin build

- `[STRUCT]` `npm test` (structural smoke test) passes. *(Already passing in this deliverable.)*
- `[STRUCT]` `claude plugin validate .` passes — no schema errors, no duplicate names, no path traversal, valid frontmatter on all eight skills.
- `[STRUCT]` `marketplace.json` has required `name`/`owner`/`plugins`; `name` is kebab-case and not reserved. `plugin.json` has `name`/`description`; `version` absent from both.
- `[STRUCT]` `/plugin marketplace add ./project-kickoff` then `/plugin install project-kickoff@project-kickoff-marketplace` succeeds.
- `[STRUCT]` SessionStart nudge appears in an empty dir and is silent in a populated one (or the hook is cleanly removed if validate rejects it).
- `[TDD-equivalent]` `/kickoff` in an empty dir starts the questionnaire.
- `[TDD-equivalent]` Finishing the questionnaire yields a `spec.md` with Given/When/Then criteria and presence checks.
- `[TDD-equivalent]` `spec.md` yields a `plan.md` of tagged `[TDD]`/`[STRUCT]` tasks with IDs matching the spec.
- `[TDD-equivalent]` `plan.md` yields project code plus a verify script; TDD, verification, and debugging skills engage during the build; the verify loop runs to green or a reported failure.
- `[STRUCT]` The generated project contains none of the plugin's files and its verify script runs with the plugin uninstalled.

---

## Build order

1. **Validate + install.** `npm test`, then `claude plugin validate .`, fix any schema issues, then add + install locally. Nothing else matters until it installs cleanly.
2. **Nudge + entry.** Confirm the SessionStart nudge behaves and `/kickoff` triggers the questionnaire.
3. **Spine.** Run kickoff to produce `spec.md` and `plan.md`. **Stop and verify the spine** — cheapest place to catch a broken hand-off.
4. **Execution + disciplines.** Build one simple input end to end; confirm TDD/verification/debugging engage and the standalone rule holds.
5. **Other harnesses last.** Only after the Claude Code path works, add a harness descriptor (Codex, etc.) per that harness's own spec, pointing at the same `skills/`.

Don't wire everything then test. Prove the spine first.

---

## Explicit non-goals

- No golden reference or template repo.
- No hardcoded package versions or build instructions in any skill or manifest.
- No generated project that depends on the plugin.
- No fabricated non-Claude manifests (`.codex-plugin` etc.) with schemas not in hand — structure for them, don't invent them.
- No "modify an existing project" mode yet — v1 is run-once on an empty dir.
- No worktree/code-review/subagent skills yet — add after the core chain is proven.

Keep the shell thin; let the eight skills carry the intelligence; validate early and often.
