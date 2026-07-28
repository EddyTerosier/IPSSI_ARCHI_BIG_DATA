#!/usr/bin/env python3
"""Reducer : achat le plus cher de chaque magasin."""
from decimal import Decimal, InvalidOperation
import sys

current_key = None
current_max = None

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
        print(f"{current_key}\t{current_max:.2f}")
        current_max = None
    current_key = key
    if current_max is None or value > current_max:
        current_max = value

if current_key is not None and current_max is not None:
    print(f"{current_key}\t{current_max:.2f}")
