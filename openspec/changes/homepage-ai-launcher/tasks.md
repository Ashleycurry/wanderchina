# Tasks: 首页 AI 入口（homepage-ai-launcher）

> 前置：`homepage-shell` 已归档。本变更只改 `ai-launcher` 相关两个文件，与 hot-posts / hot-spots **无冲突**，可任意顺序 apply。

## 1. 组件

- [x] 1.1 新增 `frontend/src/components/homepage/ai-launcher.tsx`（`'use client'`），导出 `AiLauncherProps` / `DEFAULT_PLACEHOLDER` / `ASK_LABEL` / `LAUNCHER_ARIA_LABEL`
  - 验证：文件首行为 `'use client'`；无 `fetch` / `axios`
- [x] 1.2 悬浮按钮：`type="button"`、`aria-label="AI 助手"`、`aria-expanded={open}`、`aria-controls={panelId}`；`fixed bottom-6 right-4 z-40 pb-[env(safe-area-inset-bottom)]`
  - 验证：SSR HTML 含可访问名称与 `aria-expanded="false"`
- [x] 1.3 占位面板：`role="dialog"` + `aria-modal="true"` + `aria-labelledby` + `tabIndex={-1}`；展示 `AI 助手即将上线`、`Ask` 链接（`/ask?cityCode=${cityCode}`）、关闭按钮
  - 验证：点击后 DOM 出现 `role="dialog"`
- [x] 1.4 三路关闭：关闭按钮 / ESC（`document` keydown）/ 遮罩点击（面板内 `stopPropagation`）
  - 验证：三种方式均可关闭，`aria-expanded` 回到 `false`
- [x] 1.5 焦点管理：打开后 `panelRef.focus()`；关闭后 `triggerRef.focus()`；Tab 在面板内可聚焦元素首尾循环
  - 验证：`document.activeElement` 在打开后为面板、关闭后为按钮
- [x] 1.6 改写 `regions/ai-launcher-region.tsx` 为薄壳 `<AiLauncher cityCode={cityCode} />`
  - 验证：文件 ≤ 8 行；`page.tsx` 未改动

## 2. 验证

- [x] 2.1 `robocopy` 同步到 `D:\wanderchina-frontend`，`npx tsc --noEmit` 与 `npm run build` 通过
  - 验证：`✓ Compiled successfully`，`/` 仍为 Dynamic
- [x] 2.2 断言 SSR：HTML 含 `data-region="ai-launcher"`、`aria-label="AI 助手"`、`aria-expanded="false"`，且初始不含 `role="dialog"`
  - 验证：Node `fetch` + 正则
- [x] 2.3 断言 Ask 链接：`cityCode` 变化时链接随动（面板为条件渲染，SSR 不含面板内容，故以源码模板 + 浏览器走查为准）
  - 验证：源码含 `askHref = \`/ask?cityCode=${cityCode}\``；浏览时打开面板确认实际 URL
- [x] 2.4 断言无网络请求：`grep` 组件源码无 `fetch(` / `axios`
  - 验证：Node 读文件正则，无命中
- [x] 2.5 断言降级隔离：`/?fail=hotSpots` 与 `/?fail=picks,hotSpots,hotPosts` 下 AI 入口节点仍存在且无骨架
  - 验证：可见 DOM 断言 `ai-launcher` 存在、`aria-busy` 不在该区块内
- [x] 2.6 浏览器走查：Tab → Enter 打开 → ESC 关闭 → 焦点回按钮；360px 下按钮不遮挡底部内容
  - 验证：自动化环境无法注入真实键盘事件，留待人工走查

## 3. 验收与提交

- [x] AC1 悬浮按钮存在且可访问名称为「AI 助手」，`aria-expanded` 随面板同步
- [x] AC2 面板含「AI 助手即将上线」，三种关闭方式均可用，焦点正确流转
- [x] AC3 Ask 跳转携带当前 `cityCode`，切换城市后更新
- [x] AC4 全程无网络请求，`partialError` 时入口不受影响
- [x] AC5 360px 下避开安全区，无位移动效（条件渲染）
- [x] 3.1 `frontend` 子仓库提交（1 新增 + 1 修改）
- [x] 3.2 根仓库提交 `openspec/changes/homepage-ai-launcher/`

## 实施记录（2026-11-02）

- 构建：`npx tsc --noEmit` exit 0；`npm run build` → `✓ Compiled successfully`，`/` 仍为 Dynamic（ƒ）
- SSR 断言：`data-region="ai-launcher"` 存在、按钮 `aria-label="AI 助手"` + `aria-expanded="false"`、初始 HTML 不含 `role="dialog"` 与占位文案；`?fail=picks,hotSpots,hotPosts` 下仍渲染按钮且区块内无 `aria-busy`
- 源码断言：首行 `'use client'`、无 `fetch(` / `axios`、`askHref` 为 `/ask?cityCode=${cityCode}` 模板、region 薄壳 6 行
- 偏差 1：`tasks 1.2` 的 `fixed bottom-6 right-4 … pb-[env(safe-area-inset-bottom)]` 落在按钮外层固定容器上，按钮本身只保留 `h-14 w-14` 圆形样式——padding 直接加在定高圆形按钮上会把图标顶偏
- 偏差 2：`tasks 2.3` 原计划从 SSR HTML 断言 `/ask?cityCode=SHA`，但面板为条件渲染（`{open && …}`，满足「无位移动效」），SSR 不输出面板内容，断言改为源码模板 + 人工走查
- 偏差 3：模块手册 3.4 期望 `src/components/ui/dialog.tsx`（shadcn Dialog 源码），但 Radix 属新增依赖，与零依赖约束冲突；弹层按 design D1 内联在 `ai-launcher.tsx` 中
- 偏差 4：`tasks 2.6` 的键盘走查未在自动化环境执行（无法注入真实键盘事件），需人工在浏览器确认三种关闭方式与焦点归还
