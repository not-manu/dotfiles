#!/usr/bin/env zsh

set -u

start_dir="${1:-$PWD}"
repo="$(command git -C "$start_dir" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$start_dir")"
hash="$(printf '%s' "$repo" | shasum -a 256 | cut -d ' ' -f 1)"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/git-push-bg"
lock_dir="$state_dir/$hash.lock"
log_file="$state_dir/$hash.log"

mkdir -p "$state_dir" || exit 0

{
  printf 'started: %s\n' "$(date)"
  printf 'start_dir: %s\n' "$start_dir"
  printf 'repo: %s\n' "$repo"
} >"$log_file"

mkdir "$lock_dir" 2>/dev/null || exit 0

trap 'rmdir "$lock_dir" 2>/dev/null' EXIT

cd / || exit 0

command git -C "$repo" push >>"$log_file" 2>&1
