## REMOVED Requirements

### Requirement: Vite + React SPA 工程可构建

（移除原因：前端技术栈切换为 Next.js 14 App Router，Vite 构建链路不再使用）

## ADDED Requirements

### Requirement: Next.js 14 App Router 工程

系统 SHALL 提供基于 Next.js 14.2 + React 18.3 + TypeScript 的前端工程，使用 App Router，依赖由 npm 管理。工程 SHALL 包含 `next.config.mjs`、`tsconfig.json`（含 `@/*` → `./src/*` 路径别名）与 `package.json` 依赖声明。

#### Scenario: 工程骨架完整

- **WHEN** 检查 `frontend/` 目录
- **THEN** 存在 `next.config.mjs`、`tsconfig.json`、`package.json`，且 `package.json` 声明 `next` 14.2.x 与 `react` / `react-dom` 18.3.x，不再包含 `vite` 与 `@vitejs/plugin-react`

#### Scenario: 生产构建通过（依赖安装后）

- **WHEN** 依赖安装完成后在 `frontend/` 下执行 `npm run build`
- **THEN** Next.js 构建成功并产出 `.next/` 目录

### Requirement: App Router 目录与页面一一对应

系统 SHALL 以 `src/app/` 目录组织页面：目录路径即 URL 路径，`page.tsx` 对应可访问页面，`layout.tsx` 为共享布局且不占用路由。

#### Scenario: 首页路由

- **WHEN** 访问 `/`
- **THEN** 渲染 `src/app/page.tsx` 导出的页面组件

#### Scenario: 根布局包裹页面

- **WHEN** 任意页面被渲染
- **THEN** 页面内容位于 `src/app/layout.tsx` 的 `<html><body>` 结构内，且全局样式 `globals.css` 已加载

### Requirement: Tailwind CSS 排版体系

系统 SHALL 使用 Tailwind CSS 3.4 作为唯一样式方案，包含 `tailwind.config.ts`、`postcss.config.js` 与 `src/app/globals.css`（含 Tailwind 指令与 shadcn 主题 CSS 变量），扫描范围覆盖 `src/**/*.{ts,tsx}`。

#### Scenario: 工具类生效

- **WHEN** 页面组件使用 Tailwind 工具类（如 `className="p-6 text-2xl"`）
- **THEN** 构建产物包含对应样式，页面按工具类声明排版

### Requirement: shadcn/ui 组件骨架

系统 SHALL 提供 shadcn/ui 接入骨架：`components.json` 配置、`src/components/ui/` 组件目录、`src/lib/utils.ts` 导出 `cn()` 合并工具。组件源码 SHALL 落在仓库内以支持直接修改。

#### Scenario: 骨架文件存在

- **WHEN** 检查前端工程
- **THEN** 存在 `components.json`（aliases 指向 `@/components` 与 `@/lib/utils`）、`src/components/ui/` 目录，且 `src/lib/utils.ts` 导出 `cn` 函数

#### Scenario: 新增组件不改库代码

- **WHEN** 后续按需引入 shadcn 组件
- **THEN** 组件源码生成在 `src/components/ui/`，可直接编辑，不依赖不可修改的黑盒 npm 包

## MODIFIED Requirements

### Requirement: 开发服务器代理后端 API

系统 SHALL 通过 `next.config.mjs` 的 rewrites 将 `/api/:path*` 代理到 `http://localhost:8080/api/:path*`，前端代码仍以相对路径 `/api/...` 调用后端，不硬编码后端地址。

#### Scenario: 代理转发

- **WHEN** 前端开发服务器运行且后端已启动，请求 `/api/health`
- **THEN** 请求被转发到后端并原样返回响应

### Requirement: 示例页面显示 hello

系统 SHALL 在首页（`src/app/page.tsx`）显示 hello 文案，开发服务器默认端口为 3000。

#### Scenario: 页面显示 hello

- **WHEN** 用户打开 `http://localhost:3000`
- **THEN** 页面显示 hello
