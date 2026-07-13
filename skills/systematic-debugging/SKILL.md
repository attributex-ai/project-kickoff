---
name: systematic-debugging
description: Find the root cause of a failure instead of guessing at fixes. Use this skill whenever the verify gate goes red, a test fails unexpectedly, the build breaks, or the app won't boot during a project build. It runs a short structured process: reproduce, locate, understand, fix the cause (not the symptom), and confirm. Trigger the moment a build failure appears, before attempting any speculative fix.
---

# Systematic Debugging

When the verify gate is red, the failure mode to avoid is flailing: changing things at random, weakening tests, or adding code that masks the symptom. A generated project with no reference to lean on makes flailing especially costly, because you can't diff against a known-good original. Slow down and find the actual cause.

## The process

1. **Reproduce.** Run the failing step in isolation and read the *real* error — the failing test name, the stack trace, the first error line, not a summary. If you can't reproduce it deterministically, that instability is the first thing to fix.

2. **Locate.** Find where the failure actually originates, not where it surfaces. A 500 at boot may originate in a missing env var three layers down. Trace from the symptom to the source before touching anything.

3. **Understand.** State, in one sentence, *why* this fails. If you can't explain the cause, you're not ready to fix it — keep tracing. A fix you can't explain is a guess.

4. **Fix the cause.** Change the thing that is actually wrong. Do not adjust the test to stop failing, do not add a catch that swallows the error, do not weaken the verify script. Those hide the failure; they don't fix it.

5. **Confirm.** Re-run the failing step, watch it pass for the right reason, then re-run the gate to confirm nothing else broke (`verify:quick` is acceptable mid-loop when the lockfile is unchanged; the full `verify` runs once at the loop's final confirmation).

## Rules

- **One change at a time.** Multiple simultaneous changes make it impossible to know what worked. Change one thing, re-run, observe.
- **Never weaken the gate to pass.** A red test or a failing check is information. Silencing it destroys the information and ships the bug.
- **Respect the loop ceiling.** If `verification-before-completion` has hit its iteration cap, stop and report the root cause you found (or the point you got stuck at) rather than continuing to churn.
- **The cause is usually recent and specific.** In a fresh build the break is almost always in the last thing added — a version mismatch, a missing env var, a mis-wired import. Start there.
- **Read the record before repeating it.** If the project's `plan.md` has a `## Verify status` block, read its attempted-fixes list first and never repeat an attempt already recorded as failed.
