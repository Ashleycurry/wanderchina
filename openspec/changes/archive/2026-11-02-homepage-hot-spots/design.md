# Design: 首页热门景点（homepage-hot-spots）

## D1 `rankHotSpots` 接受结构化泛型，内部完成 published 过滤

```ts
export interface RankableSpot {
  status: 'published' | 'draft' | 'archived'
  viewCount7d: number | null
  popularityScore: number
}

export function rankHotSpots<T extends RankableSpot>(spots: readonly T[], limit = 8): T[]
```

`status` 只存在于 mock 层（与 `homepage-shell` 的 `MockPick` 处理方式一致），不能出现在 API 响应里。泛型让 `load.ts` 拿到 `MockSpot[]`，再经 `toHotSpotCard` 逐字段构造为 `HotSpotCard[]`。

过滤放在函数内部而不是调用方：否则「published 过滤」会被漏写，而这正是模块的核心数据口径。

## D2 加权公式与退化判定

```ts
const score = (s: RankableSpot) => (s.viewCount7d ?? 0) * 0.7 + s.popularityScore * 0.3
```

退化条件：过滤后**全部** `viewCount7d` 为 `null` 或 `0`。此时改用 `popularityScore` 降序。

判定必须在 published 过滤之后：否则 draft 景点的浏览量会让一个本该退化的城市误判为「有数据」。

部分 `null` 不触发退化，按 0 参与加权（规格 S4）。

## D3 同分排序保持确定性

加权分相同（浮点相等的情况在 mock 数据里可通过同权重构造）时按 `popularityScore` 降序，再按 `name` 升序。三级比较保证任何输入下输出顺序唯一，测试可断言。

## D4 `formatViews` 的边界

```ts
formatViews(0)       // '0 views'
formatViews(980)     // '980 views'
formatViews(12300)   // '12.3k views'
formatViews(1200000) // '1.2m views'
formatViews(NaN)     // '0 views'
formatViews(-5)      // '0 views'
```

- 负数与 `NaN` 统一返回 `0 views`，不让脏数据把卡片打出 `NaN views`
- `toFixed(1)` 后去掉尾随 `.0`：`10k views` 比 `10.0k views` 更常见
- 单位用 `k` / `m` 小写，与手册示例一致

## D5 封面用 `next/image`，失败渐变兜底

`coverImage` 统一指向 `public/images/spots/*.svg`（本地占位）。Next 对本地 `.svg` 自动 `unoptimized`，无需 `dangerouslyAllowSVG`。

失败兜底不在 `<Image>` 上做 `onError`（Server Component 无法挂事件），而是给图片容器一个 `bg-gradient-to-br from-muted to-muted-foreground/20` 底色 + `object-cover`：图片 404 时容器仍有渐变，名称与浏览量位于图片外层，不受影响。固定 `aspect-[4/3]` 保证不塌陷。

## D6 卡片不带链接（本期）

模块手册写「链接 `/city/<slug>`」，但 `HotSpotCard.slug` 是景点 slug（`the-bund`），拼成 `/city/the-bund` 会 404。城市页需要 `citySlug`（`shanghai`），而 `HotSpotsProps` 按手册只有 `spots`。

本期卡片用 `<article>` 纯展示，不加 `<a>`。后续景点详情页 spec 落地时再补链接，避免先放一个错误 href。

## D7 数据源迁移与 `status` 剥离

- `src/mocks/hot-spots.ts`：`MOCK_HOT_SPOTS: Record<CityCode, MockSpot[]>`，`MockSpot extends HotSpotCard { status: SpotStatus }`
- `src/lib/home/mock-data.ts`：删除 `hotSpots` 字段
- `src/lib/home/load.ts`：

```ts
const spots = rankHotSpots(MOCK_HOT_SPOTS[cityCode] ?? [])
hotSpots: fail.has('hotSpots') ? [] : spots.map(toHotSpotCard)
```

`toHotSpotCard` 与已有的 `toEditorPick` 同款：显式逐字段构造，`status` 不泄漏。

## 文件结构

```
frontend/
├── public/images/spots/*.svg              # 新增：8 张占位封面
├── src/
│   ├── mocks/hot-spots.ts                 # 新增
│   ├── lib/
│   │   ├── rank-spots.ts                  # 新增
│   │   ├── format-views.ts                # 新增
│   │   └── home/
│   │       ├── load.ts                    # 改
│   │       └── mock-data.ts               # 改：移除 hotSpots
│   └── components/homepage/
│       ├── hot-spots.tsx                  # 新增
│       └── regions/hot-spots-region.tsx   # 改写：薄壳
└── tests/rank-spots.test.mjs              # 新增
```
