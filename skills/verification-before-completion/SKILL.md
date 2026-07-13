---
name: verification-before-completion
description: Decide whether a generated project is actually done, and write its verify script. Use this skill twice: early in the execution stage, right after the foundation [STRUCT] tasks, to write the self-contained verify script into the project; and at the end, before reporting a build complete or any time you are about to claim a project is finished or working. It checks two things: correctness (installs, typechecks, builds, boots, tests pass) and completeness (every module the spec promised is present and wired). "Done" is a green gate plus full coverage of the spec, never the agent's say-so. This is the project-kickoff chain's definition of done — it writes the generated project's standalone verify script and checks completeness against spec.md. Trigger before declaring any build complete.
---

# Verification Before Completion

"Done" is not "the agent believes it finished." With no golden reference and no pinned versions, this gate is the only tether between the generated project and correctness. So it is not optional and it is not the agent's opinion — it is a script that passes and a spec that is fully covered.

## Write the verify script into the project

Early in the build (right after the foundation `[STRUCT]` tasks), generate a **self-contained** `verify` entry point in the project — a `justfile` verb, an npm script, or a Makefile target, matching the stack. It is a permanent project artifact, in the same category as `spec.md` and `plan.md`, and it must run with this plugin uninstalled. It may not reference the plugin in any way.

The script runs, in order, failing loudly on the first failure:

0. **Env preflight** — every variable named in `.env.example` is present; fail fast, naming each missing variable.
1. **Install** — dependencies install cleanly from the lockfile.
2. **Typecheck** — no type errors.
3. **Lint** — passes with the project's own config (the scaffold's default ruleset).
4. **Build** — the production build succeeds.
5. **Test** — the full suite passes (where every `[TDD]` test runs).
6. **Boot** — the app starts and the spec-named health route (or root route) responds 200. The boot step owns the lifecycle of what it starts, stated as obligations (the stack picks the mechanism): start the app in the background on an explicit port; poll the health route with a bounded timeout — fail after a fixed number of seconds, never wait indefinitely; guarantee the started process is killed when the step ends, on success and failure alike (a shell trap or the stack's equivalent); on failure, exit non-zero and surface the captured server log.

Alongside `verify`, emit a `verify:quick` variant running the same stages minus install. During red-loop iterations `verify:quick` may stand in when the lockfile is unchanged since the last install; the final green before declaring done is always one full, clean, top-to-bottom `verify` including install.

The gate is a milestone tool, not a per-task loop: execution runs it right after this script is first written, after the critical block, and at finish; individual tasks are checked by their own tests and done-lines.

Output must be legible: on failure, surface the real error (failing test name, stack trace), not a truncated summary. You and the user will read it later.

If a design was imported, the boot step also confirms — **deterministically, not by pixel comparison** — that the theme is actually applied: e.g. the token stylesheet is linked in the rendered document, or a known token custom property resolves on the root element. Presence and render only; never assert exact colors or spacing. Visual-regression testing is a valid future add-on, but it stays out of this deterministic, offline gate.

## The two halves of done

A green verify proves **correctness**. It does not prove **completeness** — that everything the user asked for is present. An agent under pressure can silently drop a hard module, and a build with a missing feature still compiles. So check both:

**Correctness** — `verify` is green: installs, typechecks, builds, boots, all tests pass.

**Completeness** — against `spec.md`:
- Every behavioral category in the spec has at least one passing `[TDD]` test.
- Every `critical` criterion has **both** members of its allow/deny pair passing.
- Every structural category has its `[STRUCT]` check satisfied.
- Every module listed under Selected modules in `spec.md` is physically present and wired.
- If a design was imported: every design check the spec emitted passes, with a backstop of at least one check per `design/DESIGN.md` manifest section (tokens, fonts, components, assets, theme-applied). A build that compiles with unstyled placeholder pages is **not** complete.

If anything the spec promised is missing, the build is **not done** — return to execution and build it. "Compiles and boots" is necessary, not sufficient.

## The loop and its ceiling

```
run verify
  -> green: proceed to the completeness check
  -> red:  hand off to project-kickoff:systematic-debugging, fix the specific cause, run verify again
```

The script must be re-runnable back-to-back: it owns the lifecycle of anything it starts, and a second run must never fail because the first left a process or a port behind.

Cap the loop at 5 debug → fix → re-run iterations per invocation of this skill. On hitting the ceiling: commit work-in-progress, then append or update a `## Verify status` block in `plan.md` recording the iteration count, the failing gate step, the failing criterion IDs, each fix attempted with its outcome, and the current root-cause hypothesis — so a resumed session starts from the record instead of re-grinding the same fixes blind. Then stop and give the user explicit options: authorize more iterations, descope the failing criterion (recorded with sign-off under spec.md's Open questions, bumping the spec Version and updating plan.md's recorded Version in the same commit), or stop here. Do **not** grind indefinitely, and never "fix" a red result by weakening a test or the verify script — that defeats the entire gate. You make the code satisfy the gate; the gate never bends to the code.

## When done is real

`verify` is green, both halves pass, and the verify script runs standalone with the plugin uninstalled. Report the verify and completeness results to the invoking execution stage — it owns the single final user-facing report, after its documentation steps. Only now is the build complete.
