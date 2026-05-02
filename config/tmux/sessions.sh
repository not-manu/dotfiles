#!/usr/bin/env bash
# Emit tmux sessions for the fzf picker, sorted by last activity.
# Format: "<marker> <name>\t<rel>"

set -euo pipefail

tmux list-sessions \
    -F '#{session_activity}|#{?session_attached,●,○} #{session_name}' \
  | sort -rn -t'|' -k1,1 \
  | awk -F'|' -v now="$(date +%s)" '
      function rel(t,   d) {
        d = now - t
        if (d < 60)      return d "s"
        if (d < 3600)    return int(d/60) "m"
        if (d < 86400)   return int(d/3600) "h"
        if (d < 604800)  return int(d/86400) "d"
        if (d < 2592000) return int(d/86400/7) "w"
        return int(d/86400/30) "mo"
      }
      { printf "%s\t%s\n", $2, rel($1) }
  ' \
  | column -ts $'\t'
