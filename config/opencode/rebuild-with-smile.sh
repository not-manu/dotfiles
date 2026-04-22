#!/usr/bin/env bash
# Rebuild opencode with the smile logo patch applied.
# Usage: ./rebuild-with-smile.sh [tag]   (defaults to the upstream tag matching your current install)

set -euo pipefail

TAG="${1:-}"
SRC_DIR="${TMPDIR:-/tmp}/opencode-src"
PATCH="$(cd "$(dirname "$0")" && pwd)/smile-logo.patch"
INSTALL_BIN="$HOME/.opencode/bin/opencode"

if [[ -z "$TAG" ]]; then
  TAG="v$("$INSTALL_BIN" --version 2>/dev/null | awk '{print $1}')"
fi

rm -rf "$SRC_DIR"
git clone --depth=1 --branch "$TAG" https://github.com/sst/opencode.git "$SRC_DIR"

cd "$SRC_DIR"
git apply "$PATCH"

bun install
cd packages/opencode
OPENCODE_VERSION="${TAG#v}" bun run build --single --skip-embed-web-ui

cp "$INSTALL_BIN" "$INSTALL_BIN.bak"
cp "$SRC_DIR/packages/opencode/dist/opencode-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m | sed 's/x86_64/x64/;s/aarch64/arm64/')/bin/opencode" "$INSTALL_BIN"
chmod +x "$INSTALL_BIN"
echo "done. backup at $INSTALL_BIN.bak"
