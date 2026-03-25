Okay, awesome, the script works. However, is kinda slow.

Currently (with my shitty laptop)

a. 1 commit ~= 0.8s
b. commits per day = 69
c. End date - start date ~= 20,454 days

c * b * a = 1129060.8 seconds or  1.87 weeks

of course, i do not have that amount of time so i need to speed things up.

This is actually going to be quite simple

1. Remove the curl part since that is a major bottleneck
2. Remove heavy git features like gc and pre-commit hooks
3. use the `--allow-empty` commit flag which allows me to commit with no changes
   completely evading the I/O bottleneck

I could split into multiple repositories but that is more that necessary.

also note i can not have parallel commits since git locks commits to prevent
concurrent commits.

I deleted the faker script of the last version to make all my commits perfectly
`69` for comedic purposes. This was the code:

```bash
#!/usr/bin/env bash

set -euo pipefail

readonly FILE="README.md"
readonly COMMITS_PER_DAY=69
readonly END_DATE="2024-12-31"
readonly START_DATE="1970-01-01"
readonly COMMIT_API="https://whatthecommit.com/index.txt"

current_date="$START_DATE"

while [[ "$current_date" < "$END_DATE" ]] || [[ "$current_date" == "$END_DATE" ]]; do
  for (( i = 0; i < COMMITS_PER_DAY; i++ )); do
    msg=$(curl -fsS "$COMMIT_API")
    echo "$msg" >> "$FILE"
    git add "$FILE"

    GIT_AUTHOR_DATE="$current_date 00:00:01 +0000" \
    GIT_COMMITTER_DATE="$current_date 00:00:01 +0000" \
    git commit -m "$msg"
  done

  current_date=$(date -I -d "$current_date +1 day" 2>/dev/null || \
                 date -j -v+1d -f "%Y-%m-%d" "$current_date" "+%Y-%m-%d")
done
```

And this is the new iteration

```bash
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
```

After running the script for 4m and 40s i only got 16 days done, this is still
quite slow, so I'm going to change the amount of commits down to just one per
day.

It did not work... or did it?
