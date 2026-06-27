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

if [ -f package.json ] && has_npm_script benchmark; then
  run_js_script benchmark
  exit 0
fi

if [ -f Cargo.toml ]; then
  cargo bench
  exit 0
fi

echo "No benchmark backend detected. Edit scripts/benchmark.sh for this project." >&2
exit 1
