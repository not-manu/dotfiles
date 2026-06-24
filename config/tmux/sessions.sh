#!/usr/bin/env bash
# Emit tmux sessions for the fzf picker, sorted by last activity.
# Pretty, ANSI-coloured rows (picker runs fzf with --ansi):
#   <marker>  <name>      <rel>   <Nw>   <win1 · win2 · …>
# Field layout for the picker's parser stays: $1=marker, $2=session name.

set -euo pipefail

# --- Flexoki truecolor helpers -------------------------------------------
esc() { printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"; }
RESET=$'\033[0m'
BOLD=$'\033[1m'
TX=$(esc 206 205 195)     # base-200  — session name
DIM=$(esc 135 133 128)    # base-500  — rel time / separators
FAINT=$(esc 87 86 83)     # base-700  — inactive window names
GREEN=$(esc 135 154 57)   # green-2   — attached marker
ORANGE=$(esc 218 112 44)  # orange-2  — active window / count

now=$(date +%s)
rel() {
  local d=$(( now - $1 ))
  if   (( d < 60 ));      then echo "${d}s"
  elif (( d < 3600 ));    then echo "$(( d / 60 ))m"
  elif (( d < 86400 ));   then echo "$(( d / 3600 ))h"
  elif (( d < 604800 ));  then echo "$(( d / 86400 ))d"
  elif (( d < 2592000 )); then echo "$(( d / 86400 / 7 ))w"
  else                        echo "$(( d / 86400 / 30 ))mo"; fi
}

# --- Gather sessions, newest activity first ------------------------------
names=(); markers=(); rels=(); counts=(); winlists=()
maxn=0
while IFS='|' read -r act attached name; do
  [[ -n $name ]] || continue
  if [[ $attached == 1 ]]; then markers+=("${ORANGE}●${RESET}"); else markers+=("${FAINT}○${RESET}"); fi
  rels+=("$(rel "$act")")

  wn=()
  while IFS= read -r line; do wn+=("$line"); done \
    < <(tmux list-windows -t "$name" -F '#{?window_active,*,}#{window_name}')
  counts+=("${#wn[@]}")

  wl=""
  for j in "${!wn[@]}"; do
    w=${wn[j]}
    (( j > 0 )) && wl+="${DIM} · ${RESET}"
    if [[ $w == \** ]]; then wl+="${ORANGE}${w#\*}${RESET}"; else wl+="${FAINT}${w}${RESET}"; fi
  done
  winlists+=("$wl")

  names+=("$name")
  (( ${#name} > maxn )) && maxn=${#name}
done < <(
  tmux list-sessions -F '#{session_activity}|#{session_attached}|#{session_name}' \
    | sort -rn -t'|' -k1,1
)

# --- Render --------------------------------------------------------------
for i in "${!names[@]}"; do
  printf '%s  %s%s%-*s%s   %s%3s%s   %s%2sw%s   %s\n' \
    "${markers[i]}" \
    "$TX$BOLD" '' "$maxn" "${names[i]}" "$RESET" \
    "$DIM" "${rels[i]}" "$RESET" \
    "$ORANGE" "${counts[i]}" "$RESET" \
    "${winlists[i]}"
done
