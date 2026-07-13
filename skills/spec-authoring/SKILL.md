---
name: spec-authoring
description: Turn a completed project questionnaire into a testable specification. Use this skill immediately after the project questionnaire finishes — or after design-import, when a design source was captured — before any planning or code generation. It runs a short chunked interview to deepen the behavioral answers, then emits a spec of Given/When/Then acceptance criteria plus structural presence checks. Trigger whenever you have questionnaire answers and need a spec, whenever someone asks to "write the spec," "turn answers into criteria," or "prepare acceptance criteria," and whenever the next step in a project-kickoff chain is specification. Do not skip straight to planning or building from raw questionnaire answers; they are too thin to test against.
---

# Spec Authoring

You have a set of questionnaire answers describing a project to build. Nine or so answers are far too thin to build a correct project from, and they are far too thin to *test* a project against. Your job is to turn them into a specification precise enough that every promised behavior maps to a test written before the code exists.

This skill's place in the kickoff chain: **questionnaire → [design-import, when a design source was captured] → spec (you are here) → plan → execution**. You produce the artifact the plan is decomposed from. If your spec is vague, every test downstream is confident and wrong. Precision here is the whole point.

The spec you emit has two parts:
- **Criteria** — behavioral, written as Given/When/Then, one test each. These get test-driven (red before green).
- **Checks** — structural, written as flat presence assertions. These get verified by presence-and-boot, never test-driven.

Getting the right things into each list is what makes the downstream TDD real instead of ceremony. The rest of this skill is how.

---

## The behavioral / structural boundary

Sort every feature the questionnaire selected into one of the two lists using this test:

> **Does it have runtime behavior that could be wrong in a way a test would catch?** → behavioral (Criterion).
> **Is it either present or absent, with no interesting runtime logic?** → structural (Check).

The organizing rule, so you can classify anything not in the table below:
- **Security boundaries and money are always behavioral.** Auth, tenant isolation, payment/entitlement, admin authorization. Wrong behavior here is silent and severe, which is exactly what tests are for.
- **Connections, scaffolds, SDKs, and config are always structural.** A wired database, an installed SDK, a valid deploy config. Test-driving these is theater.
- **Anything touching an LLM's output is structural around the model and behavioral only on the deterministic plumbing.** Never assert on generated prose. Assert on retrieval, routing, tool-invocation, persistence, scoping.
- **Design and visual systems are structural, never test-driven.** You never write a test that asserts a color, a spacing value, or a copy string. A design is present-and-renders: the token file exists and is wired, the named components render, the theme is applied instead of default browser styling. The only behavioral slice is accessibility (visible focus, AA contrast on core text), and even that stays a presence/render check unless a deterministic a11y tool is wired. Asserting on visual output is the same theater as asserting on generated prose. When a design was imported, its checks come from the `design/DESIGN.md` manifest the `design-import` skill produced.

| Questionnaire category | Behavioral (Criteria, TDD) | Structural (Checks, presence) |
|---|---|---|
| Project type | the core product flows (the `core-*` chunk, from the Product line) | scaffold in the chosen stack builds & boots; a health endpoint (API) or root route (UI) responds 200; lint passes with the project's own config (the scaffold's default ruleset — never a plugin-supplied one) |
| Repository & env *(always)* | (none) | .gitignore excludes .env*, dependency dirs, build output; .env.example enumerates every required env var with placeholder values |
| UI baseline *(any UI, incl. design source none)* | (none) | viewport meta present; a global stylesheet exists and is imported into the app shell |
| Authentication | all flows: 401s, session set, expiry, logout, redirects | SDK + env present |
| Database | data rules & invariants, query scoping | connection, migrations, declared schema present; a documented local-dev DB path (compose file or provider CLI, named in the README) and a dev-only seed script creating minimum runnable state (a login-able user when auth is selected; a tenant + admin user when those are) |
| Payments | charge, webhook→entitlement, **unsigned/invalid webhook→rejected, entitlement unchanged**, refund→revoke | SDK, webhook endpoint, keys present |
| Multi-tenant | **cross-tenant denial** (highest priority) | tenant_id plumbing present |
| Admin portal | authorization boundary (who is allowed) | pages render & reachable |
| AI: chat | edge cases: empty input, history scoping | endpoint streams & persists |
| AI: RAG | retrieval contract & scoping | vector store wired |
| AI: agents | tool-invocation wiring (right tool, right args) | agent endpoint present |
| AI: voice | (little to none) | endpoints wired |
| Mobile companion | the API contract it consumes | app builds & launches |
| Deployment target | (none) | config valid, target build succeeds |
| Design / UI (if imported) | a11y: behavioral only if a deterministic checker (e.g. axe-core) is wired; otherwise a presence/render check (visible focus, AA contrast on core text) | token file present & globally imported, fonts load, each named component present & renders, brand assets present, app renders with the theme applied |

