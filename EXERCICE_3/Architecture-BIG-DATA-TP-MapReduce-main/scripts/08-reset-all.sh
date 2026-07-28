#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/common.sh"
compose down -v --remove-orphans
find "$ROOT_DIR/results" -maxdepth 1 -type f \( -name '*.tsv' -o -name '*.txt' \) -delete
printf '%s\n' "Cluster, volumes HDFS et résultats locaux supprimés."
