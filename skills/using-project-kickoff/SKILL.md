---
name: using-project-kickoff
description: Orient to the project-kickoff chain and know when to start it. Use this skill at the start of any session where the user signals they want to build, scaffold, spin up, or generate a new project or app, or when a directory is empty and a new build is plausible. It explains the four-stage chain plus its conditional design-import stage, the disciplines that run across it, and points at the entry skill. It does not build anything itself; it makes sure the right skill fires at the right time.
---

# Using Project Kickoff

This plugin turns a rough "I want to build X" into a verified starter repository, through a staged chain with human checkpoints and enforced testing. Its whole reason for existing: an agent pointed at a blank directory will happily improvise a project that looks right and sometimes isn't. The chain replaces improvisation with a process you can watch and trust.

## When to start the chain

Start when the user wants a new project and you're in a place to build one — a greenfield signal ("build me a SaaS", "spin up a dashboard", "new project") especially in an empty or near-empty directory. Begin with the `questionnaire` skill, or the user can run `/kickoff`.

Do **not** start the chain for changes to an existing, populated codebase. This plugin is for run-once greenfield generation, not for editing established projects.

## The chain

Four stages, plus one conditional, each producing a committed artifact the next consumes:

1. **`questionnaire`** — a dynamic, branching interview. Prunes questions that don't apply and rejects incoherent combinations. Captures answers — including the **design source** (a Claude Design project, a described direction, or none).
2. **`design-import`** *(conditional — runs only when a design source was given)* — pulls the design from Claude Design (or a described direction), materializes tokens, fonts, brand assets, and a component inventory into the project as standalone files, reconciles it against the answers, and emits a `design/DESIGN.md` manifest the spec consumes. Skipped entirely when the design source is "none."
3. **`spec-authoring`** — deepens the answers into a testable `spec.md`: Given/When/Then acceptance criteria for behavior, presence checks for structure (including design presence/render checks when a design was imported). Chunked human sign-off.
4. **`planning`** — turns the spec into `plan.md`: tagged `[TDD]` and `[STRUCT]` tasks, critical security-and-money work first, design foundation wired early, mocks named.
5. **`execution`** — builds the project by working the plan.

## The disciplines that run across the chain

These are not stages; they are always-on rules the execution stage invokes:

- **`test-driven-development`** — every behavioral task goes red-green: failing test first, then the code that passes it. This is the reliability engine.
- **`verification-before-completion`** — "done" means a green verify gate *and* every promised module present. Never the agent's say-so.
- **`systematic-debugging`** — when the gate is red, follow a structured root-cause process instead of guessing.

## The two rules that never bend

- **Generated artifacts stand alone.** The project must build, test, and run with this plugin uninstalled. Nothing generated may reference the plugin.
- **Only generated artifacts persist in the project.** The plugin's own skills, commands, hooks, and manifests are never copied into the built project.

If you're ever unsure which skill applies, re-read this orientation and pick the earliest stage not yet done.
