# Tasks: 首页骨架与聚合契约（homepage-shell）

> 前置：`frontend-styling-stack` 已落地（重试按钮复用 `@/components/ui/button`）。
>
> 实施记录（2026-11-02）：
> - `tsc --noEmit` exit 0；`next build` → `✓ Compiled successfully`（`/` 与 `/api/home` 均为 ƒ Dynamic）
> - 页面：200，6 个 `data-region` 顺序 hero → feature-nav → city-grid → hot-posts → hot-spots → ai-launcher，`<title>` 含 WanderChina
> - `/api/home?cityCode=SHA`：`picks=2`、`positions=[1,2]`、无 `status` 字段泄露、`hotSpots=5`、`hotPosts=4`
> - `/api/home`（无参数）：`cityCode=SHA`
> - `/api/home?cityCode=BJA&fail=hotSpots`：`hotSpots=[]`、`partialError.hotSpots=true`、`hotPosts=3`
> - `/api/home?fail=picks,hotSpots,hotPosts`：`partialError` 三键均为 true
> - `/?fail=hotSpots`：可见 DOM 中 hot-spots 换为 12 个骨架块 + 1 个重试按钮，hot-posts 正常渲染
> - 偏差 1：`picks` 在 6 个区块中无独立挂载位，页面实际只包裹 2 个数据区块（hot-posts / hot-spots）
> - 偏差 2：`readCityCode` 实现为纯函数（入参 `string | null | undefined`），而非入参 cookies 对象
> - 偏差 3：视口用等效 iframe 测量（浏览器工具无 viewport 接口），截图能力超时未产出

## 1. 数据层与类型

- [x] 1.1 新增 `frontend/src/lib/home/types.ts`：`CityCode`（8 值）、`EditorPick`（6 必填字段 + `position`）、`HomeResponse`（含 `partialError`）、`RegionKey`（6 值）
  - 验证：`npx tsc --noEmit` 通过
- [x] 1.2 新增 `frontend/src/lib/home/city.ts`：`CITY_COOKIE_NAME='wc_city'`、`DEFAULT_CITY_CODE='SHA'`、`CITY_CODES` 常量、`readCityCode(raw)`（非法/缺失回退 SHA）
  - 验证：经 `/api/home` 间接断言 —— 合法 `SHA` 回显、非法值回退 `SHA`、缺失回退 `SHA`
- [x] 1.3 新增 `frontend/src/lib/home/mock-data.ts`：`MOCK_HOME`，SHA 含 3 picks（1 条失效 guide）+ 5 hotSpots + 4 hotPosts，BJA 含 2/3/3，其余 6 城空数组
  - 验证：读文件确认三城形态与失效样例存在
- [x] 1.4 新增 `frontend/src/lib/home/load.ts`：`loadHome(cityCode, opts)` → 过滤失效 picks、按 `position` 升序、`opts.fail` 注入空数组 + `partialError`
  - 验证：`/api/home?cityCode=SHA` 断言 picks=2（3 减 1 失效）且 `positions=[1,2]`；`fail=hotSpots` 时数组空且标记 true

## 2. 接口契约桩

- [x] 2.1 新增 `frontend/src/app/api/home/route.ts`：`GET` 读取 `searchParams.cityCode` → 缺省回退 cookie/`SHA`，`fail` 参数逗号分隔，返回 `NextResponse.json(loadHome(...))`
  - 验证：`npm run build` 通过
- [x] 2.2 契约断言（本地 start 后 curl）
  - `curl "http://localhost:3000/api/home?cityCode=SHA"` → `picks` 长度 2 且 position 升序
  - `curl "http://localhost:3000/api/home"` → `cityCode` 为 `SHA`
  - `curl "http://localhost:3000/api/home?cityCode=BJA&fail=hotSpots"` → `hotSpots=[]` 且 `partialError.hotSpots=true`

## 3. 骨架与占位

- [x] 3.1 新增 `frontend/src/components/homepage/regions/` 下 6 个占位组件（`hero-region.tsx` / `feature-nav-region.tsx` / `city-grid-region.tsx` / `hot-posts-region.tsx` / `hot-spots-region.tsx` / `ai-launcher-region.tsx`），每个为带 `min-h` 的占位块 + 归属模块注释
  - 验证：6 个文件存在，单文件 ≤ 10 行
