---
name: verification-before-completion
description: Decide whether a generated project is actually done. Use this skill at the end of the execution stage, before reporting a build complete, and any time you are about to claim a project is finished or working. It writes and runs a self-contained verify script and checks two things: correctness (installs, typechecks, builds, boots, tests pass) and completeness (every module the spec promised is present and wired). "Done" is a green gate plus full coverage of the spec, never the agent's say-so. Trigger before declaring any build complete.
---

# Verification Before Completion

"Done" is not "the agent believes it finished." With no golden reference and no pinned versions, this gate is the only tether between the generated project and correctness. So it is not optional and it is not the agent's opinion — it is a script that passes and a spec that is fully covered.

## Write the verify script into the project

Early in the build (right after the foundation `[STRUCT]` tasks), generate a **self-contained** `verify` entry point in the project — a `justfile` verb, an npm script, or a Makefile target, matching the stack. It is a permanent project artifact, in the same category as `spec.md` and `plan.md`, and it must run with this plugin uninstalled. It may not reference the plugin in any way.

The script runs, in order, failing loudly on the first failure:

1. **Install** — dependencies install cleanly from the lockfile.
2. **Typecheck** — no type errors.
3. **Build** — the production build succeeds.
4. **Test** — the full suite passes (where every `[TDD]` test runs).
5. **Boot** — the app starts and a health check responds.

Output must be legible: on failure, surface the real error (failing test name, stack trace), not a truncated summary. You and the user will read it later.

If a design was imported, the boot step also confirms — **deterministically, not by pixel comparison** — that the theme is actually applied: e.g. the token stylesheet is linked in the rendered document, or a known token custom property resolves on the root element. Presence and render only; never assert exact colors or spacing (that is the same theater the behavioral/structural boundary forbids). Visual-regression testing is a valid future add-on, but it stays out of this deterministic, offline gate.

## The two halves of done

A green verify proves **correctness**. It does not prove **completeness** — that everything the user asked for is present. An agent under pressure can silently drop a hard module, and a build with a missing feature still compiles. So check both:

**Correctness** — `verify` is green: installs, typechecks, builds, boots, all tests pass.

**Completeness** — against `spec.md`:
- Every behavioral category in the spec has at least one passing `[TDD]` test.
- Every `critical` criterion has **both** members of its allow/deny pair passing.
- Every structural category has its `[STRUCT]` check satisfied.
- Every module the questionnaire selected is physically present and wired.
- If a design was imported: the token file is present and globally imported, fonts load, every component named in `design/DESIGN.md` is present, brand assets are present, and the app renders with the theme applied rather than default browser styles. A build that compiles with unstyled placeholder pages is **not** complete.

If anything the spec promised is missing, the build is **not done** — return to execution and build it. "Compiles and boots" is necessary, not sufficient.

## The loop and its ceiling

```
run verify
  -> green: proceed to the completeness check
  -> red:  hand off to systematic-debugging, fix the specific cause, run verify again
```

Cap the loop at 5 debug → fix → re-run iterations per invocation of this skill. On hitting the ceiling: commit work-in-progress, then append or update a `## Verify status` block in `plan.md` recording the iteration count, the failing gate step, the failing criterion IDs, each fix attempted with its outcome, and the current root-cause hypothesis — so a resumed session starts from the record instead of re-grinding the same fixes blind. Then stop and give the user explicit options: authorize more iterations, descope the failing criterion (recorded with sign-off under spec.md's Open questions), or stop here. Do **not** grind indefinitely, and never "fix" a red result by weakening a test or the verify script — that defeats the entire gate. You make the code satisfy the gate; the gate never bends to the code.

## When done is real

`verify` is green, both halves pass, and the verify script runs standalone with the plugin uninstalled. Then report: what was built, the verify result, and the completeness result, in the user's terms. Only now is the build complete.
