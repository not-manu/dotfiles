- [ ] nvim: clean up status bar
- [ ] nvim: figure out how to handle "auto wrapping" beyond 80 characters
- [ ] raycast: add raycast shortcuts to dotfiles
- [ ] nvim: add a more fully featured code folding setup that:
       * remembers folds per file
       * actually works with latex
- [ ] nvim: add mdx support
- [ ] nvim: working in long lines (e.g. latex) is a nightmare and extremely laggy?
- [ ] claude: remove settings from the dotfiles (it keeps updating for some reason)
- [ ] starship: eventually switch to starship?
- [ ] tmux: session switch leader + f should show number windows per session and maybe a preview as well?
- [ ] tmux: add a keybind to toggle right sidebar for agents 
- [ ] claude: add a hook to notify when a process is done (terminal bell / say [summary])
- [ ] claude: split my system prompt into files (system/tone.md, scratch.md,
      harness.md, ...) + a build script that concatenates them into the
      --system-prompt string. reference: Piebald-AI/claude-code-system-prompts
      for how anthropic fragments theirs. note --system-prompt fully replaces
      the default block (tool descriptions + system-reminders survive).

- [ ] need to standardize a spec so i can see folder descriptions in eza (cd)
      (DESCRIPTION.md) or just yaml frontmatter in README.md?
- [ ] a tmux shortcut to open project specific todos would be pretty cool (and
      the global todos as well)
- [ ] tmux: fix "emacs pinky" from the C-b prefix (pinky holds ctrl while index
      reaches inward, and it stomps on vim's page-up). options, roughly best
      first:
       * karabiner: make caps_lock dual-role — ctrl when held, esc when tapped
         (complex modification). keeps the vim esc muscle memory intact.
       * change prefix to C-Space (thumb, no vim conflict) or C-a (+ `bind C-a
         send-prefix` so readline beginning-of-line survives)
       * bigger win: cut prefix presses entirely — `bind -n M-h/j/k/l` for pane
         nav and M-H/M-L for window nav, since alt is a thumb key. already have
         M-i and C-\ prefix-less, so this fits the existing style.
       * vim-tmux-navigator so C-h/j/k/l crosses vim splits ↔ tmux panes with
         no prefix at all
- [ ] tmux: allow dots in displayed session names. real name stays sanitized
      (`.`/`:` are target separators), pretty name lives in a per-session user
      option: `set -t <sess> @display_name "copilot.vim"`. status-left renders
      `#{?#{!=:#{@display_name},},#{@display_name},#S}` instead of `#S`;
      picker.sh/windows.sh/sidebar emit `real<TAB>display`, fzf shows+matches
      the display column, acts on the real one. add a `tn` wrapper that
      sanitizes + sets the option on create. caveat: choose-tree (prefix s)
      needs a custom -F to show pretty names.
- [ ] lazygit: add a "revert TO this commit" custom command. `t` reverts a
      single commit and `g` resets (rewrites history) — neither restores the
      tree to an older commit as a new forward commit, which is the safe move
      on a pushed branch. bind `T` in the commits context to
      `git revert --no-commit {{.SelectedLocalCommit.Hash}}..HEAD` plus a
      commit with a prompted message, prefilled `revert:
      {{.SelectedLocalCommit.Name}}`. the `X..HEAD` range excludes X, so it
      collapses N commits into one revert regardless of depth — lazygit's own
      range-revert makes one commit per commit, which you then have to squash.
      note: `.Hash` supersedes the deprecated `.Sha` field (renamed ~v0.44).

**done**
- [x] tmux: remove the delay after ctrl b interrupting nvim commands (resizing is fine, but next/previous is not really necessary)
- [x] tmux: make the switching sessions fzf nicer and less in the way and minimal. kinda like telescope but for tmux sessions.
- [x] opencode: add a learn mode (gpt-5.4, openrouter). use unicode for math, not latex.
- [x] ghostty: remove unused shaders
- [x] tmux: add tmux-plugins/tmux-continuum
- [x] tmux: add tmux-plugins/tmux-resurrect
- [x] tmux: include preview when searching for processes with <C-b>f
- [x] tmux: update styling for status bar when a process is done (e.g timer is finished)
- [x] aerospace: install
- [x] aerospace: add config to dotfiles
- [x] opencode: make default ask model sonnet 4.6
- [x] remove dotfiles with basic/non-essential config (zed, codex)
- [x] nvim: autotags don't work with astro
- [x] zsh: python3 -> python
- [x] agents: add a global AGENTS.md with symlinks to CLAUDE.md
- [x] karabiner: install + config (caps→esc, ctrl+j/k → ↓/↑)
- [x] nvim: autoformat astro on save
