#!/usr/bin/env bash
# Unified fzf picker: sessions by default, command palette when query starts with ':'.

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

result=$("$DIR/sessions.sh" | fzf \
  --prompt='  ' \
  --pointer='▌' \
  --layout=reverse \
  --no-info \
  --no-scrollbar \
  --border=none \
  --margin=1,2 \
  --highlight-line \
  --bind "change:transform:[[ {q} =~ ^: ]] && echo 'reload:$DIR/commands.sh' || echo 'reload:$DIR/sessions.sh'" \
  --color=fg:#878580,bg:#100F0F,hl:#DA702C \
  --color=fg+:#CECDC3,bg+:#1C1B1A,hl+:#DA702C \
  --color=gutter:#100F0F \
  --color=pointer:#DA702C,prompt:#DA702C,marker:#DA702C
) || exit 0

# Pull out the first ':'-prefixed token, if any → command mode.
cmd=$(awk '{for(i=1;i<=NF;i++) if($i ~ /^:/){print $i; exit}}' <<<"$result")

case "$cmd" in
  :new)          tmux command-prompt -p "new session:" "new-session -d -s '%%' ; switch-client -t '%%'" ;;
  :rename)       tmux command-prompt -I "#S" -p "rename to:" "rename-session '%%'" ;;
  :kill)         tmux confirm-before -p "kill session '#S'? (y/n)" kill-session ;;
  :detach)       tmux detach-client ;;
  :reload)       tmux source-file "$HOME/.config/tmux/tmux.conf" \; display "Config reloaded" ;;
  :new-window)   tmux new-window -c "#{pane_current_path}" ;;
  :close-window) tmux confirm-before -p "kill window '#W'? (y/n)" kill-window ;;
  "")
    # No command token → treat row as a session.
    name=$(awk '{print $2}' <<<"$result")
    [[ -n "$name" ]] && tmux switch-client -t "$name"
    ;;
esac
