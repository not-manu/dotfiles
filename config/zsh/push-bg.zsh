#!/usr/bin/env zsh

set -u

repo="$(command git rev-parse --show-toplevel 2>/dev/null || pwd)"
hash="$(printf '%s' "$repo" | shasum -a 256 | cut -d ' ' -f 1)"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/git-push-bg"
lock_dir="$state_dir/$hash.lock"
log_file="$state_dir/$hash.log"

mkdir -p "$state_dir" || exit 0

if ! mkdir "$lock_dir" 2>/dev/null; then
  exit 0
fi

(
  trap 'rmdir "$lock_dir" 2>/dev/null' EXIT
  command git push "$@" >"$log_file" 2>&1
) &!

exit 0
