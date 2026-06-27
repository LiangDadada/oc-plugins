#!/usr/bin/env sh
# Managed by oc-plugins/opencode-loop
set -eu

MARKER="oc-plugins/opencode-loop"
RAW_BASE="${RAW_BASE:-https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/opencode-loop}"
ROOT="${OPENCODE_LOOP_ROOT:-$PWD}"
FORCE="${OPENCODE_LOOP_FORCE:-0}"
INSTALL_ALIASES="${OPENCODE_LOOP_INSTALL_ALIASES:-0}"
MANIFEST_REL=".ocloop/opencode-loop-manifest.txt"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required to install opencode-loop." >&2
  exit 1
fi

mkdir -p "$ROOT"
ROOT="$(cd "$ROOT" && pwd)"

TMP_DIR="$(mktemp -d)"
TMP_LIST="$TMP_DIR/files.list"
TMP_MANIFEST="$TMP_DIR/manifest.txt"
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

cat > "$TMP_LIST" <<'EOF'
templates/opencode/commands/loop.md|.opencode/commands/loop.md|0644
templates/opencode/commands/loop-bugfix.md|.opencode/commands/loop-bugfix.md|0644
templates/opencode/commands/loop-tdd.md|.opencode/commands/loop-tdd.md|0644
templates/opencode/commands/loop-review.md|.opencode/commands/loop-review.md|0644
templates/opencode/commands/loop-optimize.md|.opencode/commands/loop-optimize.md|0644
templates/opencode/commands/loop-compact.md|.opencode/commands/loop-compact.md|0644
templates/opencode/agents/loop-planner.md|.opencode/agents/loop-planner.md|0644
templates/opencode/agents/loop-builder.md|.opencode/agents/loop-builder.md|0644
templates/opencode/agents/loop-reviewer.md|.opencode/agents/loop-reviewer.md|0644
templates/opencode/agents/loop-acceptor.md|.opencode/agents/loop-acceptor.md|0644
templates/opencode/skills/software-loop-contract/SKILL.md|.opencode/skills/software-loop-contract/SKILL.md|0644
templates/opencode/opencode-loop.example.jsonc|.opencode/opencode-loop.example.jsonc|0644
templates/scripts/focused.sh|scripts/focused.sh|0755
templates/scripts/health.sh|scripts/health.sh|0755
templates/scripts/full.sh|scripts/full.sh|0755
templates/scripts/benchmark.sh|scripts/benchmark.sh|0755
templates/scripts/eval.sh|scripts/eval.sh|0755
templates/ocloop/current.json|.ocloop/current.json|0644
templates/ocloop/runs/.gitkeep|.ocloop/runs/.gitkeep|0644
templates/ocloop/run-template/state.json|.ocloop/run-template/state.json|0644
templates/ocloop/run-template/task.md|.ocloop/run-template/task.md|0644
templates/ocloop/run-template/evidence.md|.ocloop/run-template/evidence.md|0644
templates/ocloop/run-template/failures.md|.ocloop/run-template/failures.md|0644
templates/ocloop/run-template/decisions.md|.ocloop/run-template/decisions.md|0644
templates/ocloop/run-template/handoff.md|.ocloop/run-template/handoff.md|0644
templates/ocloop/run-template/metrics.json|.ocloop/run-template/metrics.json|0644
EOF

if [ "$INSTALL_ALIASES" = "1" ]; then
  cat >> "$TMP_LIST" <<'EOF'
templates/aliases/commands/bugfix.md|.opencode/commands/bugfix.md|0644
templates/aliases/commands/tdd.md|.opencode/commands/tdd.md|0644
templates/aliases/commands/review.md|.opencode/commands/review.md|0644
templates/aliases/commands/optimize.md|.opencode/commands/optimize.md|0644
templates/aliases/commands/compact.md|.opencode/commands/compact.md|0644
EOF
fi

MANIFEST_PATH="$ROOT/$MANIFEST_REL"
CONFLICTS=0

if [ -e "$MANIFEST_PATH" ] && ! grep -q "$MARKER" "$MANIFEST_PATH" 2>/dev/null && [ "$FORCE" != "1" ]; then
  echo ">>> Conflict: $MANIFEST_REL exists but is not managed by $MARKER" >&2
  CONFLICTS=$((CONFLICTS + 1))
fi

while IFS='|' read -r SRC DEST MODE; do
  [ -n "$SRC" ] || continue
  TARGET="$ROOT/$DEST"
  if [ -e "$TARGET" ] && ! grep -q "$MARKER" "$TARGET" 2>/dev/null && [ "$FORCE" != "1" ]; then
    echo ">>> Conflict: $DEST exists and is not managed by $MARKER" >&2
    CONFLICTS=$((CONFLICTS + 1))
  fi
done < "$TMP_LIST"

if [ "$CONFLICTS" -ne 0 ]; then
  cat >&2 <<EOF

Install aborted to avoid overwriting existing project files.

Options:
  - Keep safe namespaced commands only: unset OPENCODE_LOOP_INSTALL_ALIASES if aliases caused conflicts.
  - Backup and overwrite conflicts: OPENCODE_LOOP_FORCE=1 sh install.sh
  - Choose another project: OPENCODE_LOOP_ROOT=/path/to/project sh install.sh
EOF
  exit 1
fi

printf '%s\n' "# Managed by $MARKER" > "$TMP_MANIFEST"
printf '%s\n' "# Root: $ROOT" >> "$TMP_MANIFEST"
printf '%s\n' "# Installed files:" >> "$TMP_MANIFEST"

TIMESTAMP="$(date +%Y%m%d%H%M%S)"

while IFS='|' read -r SRC DEST MODE; do
  [ -n "$SRC" ] || continue
  TARGET="$ROOT/$DEST"
  DOWNLOAD="$TMP_DIR/$(basename "$DEST").download"

  curl -fsSL "$RAW_BASE/$SRC" -o "$DOWNLOAD"

  if [ -e "$TARGET" ] && ! grep -q "$MARKER" "$TARGET" 2>/dev/null && [ "$FORCE" = "1" ]; then
    BACKUP="$TARGET.bak.$TIMESTAMP"
    cp -p "$TARGET" "$BACKUP"
    echo ">>> Backed up unmanaged file: $BACKUP"
  fi

  mkdir -p "$(dirname "$TARGET")"
  cp "$DOWNLOAD" "$TARGET"
  chmod "$MODE" "$TARGET"
  printf '%s\n' "$DEST" >> "$TMP_MANIFEST"
  echo ">>> Installed: $DEST"
done < "$TMP_LIST"

mkdir -p "$(dirname "$MANIFEST_PATH")"
cp "$TMP_MANIFEST" "$MANIFEST_PATH"
chmod 0644 "$MANIFEST_PATH"
echo ">>> Installed manifest: $MANIFEST_REL"

cat <<EOF

>>> opencode-loop installed in: $ROOT
>>> Commands installed:
    /loop
    /loop-bugfix
    /loop-tdd
    /loop-review
    /loop-optimize
    /loop-compact
EOF

if [ "$INSTALL_ALIASES" = "1" ]; then
  cat <<'EOF'
>>> Short aliases installed:
    /bugfix /tdd /review /optimize /compact
EOF
else
  cat <<'EOF'
>>> Short aliases not installed. To install them:
    OPENCODE_LOOP_INSTALL_ALIASES=1 sh install.sh
EOF
fi

cat <<'EOF'
>>> Restart opencode TUI if it is already running.
>>> Optional permission snippet: .opencode/opencode-loop.example.jsonc
>>> Uninstall:
    curl -fsSL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/opencode-loop/uninstall.sh | sh
EOF
