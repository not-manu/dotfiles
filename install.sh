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
  lazygit
  bat
  btop
  zed
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

# ---- Codex and Claude (live in ~/.<name>, not ~/.config/) ----
echo ""
echo "[4/4] Linking codex and claude configs ..."

mkdir -p "$HOME/.codex"
mkdir -p "$HOME/.claude"
link "$DOTFILES_DIR/config/codex/config.toml"    "$HOME/.codex/config.toml"
link "$DOTFILES_DIR/config/claude/settings.json"  "$HOME/.claude/settings.json"

# ---- Create .zshrc.local if it doesn't exist ----
echo ""
if [ ! -f "$HOME/.zshrc.local" ]; then
  cat > "$HOME/.zshrc.local" <<'EOF'
# Machine-specific config — NOT tracked in dotfiles repo
# Add tokens, API keys, and local overrides here
EOF
  echo "Created empty ~/.zshrc.local (add your tokens here)"
else
  echo "~/.zshrc.local already exists, skipping"
fi

echo ""
echo "=== Install complete! ==="
echo ""
echo "Next steps:"
echo "  - Add tokens/secrets to ~/.zshrc.local"
echo "  - Install tmux plugins: prefix + I (in tmux)"
echo "  - Restart your terminal or run: source ~/.zshrc"
