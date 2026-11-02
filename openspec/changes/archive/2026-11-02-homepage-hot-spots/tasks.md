# Tasks: 首页热门景点（homepage-hot-spots）

> 前置：`homepage-shell` 已归档。本变更与 `homepage-hot-posts` 都会修改 `load.ts` / `mock-data.ts`，建议**在其之后**串行 apply。

## 1. mock 与占位资源

- [x] 1.1 新增 `frontend/src/mocks/hot-spots.ts`：`MockSpot extends HotSpotCard { status }`，`MOCK_HOT_SPOTS: Record<CityCode, MockSpot[]>`；SHA 8 条乱序（2 条 draft/archived、2 条 `viewCount7d: null`、4 条正常），BJA 3 条全 `null`，其余 6 城空
  - 验证：SHA 过滤后 published 恰 6 条；BJA 全部 `null` 可触发退化
- [x] 1.2 新增 `frontend/public/images/spots/*.svg` 占位封面（11 张：SHA 8 + BJA 3，440×330 视图框 + 语义色块）
  - 验证：`/images/spots/the-bund.svg` 返回 200

## 2. 纯函数与测试

- [x] 2.1 新增 `frontend/src/lib/rank-spots.ts`：`rankHotSpots(spots, limit = 8)`，顺序为 published 过滤 → 退化判定（全部 `null`/0）→ 降序（退化时按 `popularityScore`）→ 截断；同分按 `popularityScore` 降序再按 `name` 升序
  - 验证：函数内无运行时 import（仅 `import type`）
- [x] 2.2 新增 `frontend/src/lib/format-views.ts`：`formatViews(views)`，`k` / `m` 两位单位，`toFixed(1)` 后去掉尾随 `.0`，负数与 `NaN` 返回 `0 views`
  - 验证：`node -e` 断言三档示例
- [x] 2.3 新增 `frontend/tests/rank-spots.test.mjs`：断言 published 过滤、加权降序、全 `null` 退化、部分 `null` 按 0、同分确定性、`formatViews` 三档 + 异常值
  - 验证：`node --test tests/rank-spots.test.mjs` 全绿

## 3. 组件与数据装配

- [x] 3.1 新增 `frontend/src/components/homepage/hot-spots.tsx`（Server Component）：`HotSpotsProps`（`spots` / `className`），`grid grid-cols-1 gap-4 sm:grid-cols-2 md:grid-cols-4`
  - 验证：每卡含 `next/image`（`sizes` 已声明）、名称、格式化浏览量
- [x] 3.2 封面容器 `aspect-[4/3]` + `bg-gradient-to-br from-muted to-muted-foreground/20` + `object-cover`
  - 验证：阻断图片请求后渐变可见、卡片高度不变
- [x] 3.3 空态：`spots.length === 0` 时渲染 `No attractions for this city yet.`
  - 验证：`Cookie: wc_city=SIA` 显示该文案
- [x] 3.4 改写 `regions/hot-spots-region.tsx` 为薄壳 `<HotSpots spots={spots} />`
  - 验证：文件 ≤ 8 行；`page.tsx` 未改动
- [x] 3.5 改 `src/lib/home/load.ts`：`hotSpots: rankHotSpots(MOCK_HOT_SPOTS[cityCode] ?? []).map(toHotSpotCard)`；新增 `toHotSpotCard`；`fail` 时仍返回 `[]`
  - 验证：`/api/home?cityCode=SHA` 的 `hotSpots` 无 `status` 字段、≤ 8 条、分数单调不增
- [x] 3.6 改 `src/lib/home/mock-data.ts`：删除 `hotSpots` 字段与 `HotSpotCard` 引用
  - 验证：`npx tsc --noEmit` 通过

## 4. 验证

- [x] 4.1 `robocopy` 同步到 `D:\wanderchina-frontend`，`node --test tests/`、`npx tsc --noEmit`、`npm run build` 均通过
  - 验证：测试全绿 + `✓ Compiled successfully`
- [x] 4.2 断言 `/api/home?cityCode=SHA`：`hotSpots` = 6 条、无 `status`、按加权分降序、含 `viewCount7d: null` 项
  - 验证：Node `fetch` 断言
- [x] 4.3 断言退化：`?cityCode=BJA` 的 `hotSpots` 按 `popularityScore` 降序（98 → 93 → 76）
  - 验证：Node `fetch` 断言
- [x] 4.4 断言降级：`?fail=hotSpots` → `hotSpots=[]` 且 `partialError.hotSpots=true`
  - 验证：Node `fetch` + 可见 DOM
- [x] 4.5 断言格式化：SSR HTML 含 `12.3k views`、`980 views`、`1.2m views`
  - 验证：页面 HTML 正则

## 5. 验收与提交

- [x] AC1 仅 published，加权降序 ≤ 8 条；全 `null` 时按 `popularityScore` 降序
- [x] AC2 部分 `null` 按 0 参与，不触发退化、不抛错
- [x] AC3 `formatViews` 三档输出正确，异常值兜底 `0 views`
- [x] AC4 封面固定比例 + 渐变兜底；空列表显示兜底文案
- [x] AC5 `node --test` 与 `npm run build` 通过，无新增依赖
- [x] 5.1 `frontend` 子仓库提交（含 11 张占位 SVG）
- [x] 5.2 根仓库提交 `openspec/changes/homepage-hot-spots/`

## 实施记录（2026-11-02）

- 构建：`npx tsc --noEmit` exit 0；`npm run build` → `✓ Compiled successfully`
- 单测：`node --test tests/rank-posts.test.mjs tests/rank-spots.test.mjs` → 16 passed / 0 failed
- 断言：`hotSpots` 6 条、无 `status` 字段、加权分单调不增、含 2 条 `viewCount7d: null`；`?cityCode=BJA` 退化为 `98 → 93 → 76`；`?fail=hotSpots` 返回 `[]` 且区块渲染骨架 + 「重试」；SSR 同时命中 `1.2m views` / `12.3k views` / `980 views` / `0 views`
- 偏差 1：`tasks 1.1` 原计划「1 条 `viewCount7d: 0` + 2 条 `null`」，实际为 2 条 `null`（无 0 值样例）；退化判定逻辑对 0 与 `null` 等价，已由单测覆盖
- 偏差 2：`tasks 4.3` 的预期分值为 `98 → 95 → 80`，实际 mock 为 `98 → 93 → 76`（顺序与退化行为一致，以实际数据为准）
- 偏差 3：为了让 `formatViews` 三档在页面真实可见，SHA 的 `外滩` / `豫园` / `武康路` 浏览量调整为 `1_200_000` / `12_300` / `980`（对应规格 Scenario 的三个示例值）
- 偏差 4：`tasks 1.2` 原计划 8 张封面，实际生成 11 张（BJA 的 3 条景点同样需要封面，避免 404）
