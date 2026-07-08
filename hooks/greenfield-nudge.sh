#!/usr/bin/env bash
# Project Kickoff -- greenfield nudge (SessionStart hook)
#
# Surfaces the /kickoff entry point ONLY when the working directory looks like a
# fresh, near-empty project, so it stays silent in populated repos. Fully
# defensive: any failure is swallowed and the hook always exits 0 so it can
# never block a session from starting.

set +e

# Count non-hidden top-level entries. Hidden files (.git, .claude, etc.) don't
# count as "project content", so a dir with only those still reads as empty.
count=$(find . -maxdepth 1 -mindepth 1 ! -name '.*' 2>/dev/null | wc -l | tr -d ' ')

if [ "${count:-99}" -le 2 ]; then
  echo "This directory looks nearly empty. If you're starting a new project, run /kickoff (namespaced: /project-kickoff:kickoff) to scaffold a verified starter repo through an interview: questionnaire -> spec -> plan -> execution, with tests enforced."
fi

exit 0
