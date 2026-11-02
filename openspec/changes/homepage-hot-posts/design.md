# Design: 首页热门帖子（homepage-hot-posts）

## D1 复用 `HotPostCard`，不新建 `TrendingPost`

`homepage-shell` 已在 `src/lib/home/types.ts` 定义 `HotPostCard`，字段与模块手册的 `TrendingPost` 完全一致（`id` / `title` / `summary` / `author` / `status` / `commentCount` / `createdAt` / `resolved?` / `summaryRedacted?`）。

再加一个同构类型只会产生两套需要同步的定义。`rank-posts.ts` 直接消费 `HotPostCard`。

## D2 过滤 / 排序 / 截断全部集中在纯函数

```ts
export function rankHotPosts(posts: readonly HotPostCard[], now: Date, limit = 8): HotPostCard[]
```

内部顺序：`status IN (open, resolved)` → `createdAt >= now - 72h` → 按热度降序（同分按 `createdAt` 降序） → `slice(0, limit)`。

热度公式：`commentCount / max(1, (now - createdAt) / 3_600_000)`。`max(1, ...)` 同时解决两个边界：

- 未来时间戳（`now - createdAt < 0`）→ 分母取下限 1，不产生负热度
- 刚发布的帖子（不足 1 小时）→ 分母取下限 1，不产生除零或爆炸值

`now` 显式传入而不是函数内 `new Date()`：否则测试无法复现，边界用例（恰好 72h）会随运行时刻漂移。

## D3 排序稳定性用显式二级比较，不依赖 `Array.prototype.sort` 的稳定性

虽然 V8 的 sort 已稳定，但「同分按 `createdAt` 降序」是业务规则，不能依赖引擎实现。比较函数写成：

```ts
const delta = score(b) - score(a)
if (delta !== 0) return delta
return Date.parse(b.createdAt) - Date.parse(a.createdAt)
```

`Date.parse` 对非法时间返回 `NaN`，需要兜底为 0，否则整个比较链返回 `NaN`，排序结果不可预期。

## D4 mock 数据刻意包含四类边界

`MOCK_HOT_POSTS.SHA` 共 12 条，其中：

| 用例 | 条数 | 用途 |
| --- | --- | --- |
| `hidden` | 3 | 验证状态过滤 |
| `createdAt` 超 72h | 3 | 验证时间窗口 |
| `createdAt` 晚于 now | 1 | 验证分母下限 1 与不产生 NaN |
| `commentCount = 0` | 1 | 验证零热度排末尾 |
| 正常 open / resolved | 4 | 验证排序与徽标 |

BJA 给 3 条（1 resolved），其余 6 城空数组——空数组正好覆盖空态。

## D5 数据源从 `mock-data.ts` 迁到 `mocks/hot-posts.ts`

`homepage-shell` 的 `MOCK_HOME[cityCode].hotPosts` 是骨架期的占位数据（SHA 4 条，无边界样例）。本变更把它迁出：

- `src/mocks/hot-posts.ts`：`MOCK_HOT_POSTS: Record<CityCode, HotPostCard[]>`
- `src/lib/home/mock-data.ts`：删除 `hotPosts` 字段
- `src/lib/home/load.ts`：`hotPosts: rankHotPosts(MOCK_HOT_POSTS[cityCode] ?? [], now)`

`LoadHomeOptions` 增加可选 `now?: Date`（默认 `new Date()`），让契约断言可以固定时间点。

## D6 测试用 `.mjs` 导入 `.ts`，绕开 tsc 的扩展名限制

`tsconfig.json` 的 `include` 覆盖全部 `.ts`，若测试写成 `.ts` 并在 import 里带 `.ts` 扩展名，`tsc` 会报 `allowImportingTsExtensions` 错误。

改用 `tests/rank-posts.test.mjs`：Node v24 默认对 `.ts` 做类型剥离，`.mjs` 不在 `tsc` 管辖内，`next build` 也不会打包 `tests/`。

```bash
node --test frontend/tests/
```

零第三方依赖，符合「不引入测试框架」的约束。

## D7 徽标不只靠颜色

「已解决」徽标 = `CheckCircle2` 图标（`aria-hidden`）+ 文本「已解决」。色弱用户与屏幕阅读器都能获得同一信息。

## 文件结构

```
frontend/
├── src/
│   ├── mocks/hot-posts.ts                 # 新增：12 条 SHA + 3 条 BJA
│   ├── lib/
│   │   ├── rank-posts.ts                  # 新增：纯函数
│   │   └── home/
│   │       ├── load.ts                    # 改：hotPosts 走排序
│   │       └── mock-data.ts               # 改：移除 hotPosts
│   └── components/homepage/
│       ├── hot-posts.tsx                  # 新增：Server Component
│       └── regions/hot-posts-region.tsx   # 改写：薄壳
└── tests/rank-posts.test.mjs              # 新增：node --test
```
