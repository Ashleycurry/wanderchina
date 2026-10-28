# Design: 前端技术栈切换为 Next.js 14 App Router

## 目标结构

```
frontend/
├── next.config.mjs          # reactStrictMode + /api rewrites -> 8080
├── tailwind.config.ts       # content 扫描 src，shadcn 颜色 token
├── postcss.config.js        # tailwindcss + autoprefixer
├── components.json          # shadcn/ui 配置（aliases 指向 @/components、@/lib/utils）
├── tsconfig.json            # Next 插件、jsx preserve、@/* -> src/*
├── package.json             # 依赖声明（本次不安装）
└── src/
    ├── app/
    │   ├── layout.tsx       # 根布局：html/body/globals.css
    │   ├── page.tsx         # 首页 /（hello 占位）
    │   └── globals.css      # Tailwind 三指令 + shadcn 主题变量
    ├── components/
    │   └── ui/.gitkeep      # shadcn 组件目录占位
    └── lib/
        └── utils.ts         # cn() = clsx + tailwind-merge
```

## 关键决策

### D1 React 19 → 18.3.1（Next 14 的硬约束）

Next.js 14.2 的 peerDependencies 为 `react ^18.2.0`，与 React 19 不兼容。选型锁定 Next 14 就必须把 `react` / `react-dom` 降到 18.3.1，`@types/react` / `@types/react-dom` 同步降到 `^18.3`。

替代方案（未采用）：Next 15/16 + React 19 —— 与用户指定的 Next 14 冲突；若后续要回到 React 19，应单独提案升级 Next。

### D2 Tailwind CSS 3.4 而非 4.x

Tailwind 4 改为 CSS-first 配置、插件换成 `@tailwindcss/postcss`，与 Next 14 时代的工具链和 shadcn 默认模板存在版本漂移风险。选 3.4.x（`tailwind.config.ts` + `postcss` + `autoprefixer`）是最稳组合。

### D3 App Router 使用 src 目录模式

用 `src/app/` 而非根 `app/`：与现有 `src/` 习惯一致，shadcn 通过 `components.json` 的 aliases 完整支持。

目录与页面一一对应：

| 文件 | URL |
| --- | --- |
| `src/app/page.tsx` | `/` |
| `src/app/<segment>/page.tsx` | `/<segment>` |
| `src/app/layout.tsx` | 包裹所有页面（不进 URL） |

后续新增页面只加目录与 `page.tsx`，不需要维护任何路由表。

### D4 代理方式：Next rewrites

```js
// next.config.mjs
async rewrites() {
  return [{ source: '/api/:path*', destination: 'http://localhost:8080/api/:path*' }]
}
```

注意 `destination` 必须显式带 `/api`（rewrites 不会自动保留前缀）。前端调用方式不变，仍请求相对路径 `/api/...`。

### D5 端口 5173 → 3000

Next 默认 3000。`start.bat`、README、验证地址同步改为 `http://localhost:3000`；后端 8080 不变。

### D6 占位策略：骨架先行，依赖后装

用户明确要求「先用空文件占位，不要着急盲目下载」。因此：

- 只写配置文件与最小占位页面，`package.json` 仅更新依赖声明
- **不执行 `npm install`，不生成新 lock，不下载任何包**
- 页面占位保持最小合法结构：`layout.tsx` 导出 `metadata` 与默认 `RootLayout`；`page.tsx` 导出默认组件（保留 hello 文案）
- 验收截止到「文件结构与声明正确」；`next build` 与 `next dev` 验证在依赖安装后单独执行

### D7 依赖声明清单（安装时以此为准）

- dependencies：`next@14.2.x`、`react@18.3.1`、`react-dom@18.3.1`、`class-variance-authority`、`clsx`、`tailwind-merge`、`lucide-react`
- devDependencies：`typescript@~5.9`、`@types/node`、`@types/react@^18.3`、`@types/react-dom@^18.3`、`tailwindcss@^3.4`、`postcss`、`autoprefixer`、`tailwindcss-animate`

## 风险

- **Next 14 已过主流支持期**（2026 年）：安全更新与生态兼容性下降；若要长期维护，后续应提案升级 Next 15/16 + React 19
- **React 降级**：现有代码仅一个 hello 组件，无 breaking 风险；后续引入依赖 React 19 特性的库需重新评估
- **骨架期不可运行**：依赖未安装前 `next dev` / `next build` 均不可用，属预期状态而非缺陷
