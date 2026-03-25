#!/usr/bin/env bash

set -euo pipefail

readonly COMMITS_PER_DAY=69
readonly START_DATE="1970-01-01"
readonly END_DATE="2024-12-31"

current_date="$START_DATE"

while [[ "$current_date" < "$END_DATE" ]] || [[ "$current_date" == "$END_DATE" ]]; do
  echo "$current_date"

  for ((i=0; i<COMMITS_PER_DAY; i++)); do
    base_ts=$(date -d "$current_date" +%s 2>/dev/null)

    offset=$((i % 60))
    ts=$((base_ts + offset))

    formatted_date=$(date -u -d "@$ts" +"%Y-%m-%d %H:%M:%S +0000" 2>/dev/null)

    GIT_AUTHOR_DATE="$formatted_date" GIT_COMMITTER_DATE="$formatted_date" git commit --allow-empty -m "$formatted_date" >/dev/null 2>&1
  done

  current_date=$(date -I -d "$current_date +1 day" 2>/dev/null || date -j -v+1d -f "%Y-%m-%d" "$current_date" "+%Y-%m-%d" 2>/dev/null)
done
