#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/common.sh"

require_data
wait_for_hdfs

namenode hdfs dfs -mkdir -p /hadoop/data/purchases /hadoop/data/access-log

echo "Chargement de purchases.gz dans HDFS (décompression en flux)..."
compose exec -T namenode bash -lc \
  "gzip -cd /data/purchases.gz | hdfs dfs -put -f - /hadoop/data/purchases/purchases.txt"

echo "Chargement de access_log.gz dans HDFS (décompression en flux)..."
compose exec -T namenode bash -lc \
  "gzip -cd /data/access_log.gz | hdfs dfs -put -f - /hadoop/data/access-log/access_log"

echo "Chargement terminé."
namenode hdfs dfs -ls -h /hadoop/data/purchases
namenode hdfs dfs -ls -h /hadoop/data/access-log
