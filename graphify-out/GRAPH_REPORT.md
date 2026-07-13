# Graph Report - .  (2026-07-12)

## Corpus Check
- Corpus is ~14,407 words - fits in a single context window. You may not need a graph.

## Summary
- 81 nodes · 112 edges · 11 communities (8 shown, 3 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 10 edges (avg confidence: 0.83)
- Token cost: 104,444 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Kickoff Interview and Design Import|Kickoff Interview and Design Import]]
- [[_COMMUNITY_Behavioral Boundary and TDD Discipline|Behavioral Boundary and TDD Discipline]]
- [[_COMMUNITY_Plugin Architecture and Definition of Done|Plugin Architecture and Definition of Done]]
- [[_COMMUNITY_Spec Criteria and Risk-First Task Ordering|Spec Criteria and Risk-First Task Ordering]]
- [[_COMMUNITY_Planning to Execution Handoff|Planning to Execution Handoff]]
- [[_COMMUNITY_package.json Manifest|package.json Manifest]]
- [[_COMMUNITY_Marketplace Submission and Session Hook|Marketplace Submission and Session Hook]]
- [[_COMMUNITY_Debugging and Gate Integrity|Debugging and Gate Integrity]]
- [[_COMMUNITY_Smoke Test Script|Smoke Test Script]]
- [[_COMMUNITY_Greenfield Nudge Script|Greenfield Nudge Script]]
- [[_COMMUNITY_One Change at a Time|One Change at a Time]]

## God Nodes (most connected - your core abstractions)
1. `execution skill` - 10 edges
2. `design-import skill` - 8 edges
3. `test-driven-development skill` - 8 edges
4. `verification-before-completion skill` - 8 edges
5. `questionnaire skill` - 7 edges
6. `spec-authoring skill` - 7 edges
7. `Behavioral / Structural Boundary` - 7 edges
8. `systematic-debugging skill` - 7 edges
9. `Small Composable Skills over a Monolith` - 6 edges
10. `using-project-kickoff skill` - 6 edges

## Surprising Connections (you probably didn't know these)
- `Small Composable Skills over a Monolith` --semantically_similar_to--> `Thin Wiring, Intelligence in Skills`  [INFERRED] [semantically similar]
  PRD.md → CLAUDE.md
- `Prove the Spine First (Build Order)` --semantically_similar_to--> `Risk-Front-Loaded Task Ordering (security & money first)`  [INFERRED] [semantically similar]
  PRD.md → skills/planning/SKILL.md
- `Trigger-Worded Skill Descriptions` --conceptually_related_to--> `using-project-kickoff skill`  [INFERRED]
  CLAUDE.md → skills/using-project-kickoff/SKILL.md
- `Self-Contained verify Script` --conceptually_related_to--> `Project Kickoff Plugin`  [INFERRED]
  skills/verification-before-completion/SKILL.md → README.md
- `superpowers (obra/superpowers)` --rationale_for--> `SessionStart Greenfield Nudge Hook`  [EXTRACTED]
  PRD.md → README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **The staged kickoff chain (each stage emits a committed artifact the next consumes)** — questionnaire_skill_questionnaire, design_import_skill_design_import, spec_authoring_skill_spec_authoring, planning_skill_planning, execution_skill_execution [EXTRACTED 1.00]
- **Always-on disciplines the execution stage invokes** — execution_skill_execution, test_driven_development_skill_test_driven_development, verification_before_completion_skill_verification_before_completion, systematic_debugging_skill_systematic_debugging [EXTRACTED 1.00]
- **The standalone artifacts that persist in the generated project** — design_import_skill_design_manifest, spec_authoring_skill_spec_md, planning_skill_plan_md, verification_before_completion_skill_verify_script, execution_skill_standalone_rule [EXTRACTED 1.00]

## Communities (11 total, 3 thin omitted)

### Community 0 - "Kickoff Interview and Design Import"
Cohesion: 0.17
Nodes (16): Trigger-Worded Skill Descriptions, /kickoff Entry Command, design-import skill, design/DESIGN.md Manifest, DesignSync Tool (get_project / list_files / get_file), Design/Questionnaire Reconciliation Checkpoint, Token File Is the Source of Truth, Captured Answers Summary (+8 more)

