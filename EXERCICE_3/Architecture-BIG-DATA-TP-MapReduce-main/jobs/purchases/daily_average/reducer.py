#!/usr/bin/env python3
"""Reducer : chiffre d'affaires moyen par jour."""
from collections import defaultdict
from decimal import Decimal, InvalidOperation
import sys

daily_totals = defaultdict(lambda: Decimal("0"))

for raw_line in sys.stdin:
    parts = raw_line.rstrip("\n").split("\t")
    if len(parts) != 3:
        continue
    _key, date, cost_text = parts
    try:
        daily_totals[date] += Decimal(cost_text)
    except InvalidOperation:
        continue

number_of_days = len(daily_totals)
grand_total = sum(daily_totals.values(), Decimal("0"))
daily_average = grand_total / number_of_days if number_of_days else Decimal("0")

print(f"Nombre_jours\t{number_of_days}")
print(f"Chiffre_affaires_total\t{grand_total:.2f}")
print(f"Moyenne_chiffre_affaires_par_jour\t{daily_average:.2f}")
