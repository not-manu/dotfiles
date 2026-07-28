#!/usr/bin/env bash
# dispatch.sh — run a keybinding in the tmux layer it actually belongs to.
#
# The M-i scratchpad is a real session (_scratch_<parent>_w<window-id>) with a
# popup client attached to it. Some keys must never act on that inner session:
#   - window switching (prefix 1..9) belongs to the parent's tab bar
#   - the lazygit / TODO popups can't even open there, since popups don't nest
# For those, close the scratchpad and run against the parent session/client.
# Outside a scratchpad this is just the plain command on the current client.
#
# Usage: dispatch.sh <window|lazygit|todo> <session> <client> [arg]
#   arg = window index (window) | pane path (lazygit)

set -uo pipefail

action="$1" sess="$2" client="$3" arg="${4:-}"

target_client="$client"

if [[ "$sess" == _scratch_* ]]; then
  # Resolve the parent session from the scratch name: _scratch_<parent>_w<id>.
  # ${var%_w[0-9]*} strips the SHORTEST such suffix, so parents whose own name
  # contains _w<digits> survive intact.
  parent="${sess#_scratch_}"
  parent="${parent%_w[0-9]*}"

  # Renamed parent? Fall back to the window id in the name. Only as a fallback:
  # window ids restart at @0 when the server does (resurrect), so old scratch
  # names can encode an id that now belongs to some unrelated window — hence
  # the _scratch_* reject, and hence the name being authoritative.
  if ! tmux has-session -t "=$parent" 2>/dev/null && [[ "$sess" =~ _w([0-9]+)$ ]]; then
    parent=$(tmux list-windows -a -F '#{window_id} #{session_name}' |
      awk -v id="@${BASH_REMATCH[1]}" \
        '$1 == id { sub(/^[^ ]+ /, ""); if ($0 !~ /^_scratch_/) print; exit }')
  fi
  tmux has-session -t "=$parent" 2>/dev/null || exit 0

  tmux detach-client -t "$client" 2>/dev/null # closes the popup
  sess="$parent"
  target_client=$(tmux list-clients -t "=$parent" -F '#{client_name}' | head -1)
fi

# tmux refuses a popup while that client still has one open, so retry for a
# moment while the scratchpad we just detached tears itself down.
popup() {
  local i
  [[ -n "$target_client" ]] || return 0
  for ((i = 0; i < 20; i++)); do
    tmux display-popup -c "$target_client" "$@" && return 0
    sleep 0.05
  done
}

case "$action" in
window)
  # =sess:=N — exact session name, exact window index (never a name match)
  tmux select-window -t "=$sess:=$arg"
  ;;
lazygit)
  popup -d "$arg" -w 85% -h 80% -S "fg=#282726" -E lazygit
  ;;
todo)
  # q / ctrl-c (normal mode only) saves & closes, like a transient pager
  popup -w 64 -h 70% -S "fg=#282726" \
    -E "nvim -c 'nnoremap <buffer><silent> q :x<CR>|nnoremap <buffer><silent> <C-c> :x<CR>' ~/TODO.md"
  ;;
esac
