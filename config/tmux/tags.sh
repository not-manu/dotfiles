#!/usr/bin/env bash
set -euo pipefail

FILE="$(cd "$(dirname "$0")" && pwd)/tags"
action="$1" path="$2"
tilde='~'
key="${path/#$HOME/$tilde}"

case "$action" in
get)
  awk -F'\t' -v k="$key" '$1 == k { print $2 }' "$FILE"
  ;;
set)
  shift 2
  tags="$*"
  {
    awk -F'\t' -v k="$key" '$1 != k' "$FILE"
    [[ -z "$tags" ]] || printf '%s\t%s\n' "$key" "$tags"
  } | sort -t$'\t' -k1,1 >"$FILE.tmp"
  mv "$FILE.tmp" "$FILE"
  ;;
esac
