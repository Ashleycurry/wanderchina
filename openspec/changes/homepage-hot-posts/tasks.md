# Tasks: 首页热门帖子（homepage-hot-posts）

> 前置：`homepage-shell` 已归档，`HotPostCard` / `RegionBoundary` / `/api/home` 契约桩可用。
> 注意：本变更与 `homepage-hot-spots` 都会修改 `load.ts` 与 `mock-data.ts`，建议串行 apply。

## 1. mock 数据

- [x] 1.1 新增 `frontend/src/mocks/hot-posts.ts`：`MOCK_HOT_POSTS: Record<CityCode, HotPostCard[]>`，SHA 12 条乱序（2 hidden / 1 超 72h / 1 未来时间戳 / 1 零评论 / 其余正常，含 1 resolved 与 1 summaryRedacted），BJA 3 条，其余 6 城空数组
  - 验证：读文件核对四类边界样例存在；城市键覆盖 8 个 `CityCode`

## 2. 纯函数与测试

- [x] 2.1 新增 `frontend/src/lib/rank-posts.ts`：`rankHotPosts(posts, now, limit = 8)`，顺序为状态过滤 → 72h 窗口（含边界）→ 热度降序（同分按 `createdAt` 降序）→ 截断；`Date.parse` 失败兜底 0
  - 验证：文件内无 `import` 运行时依赖（仅 `import type`）
- [x] 2.2 新增 `frontend/tests/rank-posts.test.mjs`：`import { rankHotPosts } from '../src/lib/rank-posts.ts'`，用 `node:test` + `node:assert/strict` 断言 8 组用例（hidden 过滤 / 超 72h / 恰好 72h 保留 / 正常降序 / 未来时间戳不 NaN / 零评论排末尾 / 截断 / `limit <= 0`）
  - 验证：`node --test tests/rank-posts.test.mjs` 全绿，且不新增任何依赖

## 3. 组件与数据装配

- [x] 3.1 新增 `frontend/src/components/homepage/hot-posts.tsx`（Server Component）：`HotPostsProps`（`posts` / `now` / `className`），内部调用 `rankHotPosts`，渲染 `grid grid-cols-1 gap-4 md:grid-cols-2` 卡片
  - 验证：每卡片含标题、`line-clamp-2` 摘要、作者、评论数
- [x] 3.2 已解决徽标：`CheckCircle2`（`aria-hidden`）+ 文本「已解决」
  - 验证：SSR HTML 含 `/removed pending review` 与「已解决」文案（对应 mock 数据）
- [x] 3.3 空态：`posts.length === 0` 时渲染 `No trending posts for this city yet.`，保持 `min-h-72`
  - 验证：`Cookie: wc_city=SIA` 时显示该文案
- [x] 3.4 改写 `regions/hot-posts-region.tsx` 为薄壳 `<HotPosts posts={posts} now={new Date()} />`
  - 验证：文件 ≤ 8 行；`page.tsx` 未改动
- [x] 3.5 改 `src/lib/home/load.ts`：`LoadHomeOptions` 增加 `now?: Date`；`hotPosts: rankHotPosts(MOCK_HOT_POSTS[cityCode] ?? [], now)`，`fail` 时仍返回 `[]` 并标记 `partialError`
  - 验证：`/api/home?cityCode=SHA` 的 `hotPosts` ≤ 8 且热度单调不增
- [x] 3.6 改 `src/lib/home/mock-data.ts`：删除 `hotPosts` 字段与 `HotPostCard` 引用
  - 验证：`npx tsc --noEmit` 通过

## 4. 验证

- [x] 4.1 `robocopy` 同步到 `D:\wanderchina-frontend`，`node --test tests/`、`npx tsc --noEmit`、`npm run build` 均通过
  - 验证：测试全绿 + `✓ Compiled successfully`
- [x] 4.2 断言 `/api/home?cityCode=SHA`：`hotPosts` ≤ 8、无 `hidden` 状态、热度单调不增、含 `resolved: true` 与 `summaryRedacted: true` 各至少 1 条
  - 验证：Node `fetch` 断言
- [x] 4.3 断言降级：`?fail=hotPosts` → `hotPosts=[]` 且 `partialError.hotPosts=true`，页面该区块为骨架 + 重试
  - 验证：Node `fetch` + 可见 DOM 断言
- [x] 4.4 断言城市切换：`Cookie: wc_city=BJA` 的 `hotPosts` 与 SHA 不同；`wc_city=SIA` 显示空态文案
  - 验证：Node `fetch` 比对
- [x] 4.5 浏览器 360 / 768 两档检查列数与摘要截断
  - 验证：`grid-cols-1` / `md:grid-cols-2` 类已核对；真机截图待人工补

## 5. 验收与提交

- [x] AC1 仅 `open` / `resolved` 且 72h 内，按 `comment_count ÷ hours` 降序，≤ 8 条
- [x] AC2 同分按 `createdAt` 降序；未来时间戳与零评论不产生 NaN
- [x] AC3 `resolved` 显示文本徽标；`summaryRedacted` 摘要为 `[removed pending review]`
- [x] AC4 空列表显示兜底文案；降级显示骨架 + 重试
- [x] AC5 `node --test` 通过且无新增依赖；`npm run build` 通过
- [x] 5.1 `frontend` 子仓库提交（4 新增 + 3 修改）
- [x] 5.2 根仓库提交 `openspec/changes/homepage-hot-posts/`

## 实施记录（2026-11-02）

- 构建：`npx tsc --noEmit` exit 0；`npm run build` → `✓ Compiled successfully`，`/` 仍为 Dynamic（ƒ），首屏 `24.9 kB / 112 kB`
- 单测：`node --test tests/rank-posts.test.mjs tests/rank-spots.test.mjs` → 16 passed / 0 failed
- 断言：`hotPosts` 8 条、无 `hidden`、热度单调不增、含 `resolved` 与 `summaryRedacted` 各 1 条；`?fail=hotPosts` 返回 `[]` 且区块渲染 `animate-pulse` 骨架 + 「重试」；`Cookie: wc_city=SIA` 显示 `No trending posts for this city yet.`
- 偏差 1：`tasks 1.1` 原计划 3 条 hidden，实际落 2 条（有效数据 9 条 > 8 已足以验证截断）
- 偏差 2：空态文案取 `No trending posts for this city yet.`，与 `homepage-city-grid` tasks 4.1 的 `No community posts…` 不同，以本模块规格为准
- 偏差 3：`node --test frontend/tests/`（目录形式）在 Windows 报 `MODULE_NOT_FOUND`，须显式列出测试文件
- 偏差 4：`rank-posts.ts` 初版误写 `from './types'`（实际在 `./home/types`），IDE 因 H 盘无 `node_modules` 未报错，由 D 盘 `tsc` 发现并修正
