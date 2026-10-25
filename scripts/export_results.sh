#!/usr/bin/env bash
# Aggregate outputs only; all business calculations are executed in MySQL views.
set -euo pipefail
project_dir="$(cd "$(dirname "$0")/.." && pwd)"
mysql_client="${MYSQL_BIN:-mysql}"
mkdir -p "$project_dir/data/results"
while IFS='|' read -r result_name query_text; do
  "$mysql_client" "$@" --database=customer_engagement --batch --raw --execute="$query_text" > "$project_dir/data/results/$result_name.tsv"
done < "$project_dir/sql/result_manifest.txt"
printf 'Aggregate result tables exported.\n'
