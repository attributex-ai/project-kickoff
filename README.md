# Project Kickoff

A Claude Code plugin that scaffolds a new, self-verifying project through a staged chain with enforced testing. Install it, open Claude Code in an empty directory, run `/kickoff`, answer a short interview, and get a verified starter repo. No template to clone, no golden reference, no package versions hardcoded in the plugin. Inspired by [superpowers](https://github.com/obra/superpowers): small composable skills that carry a methodology, not one monolithic generator.

## How it works

An interview becomes a testable spec, the spec becomes a tagged plan, the plan becomes a build that proves every promised behavior with a test before it counts as done.

**Chain** (each stage emits a committed artifact the next consumes):
`questionnaire` -> `design-import` *(conditional — runs only when a design source was captured)* -> `spec-authoring` -> `planning` -> `execution`

**Disciplines** (enforced across the build):
`test-driven-development` (red-green for every behavioral feature), `verification-before-completion` (done = green gate + every promised module present), `systematic-debugging` (structured recovery when the gate is red).

**Orientation:** `using-project-kickoff` explains the chain and when to start it.

## Layout

```
project-kickoff/
├── .claude-plugin/
│   ├── plugin.json               # plugin manifest
│   └── marketplace.json          # catalog; lists this plugin with source "./"
├── commands/
│   └── kickoff.md                # /kickoff entry command
├── hooks/
│   ├── hooks.json                # SessionStart wiring
│   └── greenfield-nudge.sh       # suggests /kickoff only in near-empty dirs
├── skills/                       # the nine skills — the actual product
│   ├── using-project-kickoff/
│   ├── questionnaire/
│   ├── design-import/
│   ├── spec-authoring/
│   ├── planning/
│   ├── test-driven-development/
│   ├── execution/
│   ├── verification-before-completion/
│   └── systematic-debugging/
├── tests/
│   └── smoke-test.sh             # structural self-test (npm test)
├── AGENTS.md                     # cross-harness consumption
├── CLAUDE.md                     # dev-facing (working ON the plugin)
├── LICENSE                       # MIT
├── package.json
├── PRD.md                        # historical build spec (pre design-import) + audit history
└── README.md
```

Skills load from the default `skills/` scan (the marketplace entry lists `./skills/` to force a full scan under the root source). Commands load from `commands/`. The hook loads automatically from `hooks/hooks.json` (standard location; it must not also be declared in `plugin.json`).

## Validate

```bash
claude plugin validate .        # schema + frontmatter
npm test                        # structural smoke test
```

## Install and test locally

```
/plugin marketplace add ./project-kickoff
/plugin install project-kickoff@project-kickoff-marketplace
```

Then, in an empty directory, either wait for the session-start nudge or run (plugin commands and skills are namespaced by plugin name):

```
/project-kickoff:kickoff        # or just /kickoff
```

Suggested first test input: SaaS, auth yes, Postgres, payments yes, multi-tenant yes, admin yes, no AI, no mobile, Vercel, design source none. Stop after `spec.md` and `plan.md` are produced and confirm the spine works before letting execution run. (Answering the design question with a described direction instead exercises the conditional `design-import` stage.)

## Distribute

Push to GitHub, then users add it directly:

```
/plugin marketplace add attributex-ai/project-kickoff
/plugin install project-kickoff@project-kickoff-marketplace
```

For separate stable/latest channels, or to keep the catalog in its own repo, see the Claude Code marketplace docs; this repo keeps the catalog co-located for drop-in simplicity.

## Versioning

`version` is intentionally omitted from both manifests. For a git-hosted, actively developed plugin, Claude Code treats every new commit as a new version, which suits daily iteration. To pin releases later, set `version` in `plugin.json` only, and bump it each release. (The `Version:` header inside each generated `spec.md` is separate — it lets a resumed session detect a stale plan against a revised spec; it does not version this plugin.)

## The session-start nudge

`hooks/greenfield-nudge.sh` runs at session start (`startup|clear` only, so it doesn't re-fire on resume or compaction) and suggests `/kickoff` only when the working directory is near-empty, so it stays silent in populated repos. If kickoff artifacts (`spec.md`, `plan.md`, `design/DESIGN.md`) already exist, it points at the resume path instead of nudging a restart. It is fully defensive and always exits 0. If a future Claude Code version objects to the hook, delete `hooks/` and drop the hook checks from `tests/smoke-test.sh` — everything else works without it. (Do not declare the hooks file in `plugin.json`; `hooks/hooks.json` loads automatically, and a duplicate declaration prevents the plugin from loading.)
