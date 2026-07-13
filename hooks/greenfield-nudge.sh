#!/usr/bin/env bash
# Project Kickoff -- greenfield nudge (SessionStart hook)
#
# Surfaces the /kickoff entry point ONLY when the working directory looks like a
# fresh, near-empty project, so it stays silent in populated repos. If a kickoff
# is already in progress (its artifacts exist), points at the resume path
# instead of nudging a restart. Fully defensive: any failure is swallowed and
# the hook always exits 0 so it can never block a session from starting.

set +e

# An in-progress kickoff leaves artifacts; nudge resume, not restart. Match on
# the artifacts' template headers, not bare filenames — spec.md/plan.md are
# common names in repos this plugin never touched, and those must stay silent.
if { [ -f spec.md ] && grep -q '^# Project Specification' spec.md; } ||
   { [ -f plan.md ] && grep -q '^# Implementation Plan' plan.md; } ||
   { [ -f design/DESIGN.md ] && grep -q '^# Design Manifest' design/DESIGN.md; } 2>/dev/null; then
  echo "Kickoff artifacts detected. To continue an interrupted kickoff, follow 'Resuming an interrupted kickoff' in the using-project-kickoff skill."
  exit 0
fi

# Count non-hidden top-level entries. Hidden files (.git, .claude, etc.) don't
# count as "project content", so a dir with only those still reads as empty.
count=$(find . -maxdepth 1 -mindepth 1 ! -name '.*' 2>/dev/null | wc -l | tr -d ' ')

if [ "${count:-99}" -le 2 ]; then
  echo "Near-empty directory — run /kickoff (namespaced: /project-kickoff:kickoff) to scaffold a new verified project through an interview."
fi

exit 0
