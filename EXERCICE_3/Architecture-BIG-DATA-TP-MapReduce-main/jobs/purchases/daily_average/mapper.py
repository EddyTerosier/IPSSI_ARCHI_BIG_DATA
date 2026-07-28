#!/usr/bin/env python3
"""Mapper : envoie la date et le montant vers un reducer global."""
import sys

for raw_line in sys.stdin:
    fields = raw_line.rstrip("\n").split("\t")
    if len(fields) != 6:
        continue
    date, _time, _store, _product, cost, _payment = fields
    try:
        float(cost)
    except ValueError:
        continue
    print(f"GLOBAL\t{date}\t{cost}")
