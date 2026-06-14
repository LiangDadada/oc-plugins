#!/usr/bin/env sh
#
# opencode-tps-summary — 一键卸载脚本
#

set -e

# ── 配置（与 install.sh 保持一致） ───────────────────────────
PLUGIN_FILE="tps-summary-sidebar.tsx"
# ─────────────────────────────────────────────────────────────

# 确定 opencode 配置目录
if [ -n "$XDG_CONFIG_HOME" ]; then
  CONFIG_DIR="$XDG_CONFIG_HOME/opencode"
else
  CONFIG_DIR="$HOME/.config/opencode"
fi

PLUGIN_DIR="$CONFIG_DIR/plugins"
PLUGIN_PATH="$PLUGIN_DIR/$PLUGIN_FILE"
TUI_JSON="$CONFIG_DIR/tui.json"
PLUGIN_REF="./plugins/$PLUGIN_FILE"

echo ">>> 卸载 opencode-tps-summary ..."

# 1. 删除插件文件
if [ -f "$PLUGIN_PATH" ]; then
  rm "$PLUGIN_PATH"
  echo ">>> 已删除 $PLUGIN_PATH"
else
  echo ">>> 插件文件不存在，跳过"
fi

# 2. 从 tui.json 移除引用
if [ -f "$TUI_JSON" ]; then
  if grep -q "$PLUGIN_REF" "$TUI_JSON" 2>/dev/null; then
    # 使用 sed 移除该条目（兼容单元素和多元素数组）
    sed -i 's|"'"$PLUGIN_REF"'"\(,\s*\)\?||' "$TUI_JSON"
    sed -i 's|\(\s*\),\s*"'"$PLUGIN_REF"'"||' "$TUI_JSON"
    # 处理空数组情况
    sed -i 's/"plugin": \[,*/"plugin": [/; s/,\s*\]/]/' "$TUI_JSON"
    echo ">>> 已从 tui.json 移除插件引用"
  else
    echo ">>> tui.json 中未找到插件引用，跳过"
  fi
fi

echo ""
echo ">>> 卸载完成！重启 opencode TUI 即可。"
