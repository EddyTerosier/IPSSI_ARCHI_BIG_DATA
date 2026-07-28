#!/usr/bin/env python3
"""Mapper : nombre de transactions et chiffre d'affaires global."""
import sys

for raw_line in sys.stdin:
    fields = raw_line.rstrip("\n").split("\t")
    if len(fields) != 6:
        continue
    cost = fields[4]
    try:
        float(cost)
    except ValueError:
        continue
    print(f"GLOBAL\t1\t{cost}")
