#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 || $# -gt 5 ]]; then
  echo "Usage: $0 JOB_DIR INPUT_HDFS OUTPUT_HDFS JOB_NAME [REDUCERS]" >&2
  exit 2
fi

job_dir="$1"
input_hdfs="$2"
output_hdfs="$3"
job_name="$4"
reducers="${5:-1}"

streaming_jar="$(find /opt/hadoop-* -name 'hadoop-streaming*.jar' 2>/dev/null | head -n 1)"
if [[ -z "$streaming_jar" ]]; then
  echo "ERREUR : hadoop-streaming.jar est introuvable." >&2
  exit 1
fi

[[ -f "$job_dir/mapper.py" ]] || { echo "Mapper absent : $job_dir/mapper.py" >&2; exit 1; }
[[ -f "$job_dir/reducer.py" ]] || { echo "Reducer absent : $job_dir/reducer.py" >&2; exit 1; }

hdfs dfs -rm -r -f "$output_hdfs" >/dev/null 2>&1 || true

echo "Lancement du job : $job_name"
yarn jar "$streaming_jar" \
  -D "mapreduce.job.name=$job_name" \
  -D "mapreduce.job.reduces=$reducers" \
  -files "$job_dir/mapper.py,$job_dir/reducer.py" \
  -mapper "python3 mapper.py" \
  -reducer "python3 reducer.py" \
  -input "$input_hdfs" \
  -output "$output_hdfs"

echo "Sortie HDFS : $output_hdfs"
hdfs dfs -ls "$output_hdfs"
