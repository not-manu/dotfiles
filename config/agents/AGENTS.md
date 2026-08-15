- Be brief, unless explicitly asked to be more verbose.
- A question is just a question ("why do we need X?", "is this used anywhere?",
  "what does this do?"). Answer it. Don't change code until I ask for a change.
- Python: `uv`, and always `uvx`. JS: `bun` (or `pnpm` if the project uses it),
  never `npm`. Search: `rg`, not `grep`.
- IMPORTANT: Never hand-edit dependency manifests (`package.json`,
  `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`). Use the package manager
  (`bun add`, `uv add`, `cargo add`, `go get`) so lockfiles stay consistent.

## Where My Stuff Lives
- Dotfiles: `~/.dotfiles`. `~/.claude/CLAUDE.md` symlinks to
  `~/.dotfiles/config/agents/AGENTS.md` — edit the source, not the symlink.
- Code: `~/Documents/Projects/<scope>/<project>`. Scope `not-manu` is personal
  and the default; the other is a shared account.
- `.../not-manu/Clones/` — upstream repos for reading only. Never commit or
  push there.
- `.../not-manu/Forks/` — my forks; branch and PR normally. Keep the
  `github_not-manu` SSH alias in remote URLs; don't rewrite it to `github.com`.
- `.../not-manu/resume` — my resume: `current/` (LaTeX/Tectonic source of the
  live resume), `full/` (master experience/honors/LinkedIn notes), and
  `applications/` (past application essays by year).
- `-old` / `-cooked` suffixes are dead snapshots. Don't edit them.
- Other `~/Documents` folders (`Journal`, `Photos`, `YouTube`, …) are non-code.

## Shell Hygiene
- One simple command per call. No `cd`, no env prefixes, no `&&`/`;` chains —
  use absolute paths and the tool's own directory flag (`-C`, `--cwd`).
- Never feed stdin. No heredocs — write the file, then run it. Redirect
  `</dev/null` and pass the non-interactive flag (`-y`, `--batch`, `--yes`).
- Set a short `timeout` on anything unproven, and run long work in the
  background instead of sleeping in the foreground.
- Assume a hang is a hidden prompt or a permission dialog before anything
  exotic.
- Never pattern-match processes by a string your own command contains. Kill by
  exact name or PID.
- Parse machine-readable output, not pretty output — shell aliases add colour
  codes that corrupt captured paths.
- Native media tools (`ffmpeg`, `magick`) stall on their thread pools. Pin them
  to one thread, or do it in pure JS.
- If a directory itself wedges, use its real path and move to a fresh one.
- Scratch/temp files go in `./.tmp/` at the project root (create it, keep it
  git-ignored), never in the global `/tmp`.

## Notifications
- When you finish a task, run `notify "<short summary>" "<details>"` (on PATH) —
  it sends a clickable macOS notification that jumps to your tmux pane. Summary
  is a few words of what you actually did ("refactored auth"), not "done";
  details (optional) is one sentence more.
- Skip it for quick conversational replies; use it when I've likely walked away.

## Git
- Never stage, commit, or push unless I explicitly ask. I stage and review my
  own changes — read-only git (`status`, `diff`, `log`) is fine, anything that
  touches the index or history is not.

## Code Principles
- Prefer the simplest thing that works. Keep it DRY.

## Comments
- **Never write comments.** Not what, not why, no banners, no docstrings, no
  commented-out code. If a comment feels needed, the code is sloppy — rewrite it.
- Sole exception: a one-line `TODO:` for work genuinely left undone.
- Delete redundant comments in code you touch. Write one only if I ask.
