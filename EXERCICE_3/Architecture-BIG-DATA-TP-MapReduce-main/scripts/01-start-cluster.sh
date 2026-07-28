#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/common.sh"

require_command docker

echo "Construction et démarrage du cluster Hadoop/YARN..."
compose up -d --build
wait_for_hdfs
wait_for_yarn

echo
echo "Interfaces :"
echo "- NameNode       : http://localhost:9870"
echo "- ResourceManager: http://localhost:8088"
echo "- NodeManager    : http://localhost:8042"
echo "- HistoryServer  : http://localhost:8188"
echo
compose ps