- [x] 3.2 改写 `frontend/src/app/page.tsx`：Server Component，`<main className="mx-auto w-full max-w-screen-md px-4 md:px-6">` 内按序渲染 6 个 `<section data-region="...">`，挂载对应占位组件
  - 验证：页面 HTML 中 6 个 `data-region` 顺序正确
- [x] 3.3 修改 `frontend/src/app/layout.tsx`：`description` 改为面向入境游客的文案（保留 title 含 WanderChina）
  - 验证：`curl /` 的 `<head>` 含新 description

## 4. 降级容器

- [x] 4.1 新增 `frontend/src/components/homepage/region-boundary.tsx`：`'use client'`，导出 `RegionBoundaryProps`（`loading?` / `error?` / `onRetry?` / `skeleton?` / `children`）
  - 验证：文件首行 `'use client'`，类型导出存在
- [x] 4.2 实现骨架档位：`text-block`（`min-h-24`）、`card-row`（`min-h-40`）、`card-grid`（`min-h-72`），均带 `animate-pulse` 占位块
  - 验证：切档位无 TS 错误，类名符合 styling-stack 约束
- [x] 4.3 实现重试：`useRouter()`，默认 `router.refresh()`；`onRetry` 存在时优先调用；按钮为 `Button variant="outline"`，`disabled` 于 `loading` 期间，支持 Enter/Space
  - 验证：按钮为原生 `<button type="button">`、`tabIndex=0`、全页唯一可聚焦元素；`.focus()` 后 `:focus-visible=true` 且焦点环可见；触发后仅新增 `GET /?fail=hotSpots&_rsc=...` 200，无整页导航。真实 Tab/Enter 注入受浏览器工具限制，待人工复核
- [x] 4.4 `page.tsx` 中数据区块包 `RegionBoundary`，按 `partialError` 传 `error`，按区块选骨架档位
  - 说明：`picks` 无独立挂载位，本期包裹 `hot-posts` / `hot-spots` 两个区块
  - 验证：`?fail=hotSpots` 时仅该区块骨架 + 重试

## 5. 验证

- [x] 5.1 同步 NTFS 副本：`robocopy frontend D:\wanderchina-frontend /MIR /XD node_modules .next .git`，`npm run build` 通过
  - 验证：`✓ Compiled successfully`
- [x] 5.2 `npm run start` 后 `curl http://localhost:3000/` 断言：200、6 个 `data-region`、顺序正确、`<title>` 含 `WanderChina`
  - 验证：`HTTP=200`、`REGIONS(6)=hero > feature-nav > city-grid > hot-posts > hot-spots > ai-launcher`、`TITLE=WanderChina`
- [x] 5.3 全失败路径：`/api/home?fail=picks,hotSpots,hotPosts` 返回 200 且三键均在 `partialError`；页面仍 200 并显示骨架
  - 验证：三键均为 true；`/?fail=hotSpots` 页面 200 且 hot-spots 显示骨架（picks 无挂载位，页面可降级区块为 2 个）
- [x] 5.4 视口 360 / 768 / 1440 三档检查无横向滚动、`md` 以上容器居中
  - 验证：等效 iframe 测量 `scrollWidth === clientWidth`（345 / 753 / 1425），越界元素 0；截图工具超时未产出，待人工补截图

## 6. 验收与提交

- [x] AC1 `GET /` 200，6 个 `data-region` 顺序正确（hero → feature-nav → city-grid → hot-posts → hot-spots → ai-launcher）
- [x] AC2 `picks` 升序、失效剔除不补位、`cityCode` 回退与回显正确
- [x] AC3 `partialError` 单区块与全失败路径均符合规格
- [x] AC4 骨架 + 重试可聚焦触发，无整页错误页
- [x] AC5 `page.tsx` 不 import 任何区块实现；未新增 npm 依赖
- [x] AC6 `npm run build` 通过
- [x] 6.1 `frontend` 子仓库提交（12 新增 + 2 修改）
- [x] 6.2 根仓库提交 `openspec/changes/homepage-shell/`（proposal + design + spec + tasks）
