#!/bin/zsh
repo=$HOME/Documents/Projects/not-manu/taskwarrior
[ -d "$repo/.git" ] || exit 0
task rc.hooks=off rc.verbose=nothing rc.color=off export > "$repo/tasks.json" 2>/dev/null || exit 0
git -C "$repo" rev-parse --verify -q HEAD >/dev/null || exit 0
git -C "$repo" add tasks.json
git -C "$repo" diff --cached --quiet && exit 0
git -C "$repo" commit -q -m "tasks $(date '+%Y-%m-%d %H:%M')"
