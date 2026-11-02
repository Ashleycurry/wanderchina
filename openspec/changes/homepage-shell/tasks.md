# Tasks: 首页骨架与聚合契约（homepage-shell）

> 前置：`frontend-styling-stack` 已落地（重试按钮复用 `@/components/ui/button`）。

## 1. 数据层与类型

- [ ] 1.1 新增 `frontend/src/lib/home/types.ts`：`CityCode`（8 值）、`EditorPick`（6 必填字段 + `position`）、`HomeResponse`（含 `partialError`）、`RegionKey`（6 值）
  - 验证：`npx tsc --noEmit` 通过
- [ ] 1.2 新增 `frontend/src/lib/home/city.ts`：`CITY_COOKIE_NAME='wc_city'`、`DEFAULT_CITY_CODE='SHA'`、`CITY_CODES` 常量、`readCityCode(cookies)`（非法/缺失回退 SHA）
  - 验证：单测式断言或临时脚本验证 4 种输入（合法 / 非法 / 缺失 / 空串）
- [ ] 1.3 新增 `frontend/src/lib/home/mock-data.ts`：`MOCK_HOME`，SHA 含 3 picks（1 条失效 guide）+ 5 hotSpots + 4 hotPosts，BJA 含 2/3/3，其余 6 城空数组
  - 验证：读文件确认三城形态与失效样例存在
- [ ] 1.4 新增 `frontend/src/lib/home/load.ts`：`loadHome(cityCode, opts)` → 过滤失效 picks、按 `position` 升序、`opts.fail` 注入空数组 + `partialError`
  - 验证：临时脚本断言 SHA picks=2（3 减 1 失效）、升序、`fail=hotSpots` 时数组空且标记 true

## 2. 接口契约桩

- [ ] 2.1 新增 `frontend/src/app/api/home/route.ts`：`GET` 读取 `searchParams.cityCode` → 缺省回退 cookie/`SHA`，`fail` 参数逗号分隔，返回 `NextResponse.json(loadHome(...))`
  - 验证：`npm run build` 通过
- [ ] 2.2 契约断言（本地 start 后 curl）
  - `curl "http://localhost:3000/api/home?cityCode=SHA"` → `picks` 长度 2 且 position 升序
  - `curl "http://localhost:3000/api/home"` → `cityCode` 为 `SHA`
  - `curl "http://localhost:3000/api/home?cityCode=BJA&fail=hotSpots"` → `hotSpots=[]` 且 `partialError.hotSpots=true`

## 3. 骨架与占位

- [ ] 3.1 新增 `frontend/src/components/homepage/regions/` 下 6 个占位组件（`hero-region.tsx` / `feature-nav-region.tsx` / `city-grid-region.tsx` / `hot-posts-region.tsx` / `hot-spots-region.tsx` / `ai-launcher-region.tsx`），每个为带 `min-h` 的占位块 + 归属模块注释
  - 验证：6 个文件存在，单文件 < 20 行
- [ ] 3.2 改写 `frontend/src/app/page.tsx`：Server Component，`<main className="mx-auto w-full max-w-screen-md px-4 md:px-6">` 内按序渲染 6 个 `<section data-region="...">`，挂载对应占位组件
  - 验证：文件内 import 仅占位组件 + `region-boundary`
- [ ] 3.3 修改 `frontend/src/app/layout.tsx`：`description` 改为面向入境游客的文案（保留 title 含 WanderChina）
  - 验证：`curl /` 的 `<head>` 含新 description

## 4. 降级容器

- [ ] 4.1 新增 `frontend/src/components/homepage/region-boundary.tsx`：`'use client'`，导出 `RegionBoundaryProps`（`loading?` / `error?` / `onRetry?` / `skeleton?` / `children`）
  - 验证：文件首行 `'use client'`，类型导出存在
- [ ] 4.2 实现骨架档位：`text-block`（`min-h-24`）、`card-row`（`min-h-40`）、`card-grid`（`min-h-72`），均带 `animate-pulse` 占位块
  - 验证：切档位无 TS 错误，类名符合 styling-stack 约束
- [ ] 4.3 实现重试：`useRouter()`，默认 `router.refresh()`；`onRetry` 存在时优先调用；按钮为 `Button variant="outline"`，`disabled` 于 `loading` 期间，支持 Enter/Space
  - 验证：键盘操作可触发，控制台无报错
- [ ] 4.4 `page.tsx` 中三个数据区块（`hot-posts` / `hot-spots` / 后续 picks 承载位）包 `RegionBoundary`，按 `partialError` 传 `error`，按区块选骨架档位
  - 验证：`?fail=hotSpots` 时仅该区块骨架 + 重试

## 5. 验证

- [ ] 5.1 同步 NTFS 副本：`robocopy frontend D:\wanderchina-frontend /MIR /XD node_modules .next .git`，`npm run build` 通过
  - 验证：`✓ Compiled successfully`
- [ ] 5.2 `npm run start` 后 `curl http://localhost:3000/` 断言：200、6 个 `data-region`、顺序正确、`<title>` 含 `WanderChina`
  - 验证：输出与断言一致
- [ ] 5.3 全失败路径：`/api/home?fail=picks,hotSpots,hotPosts` 返回 200 且三键均在 `partialError`；页面仍 200 并显示 3 组骨架
  - 验证：curl + 浏览器检查
- [ ] 5.4 视口 360 / 768 / 1440 三档检查无横向滚动、`md` 以上容器居中
  - 验证：浏览器 Device Toolbar 截屏

## 6. 验收与提交

- [ ] AC1 `GET /` 200，6 个 `data-region` 顺序正确（hero → feature-nav → city-grid → hot-posts → hot-spots → ai-launcher）
- [ ] AC2 `picks` 升序、失效剔除不补位、`cityCode` 回退与回显正确
- [ ] AC3 `partialError` 单区块与全失败路径均符合规格
- [ ] AC4 骨架 + 重试可键盘触发，无整页错误页
- [ ] AC5 `page.tsx` 不 import 任何区块实现；未新增 npm 依赖
- [ ] AC6 `npm run build` 通过
- [ ] 6.1 `frontend` 子仓库提交（10 新增 + 2 修改）
- [ ] 6.2 根仓库提交 `openspec/changes/homepage-shell/`（proposal + design + spec + tasks）
