#!/usr/bin/env bash
set -euo pipefail

# Sync the dotfiles karabiner.json into the live config and let Karabiner
# auto-reload it.
#
# Why copy instead of symlink: Karabiner-Elements owns ~/.config/karabiner/
# karabiner.json — it rewrites the file on profile changes and replaces any
# symlink with a regular file, so a symlink from dotfiles does not survive.
# Karabiner watches this file and re-reads it automatically on change, so a
# plain copy is all that's needed — do NOT restart the daemon (that reloads
# from stale state and drops un-synced edits).

DOTFILES_JSON="$(cd "$(dirname "$0")" && pwd)/karabiner.json"
LIVE_JSON="$HOME/.config/karabiner/karabiner.json"

cp "$DOTFILES_JSON" "$LIVE_JSON"
echo "Synced karabiner.json → $LIVE_JSON (Karabiner will auto-reload)."
