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
  already in the global gitignore), never in the global `/tmp`.

## Tasks (taskwarrior)
- `task` is the global task list; a per-project `TODO.md` is only for undated
  project checklists. Anything with a date, a dependency, or a "waiting on
  someone" goes in `task`, not in a markdown file.
- Config: `~/.config/task/taskrc` (dotfiles). Data: `~/.local/share/task`. An
  on-exit hook exports to `~/Documents/Projects/not-manu/taskwarrior/tasks.json`
  and commits there on its own — never commit or push that repo yourself.
- Always call it non-interactively: `task ... </dev/null`; `confirmation=off`
  is set. Deleting a recurring task still prompts — pass
  `rc.recurrence.confirmation=no`.
- Conventions: `project:<short-name>` (recruit, janestreet, openai, …);
  `due:` for real deadlines, with a time when one exists; `wait:<date>` to hide
  until relevant; `depends:<id>` for "after X"; `+waiting who:<person-or-org>`
  for anything blocked on someone else — never a `due:` on those.
- A task's working folder is an annotation (`task N annotate <path>`, `~`-prefixed),
  never part of the description. Before working on a task, `task N` and use
  the annotated path; when adding a task for a project with a folder, annotate
  it the same way.
- IDs renumber whenever the pending set changes. Re-read them from the output
  right before `task N done|modify|delete`; never reuse an id from earlier.
- Reports: `task next` (actionable — hides waiting, blocked, and pre-`wait`),
  `task waiting`, `task blocked`, `task calendar`, `task N` (info).
- When we finish something together, `task N done` it. When we notice we're
  waiting on a reply, add the `+waiting` task then. When a deadline shows up in
  an email or doc, add it with `due:` — don't leave it in prose.
- Recurring tasks are a parent template plus child instances; avoid them unless
  asked (they clutter `next` and are awkward to delete).

## Reports & Deliverables
- Don't publish Artifacts unless I explicitly ask. For reports, write-ups, and
  visual deliverables, write a local self-contained `.html` file (inline
  CSS/JS, no CDNs) next to the relevant project files and tell me the path.

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
