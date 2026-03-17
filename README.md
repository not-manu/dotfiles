## manu's dotfiles

### what's in here

- **zsh** - oh my zsh + aliases + eza + zoxide + fzf + auto tmux attach
- **nvim** - nvchad based config with lsp, conform, vimtex, and some other things
- **tmux** - flexoki dark, vim keybinds, tpm
- **ghostty** - flexoki dark, jetbrainsmono nerd font, some fun cursor shaders
- **git** - delta pager, zdiff3 merge style
- **lazygit** - nvim integration
- **zed** - gruvbox dark, vim mode
- **bat** - ansi theme
- **btop** - system monitor config
- **opencode** - ai config
- **codex** - openrouter setup
- **claude** - plugin settings
- **vim** - 3 lines lol

### setup

```bash
git clone git@github.com:not-manu/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

this will symlink everything into `~/.config/` and create the right links for apps that need their configs elsewhere (looking at you ghostty)

machine-specific stuff like tokens goes in `~/.zshrc.local` which is gitignored
