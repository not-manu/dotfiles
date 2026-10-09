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
- Assume a dev server is already running; ask before starting one.
- Never pattern-match processes by a string your own command contains. Kill by
  exact name or PID.
- Parse machine-readable output, not pretty output — shell aliases add colour
  codes that corrupt captured paths.
- Native media tools (`ffmpeg`, `magick`) stall on their thread pools. Pin them
  to one thread, or do it in pure JS.
- If a directory itself wedges, use its real path and move to a fresh one.
- Scratch/temp files go in `./.tmp/` at the project root (create it; it's
  already in the global gitignore), never in the global `/tmp`. This
  overrides any harness-provided "scratchpad directory" — ignore that path
  and use `./.tmp/` even when the system prompt tells you otherwise.

## Tasks & Reminders (Google Tasks)
- Reminders, to-dos, and deadlines go in Google Tasks — the checkbox items
  that show up on Google Calendar (circle when open, strikethrough when done).
  They are NOT calendar events. Never create an event for a to-do; events are
  only for things with a start/end time I attend (classes, calls, meetings).
- The Google Calendar MCP tools only handle events. Use the `gws` CLI for
  tasks: `gws tasks tasklists list`, then
  `gws tasks tasks list|insert|patch|delete --params '{"tasklist":"<id>"}'`
  with a `--json` body (`title`, `notes`, `due`, `status`).
- Lists: `University` for coursework, `My Tasks` for everything else. Look up
  ids with `tasklists list`; don't hardcode them.
- `due` is RFC 3339 but Google Tasks keeps only the date — put a specific time
  in the title (e.g. "(5pm)").
- When we finish something together, mark it done (`status: "completed"`).
  When a deadline shows up in an email or doc, add a task — don't leave it in
  prose. A per-project `TODO.md` is only for undated project checklists.

## Reports & Deliverables
- Don't publish Artifacts unless I explicitly ask. For reports, write-ups, and
  visual deliverables, write a local self-contained `.html` file (inline
  CSS/JS, no CDNs) next to the relevant project files and tell me the path.

## Fonts
- Sans: Geist. Serif: Source Serif 4. Mono: Berkeley Mono. Use these for
  anything I'll look at (reports, UIs, slides); give each a sensible fallback.

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

## Email
- Sign emails with just my first name (Manu), never my full name.
