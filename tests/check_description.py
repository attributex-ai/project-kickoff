#!/usr/bin/env python3
"""Validate a SKILL.md frontmatter description.

Checks, in order:
  - a frontmatter block and a description key exist
  - the description VALUE (not the raw line) is non-empty and <= 1024
    characters (characters, not bytes; block scalars are folded first)
  - an unquoted plain scalar contains no ": " sequence, which spec-compliant
    YAML parsers reject (Claude Code is lenient; other harnesses are not)

Exit 0 on pass; exit 1 with a reason on stdout otherwise.
Usage: check_description.py <path-to-SKILL.md>
"""
import re
import sys

path = sys.argv[1]
lines = open(path, encoding="utf-8").read().split("\n")
try:
    start = lines.index("---")
    end = lines.index("---", start + 1)
except ValueError:
    print(f"{path}: no frontmatter block")
    sys.exit(1)

frontmatter = lines[start + 1:end]
value = None
quoted = False
for i, line in enumerate(frontmatter):
    m = re.match(r"^description:\s*(.*)$", line)
    if m is None:
        continue
    v = m.group(1).strip()
    if v in (">", ">-", "|", "|-"):  # block scalar: fold the indented lines
        block = [l.strip() for l in frontmatter[i + 1:] if l.startswith((" ", "\t"))]
        v = " ".join(block).strip()
    elif len(v) >= 2 and v[0] == v[-1] and v[0] in "\"'":
        quoted = True
        v = v[1:-1]
    value = v
    break

if not value:
    print(f"{path}: description missing or empty")
    sys.exit(1)
if len(value) > 1024:
    print(f"{path}: description is {len(value)} chars (limit 1024)")
    sys.exit(1)
if not quoted and ": " in value:
    print(f"{path}: unquoted description contains ': ' — invalid for strict YAML parsers")
    sys.exit(1)
sys.exit(0)
