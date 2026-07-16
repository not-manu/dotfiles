- Use `uv` for python projects by default unless explicitly asked otherwise.
- Always use `uvx` unless explicitly asked not to do so.
- Avoid using `npm` unless explicitly asked to do so. Use `bun` or `pnpm`
  depending on the project. If unsure, use `bun`.
- Prefer `rg` (ripgrep) over `grep` for searching.
- Be brief, unless explicitly asked to be more verbose.
- IMPORTANT: Never manually edit dependency manifests (e.g. `package.json`,
  `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`) to add, remove, or
  upgrade dependencies. Always use the package manager (`bun add`, `pnpm add`,
  `uv add`, `cargo add`, `go get`, etc.) so lockfiles and resolution stay
  consistent.
- My dotfiles live in `~/.dotfiles` (`~/.claude/CLAUDE.md` symlinks to
  `~/.dotfiles/config/agents/AGENTS.md`). Edit configs there, not the
  symlink targets' copies elsewhere.

## Shell Hygiene (avoid hangs)
- Never create scripts via heredocs (`cat <<EOF`) in shell commands — a
  mangled delimiter leaves the shell waiting on stdin forever. Write files
  with the Write/Edit tool, then run them with a plain one-liner.
- Set a short explicit `timeout` on experimental/unproven commands so a hang
  costs seconds, not minutes.
- Never `sleep`-and-poll in the foreground (it's blocked anyway); run long
  commands with `run_in_background` and read their output file.
- Prefer absolute paths over `cd` — the shell's cwd is sticky between calls
  and leads to commands running in the wrong directory.

## Code Principles
- Be concise and clear in your code. Avoid unnecessary complexity.
- You don't need to write comments for every line of code. Use comments to
  explain why something is done, not what is done.
- Be as DRY (Don't Repeat Yourself) as possible. If you find yourself writing
  the same code multiple times, consider refactoring it into a function or
  module.