Note the split categories. Database, admin, and each AI sub-type land in **both** columns: the plumbing is a Check, the rule on top of it is a Criterion. Don't force a whole category into one bucket.

---

## The interview: deepen the behavioral answers

Raw questionnaire answers are flags ("auth: yes"). Criteria need testable specifics ("unauthenticated requests to protected routes return 401"). Bridge that gap with a short interview, run in **digestible chunks with sign-off**, not one giant wall of questions.

**Spend your interview budget proportionally.** The depth of questioning should match how behavioral a category is. Interrogate auth, payments, multi-tenant, and RAG hard, because that is where variance hurts and where tests bite — each gets its own chunk. Deploy target, scaffold, voice, and the mobile API contract are structural with little to specify: merge them into a single closing chunk. A good interview is lopsided on purpose.

**The first chunk is always Core product flows.** From the captured Product line, elicit the one to three primary user journeys and the data rules beneath them ("a signed-in user creates an invoice; it appears in their list and nowhere else"), emitted as ordinary criteria with IDs `core-<nnn>` — critical only where a flow touches money or a security boundary (then it needs its deny pair like any other criterion). The selected modules exist to serve these flows; spec them first so the spec describes a product, not a pile of plumbing.

Work one chunk at a time, **propose-first**:
1. State what you're about to pin down ("Let's nail the auth behavior.").
2. Draft the chunk's criteria (at most four) yourself, from the boundary table and the captured answers, driving toward observable outcomes: status codes, redirects, what's in the DB after, what's denied. Flag every assumption inline ("assumed httpOnly session cookie — correct?").
3. Present the draft plus the genuinely open parameters in one turn, and get a yes — approve or amend — before moving on. Drafting first and asking second costs the person one read instead of two round-trips per category.

While drafting, include one malformed-input criterion (400/422 on a bad payload) for each core write endpoint, at `standard` priority — hardening flows through the same chunked sign-off as everything else instead of being silently emitted or silently omitted.

**Enforce the constraints as you go.** The questionnaire may have produced an incoherent combination — re-verify that the questionnaire skill's constraint list still holds, and resolve violations conversationally. The ones that shape criteria directly:
- Multi-tenant selected → auth criteria must become tenant-aware; every "user can access X" gains an implicit "user of tenant A cannot access tenant B's X."
- Payments selected but no auth → who owns the entitlement? Resolve the ownership before writing payment criteria.
- Design source captured (anything other than "none") → `design/DESIGN.md` must exist before any criterion is written. If it does not, design-import was skipped — stop and invoke it first; do not spec a design that was never imported.
- Design imported → the reconciliation is already done (the `design-import` skill resolved identity, copy, screens-in-scope, and source-of-truth conflicts with the user). Read `design/DESIGN.md` and turn its component inventory and token/font/asset entries into structural checks — one per named component, plus the token/fonts/theme-applied checks. Do not re-litigate the design; do encode what the manifest promises so it can't silently vanish from the build.

Chunking matters because a person can actually read and correct four criteria at a time. They cannot meaningfully approve forty at once. The sign-off per chunk is what makes the eventual tests trustworthy, because a human confirmed each behavior is the intended one.

---

## The criterion format

Every behavioral feature emits one or more criteria in this exact shape:

