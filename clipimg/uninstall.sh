#!/usr/bin/env sh
set -eu

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
BIN_PATH="$INSTALL_DIR/clipimg"

if [ -f "$BIN_PATH" ]; then
  rm -f "$BIN_PATH"
  printf '%s\n' ">>> Removed: $BIN_PATH"
else
  printf '%s\n' ">>> Not installed: $BIN_PATH"
fi
