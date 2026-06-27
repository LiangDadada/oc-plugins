#!/usr/bin/env sh
# Managed by oc-plugins/opencode-loop
set -eu

MARKER="oc-plugins/opencode-loop"
ROOT="${OPENCODE_LOOP_ROOT:-$PWD}"
PURGE="${OPENCODE_LOOP_PURGE:-0}"
MANIFEST_REL=".ocloop/opencode-loop-manifest.txt"

ROOT="$(cd "$ROOT" && pwd)"
MANIFEST_PATH="$ROOT/$MANIFEST_REL"
TMP_DIR="$(mktemp -d)"
TMP_LIST="$TMP_DIR/files.list"
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

write_fallback_list() {
  cat > "$TMP_LIST" <<'EOF'
.opencode/commands/loop.md
.opencode/commands/loop-bugfix.md
.opencode/commands/loop-tdd.md
.opencode/commands/loop-review.md
.opencode/commands/loop-optimize.md
.opencode/commands/loop-compact.md
.opencode/commands/bugfix.md
.opencode/commands/tdd.md
.opencode/commands/review.md
.opencode/commands/optimize.md
.opencode/commands/compact.md
.opencode/agents/loop-planner.md
.opencode/agents/loop-builder.md
.opencode/agents/loop-reviewer.md
.opencode/agents/loop-acceptor.md
.opencode/skills/software-loop-contract/SKILL.md
.opencode/opencode-loop.example.jsonc
scripts/focused.sh
scripts/health.sh
scripts/full.sh
scripts/benchmark.sh
scripts/eval.sh
.ocloop/current.json
.ocloop/runs/.gitkeep
.ocloop/run-template/state.json
.ocloop/run-template/task.md
.ocloop/run-template/evidence.md
.ocloop/run-template/failures.md
.ocloop/run-template/decisions.md
.ocloop/run-template/handoff.md
.ocloop/run-template/metrics.json
EOF
}

if [ -f "$MANIFEST_PATH" ] && grep -q "$MARKER" "$MANIFEST_PATH" 2>/dev/null; then
  : > "$TMP_LIST"
  while IFS= read -r LINE; do
    case "$LINE" in
      ""|'#'*) continue ;;
      *) printf '%s\n' "$LINE" >> "$TMP_LIST" ;;
    esac
  done < "$MANIFEST_PATH"
else
  echo ">>> Managed manifest not found. Falling back to known opencode-loop file list."
  write_fallback_list
fi

remove_managed_file() {
  REL="$1"
  PATHNAME="$ROOT/$REL"

  case "$REL" in
    .ocloop/*)
      if [ "$PURGE" != "1" ]; then
        echo ">>> Kept loop state file: $REL"
        return 0
      fi
      ;;
  esac

  if [ ! -e "$PATHNAME" ]; then
    echo ">>> Not installed: $REL"
    return 0
  fi

  if [ -f "$PATHNAME" ] && grep -q "$MARKER" "$PATHNAME" 2>/dev/null; then
    rm -f "$PATHNAME"
    echo ">>> Removed: $REL"
  else
    echo ">>> Kept non-managed file: $REL"
  fi
}

while IFS= read -r REL; do
  [ -n "$REL" ] || continue
  remove_managed_file "$REL"
done < "$TMP_LIST"

if [ -f "$MANIFEST_PATH" ]; then
  if [ "$PURGE" = "1" ]; then
    :
  elif grep -q "$MARKER" "$MANIFEST_PATH" 2>/dev/null; then
    rm -f "$MANIFEST_PATH"
    echo ">>> Removed manifest: $MANIFEST_REL"
  fi
fi

if [ "$PURGE" = "1" ] && [ -d "$ROOT/.ocloop" ]; then
  rm -rf "$ROOT/.ocloop"
  echo ">>> Purged loop state directory: .ocloop"
else
  echo ">>> Preserved .ocloop state. Set OPENCODE_LOOP_PURGE=1 to remove it."
fi

rmdir "$ROOT/.opencode/skills/software-loop-contract" 2>/dev/null || true
rmdir "$ROOT/.opencode/skills" 2>/dev/null || true
rmdir "$ROOT/.opencode/agents" 2>/dev/null || true
rmdir "$ROOT/.opencode/commands" 2>/dev/null || true
rmdir "$ROOT/.opencode" 2>/dev/null || true
rmdir "$ROOT/scripts" 2>/dev/null || true

cat <<EOF

>>> opencode-loop uninstalled from: $ROOT
>>> Restart opencode TUI if it is already running.
EOF