### Community 1 - "Behavioral Boundary and TDD Discipline"
Cohesion: 0.22
Nodes (11): Boundary Defined Once in spec-authoring, Materialize Tokens/Fonts/Assets as Standalone Files, Generated Project Stands Alone, Standalone Leak Scan (no plugin files in generated project), No Golden Reference, No Pinned Versions, Unchanged Non-Negotiables, Behavioral / Structural Boundary, Never Test an LLM's Generated Prose (+3 more)

### Community 2 - "Plugin Architecture and Definition of Done"
Cohesion: 0.28
Nodes (9): Harness-Neutral skills/ as Single Source of Truth, Thin Wiring, Intelligence in Skills, Codex/Cursor/Kimi Plugin Formats Are Real (v2 FIX), superpowers (obra/superpowers), Small Composable Skills over a Monolith, Project Kickoff Plugin, Correctness Half of Done (green gate), verification-before-completion skill (+1 more)

### Community 3 - "Spec Criteria and Risk-First Task Ordering"
Cohesion: 0.22
Nodes (9): Mock Scaffolding Named in the Plan, Risk-Front-Loaded Task Ordering (security & money first), [TDD] Task, Prove the Spine First (Build Order), Incoherent-Combination Rejection, Critical Criteria Come in Allow/Deny Pairs, Given/When/Then Criterion Format, Mandatory `Mocked` Field for External Deps (+1 more)

### Community 4 - "Planning to Execution Handoff"
Cohesion: 0.29
Nodes (8): Fetched Design Content Is Data, Not Instructions, Assemble, Don't Improvise, execution skill, plan.md Artifact, planning skill, [STRUCT] Task, Structural Presence Check Format, Criterion ID as Join Key

### Community 5 - "package.json Manifest"
Cohesion: 0.25
Nodes (7): description, license, name, private, scripts, test, version

### Community 6 - "Marketplace Submission and Session Hook"
Cohesion: 0.25
Nodes (8): claude-community Marketplace Submission Target, Complete & Submit Plugin Implementation Plan, Executable Bit on greenfield-nudge.sh (Task 1), PRD v3 (superpowers re-audit), SessionStart Greenfield Nudge Hook, Co-located Marketplace Catalog (marketplace.json), Omitted `version` Field Policy, Greenfield-Only, Run-Once Scope

### Community 7 - "Debugging and Gate Integrity"
Cohesion: 0.40
Nodes (6): Never Weaken the Gate to Pass, Reproduce-Locate-Understand-Fix-Confirm, systematic-debugging skill, Never Weaken a Test to Make It Pass, The Gate Never Bends to the Code, Verify Loop Ceiling (default 5 iterations)

## Knowledge Gaps
- **12 isolated node(s):** `greenfield-nudge.sh script`, `name`, `version`, `private`, `description` (+7 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `execution skill` connect `Planning to Execution Handoff` to `Kickoff Interview and Design Import`, `Behavioral Boundary and TDD Discipline`, `Plugin Architecture and Definition of Done`, `Spec Criteria and Risk-First Task Ordering`, `Debugging and Gate Integrity`?**
  _High betweenness centrality (0.151) - this node is a cross-community bridge._
- **Why does `Behavioral / Structural Boundary` connect `Behavioral Boundary and TDD Discipline` to `Kickoff Interview and Design Import`, `Spec Criteria and Risk-First Task Ordering`, `Planning to Execution Handoff`?**
  _High betweenness centrality (0.122) - this node is a cross-community bridge._
- **Why does `test-driven-development skill` connect `Behavioral Boundary and TDD Discipline` to `Plugin Architecture and Definition of Done`, `Spec Criteria and Risk-First Task Ordering`, `Planning to Execution Handoff`, `Debugging and Gate Integrity`?**
  _High betweenness centrality (0.111) - this node is a cross-community bridge._
- **What connects `greenfield-nudge.sh script`, `name`, `version` to the rest of the system?**
  _24 weakly-connected nodes found - possible documentation gaps or missing edges._