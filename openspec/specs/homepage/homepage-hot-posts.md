# homepage-hot-posts Specification

## Purpose

首页热门帖子列表：只取 72 小时内、状态为 open/resolved 的帖子，按单位时间评论热度排序，最多 8 条；已解决帖子带徽标，被举报待审的评论摘要做屏蔽处理。数据先用 mock 契约占位，真实接口由后续独立 spec 承接。

技术栈约束：Next.js 14 App Router（列表为 Server Component）+ Tailwind CSS 3.4；排序逻辑为纯函数（`node --test` 可验证）。

## 1. 模块边界

### 1.1 包含

| 项 | 说明 |
| --- | --- |
| 数据口径 | `status IN (open, resolved)`、`created_at ≥ now - 72h`、按 `comment_count ÷ hours_since_create` 降序、≤8 条 |
| 已解决标识 | `resolved` 帖子返回 `resolved = true`，前端展示徽标 |
| 举报屏蔽 | pending 举报评论摘要显示 `[removed pending review]`，接口不 500 |
| mock 契约 | `src/mocks/hot-posts.ts`：`PostSeed` × 12 条种子 + `getMockHotPosts(cityCode, now)`（`createdAt` 相对 `now` 计算） |
| 纯函数排序 | `src/lib/rank-posts.ts`：`rankHotPosts(posts, now, limit)` |
| 卡片渲染 | 标题、摘要、作者、评论数、resolved 徽标；mobile-first 列表 |

### 1.2 不包含

| 项 | 归属 |
| --- | --- |
| 帖子详情页、发帖、投票 | 后续独立 spec |
| 举报审核后台、内容审核流程 | 后续独立 spec（本期只做展示侧屏蔽） |
| 真实帖子接口 | 后续后端 spec（本期 mock） |
| 城市切换逻辑本身 | `homepage-city-grid`（本模块仅响应数据变化） |

### 1.3 技术约束

- 列表为 Server Component；无客户端交互（本期不做点赞/跳转详情）
- 排序与过滤全部在纯函数中完成，组件只负责渲染
- `now` 显式传入纯函数，保证测试可复现
- mock 的 `createdAt` 必须相对「请求时刻」求值（`getMockHotPosts(cityCode, now)`）；模块加载时固化成常量会让长驻进程在 72h 后列表恒为空
- `loadHome` 内排序只做一次，组件不重复调用 `rankHotPosts`
- 不引入测试框架，验收用 Node 内置 `node --test`
- 不新增 npm 依赖

## 2. 核心场景

### S1 状态过滤【正常】

- **WHEN** 数据中存在 `open`、`resolved`、`hidden` 三种状态的帖子
- **THEN** 仅返回 `status IN (open, resolved)` 的帖子
- **AND** `hidden` 帖子不出现在列表

### S2 72 小时窗口【正常】

- **WHEN** 数据中存在 `created_at` 超过 72 小时的帖子
- **THEN** 该帖子被过滤掉
- **AND** 边界值（恰好 72h）按「包含」处理，不出现差一秒抖动

### S3 单位时间评论热度排序【正常】

- **WHEN** 候选帖子数超过 8 条
- **THEN** 按 `comment_count ÷ hours_since_create` 降序返回
- **AND** 最多返回 8 条

### S4 已解决帖子带徽标【正常】

- **WHEN** 返回列表中含 `status = resolved` 的帖子
- **THEN** 响应该帖 `resolved = true`
- **AND** 前端展示「已解决」徽标（文本可见，不仅靠颜色）

### S5 pending 举报评论不展示【异常】

- **WHEN** 帖子下存在 `pending` 举报的评论（作为列表摘要来源）
- **THEN** 摘要不展示该评论内容，显示 `[removed pending review]`
- **AND** 接口返回 200，不返回 500

### S6 空列表兜底【异常】

- **WHEN** 过滤后无任何帖子
- **THEN** 区块显示兜底文案（如「暂无热门帖子」）
- **AND** 不出现空白列表容器或骨架常驻

### S7 全部超时过期【边界】

- **WHEN** 所有帖子均超过 72 小时
- **THEN** 返回空数组，进入 S6 兜底
- **AND** 不抛错、不返回 500

### S8 数据异常：未来时间戳【异常】

- **WHEN** 某帖 `created_at` 晚于 `now`（脏数据）
- **THEN** `hours_since_create` 取下限 1（不做负数/除零计算）
- **AND** 该帖不因脏数据导致排序崩溃或 NaN

### S9 零评论帖子【边界】

- **WHEN** 帖子 `comment_count = 0`
- **THEN** 热度记 0，排在列表末尾
- **AND** 同分时按 `created_at` 降序保持稳定顺序

### S10 区块降级【异常】

