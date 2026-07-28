#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
export LC_ALL=C

run_local_job() {
  local job="$1"
  local input="$2"
  python3 "$ROOT_DIR/jobs/$job/mapper.py" < "$input" \
    | sort -t $'\t' -k1,1 \
    | python3 "$ROOT_DIR/jobs/$job/reducer.py"
}

echo "Test des jobs purchases sur l'échantillon..."
run_local_job "purchases/sales_by_store" "$ROOT_DIR/samples/purchases_sample.txt"
run_local_job "purchases/sales_by_product" "$ROOT_DIR/samples/purchases_sample.txt"
run_local_job "purchases/max_purchase_by_store" "$ROOT_DIR/samples/purchases_sample.txt"
run_local_job "purchases/global_stats" "$ROOT_DIR/samples/purchases_sample.txt"
run_local_job "purchases/daily_average" "$ROOT_DIR/samples/purchases_sample.txt"

echo
echo "Test des jobs access_log sur l'échantillon..."
run_local_job "access_log/clicks_by_page" "$ROOT_DIR/samples/access_log_sample.txt" > "$TMP_DIR/pages.tsv"
cat "$TMP_DIR/pages.tsv"
run_local_job "access_log/clicks_by_ip" "$ROOT_DIR/samples/access_log_sample.txt"
python3 "$ROOT_DIR/jobs/access_log/most_visited_page/mapper.py" < "$TMP_DIR/pages.tsv" \
  | sort -t $'\t' -k1,1 \
  | python3 "$ROOT_DIR/jobs/access_log/most_visited_page/reducer.py"

echo
echo "Tous les tests locaux ont réussi."
