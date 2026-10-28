# Proposal: 前端技术栈切换为 Next.js 14 App Router

## Why

当前前端是 Vite 7 + React 19 的单页 SPA：只有 `src/App.tsx` 一个页面，没有路由、没有样式体系、没有组件库。随着业务（如 Todo 模块）推进，三处缺口会持续放大成本：

- **页面组织**：无路由，新增页面只能靠条件渲染堆在一个入口里
- **样式**：行内样式 + 单个 `index.css`，没有设计 token 与复用机制
- **组件**：没有组件层，要么手写重复结构，要么引入不可改源码的黑盒 UI 库

Next.js 14 App Router + Tailwind CSS + shadcn/ui 正好对应这三层：目录即路由、工具类排版、组件源码进仓库可直接改。

## What Changes

### 技术选型（新基线）

| 层 | 旧 | 新 | 职责 |
| --- | --- | --- | --- |
| 框架 | React 19.2.8（纯 SPA） | React 18.3.1 + Next.js 14.2.x | React 负责组件拆分；Next.js 负责路由与页面组织 |
| 路由 | 无 | App Router | 目录与页面一一对应 |
| 语言 | TypeScript 5.9 | TypeScript 5.9（不变） | 类型约束 |
| 样式 | 行内样式 + index.css | Tailwind CSS 3.4 | 快速排版 |
| 组件 | 无 | shadcn/ui | 可直接改源码的组件骨架 |
| 构建 | Vite 7 | Next.js（`next build`） | — |
| 端口 | 5173 | 3000 | Next 默认 |

> React 从 19 降到 18.3 是 Next.js 14 的硬约束（其 peerDependencies 为 `react ^18.2.0`），详见 design.md D1。

### 包含（In Scope）

- 工程结构切换：`src/app/`（App Router）、`src/components/ui/`（shadcn 组件目录）、`src/lib/utils.ts`（`cn()` 工具）
- 配置文件占位：`next.config.mjs`（含 `/api` → 8080 rewrites）、`tailwind.config.ts`、`postcss.config.js`、`components.json`、`tsconfig.json`（Next 插件 + `@/*` 别名）
- 页面占位：`src/app/layout.tsx`（根布局）、`src/app/page.tsx`（首页，保留 hello）、`src/app/globals.css`（Tailwind 指令 + shadcn 主题变量）
- `package.json` 依赖声明更新（Next 14.2 / React 18.3 / Tailwind 3.4 / shadcn 运行时依赖）
- 移除 Vite 遗留：`index.html`、`vite.config.ts`、`src/main.tsx`、`src/App.tsx`、`src/index.css`、`src/vite-env.d.ts`
- 规范同步：`AGENTS.md` 技术选型约束、`openspec/project.md` Tech Stack、`README.md`、`start.bat`（端口 3000）

### 不包含（Out of Scope）

- **依赖安装与 lock 生成：本变更不执行 `npm install`，不下载任何包**（用户明确要求「不要着急盲目下载」）
- shadcn/ui 组件实际拉取：本次只建 `components/ui/` 骨架与 `components.json`，组件按需后续引入
- 业务页面（Todo 前端页面另行提案）
- 样式主题定制、暗色模式落地
- 后端任何改动（8080 与 `/api` 契约不变）
- Next.js 15/16 与 React 19（按用户指定锁定 Next 14）

## Impact

- 修改 capability：`frontend-scaffold`（Vite SPA → Next.js App Router）
- 受影响文件：`frontend/` 全部工程文件；`AGENTS.md`、`openspec/project.md`、`README.md`、`start.bat`
- 状态影响：本变更完成后前端处于「骨架就绪、依赖未装」状态，`next dev` / `next build` 暂不可用，直到执行依赖安装（需用户另行确认）