- **WHEN** `/api/home` 的 `hotPosts` 区块失败
- **THEN** 该区块展示骨架 + 重试
- **AND** 其余区块正常展示，页面不整页报错

### S11 城市切换重拉【正常】

- **WHEN** 用户切换城市（如 `SHA` → `BJA`）
- **THEN** 帖子列表按新城市重新拉取并渲染
- **AND** 不残留上一城市数据

### S12 响应式列表【正常】

- **WHEN** 视口 360px / ≥768px
- **THEN** 360px 单列列表，≥768px 两列网格
- **AND** 摘要超长时行数截断，不撑破卡片

## 3. 数据结构

### 3.1 mock 契约

```ts
export type PostStatus = 'open' | 'resolved' | 'hidden';

export interface TrendingPost {
  id: string;
  title: string;
  /** 列表摘要；来源评论被 pending 举报时，服务端替换为屏蔽文案 */
  summary: string;
  author: string;
  status: PostStatus;
  commentCount: number;      // ≥ 0
  createdAt: string;         // ISO 时间
  /** 仅 resolved 帖子为 true */
  resolved?: boolean;
  /** 摘要是否已被屏蔽（pending 举报） */
  summaryRedacted?: boolean;
}
```

### 3.2 纯函数签名

```ts
/**
 * 过滤 + 排序 + 截断
 * @param posts 原始列表（顺序任意）
 * @param now   当前时间（显式传入，保证可复现）
 * @param limit 默认 8
 */
export function rankHotPosts(posts: TrendingPost[], now: Date, limit = 8): TrendingPost[];
```

### 3.3 组件 Props

```ts
/** src/components/homepage/hot-posts.tsx —— Server Component */
export interface HotPostsProps {
  /** 已过滤 + 排序 + 截断的热门列表；排序在 loadHome 内完成，组件只渲染 */
  posts: TrendingPost[];
  className?: string;
}
```

### 3.4 约束与默认值

| 项 | 约束 | 默认值 |
| --- | --- | --- |
| 排序公式 | `commentCount / max(1, (now - createdAt) / 3600_000)` | — |
| 条数上限 | 最多 8 条 | 8 |
| 时间窗口 | `createdAt >= now - 72h`（含边界） | 72h |
| 同分排序 | `createdAt` 降序（稳定） | — |
| 屏蔽文案 | 固定 `[removed pending review]` | 同左 |
| 徽标 | 文本「已解决」+ 图标，不仅靠颜色 | — |

### 3.5 文件与依赖

```
frontend/src/
├── mocks/hot-posts.ts                 # 12 条种子（含 hidden / 超 72h 用例）+ getMockHotPosts
├── lib/rank-posts.ts                  # rankHotPosts 纯函数
└── components/homepage/
    ├── hot-posts.tsx                  # Server Component 列表
    └── regions/hot-posts-region.tsx   # 挂载中间层：透传 posts

frontend/tests/rank-posts.test.mjs     # node --test 断言
```

## 4. 验收标准（ACCEPTANCE Checklist）

### 4.1 数据口径

- [ ] 仅返回 `status IN (open, resolved)`，`hidden` 不出现
- [ ] 仅返回 72 小时内帖子，72h 边界按包含处理
- [ ] 按 `comment_count ÷ hours_since_create` 降序，最多 8 条
- [ ] 未来时间戳不导致 NaN / 崩溃（hours 下限 1）

### 4.2 内容与展示

- [ ] 每条含标题、摘要、作者、评论数
- [ ] `resolved` 帖子展示「已解决」徽标（文本 + 图标）
- [ ] pending 举报摘要显示 `[removed pending review]`
- [ ] 空列表显示兜底文案，不残留空白容器

### 4.3 排序验证（node --test）

- [ ] `rankHotPosts` 对 12 条乱序输入返回 ≤8 条且热度单调不增
- [ ] 过滤边界用例（72h、hidden、未来时间、0 评论）全部通过
- [ ] `node --test frontend/tests/rank-posts.test.mjs` 在无新增依赖下通过（Node 24 不接受目录形式）

### 4.4 交互与隔离

- [ ] 切换城市后列表按新城市重拉，无旧数据残留
- [ ] `hotPosts` 区块 `partialError` 时显示骨架 + 重试，其余区块正常
- [ ] 360px 单列 / ≥768px 两列，摘要截断不撑破卡片

### 4.5 手动验证步骤

1. `node --test frontend/tests/rank-posts.test.mjs`，确认排序与过滤断言通过
2. `npm run build && npm run start`，`curl` 断言 ≤8 条与徽标文案
3. 浏览器检查 pending 举报摘要显示屏蔽文案
4. 切换城市确认列表刷新；断网模拟 `partialError` 检查骨架 + 重试
