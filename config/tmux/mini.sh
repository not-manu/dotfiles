#!/usr/bin/env bash
# mini — nested "mini tmux" for swapping between agent instances in one pane.
#
# Runs on its OWN socket (-L mini), i.e. a separate tmux server, so its
# sessions never show up in the main tmux's session picker (prefix+f).
#
# Usage:
#   mini            attach-or-create session "mini" with 3 windows
#   mini <name>     attach-or-create a named mini session
#   mini -k         kill the entire mini server (all sessions)
set -euo pipefail

SOCKET="mini"
CONF="$HOME/.config/tmux/mini.conf"
SESSION="${1:-mini}"

if [ "$SESSION" = "-k" ]; then
  tmux -L "$SOCKET" kill-server 2>/dev/null || true
  echo "mini server killed"
  exit 0
fi

# TMUX= so the nested tmux doesn't refuse to attach from inside the outer one
if ! tmux -L "$SOCKET" has-session -t "$SESSION" 2>/dev/null; then
  # Fresh session: pre-create 3 windows (one per instance).
  # No -n flag — automatic-rename keeps names tracking the running process
  # until you rename one manually (prefix + ,)
  tmux -L "$SOCKET" -f "$CONF" new-session -d -s "$SESSION"
  tmux -L "$SOCKET" new-window -t "$SESSION"
  tmux -L "$SOCKET" new-window -t "$SESSION"
  tmux -L "$SOCKET" select-window -t "$SESSION:1"
fi

exec env TMUX= tmux -L "$SOCKET" attach-session -t "$SESSION"
