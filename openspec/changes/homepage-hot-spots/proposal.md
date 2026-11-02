# Proposal: 首页热门景点（homepage-hot-spots）

## Why

首页 `hot-spots` 挂载位当前只打印「待实现（N 条）」。热门景点是首页的转化担当：卡片要有封面、名称、浏览量，并链向可继续浏览的落点。

排序规则是「近 7 日浏览 × 0.7 + 编辑权重 × 0.3」。它有两个必须显式处理的退化：新城市没有埋点数据时按编辑权重兜底；部分景点缺数据时 `null` 必须视作 0 而不是跳过或抛错。这两条都属于纯函数职责，不适合沉在 JSX 里。

## What Changes

- 新增 `src/mocks/hot-spots.ts`：`MOCK_HOT_SPOTS`（按城市），SHA 8 条乱序（含 2 条非 published、2 条无浏览数据），BJA 3 条全 `null` 用于验证退化
- 新增 `src/lib/rank-spots.ts`：`rankHotSpots(spots, limit = 8)`（published 过滤 + 加权排序 + 退化 + 截断）
- 新增 `src/lib/format-views.ts`：`formatViews(views)`（`12.3k views` / `980 views` / `1.2m views`）
- 新增 `src/components/homepage/hot-spots.tsx`（Server Component）：`next/image` 封面卡片网格 + 空态
- 新增 `frontend/tests/rank-spots.test.mjs`：Node 内置 test runner 断言排序、退化、格式化
- 改写 `regions/hot-spots-region.tsx` 为薄壳；`load.ts` 的 `hotSpots` 改由 `rankHotSpots` 产出并剥离 `status`；`mock-data.ts` 移除 hotSpots 字段
- 规格：MODIFIED「热门景点加权排序」（原 2 Scenario + 部分缺失按 0 + 纯函数可验证），ADDED「热门景点卡片展示」

## Impact

| 维度 | 影响 |
| --- | --- |
| capability | `homepage` |
| 新增文件 | 5（mocks / rank / format / 组件 / 测试） |
| 修改文件 | 3（`hot-spots-region`、`load.ts`、`mock-data.ts`） |
| 数据接口 | `/api/home` 的 `hotSpots` 改为排序后结果，`status` 不进入响应 |
| 共享文件冲突 | **与 `homepage-hot-posts` 同时修改 `load.ts` / `mock-data.ts`，建议串行 apply** |
| 新增依赖 | 无 |
| 上游依赖 | `homepage-shell`（`HotSpotCard` 类型、`RegionBoundary`） |

## 待确认

1. **卡片链接落点**：模块手册 1.1 写「链接 `/city/<slug>`」，但 mock 的 `slug` 是景点 slug（`the-bund`），拼出 `/city/the-bund` 是错的；而城市 slug 需要额外 props。本提案**本期卡片不带链接**（纯展示），详情页与城市页跳转留给后续 spec。
2. **`12.3k` / `1.2m` 去掉尾随 `.0`**：`10000` 渲染为 `10k views` 而非 `10.0k views`，与手册「保留 1 位小数」有轻微差异，取更常见的展示形态。
3. **UI 文案英文**（与批 3 一致），空态 `No attractions for this city yet.`（与 `homepage-city-grid` 的空态文案保持一致）。
