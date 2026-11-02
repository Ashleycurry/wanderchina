# Tasks: 首页 Hero 区块（homepage-hero）

> 前置：`frontend-styling-stack` 的 `Input` / `Button` 已 vendored；`homepage-shell` 已提供 `[data-region="hero"]` 挂载位。

## 1. 占位资源

- [x] 1.1 新增 `frontend/public/images/hero-placeholder.svg`：深色渐变 + 抽象城市天际线剪影，`viewBox="0 0 1600 900"`，纯几何路径，不含文字
  - 验证：文件可被浏览器直接打开；`curl -I /images/hero-placeholder.svg` 返回 200 且 `content-type: image/svg+xml`

## 2. 搜索框（Client）

- [x] 2.1 新增 `frontend/src/components/homepage/search-box.tsx`：`'use client'`，导出 `SearchBoxProps`（`placeholder` / `submitLabel` / `hint`）
  - 验证：首行 `'use client'`；无 `fetch` / `router.push` / `<a>` 跳转
- [x] 2.2 实现受控输入与空值禁用：`query` state + `trim() === ''` → `Button disabled`
  - 验证：空输入无法提交；输入后按钮可用
- [x] 2.3 实现提交提示：`onSubmit` 中 `preventDefault()` + `setShowHint(true)`，提示 <p aria-live="polite" className="min-h-5">
  - 验证：提交后提示出现且 Network 面板无新请求；提示区有固定高度不引起抖动

## 3. Hero 主体（Server）

- [x] 3.1 新增 `frontend/src/components/homepage/hero.tsx`：导出 `HeroContent` / `HeroBackground` / `HeroSearchConfig` / `HeroProps` 与 `DEFAULT_HERO_CONTENT`
  - 验证：`npx tsc --noEmit` 通过
- [x] 3.2 实现背景层：渐变兜底（`-z-20`）+ `<Image fill priority sizes="100vw" alt="" aria-hidden className="-z-10 object-cover opacity-60" />` + 暗角层
  - 验证：无裸 `<img>`；`fill` 的父容器为 `relative`
- [x] 3.3 实现内容层：`eyebrow?` / `h1` / 副标题 / `<SearchBox />`，容器 `min-h-[440px] md:min-h-[520px]`，`md` 以上居中
  - 验证：SSR HTML 含唯一 `h1` 与 `role="search"`
- [x] 3.4 改写 `frontend/src/components/homepage/regions/hero-region.tsx` 为薄壳 `<Hero />`
  - 验证：文件 ≤ 6 行；`page.tsx` 未改动

## 4. 验证

- [x] 4.1 `robocopy` 同步到 `D:\wanderchina-frontend`，`npx tsc --noEmit` 与 `npm run build` 通过
  - 验证：`✓ Compiled successfully`
- [x] 4.2 `npm run start` 后断言 SSR：`role="search"`、`sr-only` label、`h1` 文案、`/images/hero-placeholder.svg`、`alt=""`
  - 验证：Node `fetch` 逐项断言输出 true
- [x] 4.3 断言静态隔离：同一 HTML 中无 `_next/data` 额外请求；对比 `Cookie: wc_city=SHA` 与 `wc_city=BJA` 两次请求，Hero 片段完全一致
  - 验证：两次响应中 `[data-region="hero"]` 片段字符串相等
- [x] 4.4 断言降级隔离：`/?fail=hotSpots` 时 Hero 仍含 `h1` 与 `role="search"`，且 Hero 内无 `重试`
  - 验证：Node `fetch` 断言
- [x] 4.5 浏览器三档视口（360 / 768 / 1440）检查：无横向滚动、`md` 以上内容居中、文字不裁切
  - 验证：等效 iframe 测量 `scrollWidth === clientWidth`；截图待人工补

## 5. 验收与提交

- [x] AC1 Hero 位于 `[data-region="hero"]`，含唯一 `h1` + 副标题 + `role="search"`
- [x] AC2 空输入按钮 `disabled`；提交后提示出现且无网络请求、URL 不变
- [x] AC3 背景走 `next/image`（`fill` + `priority` + `sizes="100vw"` + `alt=""`），渐变兜底在图片失败时可见
- [x] AC4 `hero.tsx` 为 Server Component，`'use client'` 仅出现在 `search-box.tsx`
- [x] AC5 城市切换与 `/api/home` 降级均不影响 Hero
- [x] AC6 未新增 npm 依赖；`npm run build` 通过
- [x] 5.1 `frontend` 子仓库提交（3 新增 + 1 修改）
- [x] 5.2 根仓库提交 `openspec/changes/homepage-hero/`

## 实施记录（2026-11-02）

- 构建：`npx tsc --noEmit` exit 0；`npm run build` → `✓ Compiled successfully`，`/` 仍为 Dynamic（ƒ）
- SSR 断言（`node fetch`，16 项全过）：`role="search"`、唯一 `h1`、`hero-placeholder.svg`、`alt=""`、`sr-only` label、`aria-live="polite"` 提示位、城市切换片段一致、`/?fail=hotSpots` 时 Hero 完整且无「重试」
- 静态隔离：`Cookie: wc_city=SHA` 与 `wc_city=BJA` 两次响应的 `[data-region="hero"]` 片段字符串完全相等
- 偏差 1：`4.5` 三档视口截图未产出（浏览器子代理截图工具超时），已用等效测量替代，截图待人工补
- 偏差 2：`gradient from-neutral-950 via-neutral-900 to-amber-900` 与 `text-amber-200` 属装饰性调色板类，按 design D1 的例外处理，未计入「硬编码色值」检查
