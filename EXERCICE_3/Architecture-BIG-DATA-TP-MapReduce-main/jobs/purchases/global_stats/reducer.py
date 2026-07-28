#!/usr/bin/env python3
"""Reducer : statistiques globales sur toutes les transactions."""
from decimal import Decimal, InvalidOperation
import sys

count = 0
total = Decimal("0")

for raw_line in sys.stdin:
    parts = raw_line.rstrip("\n").split("\t")
    if len(parts) != 3:
        continue
    _key, count_text, cost_text = parts
    try:
        count += int(count_text)
        total += Decimal(cost_text)
    except (ValueError, InvalidOperation):
        continue

average = total / count if count else Decimal("0")
print(f"Nombre_transactions\t{count}")
print(f"Chiffre_affaires_total\t{total:.2f}")
print(f"Montant_moyen_transaction\t{average:.2f}")
