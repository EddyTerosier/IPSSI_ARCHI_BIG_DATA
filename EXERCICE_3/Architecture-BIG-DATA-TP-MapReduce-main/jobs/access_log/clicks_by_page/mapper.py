#!/usr/bin/env python3
"""Mapper : extrait la page demandée d'une ligne de log Apache."""
import re
import sys

LOG_PATTERN = re.compile(
    r'^(\S+)\s+\S+\s+\S+\s+\[[^\]]+\]\s+"(\S+)\s+(\S+)(?:\s+\S+)?"\s+(\d{3})\s+(\S+)'
)

for raw_line in sys.stdin:
    match = LOG_PATTERN.match(raw_line)
    if not match:
        continue
    _ip, _method, page, _status, _size = match.groups()
    print(f"{page}\t1")
