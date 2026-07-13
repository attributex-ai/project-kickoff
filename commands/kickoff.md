---
description: Start a new project. Runs the kickoff interview, then builds a verified starter repo through spec -> plan -> execution. Use in an empty directory.
---

Begin a new project kickoff.

Invoke the `questionnaire` skill to interview the user about what they want to build. From there, follow the chain the skills define:

1. `questionnaire` captures answers — including the design source — then hands off to
2. `design-import` *(only when a design source was given)*, which pulls the design from Claude Design (or a described direction), materializes tokens/fonts/assets and a component manifest into the project, then hands off to
3. `spec-authoring`, which produces an approved `spec.md`, then
4. `planning`, which produces `plan.md`, then
5. `execution`, which builds the project test-first, calling
   - `test-driven-development` for every behavioral task,
   - `verification-before-completion` as the definition of done, and
   - `systematic-debugging` whenever the verify gate goes red.

If a previous kickoff was interrupted, use the "Resuming an interrupted kickoff" table in the `using-project-kickoff` skill to map the on-disk artifacts to the stage to re-enter, instead of starting over.

Do not skip stages. Each produces a committed artifact the next consumes. Only the generated artifacts (spec.md, plan.md, the code, the tests, the verify script — and, when a design was imported, design/DESIGN.md plus the materialized tokens, fonts, and brand assets) belong in the project. None of this plugin's own files are copied into the generated project.
