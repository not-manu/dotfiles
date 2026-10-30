#!/usr/bin/env bash
# resurrect-claude.sh — save & restore `claude` (Claude Code) panes around
# tmux-resurrect, since claude renames its process to its version string
# (e.g. "2.1.143") and resurrect's normal process matcher can't catch it.
#
# Usage (wired from tmux.conf):
#   @resurrect-hook-pre-save-all   -> resurrect-claude.sh save
#   @resurrect-hook-post-restore-all -> resurrect-claude.sh restore

set -euo pipefail

SIDECAR="$HOME/.local/share/tmux/resurrect/claude-panes.txt"
mkdir -p "$(dirname "$SIDECAR")"

# A pane is "running claude" if its current command looks like a semver
# (X.Y.Z) — claude sets its process title to its version. Cheap heuristic,
# but nothing else on this machine names a process that way.
is_claude_cmd() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

session_for_pane() {
  local file json re='"sessionId":"([^"]+)"'
  for file in "$HOME"/.claude/sessions/*.json; do
    [[ -e "$file" ]] || continue
    json=$(<"$file")
    [[ "$json" == *"\"tmux\":\""*".$1\""* ]] || continue
    kill -0 "$(basename "$file" .json)" 2>/dev/null || continue
    [[ "$json" =~ $re ]] && echo "${BASH_REMATCH[1]}" && return 0
  done
  return 1
}

save() {
  : > "$SIDECAR"
  local napped=" " pane command target cwd cmd session
  if command -v nap >/dev/null; then
    while IFS=$'\t' read -r pane command; do
      IFS=$'\t' read -r target cwd < <(tmux display -p -t "$pane" '#{session_name}:#{window_index}.#{pane_index}	#{pane_current_path}') || continue
      printf '%s\t%s\t%s\n' "$target" "$cwd" "$command" >> "$SIDECAR"
      napped+="$pane "
    done < <(nap _relaunch)
  fi
  while IFS=$'\t' read -r pane target cmd cwd; do
    [[ "$napped" == *" $pane "* ]] && continue
    if is_claude_cmd "$cmd"; then
      if session=$(session_for_pane "$pane"); then
        command="claude --resume $session"
      else
        command="claude --continue"
      fi
      printf '%s\t%s\t%s\n' "$target" "$cwd" "$command" >> "$SIDECAR"
    fi
  done < <(tmux list-panes -a -F '#{pane_id}	#{session_name}:#{window_index}.#{pane_index}	#{pane_current_command}	#{pane_current_path}')
}

restore() {
  [[ -f "$SIDECAR" ]] || exit 0
  # Give resurrect a moment to finish spawning shells before we send keys.
  sleep 1
  while IFS=$'\t' read -r target cwd command; do
    [[ -z "$target" ]] && continue
    # Only act if the pane exists and is currently a shell (not already
    # running something). If the cwd differs, cd first so claude picks the
    # right per-project session.
    tmux list-panes -t "$target" >/dev/null 2>&1 || continue
    current=$(tmux display -p -t "$target" '#{pane_current_command}' 2>/dev/null || echo "")
    [[ "$current" =~ ^-?(zsh|bash|sh)$ ]] || continue
    current_cwd=$(tmux display -p -t "$target" '#{pane_current_path}' 2>/dev/null || echo "")
    if [[ "$current_cwd" != "$cwd" ]]; then
      tmux send-keys -t "$target" "cd $(printf %q "$cwd")" Enter
    fi
    tmux send-keys -t "$target" -l "${command:-claude --continue}"
    tmux send-keys -t "$target" Enter
  done < "$SIDECAR"
}

case "${1:-}" in
  save) save ;;
  restore) restore ;;
  *) echo "usage: $0 {save|restore}" >&2; exit 2 ;;
esac
