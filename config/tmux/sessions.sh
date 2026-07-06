#!/usr/bin/env bash
# Emit tmux sessions for the fzf picker, sorted by last activity.
# Pretty, ANSI-coloured rows (picker runs fzf with --ansi):
#   <marker>  <name>      <rel>   <Nw>   <win1 · win2 · …>
# Field layout for the picker's parser stays: $1=marker, $2=session name.
#
# Speed: exactly two tmux calls total (all sessions + all windows via -a),
# assembled in a single awk pass — no per-session subprocess fan-out.

set -euo pipefail

# Sessions starting with "_" (e.g. _scratch_*) are hidden unless --all is passed.
hide=1
[[ "${1:-}" == "--all" ]] && hide=0

awk -v now="$(date +%s)" -v hide="$hide" '
  BEGIN {
    RESET = "\033[0m"; BOLD = "\033[1m";
    TX     = "\033[38;2;206;205;195m";   # base-200  — session name
    DIM    = "\033[38;2;135;133;128m";   # base-500  — rel / separators
    FAINT  = "\033[38;2;87;86;83m";      # base-700  — inactive windows
    ORANGE = "\033[38;2;218;112;44m";    # orange-2  — marker / active / count
    SEP    = DIM " · " RESET;
  }
  function rel(t,   d) {
    d = now - t;
    if (d < 60)      return d "s";
    if (d < 3600)    return int(d / 60) "m";
    if (d < 86400)   return int(d / 3600) "h";
    if (d < 604800)  return int(d / 86400) "d";
    if (d < 2592000) return int(d / 86400 / 7) "w";
    return int(d / 86400 / 30) "mo";
  }
  # First input: windows — "session|*name" (active) or "session|name"
  FNR == NR {
    p = index($0, "|"); s = substr($0, 1, p - 1); w = substr($0, p + 1);
    cnt[s]++;
    if (substr(w, 1, 1) == "*") { col = ORANGE; w = substr(w, 2); } else col = FAINT;
    wl[s] = wl[s] (wl[s] == "" ? "" : SEP) col w RESET;
    next;
  }
  # Second input: sessions (pre-sorted) — "activity|attached|name"
  {
    p = index($0, "|"); act = substr($0, 1, p - 1); rest = substr($0, p + 1);
    q = index(rest, "|"); att = substr(rest, 1, q - 1); name = substr(rest, q + 1);
    if (hide && substr(name, 1, 1) == "_") next;
    order[++m] = name; A[name] = act; AT[name] = att;
    if (length(name) > maxn) maxn = length(name);
  }
  END {
    for (i = 1; i <= m; i++) {
      name = order[i];
      mark = (AT[name] == "1") ? ORANGE "●" RESET : FAINT "○" RESET;
      pad = ""; n = maxn - length(name);
      while (n-- > 0) pad = pad " ";
      printf "%s  %s%s%s%s   %s%3s%s   %s%2sw%s   %s\n",
        mark, TX BOLD, name, pad, RESET,
        DIM, rel(A[name]), RESET,
        ORANGE, cnt[name], RESET,
        wl[name];
    }
  }
' \
  <(tmux list-windows -a -F '#{session_name}|#{?window_active,*,}#{window_name}') \
  <(tmux list-sessions -F '#{session_activity}|#{session_attached}|#{session_name}' | sort -rn -t'|' -k1,1)
