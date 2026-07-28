#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/common.sh"

wait_for_hdfs
wait_for_yarn
input="/hadoop/data/purchases/purchases.txt"
namenode hdfs dfs -test -e "$input" || {
  echo "ERREUR : $input absent. Lance d'abord scripts/02-load-data.sh" >&2
  exit 1
}

run_job "purchases/sales_by_store" "$input" "/results/purchases/sales_by_store" "purchases-sales-by-store"
export_output "/results/purchases/sales_by_store" "purchases_sales_by_store.tsv"

run_job "purchases/sales_by_product" "$input" "/results/purchases/sales_by_product" "purchases-sales-by-product"
export_output "/results/purchases/sales_by_product" "purchases_sales_by_product.tsv"

run_job "purchases/max_purchase_by_store" "$input" "/results/purchases/max_purchase_by_store" "purchases-max-by-store"
export_output "/results/purchases/max_purchase_by_store" "purchases_max_by_store.tsv"

run_job "purchases/global_stats" "$input" "/results/purchases/global_stats" "purchases-global-stats"
export_output "/results/purchases/global_stats" "purchases_global_stats.tsv"

run_job "purchases/daily_average" "$input" "/results/purchases/daily_average" "purchases-daily-average"
export_output "/results/purchases/daily_average" "purchases_daily_average.tsv"

echo
echo "=== Réponses demandées ==="
grep -F $'Buffalo\t' "$ROOT_DIR/results/purchases_sales_by_store.tsv" || true
grep -F $'Toys\t' "$ROOT_DIR/results/purchases_sales_by_product.tsv" || true
grep -F $'Consumer Electronics\t' "$ROOT_DIR/results/purchases_sales_by_product.tsv" || true
grep -E $'^(Reno|Toledo|Chandler)\t' "$ROOT_DIR/results/purchases_max_by_store.tsv" || true
cat "$ROOT_DIR/results/purchases_global_stats.tsv"
cat "$ROOT_DIR/results/purchases_daily_average.tsv"
