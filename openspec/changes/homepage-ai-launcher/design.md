# Design: 首页 AI 入口（homepage-ai-launcher）

## D1 不引入 radix，手写轻量弹层

模块手册 3.4 期望 `src/components/ui/dialog.tsx`（shadcn Dialog 源码）。但 shadcn 的 Dialog 建立在 `@radix-ui/react-dialog` 之上，而项目约束是**零新增依赖**。

权衡：这个弹层的唯一调用方就是 AI 入口，内容是一个标题、一句文案、一个 Ask 链接和一个关闭按钮。抽成通用 `ui/dialog.tsx` 反而是过度抽象。直接在 `ai-launcher.tsx` 内实现，约 40 行。

需要的能力只有：`role="dialog"` + `aria-modal`、ESC、遮罩点击、焦点进入 / 归还、Tab 循环。全部可用原生 DOM 完成。

## D2 焦点管理的三个节点

| 时机 | 动作 |
| --- | --- |
| 打开 | `requestAnimationFrame` 后 `panelRef.current?.focus()`（面板 `tabIndex={-1}`） |
| 打开期间 | `keydown` 监听 Tab，在面板内可聚焦元素首尾循环 |
| 关闭 | `triggerRef.current?.focus()` |

焦点落在面板容器而非首个链接：屏幕阅读器会先读出 `aria-labelledby` 指向的标题，比直接跳到 Ask 链接更完整。

只在 `open === true` 时注册 `document` 级 `keydown`，关闭即移除，避免全局监听常驻。

## D3 ESC / 遮罩 / 按钮三路关闭收敛成一个 `close()`

```ts
const close = useCallback(() => setOpen(false), [])
```

三处都调它。焦点归还放在 `useEffect` 的 cleanup 里，而不是 `close()` 内：这样卸载组件时也能把焦点还回去。

## D4 状态只有一个布尔值

```ts
const [open, setOpen] = useState(false)
```

不存「是否已打开过」「面板高度」之类的派生状态。`aria-expanded={open}`、`aria-controls={panelId}` 直接从它推导。

`panelId` 用 `useId()` 生成，避免同页多个实例（虽然当前只有一个）时 id 冲突。

## D5 Ask 链接的 cityCode 不缓存

```tsx
<Link href={`/ask?cityCode=${cityCode}`}>Ask</Link>
```

每次渲染现拼，不 `useMemo`、不存 state。城市切换后 `page.tsx` 重渲染并传入新的 `cityCode`，链接自动更新——这也是规格 S6 的验证点。

## D6 定位与安全区

```
fixed bottom-6 right-4 z-40 pb-[env(safe-area-inset-bottom)]
md:bottom-8 md:right-6
```

`z-40` 低于面板遮罩的 `z-50`，高于内容层。`pb-[env(safe-area-inset-bottom)]` 是任意值类，属 Tailwind 原子类（不是 inline style），符合样式约束。

面板为全屏遮罩 + 居中卡片：`fixed inset-0 z-50 flex items-center justify-center bg-foreground/40 p-4`。

## D7 无动效即满足 reduced-motion

面板用条件渲染（`{open && ...}`）而非 CSS 过渡，没有位移或淡入。`prefers-reduced-motion` 场景下行为完全一致，不需要额外的媒体查询分支。

## D8 文案：规格写死的中文保留

| 位 | 文案 | 来源 |
| --- | --- | --- |
| 按钮可访问名称 | `AI 助手` | 主规格 Scenario / 手册 3.2 `LAUNCHER_ARIA_LABEL` |
| 面板占位文案 | `AI 助手即将上线` | 主规格 Scenario / 手册 3.2 `DEFAULT_PLACEHOLDER` |
| Ask 按钮 | `Ask` | 手册 3.2 `ASK_LABEL` |

批 3/4 其他区块用英文，但这两条是主规格的显式文本，改动会破坏已归档的 Scenario 断言，因此保留。

## 组件骨架

```tsx
'use client'

export function AiLauncher({ cityCode, askHref, placeholderText = DEFAULT_PLACEHOLDER, className }: AiLauncherProps) {
  const [open, setOpen] = useState(false)
  const panelId = useId()
  const triggerRef = useRef<HTMLButtonElement>(null)
  const panelRef = useRef<HTMLDivElement>(null)
  // D2：open 时注册 keydown（ESC + Tab 循环），cleanup 归还焦点
  // D3：close = () => setOpen(false)
  return (
    <>
      <button ref={triggerRef} type="button" aria-label={LAUNCHER_ARIA_LABEL}
        aria-expanded={open} aria-controls={panelId} onClick={() => setOpen(true)}>…</button>
      {open && (
        <div className="fixed inset-0 z-50 ..." onClick={close} role="presentation">
          <div ref={panelRef} id={panelId} role="dialog" aria-modal="true"
            aria-labelledby={`${panelId}-title`} tabIndex={-1} onClick={(e) => e.stopPropagation()}>
            …
          </div>
        </div>
      )}
    </>
  )
}
```

## 文件结构

```
frontend/src/components/homepage/
├── ai-launcher.tsx                     # 新增：'use client'
└── regions/ai-launcher-region.tsx      # 改写：薄壳
```
