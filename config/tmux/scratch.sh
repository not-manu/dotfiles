#!/usr/bin/env bash
# Per-window scratchpad popup (toggled with M-i, no prefix).
# Called two ways:
#   scratch.sh <session> <window_id> <path> <client>   from the keybinding (via run-shell)
#   scratch.sh --attach <name>                         inside the popup

set -u

if [[ "${1:-}" == "--attach" ]]; then
  name="$2"
  unset TMUX # tmux refuses a nested attach unless this is cleared
  if ! tmux has-session -t "=$name" 2>/dev/null; then
    # popup is opened with -d <path>, so $PWD is the parent pane's path.
    # tmux 3.6 fails to resolve set/show -t by session *name*, so grab the
    # session id at creation and target that to hide the status bar.
    id=$(tmux new-session -dPF '#{session_id}' -s "$name" -c "$PWD")
    tmux set -t "$id" status off
  fi
  exec tmux attach -t "=$name"
fi

sess="$1" win="$2" path="$3" client="$4"

# Already inside a scratch popup → toggle it closed
if [[ "$sess" == _scratch_* ]]; then
  exec tmux detach-client -t "$client"
fi

# strip the "@" from the window id — "@" in a session name breaks tmux's
# target parser (-t), which made "set status off" fail silently
exec tmux display-popup -c "$client" -d "$path" -w 85% -h 80% \
  -S "fg=#1c1b1a" \
  -E "$HOME/.config/tmux/scratch.sh --attach '_scratch_${sess}_w${win#@}'"
