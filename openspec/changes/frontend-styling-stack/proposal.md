# Proposal: 前端样式技术栈基线（frontend-styling-stack）

## Why

前端样式基线目前只存在于配置文件（`tailwind.config.ts` / `globals.css` / `components.json`）与零散约定中，缺少可执行、可校验的规格。两个具体问题：

1. `frontend/src/components/ui/` 目录为空——Button / Input 尚未 vendored，而 Hero、AI 入口等 6 个模块都要用；若各模块自行实现会重复并产生风格漂移
2. 样式禁止项（CSS-in-JS、黑盒 UI 库、硬编码色值、`max-*` 断点、`.module.css`）没有形成验收口径，后续 7 个模块并行开发时极易失控

本变更把样式基线固化为「规格 + vendored 组件 + 可 grep 校验」三件套，作为其余 7 个单元的共同前置。

## What Changes

- 新增能力：`frontend-styling-stack`（ADDED）
- 规格基线：`openspec/specs/homepage/frontend-styling-stack.md`（已就位，作为验收事实来源；本变更只在其上补 delta 声明）
- 新增 vendored 组件源码：
  - `frontend/src/components/ui/button.tsx`（cva 变体 + `cn()`，shadcn new-york 等价实现）
  - `frontend/src/components/ui/input.tsx`（受控输入，`cn()` 合并，focus-visible 环）
- 配置只校验不改动（`tailwind.config.ts` / `globals.css` / `components.json` / `src/lib/utils.ts` 均已符合规格）
- 提供禁止项 grep 检查清单（写入 tasks，不新增脚本依赖）

## Impact

- 修改 capability：`frontend-styling-stack`（ADDED）
- 新增文件：`frontend/src/components/ui/button.tsx`、`frontend/src/components/ui/input.tsx`
- 不修改 `tailwind.config.ts` / `globals.css` / `components.json`（现状已合规）
- 不新增 npm 依赖（`cva`、`clsx`、`tailwind-merge`、`lucide-react` 已装）
- 后续影响：`homepage-hero` / `homepage-ai-launcher` 直接复用 Button / Input；其余模块只需引用语义令牌

## Out of Scope

- 品牌视觉定稿（Logo、主色替换、字体选型）
- 暗色模式切换器（仅保留 `.dark` 变量）
- Dialog / Sheet 等其余 shadcn 组件（由 ai-launcher 等使用方按需追加）
- 引入任何测试框架或样式检查工具
