#!/usr/bin/env bash
# fzf window switcher for the current session (prefix + w), with a pane preview.
# Lives in a script rather than inline in tmux.conf so the binding can be
# wrapped in an if-shell guard without escaping every quote twice.

set -euo pipefail

tmux list-windows -F '#{window_index} #{window_name}' | fzf \
  --prompt='  window: ' \
  --layout=reverse \
  --border=none \
  --preview='tmux list-panes -t :{1} -F "  #{pane_index}  #{pane_current_command}  #{pane_current_path}" 2>/dev/null' \
  --preview-window=right,40%,border-left \
  --color=fg:#878580,bg:#100F0F,hl:#CECDC3 \
  --color=fg+:#CECDC3,bg+:#1C1B1A,hl+:#CECDC3 \
  --color=border:#343331,header:#CECDC3,gutter:#100F0F \
  --color=spinner:#24837B,info:#24837B,separator:#1C1B1A \
  --color=pointer:#AD8301,marker:#AF3029,prompt:#AD8301 \
  --color=preview-fg:#878580,preview-bg:#100F0F \
  | awk '{print $1}' | xargs -r tmux select-window -t
