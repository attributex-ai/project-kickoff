---
name: test-driven-development
description: Enforce true red-green test-driven development for every behavioral task in a build. Use this skill during the execution stage whenever implementing a task tagged [TDD], or any time a behavioral feature (a security boundary, money, or a business rule) is being built. It requires a failing test written and run before any implementation, and it forbids writing implementation first. It applies only to behavioral work; structural presence (scaffold, config, connections) is verified, not test-driven. This is the project-kickoff chain's TDD discipline, for tasks tagged [TDD] in a plan.md produced by the planning skill. Trigger before writing any behavioral code.
---

# Test-Driven Development

TDD is the reliability mechanism for this whole system, not a stylistic preference. This plugin ships no golden reference and pins no versions, so the only thing tying generated behavior to correctness is a test that failed before the code existed and passed after. Red-then-green is mechanical proof. Skip it and "it works" degrades to "it looks like it works."

## Scope: behavioral only

Apply TDD to `[TDD]` tasks — behavior that could be wrong in a way a test catches: authentication flows, tenant isolation, payment/entitlement, admin authorization, data invariants, RAG retrieval mechanics, agent tool-routing. The plan's tags already encode the classification — obey the tag, never reclassify mid-build; a wrong-looking tag is a spec/plan gap: stop and flag it. The boundary itself is defined in the `spec-authoring` skill.

Do **not** test-drive `[STRUCT]` tasks. Writing a red-green test for "tsconfig exists" or "the DB is connected" is theater. Those are handled by `project-kickoff:verification-before-completion` as presence checks.

Never test an LLM's generated prose. For AI features, test the deterministic plumbing around the model — retrieval, routing, tool-invocation, persistence, scoping — and mock the model with fixed responses.

## The cycle, per task

Each `[TDD]` task in `plan.md` carries a criterion ID and a `Then` to assert. Work it in this exact order:

1. **Stand up mocks/fixtures** the task names (or confirm the shared harness is in place). Payment tests use test-mode signed webhooks and faked charges, never a live API. AI tests use a stubbed model client.
2. **RED — write the test** that asserts exactly the criterion's `Then`. One behavior, one test. Title it with the criterion ID ("auth-001: no session → 401") so a red test names its spec line and completeness can be checked by ID.
3. **Run it. Watch it fail** — and fail for the *right reason* (the behavior is missing, not the test is malformed). A test that passes before you implement is broken; fix the test.
4. **GREEN — write the minimal code** that makes the test pass. No more than the test demands. Resist building ahead of the test (YAGNI).
5. **Run it. Watch it pass.**
6. **REFACTOR** if useful, keeping the test green.
7. **Commit** the test and code together, then move to the next task.

## Hard rules

- **No implementation before a failing test.** If you find behavioral code written without a preceding red test, delete it and restart the cycle for that behavior. Code that never had a failing test has never been proven.
- **One behavior per test.** No hidden `and` combining two assertions — that's two tasks.
- **Critical criteria come in allow/deny pairs.** For every security or money boundary, both the success case and its violation must have passing tests (e.g. valid login succeeds *and* no-session is rejected). A green happy-path with no deny test is not done.
- **Never weaken a test to make it pass.** If a test is hard to satisfy, fix the code, not the test. Weakening the test destroys the only signal that matters. When stuck, hand off to `project-kickoff:systematic-debugging`.

## Definition of done for a task

The criterion's test is green, for the right reason, and committed. For critical criteria, both members of the allow/deny pair are green. Then, and only then, the task is done.
