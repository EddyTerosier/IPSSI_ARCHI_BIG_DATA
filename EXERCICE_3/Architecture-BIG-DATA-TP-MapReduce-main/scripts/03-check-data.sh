#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/common.sh"

wait_for_hdfs

echo "=== Présence et taille de purchases.txt ==="
namenode hdfs dfs -ls -h /hadoop/data/purchases
namenode bash -lc "hdfs dfs -cat /hadoop/data/purchases/purchases.txt | head -n 5"

echo
echo "=== Présence et taille de access_log ==="
namenode hdfs dfs -ls -h /hadoop/data/access-log
namenode bash -lc "hdfs dfs -cat /hadoop/data/access-log/access_log | head -n 5"
