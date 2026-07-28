#!/usr/bin/env python3
"""Reducer : somme des ventes par magasin."""
from decimal import Decimal, InvalidOperation
import sys

current_key = None
current_total = Decimal("0")

for raw_line in sys.stdin:
    parts = raw_line.rstrip("\n").split("\t", 1)
    if len(parts) != 2:
        continue
    key, value_text = parts
    try:
        value = Decimal(value_text)
    except InvalidOperation:
        continue

    if current_key is not None and key != current_key:
        print(f"{current_key}\t{current_total:.2f}")
        current_total = Decimal("0")
    current_key = key
    current_total += value

if current_key is not None:
    print(f"{current_key}\t{current_total:.2f}")
