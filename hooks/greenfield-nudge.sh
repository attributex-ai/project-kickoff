#!/usr/bin/env bash
# Project Kickoff -- greenfield nudge (SessionStart hook)
#
# Nudges /kickoff only when the directory looks like a fresh project, points at
# the resume path when a kickoff is demonstrably in progress, and stays silent
# everywhere else -- including completed kickoff projects and populated repos.
# Fully defensive: every grep suppresses its own errors and the hook always
# exits 0 so it can never block a session from starting.

set +e

# Kickoff artifacts are identified by BOTH their template header and a second
# chain-specific marker, so a foreign spec.md/plan.md never matches.
is_kickoff_spec() {
  [ -f spec.md ] && grep -q '^# Project Specification' spec.md 2>/dev/null \
                 && grep -q '^Status:' spec.md 2>/dev/null
}
is_kickoff_plan() {
  [ -f plan.md ] && grep -q '^# Implementation Plan' plan.md 2>/dev/null \
                 && grep -q '^Spec: spec.md' plan.md 2>/dev/null
}
is_kickoff_design() {
  [ -f design/DESIGN.md ] && grep -q '^# Design Manifest' design/DESIGN.md 2>/dev/null
}

resume_msg="Kickoff artifacts detected. To continue an interrupted kickoff, follow 'Resuming an interrupted kickoff' in the using-project-kickoff skill."

if is_kickoff_plan; then
  # Unchecked tasks mean an in-progress build; a fully checked (or descoped)
  # plan is a finished project -- stay silent there, forever.
  if grep -q '^- \[ \]' plan.md 2>/dev/null; then
    echo "$resume_msg"
  fi
  exit 0
fi

if is_kickoff_spec || is_kickoff_design; then
  echo "$resume_msg"
  exit 0
fi

# No kickoff artifacts. Nudge /kickoff only in a fresh, near-empty directory --
# and only when none of the artifact filenames exist at all (an unreadable
# spec.md must produce silence, never a restart nudge over real work).
count=$(find . -maxdepth 1 -mindepth 1 ! -name '.*' 2>/dev/null | wc -l | tr -d ' ')
if [ "${count:-99}" -le 2 ] && [ ! -e spec.md ] && [ ! -e plan.md ] && [ ! -e design/DESIGN.md ]; then
  if [ -d design ]; then
    # Staged design files but no manifest: a kickoff died mid design-import.
    echo "Kickoff interrupted mid design-import (design/ staged, no manifest). Resume the design-import skill and keep the staged files."
  else
    echo "Near-empty directory — run /kickoff (namespaced: /project-kickoff:kickoff) to scaffold a new verified project through an interview."
  fi
fi

exit 0
