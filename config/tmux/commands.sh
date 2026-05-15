#!/usr/bin/env bash
# Emit the command palette for the fzf picker.
# Format: "<icon>  :command  <description>"

cat <<'EOF'
   :new           create new session
   :rename        rename current session
   :kill          kill current session
   :detach        detach client
   :reload        reload tmux config
   :new-window    create new window
   :close-window  kill current window
EOF
