#!/usr/bin/env bash
# Managed by oc-plugins/opencode-loop
set -euo pipefail

has_npm_script() {
  local script="$1"
  command -v node >/dev/null 2>&1 || return 1
  node -e 'const p=require("./package.json"); const s=p.scripts||{}; process.exit(s[process.argv[1]] ? 0 : 1)' "$script" >/dev/null 2>&1
}

run_js_script() {
  local script="$1"
  if [ -f pnpm-lock.yaml ] && command -v pnpm >/dev/null 2>&1; then
    pnpm run "$script"
    return
  fi
  if [ -f yarn.lock ] && command -v yarn >/dev/null 2>&1; then
    yarn run "$script"
    return
  fi
  npm run "$script"
}

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "== git diff whitespace check =="
  git diff --check
fi

if [ -f package.json ]; then
  for script in lint typecheck test; do
    if has_npm_script "$script"; then
      echo "== npm script: $script =="
      run_js_script "$script"
    else
      echo "== skip missing npm script: $script =="
    fi
  done
  exit 0
fi

if [ -f Cargo.toml ]; then
  echo "== cargo test =="
  cargo test
  exit 0
fi

if [ -f pyproject.toml ] || [ -f setup.cfg ] || [ -f setup.py ]; then
  echo "== pytest =="
  python -m pytest
  exit 0
fi

echo "No health check backend detected. Edit scripts/health.sh for this project." >&2
exit 1