```
ID:        <feature>-<nnn>          e.g. auth-003, tenant-001
Feature:   <behavioral category>     e.g. Authentication, Multi-tenant
Priority:  critical | standard       critical = security boundary or money
Given:     <preconditions / state>
When:      <the single action taken>
Then:      <the observable, assertable result>
Fixture:   <test data/state that must exist>   (optional)
Mocked:    <external deps stubbed>              (required when it touches an LLM, payment, or 3rd-party API)
Pair:      <ID of the allow/deny partner>       (required when Priority: critical)
```

Five rules govern what may be emitted. They are not style preferences; each one prevents a specific downstream failure.

**1. The `Then` must be observable and binary.** It asserts something a test can mechanically check: a status code, a row present or absent, a cookie set, a function called with given args. If a `Then` says "is secure," "works correctly," or "handles properly," it names a wish, not an assertion. A test can't fail against it, so it isn't a criterion.

**2. One criterion, one behavior.** No `and` in the `Then` hiding two assertions. "Returns 401 and logs the attempt" is two criteria. Atomic criteria mean a red test names exactly one broken behavior. One deliberate exception: a deny criterion may assert the rejection plus the absence of the side effect it guards ("status is 400 and entitlement unchanged") — that is one behavior, the refusal, observed at two points.

**3. Critical criteria come in allow/deny pairs.** For every security or money boundary, write the success case *and* its violation. Auth is "valid login succeeds" plus "invalid login is rejected" plus "no session is rejected." The deny cases catch the real bugs and are the ones an agent skips under pressure. A lone happy-path criterion at `critical` priority with no matching denial is a spec smell — do not emit it. Record the partnership in each half's `Pair:` field so planning and verification can check pair coverage mechanically. For payments the deny is webhook authenticity: a webhook that fails signature verification is rejected and changes no entitlement — an endpoint that trusts unsigned events hands out entitlements to anyone who can POST to it.

**4. `Mocked` is mandatory whenever an external dependency appears.** Payments name the stub (test-mode signed webhook, faked charge). AI names the mocked model response. Any third-party API names its stub. A criterion that touches Stripe or an LLM with a blank `Mocked` field is malformed. This forces the test-isolation decision into the spec instead of leaving the agent to improvise it (or hit a live API) mid-build.

**5. `critical` is reserved for security boundaries and money.** Auth, multi-tenant isolation, payment/entitlement, admin authorization. Critical criteria get the deny-pair requirement, get ordered first in the plan, and are non-negotiable in the verify gate. Everything else behavioral is `standard`.

### Worked examples

```
ID:       auth-001
Feature:  Authentication
Priority: critical
Given:    no active session
When:     GET /api/projects
Then:     response status is 401
Pair:     auth-002
```
```
ID:       auth-002
Feature:  Authentication
Priority: critical
Given:    a valid user credential
When:     POST /api/login with that credential
Then:     response sets an httpOnly session cookie
Pair:     auth-001
```
```
ID:       tenant-001
Feature:  Multi-tenant
Priority: critical
Given:    user U belongs to tenant A; resource R belongs to tenant B
When:     U requests GET /api/resources/R
Then:     response status is 403 and body contains no fields of R
Fixture:  tenant A with user U; tenant B with resource R
Pair:     tenant-002
```
```
ID:       pay-004
Feature:  Payments
Priority: critical
Given:    a checkout session for user U
When:     a payment_succeeded webhook for that session is received
Then:     user U's entitlement record is set to active
Mocked:   Stripe webhook event (test-mode signed payload)
Pair:     pay-005
```
```
ID:       pay-005
Feature:  Payments
Priority: critical
Given:    a checkout session for user U
When:     a payment_succeeded webhook with an invalid signature is received
Then:     response status is 400 and user U's entitlement record is unchanged
Mocked:   Stripe webhook event (mis-signed payload)
Pair:     pay-004
```
```
ID:       rag-002
Feature:  AI / RAG
Priority: standard
Given:    a corpus containing document D with a unique marker phrase
When:     a retrieval query for that marker runs
Then:     document D's chunk is in the returned set
Fixture:  corpus seeded with D
Mocked:   embedding model returns fixed vectors; LLM generation stubbed
```

