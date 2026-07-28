#!/usr/bin/env python3
"""Mapper du second job : reçoit page<TAB>visites et envoie tout à un reducer."""
import sys

for raw_line in sys.stdin:
    parts = raw_line.rstrip("\n").split("\t", 1)
    if len(parts) != 2:
        continue
    page, count_text = parts
    try:
        count = int(count_text)
    except ValueError:
        continue
    print(f"GLOBAL\t{count}\t{page}")
