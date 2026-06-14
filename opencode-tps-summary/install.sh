#!/usr/bin/env sh
#
# opencode-tps-summary — 一键安装脚本
# 用法: curl -sL https://<你的托管地址>/install.sh | sh
#

set -e

# ── 配置（改为你的实际 raw URL 前缀） ──────────────────────────
RAW_BASE="https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/opencode-tps-summary"
PLUGIN_FILE="tps-summary-sidebar.tsx"
# ─────────────────────────────────────────────────────────────

# 确定 opencode 配置目录
if [ -n "$XDG_CONFIG_HOME" ]; then
  CONFIG_DIR="$XDG_CONFIG_HOME/opencode"
else
  CONFIG_DIR="$HOME/.config/opencode"
fi

PLUGIN_DIR="$CONFIG_DIR/plugins"
TUI_JSON="$CONFIG_DIR/tui.json"

echo ">>> 安装 opencode-tps-summary ..."

# 1. 确保 plugins 目录存在
mkdir -p "$PLUGIN_DIR"

# 2. 下载插件文件
echo ">>> 下载 $PLUGIN_FILE ..."
curl -sL "$RAW_BASE/$PLUGIN_FILE" -o "$PLUGIN_DIR/$PLUGIN_FILE"
echo ">>> 已保存到 $PLUGIN_DIR/$PLUGIN_FILE"

# 3. 在 tui.json 中注册
PLUGIN_REF="./plugins/$PLUGIN_FILE"

if [ ! -f "$TUI_JSON" ]; then
  # tui.json 不存在，创建
  echo '{ "plugin": [] }' > "$TUI_JSON"
fi

# 用简单的 sh 逻辑判断是否已注册
if grep -q "$PLUGIN_REF" "$TUI_JSON" 2>/dev/null; then
  echo ">>> tui.json 中已存在该插件引用，跳过"
else
  # 使用 sed 在 "plugin" 数组末尾添加条目
  # 匹配 "plugin": [ 或 "plugin": [ ... 并在最后一个元素后添加
  if grep -q '"plugin": \[\]' "$TUI_JSON"; then
    # 空数组
    sed -i 's/"plugin": \[\]/"plugin": ["'"$PLUGIN_REF"'"]/' "$TUI_JSON"
  else
    # 非空数组，在 ] 前追加
    sed -i 's/\(.*\)"plugin": \[\(.*\)\]/\1"plugin": [\2, "'"$PLUGIN_REF"'"]/' "$TUI_JSON"
  fi
  echo ">>> 已在 tui.json 中注册 $PLUGIN_REF"
fi

echo ""
echo ">>> 安装完成！重启 opencode TUI 即可生效。"
echo "    如需卸载，执行: curl -sL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/opencode-tps-summary/uninstall.sh | sh"
