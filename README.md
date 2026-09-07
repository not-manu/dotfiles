## manu's dotfiles

### what's in here

- **zsh** - oh my zsh + aliases + eza + zoxide + fzf + auto tmux attach
- **nvim** - nvchad based config with lsp, conform, vimtex, and some other things
- **tmux** - flexoki dark, vim keybinds, tpm
- **ghostty** - flexoki dark, jetbrainsmono nerd font, some fun cursor shaders
- **git** - delta pager, zdiff3 merge style
- **lazygit** - nvim integration
- **bat** - ansi theme
- **btop** - system monitor config
- **opencode** - ai config
- **claude** - plugin settings
- **vim** - 3 lines lol
- **karabiner** - caps→esc, ctrl+j/k → ↓/↑
- **task** - taskwarrior: `next` hides waiting/blocked, `waiting` + `blocked` reports, `who:` uda; data in `~/.local/share/task`
- **cron** - scheduled jobs. `cron/jobs.toml` says what runs and how often (`every = "5m"` or `at = "07:30"`), `cron/<job>` is the script. `cronctl sync` turns it into launchd agents, `cronctl` (or `cronctl status`) shows state + last log line, `cronctl run <job>` / `cronctl log <job>`. logs in `~/.local/state/cron/`

### setup

```bash
git clone git@github.com:not-manu/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

this will symlink everything into `~/.config/` and create the right links for apps that need their configs elsewhere (looking at you ghostty)

machine-specific stuff like tokens goes in `~/.zshrc.local` which is gitignored
