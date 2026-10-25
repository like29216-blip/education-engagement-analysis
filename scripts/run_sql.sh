#!/usr/bin/env bash
# Run from any directory. Pass mysql connection flags, e.g. -u analyst -p.
# MYSQL_BIN may point to a MySQL client; credentials must never be written in this script.
set -euo pipefail
project_dir="$(cd "$(dirname "$0")/.." && pwd)"
mysql_client="${MYSQL_BIN:-mysql}"
mkdir -p "$project_dir/docs/qa/execution_logs"
for query_file in "$project_dir"/sql/[0-9][0-9]_*.sql; do
  query_name="$(basename "$query_file" .sql)"
  "$mysql_client" "$@" --batch --raw < "$query_file" > "$project_dir/docs/qa/execution_logs/$query_name.tsv"
done
printf 'All SQL modules executed successfully. See docs/qa/execution_logs.\n'
