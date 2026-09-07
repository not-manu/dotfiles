#!/bin/zsh
repo=$HOME/Documents/Projects/not-manu/taskwarrior
[ -d "$repo/.git" ] || exit 0
task rc.hooks=off rc.verbose=nothing rc.color=off export > "$repo/tasks.json" 2>/dev/null
exit 0
