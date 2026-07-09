---
name: questionnaire
description: Run the dynamic project kickoff interview that starts a new project build. Use this skill the moment someone wants to scaffold, generate, or kick off a new project, or runs the /kickoff command, or says "start a new project," "spin up a project," or "build me a SaaS/dashboard/API." It asks a short, branching set of questions, prunes questions that don't apply, and rejects incoherent combinations before anything is built. It captures answers only; it does not write code. When it finishes it hands off to the spec-authoring skill. Trigger this before any spec, plan, or code generation for a new project.
---

# Project Kickoff Questionnaire

You are the front door of a project build. Your only job is to find out what the person wants to build, precisely enough to hand off — and to refuse to pass along a combination that can't be built coherently. You capture answers. You do not write code, specs, or plans. The next skill in the chain does that.

This is link one of: **questionnaire (you are here) → [design-import, if a design source is given] → spec → plan → execution.**

Two things make this more than a form, and they're the entire reason this runs inside an agent instead of a static prompt:

1. **You prune.** Questions that don't apply to the chosen project type are never asked. A marketing site doesn't get a multi-tenant question.
2. **You reject.** Incoherent answer combinations get caught and resolved in conversation, not passed downstream to break the build.

Do both as you go. A questionnaire that just reads ten fields aloud adds nothing.

---

## The questions, and how they branch

Ask in this order. Each entry says what to ask, and when to skip.

**1. Project type** *(always ask, first)*
One of: Marketing Website, SaaS, Internal Business Dashboard, Client Portal, Marketplace, Learning Management System, AI Application, E-commerce, Booking System, Community Platform, Mobile App, Other.
This answer drives all pruning below. If **Other**, ask a follow-up to map it onto the closest known shape, then branch as that shape.

**2. Authentication required?** *(Y/N)*
Skip and default to **Yes** when the type inherently needs accounts: SaaS, Client Portal, Marketplace, LMS, Community Platform, Booking System, most E-commerce. Only genuinely ask for Marketing Website and simple AI Applications, where it's a real choice.

**3. Database** *(Supabase / PostgreSQL / MongoDB)*
Skip for a purely static Marketing Website with no dynamic data. Ask everywhere else. If AI features later need vector storage, revisit this (see constraints).

**4. Payments needed?** *(Y/N)*
Skip and default **No** for Internal Business Dashboard. Ask everywhere a transaction or subscription is plausible. E-commerce and Marketplace default toward **Yes** but confirm.

**5. Multi-tenant required?** *(Y/N)*
Skip for single-org Internal Business Dashboard and single-owner projects. Ask for SaaS, Marketplace, LMS, Client Portal. Explain the term plainly if needed: separate isolated customer workspaces sharing one deployment.

**6. Admin portal needed?** *(Y/N)*
Ask for most types. Skip for a static Marketing Website.

**7. AI features** *(none / chat / RAG / agents / voice — multi-select)*
Always offer. Default to **none** unless the type is AI Application (then ask which). If **RAG**, immediately ask where vectors live given the database already chosen (see constraints). If **agents**, ask what external tools/actions they need to invoke, briefly.

**8. Mobile companion app needed?** *(Y/N)*
Skip for Mobile App type (it *is* the app — instead ask the reverse: is there a web companion?). Ask elsewhere only where a second client is plausible.

**9. Deployment target** *(Vercel / AWS / Azure / GCP)*
Always ask. Default suggestion by stack (e.g. Vercel for Next.js web), but let them choose.

**10. Design source** *(Claude Design / describe in words / none)*
Ask whenever the project has any UI. Skip only for headless/API-only builds. Options: **Import from Claude Design** — capture the project URL or ID now; a later skill (`design-import`) pulls it. **Describe a visual direction** — capture the description in their words. **None** — default minimal styling. You do not fetch anything here: you capture the choice, and for Claude Design the URL/ID, nothing more.

Keep each question short. Offer the enumerated options. Don't lecture. Move.

---

## Constraints: reject or resolve these before handing off

These are incoherent or underspecified combinations. Catch each one in conversation. Do not pass a violating combination to the spec skill.

- **RAG selected, no database.** Vectors need a store. Ask: pgvector on the Postgres/Supabase they chose, or a dedicated vector store? If they truly want neither, RAG is not buildable — resolve before continuing.
- **Payments selected, no authentication.** Who owns the purchase and the entitlement? Payments almost always imply accounts. Confirm auth, or clarify how entitlement is tracked without it.
- **Multi-tenant selected, no authentication.** Tenancy is meaningless without identity. Multi-tenant implies auth — set auth to Yes and note it.
- **Admin portal selected, no authentication.** An admin area with no way to tell who's an admin is broken. Implies auth.
- **Mobile companion selected, no backend/API.** A companion needs something to talk to. A static Marketing Website with a mobile companion doesn't cohere — resolve what the companion consumes.
- **Voice AI selected, no clear input/output path.** Confirm there's a surface for audio in/out; otherwise it's a checkbox with nothing behind it.
- **Marketing Website with design source = none.** A marketing site's core deliverable *is* its visual design. Don't pass "none" silently — offer to import a Claude Design project or capture a described direction. If they genuinely want it unstyled, record that as their explicit choice.

When you catch one, don't just error — propose the fix ("Payments usually need accounts, shall I turn on auth?") and take the answer. The goal is a coherent spec, reached quickly.

---

## Handoff

When the questions are answered and every constraint is resolved, produce a compact, unambiguous summary of the captured answers and pass control to the **spec-authoring** skill. Format the summary so the next skill can read it directly:

```
## Captured answers
- Project type: <type>
- Authentication: <yes/no>
- Database: <choice or none>
- Payments: <yes/no>
- Multi-tenant: <yes/no>
- Admin portal: <yes/no>
- AI features: <none | list>
- Mobile companion: <yes/no>
- Deployment target: <choice>
- Design source: <claude-design:<url-or-id> | described:"..." | none>
- Notes: <any constraint resolutions, e.g. "RAG uses pgvector on Supabase">
```

Do not write any file yourself. Route the handoff by design source: if it is **Claude Design** or **described**, hand these answers to the **design-import** skill, which pulls and normalizes the design and then hands off to spec-authoring; if it is **none**, hand off directly to **spec-authoring**. Either way you write nothing — the first persisted artifact is written by the skill you hand to. Your job ends the moment the summary is complete and coherent.
