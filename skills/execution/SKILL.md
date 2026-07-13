---
name: execution
description: Build the project by working an approved implementation plan, delegating testing and verification to their dedicated skills. Use this skill after plan.md exists and the user is ready to generate the actual project. It works tasks top to bottom, installs dependencies, and drives the build to a verified, complete state. It calls test-driven-development for behavioral tasks, verification-before-completion for the definition of done, and systematic-debugging when the gate is red. Trigger when plan.md exists and it's time to build.
---

# Execution

You have an approved `plan.md`: an ordered list of `[TDD]` and `[STRUCT]` tasks, each carrying an ID that traces to the spec. Build the project by working that list, and leave behind a project that verifies itself and stands entirely on its own.

This is the final stage of: **questionnaire -> [design-import, when a design source was captured] -> spec -> plan -> execution.** It orchestrates; the disciplines do the enforcing.

## Two principles that govern everything

**Assemble, don't improvise.** Work strictly from the approved plan. Don't add behavior the spec didn't promise — if the build obviously needs something the plan lacks, that's a plan gap: note it, don't silently invent it.

**The generated project stands alone.** When you finish, someone can clone this project *without this plugin installed* and it builds, tests, and runs. Nothing generated may reference the plugin at runtime — not the verify script, not the tests, not the code. The plugin builds the project and walks away. This extends to an imported design: tokens, fonts, and brand assets are materialized into the project as real files (the `design-import` skill did this), and the app never fetches from claude.ai/design or a remote font host at runtime. Imported component specs are *translated* into the project's own framework components — Claude Design ships static HTML; the project gets typed components in the target stack — never copied in as-is or referenced remotely.

## Working the plan

**Intake first.** Verify plan.md's recorded spec Version matches spec.md's current header — a mismatch means the spec was revised after planning; return to planning. Verify every task carries exactly one `[TDD]`/`[STRUCT]` tag and an ID that exists in spec.md — defects go back to planning; never improvise around them. If plan approval can't be established (a resumed session), show the build order and get a go-ahead before task 1.

Go top to bottom. The plan is ordered to keep the app bootable and to front-load risk; don't reorder.

**For each `[STRUCT]` task:** create what it names (scaffold — named from the spec's Product line — connection, config, dependency), confirm it's present and the app still boots, move on. Do not test-drive these — `verification-before-completion` presence-checks them.

**For each `[TDD]` task:** hand off to the `test-driven-development` skill and run its full red-green cycle — failing test first, then minimal code, then green. Do not implement behavioral code any other way.

**Record progress as you go.** Flip the task's checkbox in plan.md to `[x]` in the same commit as the task's work (for `[TDD]` tasks, the commit the TDD cycle already makes). A plan whose checkboxes match reality is what makes an interrupted build resumable.

**Resuming.** On entering execution with a plan that already has checked tasks, never restart from the top. If the project's verify script exists, run it first and debug any red before proceeding; then continue from the first unchecked task. If the verify script doesn't exist yet (interrupted before the foundation tasks finished), confirm the app state matches the checked tasks, then continue from the first unchecked one.

**Design foundation runs early; design tasks are `[STRUCT]`.** If the plan has design-foundation tasks (token file, fonts, global stylesheet), work them right after scaffold so every later screen is built against the theme, not restyled afterward. Component and screen tasks are structural present-and-render work — build the component to the manifest's spec, confirm it renders, move on. Do not test-drive design and do not assert on colors or copy.

**Dependencies:** install as tasks require them. Choose current, compatible versions and let the lockfile pin them — copy resolved versions into the lockfile rather than leaving them floating. When a task needs a package, add it; don't defer.

**The verify script:** early, right after the foundation `[STRUCT]` tasks, have `verification-before-completion` write the self-contained verify script into the project. Later tasks are checked against it as you go.

## Finishing the build

When every task is worked:

1. **Verify.** Hand off to `verification-before-completion`. It runs the gate (install, typecheck, build, test, boot) and the completeness check (every spec-promised module present, every critical allow/deny pair green). If the gate is red, hand off to `systematic-debugging`, fix the root cause, and re-run — within the loop ceiling. The build is not done until both halves pass.

2. **Document.** After the project exists and verifies, run `/init` (or write the equivalent) so the generated `CLAUDE.md`/`AGENTS.md` describes the real, finished codebase for whoever works on it next. `/init` is a finishing step — it documents what was built, it never guides the build.

3. **Provenance.** Write into the generated README that the project was produced from the committed `spec.md` and `plan.md`, and that `verify` is the source of truth for "is it working."

4. **Confirm the standalone rule.** Nothing in the generated project references or imports the plugin. Spec, plan, tests, verify script, and code — and, when a design was imported, design/DESIGN.md plus the materialized tokens, fonts, and brand assets — are all self-contained and committed.

5. **Report** what was built, the verify result, and the completeness result, in the user's terms.

The project is done when it verifies itself, proves every promised behavior, and needs nothing from the plugin to do so.
