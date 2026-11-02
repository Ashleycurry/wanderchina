# Proposal: 首页热门帖子（homepage-hot-posts）

## Why

首页 `hot-posts` 挂载位当前只打印「待实现（N 条）」。热门帖子是把「社区在发生什么」带到首屏的唯一入口，也是首页唯一有内容治理约束的区块：必须按时间窗口 + 单位时间评论数排序，必须隐藏被举报待审的评论摘要，必须给已解决帖子打标。

这些规则如果散落在组件里，后续接真实接口时几乎必然复制一遍。本变更把它们收敛成一个可独立验证的纯函数。

## What Changes

- 新增 `src/mocks/hot-posts.ts`：`MOCK_HOT_POSTS`（按城市），SHA 12 条乱序数据，覆盖 hidden / 超 72h / 未来时间戳 / 0 评论四类边界
- 新增 `src/lib/rank-posts.ts`：`rankHotPosts(posts, now, limit = 8)` 纯函数（过滤 → 排序 → 截断）
- 新增 `src/components/homepage/hot-posts.tsx`（Server Component）：卡片列表 + 已解决徽标 + 空态
- 新增 `frontend/tests/rank-posts.test.mjs`：Node 内置 test runner 断言（零第三方依赖）
- 改写 `regions/hot-posts-region.tsx` 为薄壳；`load.ts` 的 `hotPosts` 改由 `rankHotPosts` 产出；`mock-data.ts` 移除 hotPosts 字段
- 规格：MODIFIED「热门帖子热度排序」（原 2 Scenario + 脏数据稳定排序 + 纯函数可验证），ADDED「热门帖子列表展示」

## Impact

| 维度 | 影响 |
| --- | --- |
| capability | `homepage` |
| 新增文件 | 4（mocks / 纯函数 / 组件 / 测试） |
| 修改文件 | 3（`hot-posts-region`、`load.ts`、`mock-data.ts`） |
| 数据接口 | `/api/home` 的 `hotPosts` 改为排序后结果，字段不变 |
| 共享文件冲突 | **与 `homepage-hot-spots` 同时修改 `load.ts` / `mock-data.ts`，建议串行 apply** |
| 新增依赖 | 无（测试用 Node 24 内置 runner + 类型剥离） |
| 上游依赖 | `homepage-shell`（`HotPostCard` 类型、`RegionBoundary`、契约桩） |

## 待确认

1. **`load.ts` / `mock-data.ts` 会被批 4 的 hot-posts 与 hot-spots 各改一次**：两者都要把数据源切到自己的 `mocks/*.ts` 并接入排序函数。建议按 `hot-posts → hot-spots` 串行实施，避免同文件冲突。
2. **测试用 `.mjs` + Node 类型剥离**：`tests/rank-posts.test.mjs` 直接 `import '../src/lib/rank-posts.ts'`，本机 Node v24 默认支持。若 CI 使用 Node 20，需补 `--experimental-strip-types` 或改用编译产物。
3. **UI 文案英文**（与批 3 一致），空态 `No trending posts for this city yet.`。
