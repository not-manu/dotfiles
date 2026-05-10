#!/bin/bash
input=$(cat)
if echo "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi
afplay /System/Library/Sounds/Blow.aiff &
exit 0
