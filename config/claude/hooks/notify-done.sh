#!/bin/bash
input=$(cat)
[ "$(echo "$input" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0
event=$(echo "$input" | jq -r '.hook_event_name // "Stop"')
dir=$(echo "$input" | jq -r '.cwd // empty')
msg="claude done"
[ "$event" = "Notification" ] && msg="claude needs input"
[ -n "$dir" ] && msg="$msg — ${dir##*/}"
"$HOME/.config/bin/notify" "$msg" &
exit 0
