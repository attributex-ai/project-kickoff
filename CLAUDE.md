# CLAUDE.md — developing this plugin

This file is for working **on** the project-kickoff plugin (contributor/dev context). It is not a component of the plugin and is not copied into any generated project. When the plugin is installed, its skills load automatically from `skills/`; nothing here needs to point at them.

## What this plugin is

A Claude Code plugin that scaffolds a new, self-verifying project through a staged chain with enforced testing. The intelligence lives entirely in the skills under `skills/`. Everything else (manifests, command, hook) is thin wiring.

## Layout

```
.claude-plugin/plugin.json        plugin manifest
.claude-plugin/marketplace.json   catalog; lists this plugin with source "./"
commands/kickoff.md               /kickoff entry command
hooks/hooks.json                  SessionStart wiring
hooks/greenfield-nudge.sh         nudges /kickoff only in near-empty dirs
skills/                           the skills (the actual product)
tests/smoke-test.sh               structural self-test (npm test)
```

## The skills

Chain (staged; every stage after the questionnaire emits a committed artifact): `questionnaire` -> `design-import` -> `spec-authoring` -> `planning` -> `execution`. `design-import` is the conditional link — it runs only when the questionnaire captured a design source, and is skipped entirely for source "none".
Disciplines (invoked across the chain): `test-driven-development`, `verification-before-completion`, `systematic-debugging`.
Orientation: `using-project-kickoff` (bootstrap; explains the chain and when to start it).

## Working on skills

- Keep each skill focused on one job. The chain's reliability comes from small, composable skills, not one big one.
- The behavioral/structural boundary and the Given/When/Then criterion format are defined once, in `spec-authoring`. Other skills reference that definition rather than restating it. If you change the boundary, change it there.
- Descriptions are written to trigger reliably (they name the situations that should fire the skill). If a skill isn't firing during testing, sharpen its description first.

## Testing the plugin

- Structure: `npm test` (runs `tests/smoke-test.sh`).
- Schema: `claude plugin validate .`
- Behavior: install locally and run the chain on one input. See README.

## Before publishing

The marketplace `name` must stay off Anthropic's reserved-names list (see the plugin-marketplaces docs).
