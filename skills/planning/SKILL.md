---
name: planning
description: Turn an approved project spec into an ordered, tagged implementation plan. Use this skill immediately after spec-authoring has produced and the person has signed off on spec.md, and before any code is written. It reads the spec's acceptance criteria and structural checks and emits plan.md, where every criterion becomes a test-first [TDD] task and every check becomes a present-and-boot [STRUCT] task, ordered with critical security and payment work first. Trigger whenever spec.md exists and the next step is planning the build, or when someone asks to "write the plan," "decompose the spec," or "turn the spec into tasks." Do not begin execution directly from a spec; the plan is what makes the build test-driven.
---

# Implementation Planning

You have an approved `spec.md` containing two lists: behavioral **criteria** (Given/When/Then) and structural **checks** (presence assertions). Your job is to turn them into an ordered task list that the execution skill works top to bottom. You write `plan.md`. You do not write code.

This skill's place in the chain: **questionnaire → [design-import, when a design source was captured] → spec → plan (you are here) → execution.**

The plan is where the behavioral/structural split stops being a table and becomes something the executor mechanically obeys. Every task carries a tag that tells the executor *how* to satisfy it — by going red-green, or by verifying presence. Get the tags and the order right and the build is honest. Get them wrong and TDD collapses back into ceremony.

---

## Intake

Before decomposing anything, confirm `spec.md`'s header reads `Status: approved`, and that the spec passes spec-authoring's self-check gate (defined in the spec-authoring skill — reference it, don't restate it). A draft spec goes back to spec-authoring to finish the interview; a malformed one goes back for repair. Never plan around a malformed spec.

---

## The one rule: preserve the split, by tag

- Every **criterion** in the spec becomes exactly one `[TDD]` task.
- Every **check** in the spec becomes exactly one `[STRUCT]` task.
- Carry the spec's `ID` onto the task unchanged. The ID is the join key linking spec → task → test → failure. Never renumber.

You do not invent behavior. If the spec doesn't cover something the build obviously needs, that's a gap in the spec — note it under Open Questions, don't silently paper over it with a task the person never approved.

---

## Task shape

**`[TDD]` task** (one per criterion):

```
[TDD] <id> — <one-line behavior>
  Test:      write a failing test asserting: <the criterion's Then>
  Given:     <preconditions to set up in the test>
  Fixture:   <test data/state to create>        (if the criterion has one)
  Mocked:    <stubs to stand up>                 (if the criterion has one)
  Implement: <the smallest change that makes the test pass>
  Done when: test is green
```

**`[STRUCT]` task** (one per check):

```
[STRUCT] <id> — <one-line presence statement>
  Verify:    <the check, mechanically>
  Done when: present and the app still boots
```

Keep implementation notes short. You're sequencing and framing the work, not writing it. The executor reasons out the actual code.

---

## Ordering

Order is not cosmetic — it front-loads risk and keeps the build bootable at every step.

1. **Foundation `[STRUCT]` first.** Scaffold, database connection, env config — and, if a design was imported, the **design foundation**: the token file, self-hosted fonts, and the global stylesheet wired into the app shell. Nothing behavioral can be tested and no screen can be styled until the app boots with the theme applied, so these come first even though they're not test-driven.
2. **Critical `[TDD]` next, in this order:** authentication → multi-tenant isolation → payments/entitlement → admin authorization. These are the security-and-money boundaries. They're the highest-risk behavior and everything else assumes they work, so they get built and proven early.
3. **Standard `[TDD]`** — the remaining behavioral features (chat edge cases, RAG retrieval, agent tool-wiring, etc.).
4. **Remaining `[STRUCT]`** — deploy config, secondary presence checks, anything that just needs to exist.

Within the critical block, respect dependencies: auth before anything tenant-aware, tenancy before tenant-scoped payments.

**Design tasks after the critical block.** The design *foundation* (tokens, fonts, global theme) is wired early in step 1 because everything visual depends on it. But component-library `[STRUCT]` tasks and per-screen build tasks come after the critical security-and-money `[TDD]` block — design must never jump ahead of auth, tenancy, or payments. A screen that consumes a behavioral endpoint (a chat UI over its endpoint, an admin table over its API) is planned after that endpoint's `[TDD]` tasks are green, so the UI is built against a proven contract.

---

## Mock scaffolding: name it in the plan, don't leave it to the build

Any `[TDD]` task whose criterion had a `Mocked` field needs its stub stood up *before* the test can run. Make that explicit as part of the task, because an executor that discovers mid-build that it needs a fake Stripe webhook will either improvise badly or hit a live API. For each such task, the `Mocked:` line names exactly what to stand up:

- **Payments** → test-mode signed webhook payloads plus a mis-signed payload for the authenticity deny test, a faked charge/session object. Never the live Stripe API.
- **AI (any)** → a stubbed model client returning fixed responses; for RAG, fixed embedding vectors so retrieval is deterministic.
- **Third-party APIs** → a recorded/stubbed response for the specific call.

If several tasks share a mock (e.g. a common stubbed model client), add a single early `[STRUCT]` task to build the test harness/mocks, and have the `[TDD]` tasks depend on it.

---

## Output

Present the build order as a compact summary first — task counts per block, the critical block's contents, shared mocks, open questions — and write and commit `plan.md` only after an explicit yes. This is the last cheap veto point before hours of building; execution assumes an *approved* plan. Structure:

```markdown
# Implementation Plan

Spec: spec.md (Version <n> — copied from spec.md's header)

## Build order
<all tasks as markdown checkboxes — `- [ ] [TDD] auth-001 — ...` — in the order defined above, each with its tag and ID>

## Test harness
<shared mocks/fixtures to stand up once, if any>

## Open questions
<anything the spec didn't cover that the build will need; empty is good>
```

`plan.md` is a permanent, standalone artifact — readable without this plugin installed. After approval, exactly two edits to it are permitted: flipping a task's checkbox to `[x]` as the work lands, and appending/updating the `## Verify status` block defined in verification-before-completion. Everything else is frozen. The execution skill works it top to bottom: `[TDD]` tasks red-green, `[STRUCT]` tasks present-and-boot. The verify gate's definition of done is stated in these tasks' terms — every `[TDD]` test green (both members of every critical allow/deny pair), every `[STRUCT]` check present, app boots. Keep IDs intact so a red test at the end traces straight back to one line of the spec.
