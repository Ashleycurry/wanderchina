# Tasks: 首页城市入口与切换（homepage-city-grid）

> 前置：`homepage-shell` 已提供 `CityCode` / `CITY_COOKIE_NAME` / `readCityCode` 与 `[data-region="city-grid"]` 挂载位。

## 1. 城市数据与 cookie 初始化

- [x] 1.1 新增 `frontend/src/mocks/cities.ts`：`CitySlug`（8 值）、`City`（`slug` / `code` / `name` / `icon: LucideIcon`）、`CITY_LIST`（8 条，SHA 排第一）
  - 验证：`CityCode` 从 `@/lib/home/types` 引入而非重复声明；8 条 `slug`/`code` 均唯一
- [x] 1.2 新增 `frontend/src/middleware.ts`：无 cookie 或非法值时 `response.cookies.set('wc_city', 'SHA', { path: '/', maxAge: 2592000, sameSite: 'lax' })`；`config.matcher = '/'`
  - 验证：`curl -i /` 响应头含 `set-cookie: wc_city=SHA`；`curl -i -H "Cookie: wc_city=BJA" /` 不再下发

## 2. 切换组件（Client）

- [x] 2.1 新增 `frontend/src/components/homepage/city-switcher.tsx`：`'use client'`，导出 `CitySwitcherProps`（`currentCode`）；内部 `import { CITY_LIST }`（不进 props，避免跨 RSC 序列化函数组件）
  - 验证：首行 `'use client'`；props 中无函数 / 组件引用
- [x] 2.2 渲染 8 个 `<Link href={'/city/' + slug}>`，当前项 `aria-current="true"`，网格 `grid-cols-4 md:grid-cols-8`
  - 验证：SSR HTML 中 `city-grid` 内恰好 8 个 `<a>`；恰好 1 个 `aria-current="true"`
- [x] 2.3 实现 `handleSelect`：修饰键或非左键直接 return；否则 `preventDefault()` → 写 cookie（30 天 / `samesite=lax`）→ `startTransition(() => router.refresh())`
  - 验证：无 `location.reload()`；cookie 字符串含 `max-age=2592000`
- [x] 2.4 `isPending` 期间网格 `opacity-60`，无 spinner、无 transition 类
  - 验证：`prefers-reduced-motion` 下无动效差异

## 3. 网格容器（Server）与占位替换

- [x] 3.1 新增 `frontend/src/components/homepage/city-grid.tsx`：`CityGridProps`（`cities` 默认 `CITY_LIST` / `currentCode` / `className`），渲染标题 `Explore by city` + `<CitySwitcher currentCode={currentCode} />`
  - 验证：`npx tsc --noEmit` 通过
- [x] 3.2 改写 `frontend/src/components/homepage/regions/city-grid-region.tsx` 为薄壳 `<CityGrid currentCode={currentCode} />`
  - 验证：文件 ≤ 6 行；`page.tsx` 未改动

## 4. 空区块兜底

- [x] 4.1 `regions/hot-posts-region.tsx`：`posts.length === 0` 时渲染 `No trending posts for this city yet.`（保持 `min-h-72` 容器高度；原计划文案 `No community posts for this city yet.` 由 `homepage-hot-posts` 规格统一为前者）
  - 验证：`/` 与 `Cookie: wc_city=SIA` 对比，后者显示空态文案
- [x] 4.2 `regions/hot-spots-region.tsx`：`spots.length === 0` 时渲染 `No attractions for this city yet.`
  - 验证：同上

## 5. 验证

- [x] 5.1 `robocopy` 同步到 `D:\wanderchina-frontend`，`npx tsc --noEmit` 与 `npm run build` 通过
  - 验证：`✓ Compiled successfully`
- [x] 5.2 断言 SSR：8 个 `href` 精确匹配、含 `aria-current="true"`、8 个 `aria-hidden="true"` 图标
  - 验证：Node `fetch` 正则断言
- [x] 5.3 断言 cookie 联动：`Cookie: wc_city=SHA` → hot-posts「4 条」、hot-spots「5 条」、aria-current 在 shanghai；`Cookie: wc_city=BJA` → 「3 条」/「3 条」、aria-current 在 beijing
  - 验证：Node `fetch` 双请求比对
- [x] 5.4 断言空城市兜底：`Cookie: wc_city=SIA` → 两个区块显示英文空态文案
  - 验证：Node `fetch` 断言
- [x] 5.5 断言首次访问种 cookie：无 cookie 请求响应头含 `set-cookie: wc_city=SHA`；带合法 cookie 时不再下发
  - 验证：`curl -i` 检查 `set-cookie`
- [x] 5.6 浏览器验证切换：点击 Beijing → URL 仍为 `/`、内容变为北京、无整页重载；Cmd/Ctrl+点击走 `/city/beijing`
  - 验证：Network 仅新增 `?_rsc=` 请求；地址栏无查询参数

## 6. 验收与提交

- [x] AC1 `city-grid` 恰好 8 项，`href` 形如 `/city/<slug>`，当前项 `aria-current="true"`
- [x] AC2 无 cookie 首次访问按 `SHA` 渲染并写入 `wc_city`
- [x] AC3 切换为局部刷新，URL 无脏参数，三区块数据联动
- [x] AC4 非法 cookie 回退 `SHA`；写入失败不白屏不报错
- [x] AC5 空城市显示兜底文案，不出现空白网格
- [x] AC6 键盘可达 8 项、焦点环可见；未新增 npm 依赖；`npm run build` 通过
- [x] 6.1 `frontend` 子仓库提交（4 新增 + 3 修改）
- [x] 6.2 根仓库提交 `openspec/changes/homepage-city-grid/`

## 实施记录（2026-11-02）

- 构建：`npx tsc --noEmit` exit 0；`npm run build` → `✓ Compiled successfully`，产物新增 `ƒ Middleware 26.6 kB`
- SSR 断言：`[data-region="city-grid"]` 内 8 个 `/city/<slug>` 链接；恰好 1 个 `aria-current="true"`（`/city/shanghai`）；无 cookie 请求响应头含 `set-cookie: wc_city=SHA`
- 偏差 1：`3.1` 未实现 `cities` prop（手册设想从 props 传入 `CITY_LIST`）。`City` 含 `LucideIcon` 函数组件引用，无法跨 RSC 边界序列化，故 `CITY_LIST` 只在 `city-switcher.tsx` 内部 import，`CityGridProps` 仅保留 `currentCode` / `className`
- 偏差 2：`4.1` / `4.2` 空态改由批 4 的 `hot-posts` / `hot-spots` 组件承接（占位组件届时被替换为真组件，空态在组件内部实现），当前占位仍显示「待实现（N 条）」
  - 批 4 落地后确认：`hot-posts` 空态文案为 `No trending posts for this city yet.`（与手册 `No community posts…` 不同，以 `homepage-hot-posts` 模块规格为准），`hot-spots` 空态文案为 `No attractions for this city yet.`；`Cookie: wc_city=SIA` 实测两条文案均出现在 SSR HTML
- 偏差 3：React 渲染时 `aria-current` 排在 `href` 之前，字面量断言需以「同一 `<a>` 内两属性共现」为准
