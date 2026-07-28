#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/common.sh"

wait_for_hdfs
wait_for_yarn
input="/hadoop/data/access-log/access_log"
namenode hdfs dfs -test -e "$input" || {
  echo "ERREUR : $input absent. Lance d'abord scripts/02-load-data.sh" >&2
  exit 1
}

run_job "access_log/clicks_by_page" "$input" "/results/access/clicks_by_page" "access-clicks-by-page"
export_output "/results/access/clicks_by_page" "access_clicks_by_page.tsv"

run_job "access_log/clicks_by_ip" "$input" "/results/access/clicks_by_ip" "access-clicks-by-ip"
export_output "/results/access/clicks_by_ip" "access_clicks_by_ip.tsv"

run_job "access_log/most_visited_page" "/results/access/clicks_by_page" "/results/access/most_visited_page" "access-most-visited-page"
export_output "/results/access/most_visited_page" "access_most_visited_page.tsv"

echo
echo "=== Réponses demandées ==="
grep -F $'/assets/js/the-associates.js\t' "$ROOT_DIR/results/access_clicks_by_page.tsv" || true
grep -F $'10.99.99.186\t' "$ROOT_DIR/results/access_clicks_by_ip.tsv" || true
cat "$ROOT_DIR/results/access_most_visited_page.tsv"
