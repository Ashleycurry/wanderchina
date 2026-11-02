# Proposal: 首页 AI 入口（homepage-ai-launcher）

## Why

首页 `ai-launcher` 挂载位当前只打印「待实现」。AI 助手是产品定位的一环，但在对话能力落地前，先要把入口做对：右下角常驻按钮、可关闭的占位面板、以及携带当前城市跳转 `/ask` 的 Ask 入口。

这一块是首页唯一的 Client Component，也是唯一需要焦点管理的区块。规格对「无网络请求」「ESC / 遮罩 / 按钮三种关闭」「焦点回到触发按钮」都有硬要求，值得单独一个变更。

## What Changes

- 新增 `src/components/homepage/ai-launcher.tsx`（`'use client'`）：悬浮按钮 + `role="dialog"` 占位面板 + Ask 链接
- 手写轻量弹层（约 40 行）：`aria-modal` / ESC / 遮罩点击 / 焦点进入与归还 / 简化 Tab 循环，**不引入 `@radix-ui/react-dialog`**
- 改写 `regions/ai-launcher-region.tsx` 为薄壳 `<AiLauncher cityCode={cityCode} />`
- 不改 `load.ts` / `mock-data.ts`（与 hot-posts / hot-spots 无冲突，可任意顺序 apply）
- 规格：MODIFIED「AI 入口与 Ask 跳转」（原 2 Scenario + 无网络请求 + 切换城市携带新城市），ADDED「AI 入口无障碍与响应式」

## Impact

| 维度 | 影响 |
| --- | --- |
| capability | `homepage` |
| 新增文件 | 1（组件） |
| 修改文件 | 1（`ai-launcher-region.tsx`） |
| 共享文件冲突 | 无 |
| 新增依赖 | **无**（不 vendored shadcn `dialog.tsx`，因其依赖 `@radix-ui/react-dialog`） |
| 上游依赖 | `homepage-shell`（挂载位）、`homepage-city-grid`（`cityCode` 来源，仅约定 props） |
| 下游 | 真实对话面板由后续 spec 承接 |

## 待确认

1. **面板文案保留中文**：主规格明确写死「AI 助手即将上线」与「AI 助手」可访问名称，与批 3/4 的英文 UI 不一致。本提案按规格保留中文，只在 Ask 按钮上用英文 `Ask`。
2. **不写 `src/components/ui/dialog.tsx`**：模块手册 3.4 列了该文件，但它需要 `@radix-ui/react-dialog`。本提案改为在 `ai-launcher.tsx` 内手写弹层，规模足够小（单个调用方），避免为一个占位面板引入整个 radix 依赖。
3. **不做滚动锁定与动画**：占位面板内容极短，锁定 `body` 滚动收益低且会触碰「无 inline style」约束边界；无动画天然满足 `prefers-reduced-motion`。
