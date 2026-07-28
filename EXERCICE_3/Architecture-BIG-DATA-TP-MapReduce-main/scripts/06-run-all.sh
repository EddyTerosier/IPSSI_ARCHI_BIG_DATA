#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"$SCRIPT_DIR/01-start-cluster.sh"
"$SCRIPT_DIR/02-load-data.sh"
"$SCRIPT_DIR/03-check-data.sh"
"$SCRIPT_DIR/04-run-purchases.sh"
"$SCRIPT_DIR/05-run-access-log.sh"

echo
echo "Tous les jobs sont terminés. Consulte le dossier results/."
