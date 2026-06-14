/**
 * TPS Summary TUI Plugin — 在 sidebar 中显示 Token 使用统计
 *
 * 简化方案：直接从 api.state.session.messages() 推导，不自己维护状态。
 */

/** @jsxImportSource @opentui/solid */
import { createSignal, createMemo } from "solid-js"
import type { TuiPlugin } from "@opencode-ai/plugin/tui"

type Totals = {
  freshIn: number
  cacheIn: number
  out: number
  startTime: number
  endTime: number
}

function emptyTotals(): Totals {
  return { freshIn: 0, cacheIn: 0, out: 0, startTime: 0, endTime: 0 }
}

function msgToTotals(msg: any): Totals {
  return {
    freshIn: msg.tokens?.input ?? 0,
    cacheIn: msg.tokens?.cache?.read ?? 0,
    out: (msg.tokens?.output ?? 0) + (msg.tokens?.reasoning ?? 0),
    startTime: msg.time?.created ?? Date.now(),
    endTime: msg.time?.completed ?? Date.now(),
  }
}

function addTotals(a: Totals, b: Totals): Totals {
  return {
    freshIn: a.freshIn + b.freshIn,
    cacheIn: a.cacheIn + b.cacheIn,
    out: a.out + b.out,
    startTime: a.startTime ? Math.min(a.startTime, b.startTime) : b.startTime,
    endTime: Math.max(a.endTime, b.endTime),
  }
}

function hitRate(freshIn: number, cacheIn: number): number | undefined {
  const denom = freshIn + cacheIn
  return denom > 0 ? (cacheIn / denom) * 100 : undefined
}

function tpsOf(totals: Totals): number | undefined {
  if (totals.out <= 0) return undefined
  const elapsed = (totals.endTime - totals.startTime) / 1000
  return elapsed > 0 ? totals.out / elapsed : undefined
}

const fmt = new Intl.NumberFormat("en", {
  notation: "compact",
  maximumFractionDigits: 1,
})

const tui: TuiPlugin = async (api) => {
  const [tick, setTick] = createSignal(0)

  const unsubMsg = api.event.on("message.updated", () => {
    try {
      setTick((t) => t + 1)
    } catch {}
  })

  const unsubIdle = api.event.on("session.idle", () => {
    try {
      setTick((t) => t + 1)
    } catch {}
  })

  api.slots.register({
    order: 150,
    slots: {
      sidebar_content(_ctx, props) {
        const t = () => api.theme.current

        const stats = createMemo(() => {
          tick()

          const messages = (api.state.session.messages(props.session_id) ?? []) as any[]
          const sorted = [...messages].sort((a, b) => (a.time?.created ?? 0) - (b.time?.created ?? 0))

          const turns: Totals[] = []
          let currentTurn: Totals | null = null
          let sessionTotals = emptyTotals()

          for (const msg of sorted) {
            if (msg.role === "user") {
              if (currentTurn) turns.push(currentTurn)
              currentTurn = null
            } else if (msg.role === "assistant" && msg.tokens) {
              const mt = msgToTotals(msg)
              sessionTotals = addTotals(sessionTotals, mt)
              currentTurn = currentTurn ? addTotals(currentTurn, mt) : { ...mt }
            }
          }
          if (currentTurn) turns.push(currentTurn)

          return {
            sessionTotals,
            latest: turns.length > 0 ? turns[turns.length - 1] : null,
          }
        })

        const tpsValue = createMemo(() => {
          const latest = stats().latest
          return latest ? tpsOf(latest) : undefined
        })

        const latestHit = createMemo(() => {
          const latest = stats().latest
          return latest ? hitRate(latest.freshIn, latest.cacheIn) : undefined
        })

        const sessionHit = createMemo(() => {
          const { sessionTotals } = stats()
          return hitRate(sessionTotals.freshIn, sessionTotals.cacheIn)
        })

        const tpsColor = createMemo(() => {
          const v = tpsValue()
          if (v === undefined) return t().textMuted
          return v >= 50 ? t().success : v >= 20 ? t().text : t().warning
        })

        const latestHitColor = createMemo(() => {
          const v = latestHit()
          if (v === undefined) return t().textMuted
          return v >= 50 ? t().success : v >= 20 ? t().text : t().warning
        })

        const sessionHitColor = createMemo(() => {
          const v = sessionHit()
          if (v === undefined) return t().textMuted
          return v >= 50 ? t().success : v >= 20 ? t().text : t().warning
        })

        return (
          <box>
            <text fg={t().text}>
              TPS{" "}
              <span style={{ fg: tpsColor() }}>
                {tpsValue() === undefined ? "\u2014" : tpsValue()!.toFixed(1)}
              </span>{" "}
              tok/s
            </text>
            <text fg={t().textMuted}>
              out {fmt.format(stats().sessionTotals.out)}  in {fmt.format(stats().sessionTotals.freshIn)} / {fmt.format(stats().sessionTotals.cacheIn)}
            </text>
            <text fg={t().textMuted}>
              hit{" "}
              <span style={{ fg: latestHitColor() }}>
                {latestHit() === undefined ? "\u2014" : latestHit()!.toFixed(1)}
              </span>
              %{" "}
              sess{" "}
              <span style={{ fg: sessionHitColor() }}>
                {sessionHit() === undefined ? "\u2014" : sessionHit()!.toFixed(1)}
              </span>
              %
            </text>
          </box>
        )
      },
    },
  })

  api.lifecycle.onDispose(() => {
    unsubMsg()
    unsubIdle()
  })
}

const plugin = { id: "tps-summary-sidebar", tui }
export default plugin
