# 实施任务 · 前端技术栈切换为 Next.js 14 App Router

> 本变更遵循「骨架占位优先」：**全程不执行 `npm install`、不下载任何依赖**。构建验证（`next build` / `next dev`）在依赖安装后另行确认。

## 验收标准（Acceptance Checklist）

- [x] AC1 目录结构：`frontend/src/app/`（`layout.tsx` / `page.tsx` / `globals.css`）、`frontend/src/components/ui/`、`frontend/src/lib/utils.ts` 存在
- [x] AC2 配置齐全：`next.config.mjs`、`tailwind.config.ts`、`postcss.config.mjs`、`components.json`、`tsconfig.json` 存在
- [x] AC3 依赖声明：`package.json` 声明 `next` 14.2.x、`react` / `react-dom` 18.3.x、`tailwindcss` ^3.4，且不含 `vite` / `@vitejs/plugin-react`
- [x] AC4 Vite 清理：`index.html`、`vite.config.ts`、`src/main.tsx`、`src/App.tsx`、`src/index.css`、`src/vite-env.d.ts` 全部删除
- [x] AC5 路由映射：`src/app/page.tsx` 为首页（`/`），`src/app/layout.tsx` 提供 `<html><body>` 并引入 `globals.css`
- [x] AC6 代理配置：`next.config.mjs` 的 rewrites 将 `/api/:path*` 指向 `http://localhost:8080/api/:path*`
- [x] AC7 Tailwind：`globals.css` 含 `@tailwind base/components/utilities` 与 shadcn 主题变量，content 覆盖 `./src/**/*.{ts,tsx}`
- [x] AC8 shadcn 骨架：`components.json` 的 aliases 指向 `@/components` 与 `@/lib/utils`，`src/lib/utils.ts` 导出 `cn()`
- [x] AC9 无下载：执行后 `frontend/node_modules` 不存在，`package-lock.json` 未新增 Next 相关条目
- [x] AC10 文档同步：`AGENTS.md` 技术选型约束、`openspec/project.md` Tech Stack、`README.md`、`start.bat`（端口 3000）
- [x] AC11 占位最小化：所有占位文件为最小合法结构，不含业务逻辑
- [x] AC12 校验：`openspec validate 0004-update-frontend-stack --strict` 通过

## 实施任务

## 1. 清理 Vite 遗留

- [x] 1.1 删除 `frontend/index.html`、`frontend/vite.config.ts`
- [x] 1.2 删除 `frontend/src/main.tsx`、`frontend/src/App.tsx`、`frontend/src/index.css`、`frontend/src/vite-env.d.ts`

## 2. Next.js 骨架占位

- [x] 2.1 创建 `frontend/next.config.mjs`：`reactStrictMode: true` + `/api` rewrites（destination 显式带 `/api`）
- [x] 2.2 改写 `frontend/tsconfig.json`：`jsx: preserve`、`moduleResolution: bundler`、`paths: { "@/*": ["./src/*"] }`、`plugins: [{ "name": "next" }]`、`include` 补 `next-env.d.ts` 与 `.next/types`
- [x] 2.3 创建 `frontend/src/app/layout.tsx`：导出 `metadata` 与默认 `RootLayout`（`html lang="zh-CN"`，`body` 引入 `globals.css`）
- [x] 2.4 创建 `frontend/src/app/page.tsx`：默认导出首页组件，hello 文案用 Tailwind 类替代行内样式
- [x] 2.5 创建 `frontend/src/app/globals.css`：Tailwind 三指令 + shadcn 主题 CSS 变量（neutral 基色）

## 3. Tailwind CSS 配置

- [x] 3.1 创建 `frontend/tailwind.config.ts`：`darkMode: "class"`、content 扫描 `./src/**/*.{ts,tsx}`、扩展 shadcn 颜色 token 与 `tailwindcss-animate` 插件
- [x] 3.2 创建 `frontend/postcss.config.mjs`（package.json 为 `type: module`，故用 .mjs）：`tailwindcss` + `autoprefixer`

## 4. shadcn/ui 骨架

- [x] 4.1 创建 `frontend/components.json`：`style: new-york`、`rsc: true`、`tsx: true`、tailwind 指向 `tailwind.config.ts` 与 `src/app/globals.css`、aliases 齐全
- [x] 4.2 创建 `frontend/src/lib/utils.ts`：`cn()`（`clsx` + `tailwind-merge`）
- [x] 4.3 创建 `frontend/src/components/ui/.gitkeep`（组件目录占位，本次不拉取任何组件）

## 5. 依赖声明（不安装）

- [x] 5.1 更新 `frontend/package.json` scripts：`dev: next dev`、`build: next build`、`start: next start`、`lint: next lint`
- [x] 5.2 按 design.md D7 更新 dependencies / devDependencies，移除 `vite` 与 `@vitejs/plugin-react`
- [x] 5.3 确认未执行安装：`frontend/node_modules` 不存在，`package-lock.json` 无 Next / Tailwind 新条目

## 6. 文档与脚本同步

- [x] 6.1 更新 `AGENTS.md` 技术选型约束：React 18.3 + Next.js 14 App Router + Tailwind 3.4 + shadcn/ui，端口 3000
- [x] 6.2 更新 `openspec/project.md` Tech Stack（前端一行）与端口约定
- [x] 6.3 更新 `README.md`：前端启动命令（`npm run dev`，3000）、目录结构说明、验证地址
- [x] 6.4 更新 `start.bat`：前端端口 3000，浏览器打开 `http://localhost:3000`（保持 GBK 编码）

## 7. 验收与提交

- [x] 7.1 对照 AC1~AC11 逐条验证并勾选
- [x] 7.2 `openspec validate 0004-update-frontend-stack --strict` 通过
- [x] 7.3 子仓库 `frontend/` 提交：`feat(0004): 切换为 Next.js 14 App Router 骨架`
- [x] 7.4 根仓库提交 gitlink 与文档变更：`chore(0004): 更新前端选型规范与子模块指针`
- [x] 7.5 记录阻塞项：依赖安装与 `next build` 验证待用户确认后执行（不阻塞本提案验收）
