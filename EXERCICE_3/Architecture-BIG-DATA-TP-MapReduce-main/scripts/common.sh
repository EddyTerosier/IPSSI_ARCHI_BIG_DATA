#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/docker-compose.yml"

compose() {
  docker compose -f "$COMPOSE_FILE" "$@"
}

namenode() {
  compose exec -T namenode "$@"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERREUR : la commande '$1' est introuvable." >&2
    exit 1
  }
}

require_data() {
  local missing=0
  for file in "$ROOT_DIR/data/purchases.gz" "$ROOT_DIR/data/access_log.gz"; do
    if [[ ! -f "$file" ]]; then
      echo "ERREUR : fichier absent : $file" >&2
      missing=1
    fi
  done
  if [[ "$missing" -ne 0 ]]; then
    echo "Place les deux fichiers .gz dans le dossier data/ puis relance." >&2
    exit 1
  fi
}

wait_for_hdfs() {
  echo "Attente de HDFS..."
  for _ in $(seq 1 60); do
    if namenode hdfs dfsadmin -report >/dev/null 2>&1; then
      echo "HDFS est prêt."
      return 0
    fi
    sleep 3
  done
  echo "ERREUR : HDFS n'est pas prêt après 3 minutes." >&2
  compose ps
  exit 1
}

wait_for_yarn() {
  echo "Attente de YARN et du NodeManager..."
  for _ in $(seq 1 60); do
    if namenode yarn node -list 2>/dev/null | grep -q 'RUNNING'; then
      echo "YARN est prêt."
      return 0
    fi
    sleep 3
  done
  echo "ERREUR : aucun NodeManager RUNNING après 3 minutes." >&2
  compose ps
  exit 1
}

run_job() {
  local job_dir="$1"
  local input_hdfs="$2"
  local output_hdfs="$3"
  local job_name="$4"
  local reducers="${5:-1}"

  compose exec -T namenode bash /container-scripts/run-streaming-job.sh \
    "/jobs/$job_dir" "$input_hdfs" "$output_hdfs" "$job_name" "$reducers"
}

export_output() {
  local output_hdfs="$1"
  local local_filename="$2"
  rm -f "$ROOT_DIR/results/$local_filename"
  namenode hdfs dfs -getmerge "$output_hdfs" "/results/$local_filename"
  echo "Résultat local : results/$local_filename"
}
