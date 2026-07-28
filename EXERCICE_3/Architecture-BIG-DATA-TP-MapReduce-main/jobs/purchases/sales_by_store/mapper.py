#!/usr/bin/env python3
"""Mapper : total des ventes par magasin."""
import sys

for raw_line in sys.stdin:
    fields = raw_line.rstrip("\n").split("\t")
    if len(fields) != 6:
        continue
    _date, _time, store, _product, cost, _payment = fields
    try:
        float(cost)
    except ValueError:
        continue
    print(f"{store}\t{cost}")
