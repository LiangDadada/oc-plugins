#!/usr/bin/env bash
# Managed by oc-plugins/opencode-loop
set -euo pipefail

TARGET="${1:-}"

if [ -z "$TARGET" ]; then
  echo "Usage: ./scripts/focused.sh <test-pattern>" >&2
  exit 1
fi

if [ -f package.json ]; then
  if [ -f pnpm-lock.yaml ] && command -v pnpm >/dev/null 2>&1; then
    exec pnpm test -- "$TARGET"
  fi
  if [ -f yarn.lock ] && command -v yarn >/dev/null 2>&1; then
    exec yarn test "$TARGET"
  fi
  exec npm test -- "$TARGET"
fi

if [ -f Cargo.toml ]; then
  exec cargo test "$TARGET"
fi

if [ -f pyproject.toml ] || [ -f setup.cfg ] || [ -f setup.py ]; then
  exec python -m pytest "$TARGET"
fi

echo "No focused check backend detected. Edit scripts/focused.sh for this project." >&2
exit 1
