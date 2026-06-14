# opencode-tps-summary

在 opencode TUI 侧边栏显示 Token 使用统计（TPS、cache hit rate 等）。

## 安装

### 一键安装（推荐）

```bash
curl -sL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/opencode-tps-summary/install.sh | sh
```

重启 opencode TUI 后生效。

### 手动安装

将 `tps-summary-sidebar.tsx` 复制到 `~/.config/opencode/plugins/`，然后在 `~/.config/opencode/tui.json` 的 `plugin` 数组中添加：

```json
"./plugins/tps-summary-sidebar.tsx"
```

## 卸载

```bash
curl -sL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/opencode-tps-summary/uninstall.sh | sh
```

## 效果

TUI 侧边栏会显示：

- **TPS** — 当前轮次的 Token 输出速率（tok/s）
- **out / in** — 当前会话累计的输出/输入 Token 数
- **hit %** — 当前轮次和整个会话的 Cache 命中率

颜色指示：绿色 ≥50，默认 ≥20，红色 <20，灰色不可用。
