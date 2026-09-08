#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

hide=1
[[ "${1:-}" == "--all" ]] && hide=0

awk -F'\t' -v now="$(date +%s)" -v hide="$hide" -v home="$HOME" '
  BEGIN {
    RESET = "\033[0m"; BOLD = "\033[1m";
    TX     = "\033[38;2;206;205;195m";
    DIM    = "\033[38;2;135;133;128m";
    FAINT  = "\033[38;2;87;86;83m";
    ORANGE = "\033[38;2;218;112;44m";
    PURPLE = "\033[38;2;139;126;200m";
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
  function tags(p,   n, j, out) {
    while (p != "" && !(p in TAG)) sub(/\/[^\/]*$/, "", p);
    n = split(TAG[p], ts, " ");
    out = "";
    for (j = 1; j <= n; j++) out = out (j > 1 ? " " : "") "#" ts[j];
    return out;
  }
  FILENAME == ARGV[1] {
    if (NF < 2) next;
    k = $1; if (substr(k, 1, 1) == "~") k = home substr(k, 2);
    TAG[k] = $2;
    next;
  }
  FILENAME == ARGV[2] {
    s = $1; w = $2;
    cnt[s]++;
    if (substr(w, 1, 1) == "*") { col = ORANGE; w = substr(w, 2); cwd[s] = $3; } else col = FAINT;
    wl[s] = wl[s] (wl[s] == "" ? "" : SEP) col w RESET;
    next;
  }
  {
    name = $3;
    if (hide && substr(name, 1, 1) == "_") next;
    order[++m] = name; A[name] = $1; AT[name] = $2; P[name] = $4;
    if (length(name) > maxn) maxn = length(name);
  }
  END {
    for (i = 1; i <= m; i++) {
      name = order[i];
      T[name] = tags(cwd[name] != "" ? cwd[name] : P[name]);
      if (length(T[name]) > maxt) maxt = length(T[name]);
    }
    for (i = 1; i <= m; i++) {
      name = order[i];
      mark = (AT[name] == "1") ? ORANGE "●" RESET : FAINT "○" RESET;
      pad = ""; n = maxn - length(name);
      while (n-- > 0) pad = pad " ";
      tpad = ""; n = maxt - length(T[name]);
      while (n-- > 0) tpad = tpad " ";
      printf "%s  %s%s%s%s   %s%3s%s   %s%2sw%s   %s%s%s%s%s\n",
        mark, TX BOLD, name, pad, RESET,
        DIM, rel(A[name]), RESET,
        ORANGE, cnt[name], RESET,
        PURPLE, T[name], RESET, tpad, (maxt ? "   " : "") wl[name];
    }
  }
' \
  "$DIR/tags" \
  <(tmux list-windows -a -F $'#{session_name}\t#{?window_active,*,}#{window_name}\t#{pane_current_path}') \
  <(tmux list-sessions -F $'#{session_activity}\t#{session_attached}\t#{session_name}\t#{session_path}' | sort -rn -t$'\t' -k1,1)
