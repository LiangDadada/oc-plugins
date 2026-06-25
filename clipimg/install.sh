#!/usr/bin/env sh
set -eu

RAW_BASE="https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/clipimg"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
BIN_PATH="$INSTALL_DIR/clipimg"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required to install clipimg." >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT INT TERM

curl -fsSL "$RAW_BASE/clipimg" -o "$tmp"
chmod 0755 "$tmp"
mv "$tmp" "$BIN_PATH"

printf '%s\n' ">>> Installed: $BIN_PATH"

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
printf '%s\n' ">>> Usage: copy an image on Windows, then run: clipimg"
