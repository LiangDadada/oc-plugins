#!/usr/bin/env sh
set -eu

RAW_BASE="${RAW_BASE:-https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/clipimg}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
BIN_PATH="$INSTALL_DIR/clipimg"
OMP_AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}"
COMMAND_DIR="${OMP_COMMAND_DIR:-$OMP_AGENT_DIR/commands}"
COMMAND_PATH="$COMMAND_DIR/clipimg.md"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required to install clipimg." >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR" "$COMMAND_DIR"

tmp_bin="$(mktemp)"
tmp_command="$(mktemp)"
trap 'rm -f "$tmp_bin" "$tmp_command"' EXIT INT TERM

curl -fsSL "$RAW_BASE/clipimg" -o "$tmp_bin"
curl -fsSL "$RAW_BASE/clipimg.md" -o "$tmp_command"

chmod 0755 "$tmp_bin"
mv "$tmp_bin" "$BIN_PATH"
mv "$tmp_command" "$COMMAND_PATH"

printf '%s\n' ">>> Installed binary: $BIN_PATH"
printf '%s\n' ">>> Installed OMP slash command: $COMMAND_PATH"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    printf '%s\n' ""
    printf '%s\n' ">>> Warning: $INSTALL_DIR is not in PATH."
    printf '%s\n' '>>> Add this to your shell config:'
    printf '%s\n' '    export PATH="$HOME/.local/bin:$PATH"'
    ;;
esac

printf '%s\n' ""
printf '%s\n' ">>> Usage: restart OMP if needed, then run: /clipimg <your question>"
