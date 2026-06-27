# opencode-loop

在当前项目中快速安装一套 opencode-native software loop scaffold。

第一版安装的是 **commands + agents + skill + `.ocloop` 状态目录 + scripts**。它提供流程约束、证据记录和权限边界，但还不是 plugin 强制执行的 runtime。

## 安装

在项目根目录执行：

```bash
curl -fsSL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/opencode-loop/install.sh | sh
```

安装到指定目录：

```bash
curl -fsSL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/opencode-loop/install.sh | OPENCODE_LOOP_ROOT=/path/to/project sh
```

默认安装 namespaced commands，避免覆盖项目已有 `/review`、`/optimize` 等命令：

```text
/loop
/loop-bugfix
/loop-tdd
/loop-review
/loop-optimize
/loop-compact
```

如果确认项目没有同名短命令，可以显式安装短别名：

```bash
curl -fsSL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/opencode-loop/install.sh | OPENCODE_LOOP_INSTALL_ALIASES=1 sh
```

短别名：

```text
/bugfix
/tdd
/review
/optimize
/compact
```

## 已有 `.opencode` 时的行为

安装器只做增量合并，不覆盖整个 `.opencode` 目录。

规则：

| 情况 | 行为 |
|---|---|
| 文件不存在 | 创建 |
| 文件存在且包含 `oc-plugins/opencode-loop` marker | 更新 |
| 文件存在但没有 marker | 默认中止 |
| `OPENCODE_LOOP_FORCE=1` | 先备份为 `*.bak.<timestamp>`，再覆盖 |

因此可以安全用于已有 `.opencode` 的项目。

## 安装内容

```text
.opencode/
├── commands/
│   ├── loop.md
│   ├── loop-bugfix.md
│   ├── loop-tdd.md
│   ├── loop-review.md
│   ├── loop-optimize.md
│   └── loop-compact.md
├── agents/
│   ├── loop-planner.md
│   ├── loop-builder.md
│   ├── loop-reviewer.md
│   └── loop-acceptor.md
├── skills/
│   └── software-loop-contract/
│       └── SKILL.md
└── opencode-loop.example.jsonc

.ocloop/
├── current.json
├── opencode-loop-manifest.txt
├── run-template/
└── runs/

scripts/
├── focused.sh
├── health.sh
├── full.sh
├── benchmark.sh
└── eval.sh
```

## 使用

Bugfix：

```text
/loop-bugfix 登录后 refresh token 没有更新，auth-refresh.test.ts 失败
```

TDD：

```text
/loop-tdd 给 billing 模块增加 coupon 过期校验
```

Review：

```text
/loop-review 当前 diff，重点看 correctness/security/test coverage
```

Optimize：

```text
/loop-optimize 将 parser benchmark throughput 提升至少 10%，不能增加 p95 latency
```

Compact：

```text
/loop-compact
```

## 可选权限配置

安装器不会自动修改已有 `opencode.json`，避免破坏项目配置。

可选配置片段会安装到：

```text
.opencode/opencode-loop.example.jsonc
```

需要时手动合并到项目的 `opencode.json` 或 `opencode.jsonc`。

## 卸载

```bash
curl -fsSL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/opencode-loop/uninstall.sh | sh
```

默认只移除带 marker 的 commands、agents、skill 和 scripts，并保留 `.ocloop` 状态和证据。

同时删除 `.ocloop`：

```bash
curl -fsSL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/opencode-loop/uninstall.sh | OPENCODE_LOOP_PURGE=1 sh
```

指定目录卸载：

```bash
curl -fsSL https://raw.githubusercontent.com/LiangDadada/oc-plugins/main/opencode-loop/uninstall.sh | OPENCODE_LOOP_ROOT=/path/to/project sh
```
