---
description: Start a new project. Runs the kickoff interview, then builds a verified starter repo through spec -> plan -> execution. Use in an empty directory.
---

Begin a new project kickoff.

Invoke the `questionnaire` skill to interview the user about what they want to build, then follow the chain the skills define (each stage after the questionnaire produces a committed artifact the next consumes; the questionnaire hands off in-conversation and writes nothing):

1. `questionnaire` — captured answers, including the design source
2. `design-import` *(only when a design source was given)* — staged design files + `design/DESIGN.md`
3. `spec-authoring` — approved `spec.md`
4. `planning` — approved `plan.md`
5. `execution` — the built project, calling `project-kickoff:test-driven-development` for every behavioral task, `project-kickoff:verification-before-completion` as the definition of done, and `project-kickoff:systematic-debugging` when the verify gate goes red

Do not skip stages. The full map, the disciplines, and the "Resuming an interrupted kickoff" table (mapping on-disk artifacts to the stage to re-enter) live in the `using-project-kickoff` skill.

Only the generated artifacts (spec.md, plan.md, the code, the tests, the verify script — and, when a design was imported, design/DESIGN.md plus the staged tokens, fonts, and brand assets) belong in the project. None of this plugin's own files are copied into the generated project.
