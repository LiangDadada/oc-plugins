#!/usr/bin/env sh
set -eu

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
BIN_PATH="$INSTALL_DIR/clipimg"
OMP_AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}"
COMMAND_DIR="${OMP_COMMAND_DIR:-$OMP_AGENT_DIR/commands}"
COMMAND_PATH="$COMMAND_DIR/clipimg.md"
MARKER="installed by LiangDadada/oc-plugins clipimg"

if [ -f "$BIN_PATH" ]; then
  rm -f "$BIN_PATH"
  printf '%s\n' ">>> Removed binary: $BIN_PATH"
else
  printf '%s\n' ">>> Binary not installed: $BIN_PATH"
fi

if [ -f "$COMMAND_PATH" ]; then
  if grep -q "$MARKER" "$COMMAND_PATH"; then
    rm -f "$COMMAND_PATH"
    printf '%s\n' ">>> Removed OMP slash command: $COMMAND_PATH"
  else
    printf '%s\n' ">>> Kept OMP slash command without clipimg install marker: $COMMAND_PATH"
  fi
else
  printf '%s\n' ">>> OMP slash command not installed: $COMMAND_PATH"
fi
