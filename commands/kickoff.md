---
description: Start a new project. Runs the kickoff interview, then builds a verified starter repo through spec -> plan -> execution. Use in an empty directory.
---

Begin a new project kickoff.

Invoke the `questionnaire` skill to interview the user about what they want to build. From there, follow the chain the skills define:

1. `questionnaire` captures answers, then hands off to
2. `spec-authoring`, which produces an approved `spec.md`, then
3. `planning`, which produces `plan.md`, then
4. `execution`, which builds the project test-first, calling
   - `test-driven-development` for every behavioral task,
   - `verification-before-completion` as the definition of done, and
   - `systematic-debugging` whenever the verify gate goes red.

Do not skip stages. Each produces a committed artifact the next consumes. Only the generated artifacts (spec.md, plan.md, the code, the tests, and the verify script) belong in the project. None of this plugin's own files are copied into the generated project.
