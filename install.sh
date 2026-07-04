#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "=== Dotfiles Install Script ==="
echo "Source: $DOTFILES_DIR"
echo ""

# Helper: create a symlink, backing up existing file/dir if needed
link() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "  Backing up existing $dest → ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "  Linked: $dest → $src"
}

# ---- ~/.config/ directories ----
echo "[1/4] Linking config directories into ~/.config/ ..."

config_dirs=(
  ghostty
  tmux
  nvim
  nvim-lean
  lazygit
  bat
  bin
  btop
  git
  opencode
  vim
  zsh
  aerospace
)

for dir in "${config_dirs[@]}"; do
  link "$DOTFILES_DIR/config/$dir" "$CONFIG_DIR/$dir"
done

# ---- Home directory symlinks (apps that don't support XDG) ----
echo ""
echo "[2/4] Linking shell dotfiles into ~/ ..."

link "$CONFIG_DIR/zsh/.zshrc"   "$HOME/.zshrc"
link "$CONFIG_DIR/zsh/.zshenv"  "$HOME/.zshenv"
link "$CONFIG_DIR/zsh/.profile" "$HOME/.profile"
link "$CONFIG_DIR/vim/vimrc"    "$HOME/.vimrc"

# ---- Ghostty (macOS Application Support) ----
echo ""
echo "[3/4] Linking Ghostty config into ~/Library/Application Support/ ..."

ghostty_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
mkdir -p "$ghostty_dir"
link "$CONFIG_DIR/ghostty/config"  "$ghostty_dir/config"
link "$CONFIG_DIR/ghostty/shaders" "$ghostty_dir/shaders"

# ---- Karabiner (symlink just the json — Karabiner writes other state into the dir) ----
mkdir -p "$CONFIG_DIR/karabiner"
link "$DOTFILES_DIR/config/karabiner/karabiner.json" "$CONFIG_DIR/karabiner/karabiner.json"

# ---- Herdr (symlink just the toml — herdr writes sockets/logs into the dir) ----
mkdir -p "$CONFIG_DIR/herdr"
link "$DOTFILES_DIR/config/herdr/config.toml" "$CONFIG_DIR/herdr/config.toml"

# ---- Claude (lives in ~/.<name>, not ~/.config/) ----
echo ""
echo "[4/5] Linking claude config ..."

mkdir -p "$HOME/.claude"
link "$DOTFILES_DIR/config/claude/settings.json"  "$HOME/.claude/settings.json"
link "$DOTFILES_DIR/config/claude/hooks"          "$HOME/.claude/hooks"

# ---- Global agent instructions (AGENTS.md → CLAUDE.md + OpenCode) ----
echo ""
echo "[5/5] Linking global agent instructions ..."

link "$DOTFILES_DIR/config/agents/AGENTS.md"       "$HOME/.claude/CLAUDE.md"
link "$DOTFILES_DIR/config/agents/AGENTS.md"       "$CONFIG_DIR/opencode/AGENTS.md"

# ---- .zshrc.local: gitignored secrets file kept in-repo, symlinked to ~ ----
# The source lives in config/zsh/.zshrc.local (gitignored, so a fresh clone
# won't have it) — seed it from a template if missing, then symlink.
echo ""
zshrc_local_src="$CONFIG_DIR/zsh/.zshrc.local"
if [ ! -f "$zshrc_local_src" ]; then
  cat > "$zshrc_local_src" <<'EOF'
# Machine-specific config — NOT tracked in dotfiles repo (gitignored)
# Add tokens, API keys, and local overrides here

# Anthropic API key — used by `ccm` (config/bin/ccm) to list models.
# export ANTHROPIC_API_KEY="sk-ant-..."
EOF
  echo "Created template $zshrc_local_src (add your tokens here)"
fi
link "$zshrc_local_src" "$HOME/.zshrc.local"

echo ""
echo "=== Install complete! ==="
echo ""
echo "Next steps:"
echo "  - Add tokens/secrets to ~/.zshrc.local"
echo "  - Install tmux plugins: prefix + I (in tmux)"
echo "  - Restart your terminal or run: source ~/.zshrc"
