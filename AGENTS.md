# AGENTS.md — using project-kickoff on non-Claude harnesses

This repository is packaged as a Claude Code plugin (see README). The skill instructions under `skills/` are harness-neutral — they contain no Claude-specific logic — so other coding agents can consume them directly.

## Harnesses with their own plugin systems

Codex, Cursor, Kimi, Gemini, and others have their own plugin/extension formats (superpowers, for example, ships a directory per harness). Those formats are defined by each harness, not by this repository, and are not included here yet. To support one, add its plugin descriptor at the repo root alongside `skills/` following that harness's own spec, pointing at the same skills. Do not fork the skill content — keep `skills/` the single source of truth.

## Consuming the skills directly (any agent)

If your agent has no plugin install for this, run the chain by following the skill files in order, in an empty target directory:

1. `skills/using-project-kickoff/SKILL.md` — orientation and when to start
2. `skills/questionnaire/SKILL.md` — the dynamic interview
3. `skills/design-import/SKILL.md` — *(only when the questionnaire captured a design source)* pulls the design into standalone project files plus a manifest the spec consumes; skipped for source "none"
4. `skills/spec-authoring/SKILL.md` — answers into a testable `spec.md`
5. `skills/planning/SKILL.md` — `spec.md` into a tagged `plan.md`
6. `skills/execution/SKILL.md` — build the plan, which invokes:
   - `skills/test-driven-development/SKILL.md`
   - `skills/verification-before-completion/SKILL.md`
   - `skills/systematic-debugging/SKILL.md`

Only the generated artifacts (`spec.md`, `plan.md`, code, tests, verify script) land in the project. Nothing from this repository is copied into the generated project, and the generated project must run without it.
