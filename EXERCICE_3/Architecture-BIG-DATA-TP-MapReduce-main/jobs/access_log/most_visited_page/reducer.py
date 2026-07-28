#!/usr/bin/env python3
"""Reducer du second job : retourne la page la plus visitée."""
import sys

max_page = None
max_count = -1

for raw_line in sys.stdin:
    parts = raw_line.rstrip("\n").split("\t", 2)
    if len(parts) != 3:
        continue
    _key, count_text, page = parts
    try:
        count = int(count_text)
    except ValueError:
        continue
    if count > max_count or (count == max_count and (max_page is None or page < max_page)):
        max_count = count
        max_page = page

if max_page is not None:
    print(f"{max_page}\t{max_count}")
