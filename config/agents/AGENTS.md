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