`rag-002` tests retrieval mechanics, not answer quality, and mocks the model. The format carried the AI rule automatically — follow the same instinct everywhere an LLM appears. Note the pairing: `auth-001`/`auth-002` and `pay-004`/`pay-005` show full allow/deny pairs; `tenant-001` is the deny half of a pair whose allow partner is omitted here for brevity — a real spec emits both halves.

---

## The check format

Structural features do **not** use Given/When/Then. Forcing that shape onto "tsconfig exists" is the theater the boundary exists to prevent. Emit a flat presence assertion:

```
ID:      struct-<area>-<nnn>
Type:    presence
Check:   <a single, mechanically verifiable statement of existence or boot>
```

Examples:
```
ID:      struct-deploy-001
Type:    presence
Check:   vercel.json exists and is valid JSON
```
```
ID:      struct-db-001
Type:    presence
Check:   app boots with a live DB connection and all declared schema tables exist
```

Two safety rules for the always-on checks: `.env.example` carries placeholder values only, never live secrets; the seed script must be unmistakably dev-only.

---

## Self-check before emitting (this is what makes the format real)

A format is only enforced if you refuse to emit anything that violates it. Before writing the spec file, run each criterion through this gate. Any failure means rewrite that criterion — do not emit it malformed.

- Is the `Then` observable and binary? (No "secure/correct/properly.")
- Is it exactly one behavior? (No hidden `and` — except a deny's rejection plus the absence of its guarded side effect.)
- If `critical`: does it have its allow/deny partner, recorded in both `Pair:` fields?
- If it touches an LLM, payment, or third-party API: is `Mocked` filled?
- Does every behavioral category the questionnaire selected have at least one criterion?
- Does the spec contain at least one criterion for the product's core flow (`core-*`), not only module plumbing? If the build is genuinely flow-less (a static marketing site), is that recorded explicitly under Open questions?
- Does every structural category have at least one check?
- Are the always-on checks present: .gitignore, .env.example (placeholders only), the health/root route, lint with the project's own config — and, for any UI, the viewport meta + global stylesheet baseline?
- If the captured answers record a design source other than "none": does `design/DESIGN.md` exist? If not, stop — invoke `design-import` before emitting the spec.
- If a design was imported: does the spec include structural checks for the token file (present + globally imported), fonts, each named component in the manifest, brand assets, and the app rendering with the theme applied?

If a criterion can't be made to pass this gate, the underlying answer is still too vague — go back to the interview for that one category rather than emitting a criterion no honest test can be written from. This refusal is the point.

---

## Output

Persist as you go, not only at the end — the interview is the chain's largest window of unrecoverable user investment:

- **On receiving the handoff, before the first chunk:** write and commit a skeleton `spec.md` containing the Summary, the complete `## Selected modules` list (this durably captures the questionnaire answers, including the design source), and a `Status: draft` header. If the project directory is not already a git repository, run `git init` and write a minimal `.gitignore` (`.env*`, dependency dirs, build output) before this first commit — never re-init or rewrite existing history, and when a scaffold tool later writes its own `.gitignore`, merge, don't clobber.
- **After each chunk's sign-off:** append that chunk's criteria and checks, and commit.
- **At final sign-off:** flip the header to `Status: approved`. Any post-sign-off revision increments `Version` and requires re-sign-off.

Structure:

```markdown
# Project Specification

Status: draft | approved
Version: 1

## Summary
<2-4 sentences: what this project is, from the Product line and questionnaire answers>

## Selected modules
<the questionnaire answers, as a flat list>

## Acceptance criteria (behavioral — test-driven)
<every criterion, grouped by Feature, critical first>

## Structural checks (presence-verified)
<every check, grouped by area>

## Open questions
<anything the interview couldn't resolve; empty is good>
```

`spec.md` is a permanent artifact. Commit it into the project. The plan skill decomposes it: each **criterion** becomes one `[TDD]` task (write failing test → implement → green), each **check** becomes one `[STRUCT]` task (presence-verified; boot re-checked only for boot-path tasks). The `ID` is the join key that lets every task, test, and failure trace back to one line of this spec — so keep IDs stable and unique.

Definition of done for the whole downstream build, stated in this spec's own terms: every criterion has a passing test, every `critical` criterion has both its allow and deny test passing, every check passes, and the app boots.
