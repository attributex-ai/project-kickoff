---
name: using-project-kickoff
description: Orient to the project-kickoff chain and know when to start it. Use this skill at the start of any session where the user signals they want to build, scaffold, spin up, or generate a new project or app, or when a directory is empty and a new build is plausible. It explains the four-stage chain plus its conditional design-import stage, the disciplines that run across it, and points at the entry skill. It does not build anything itself; it makes sure the right skill fires at the right time.
---

# Using Project Kickoff

This plugin turns a rough "I want to build X" into a verified starter repository, through a staged chain with human checkpoints and enforced testing. The chain replaces improvisation with a process you can watch and trust.

## When to start the chain

Start when the user wants a new project and you're in a place to build one — a greenfield signal ("build me a SaaS", "spin up a dashboard", "new project") especially in an empty or near-empty directory. Begin with the `questionnaire` skill, or the user can run `/kickoff`.

Do **not** start the chain for changes to an existing, populated codebase. This plugin is for run-once greenfield generation, not for editing established projects.

## The chain

Four stages, plus one conditional. Every stage after the questionnaire produces a committed artifact the next consumes; the questionnaire itself writes nothing — its capture becomes durable when the next stage writes its first artifact (`design/DESIGN.md` on the design path, otherwise the skeleton `spec.md`).

1. **`questionnaire`** — a dynamic, branching interview. Prunes questions that don't apply and rejects incoherent combinations. Captures answers — including the **design source** (a Claude Design project, a described direction, or none).
2. **`design-import`** *(conditional — runs only when a design source was given)* — pulls the design from Claude Design (or a described direction), materializes tokens, fonts, brand assets, and a component inventory into the project as standalone files, reconciles it against the answers, and emits a `design/DESIGN.md` manifest the spec consumes. Skipped entirely when the design source is "none."
3. **`spec-authoring`** — deepens the answers into a testable `spec.md`: Given/When/Then acceptance criteria for behavior, presence checks for structure (including design presence/render checks when a design was imported). Chunked human sign-off.
4. **`planning`** — turns the spec into `plan.md`: tagged `[TDD]` and `[STRUCT]` tasks, critical security-and-money work first, design foundation wired early, mocks named.
5. **`execution`** — builds the project by working the plan.

## The disciplines that run across the chain

These are not stages; they are always-on rules the execution stage invokes:

- **`project-kickoff:test-driven-development`** — every behavioral task goes red-green: failing test first, then the code that passes it. This is the reliability engine.
- **`project-kickoff:verification-before-completion`** — "done" means a green verify gate *and* every promised module present. Never the agent's say-so.
- **`project-kickoff:systematic-debugging`** — when the gate is red, follow a structured root-cause process instead of guessing.

Other installed plugins may ship skills with these same names. Within this chain, always invoke the project-kickoff-namespaced variants — only they write the verify script, enforce the tag discipline, and check completeness against spec.md.

## The two rules that never bend

- **Generated artifacts stand alone.** The project must build, test, and run with this plugin uninstalled. Nothing generated may reference the plugin.
- **Only generated artifacts persist in the project.** The plugin's own skills, commands, hooks, and manifests are never copied into the built project.

## Resuming an interrupted kickoff

Detect the stage from the artifacts on disk, then enter there:

| On disk | Resume at |
|---|---|
| no `spec.md`, no `design/` | `questionnaire` — nothing durable existed yet |
| `design/` staged files, no `design/DESIGN.md` | `design-import` — re-confirm the questionnaire answers with the user (not yet durable), keep valid staged files, and finish from the manifest step |
| `design/DESIGN.md` present, no `spec.md` | `spec-authoring` — design-import is done, don't re-run it; read the questionnaire answers from the manifest's Captured answers section |
| `spec.md` with `Status: draft` | `spec-authoring` — resume the interview at the first category with no criteria |
| `spec.md` approved, no `plan.md` | `planning` |
| `plan.md` with unchecked tasks | `execution`'s resume procedure |
| every task checked or descoped | `execution`'s finishing steps — verify via `project-kickoff:verification-before-completion`, then document and report |

If `plan.md` carries a `## Verify status` block, read it before any debugging — it records what already failed. Consistency check: if spec.md's Selected modules names a design source but `design/DESIGN.md` is absent, design-import was skipped — run it before proceeding.

If you're ever unsure which skill applies, re-read this orientation and pick the earliest stage not yet done.
