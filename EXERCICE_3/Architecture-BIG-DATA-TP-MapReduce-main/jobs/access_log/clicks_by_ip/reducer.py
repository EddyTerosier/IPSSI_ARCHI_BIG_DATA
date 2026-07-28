#!/usr/bin/env python3
"""Reducer : nombre de requêtes par adresse IP."""
import sys

current_key = None
current_count = 0

for raw_line in sys.stdin:
    parts = raw_line.rstrip("\n").split("\t", 1)
    if len(parts) != 2:
        continue
    key, value_text = parts
    try:
        value = int(value_text)
    except ValueError:
        continue

    if current_key is not None and key != current_key:
        print(f"{current_key}\t{current_count}")
        current_count = 0
    current_key = key
    current_count += value

if current_key is not None:
    print(f"{current_key}\t{current_count}")
