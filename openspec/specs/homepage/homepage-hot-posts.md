# homepage-hot-posts Specification

## Purpose

首页热门帖子列表：只取 72 小时内、状态为 open/resolved 的帖子，按单位时间评论热度排序，最多 8 条；已解决帖子带徽标，被举报待审的评论摘要做屏蔽处理。数据先用 mock 契约占位，真实接口由后续独立 spec 承接。

## Requirements

### Requirement: 热门帖子榜单

系统 SHALL 仅返回 `status IN (open, resolved)` 且 `created_at ≥ now - 72h` 的帖子，按 `comment_count ÷ hours_since_create` 降序，最多 8 条；`resolved` 帖子响应中返回 `resolved = true`，前端展示徽标。

#### Scenario: 按单位时间评论热度返回 ≤8 条（H4-1）

- **WHEN** 用户查看热门帖子
- **THEN** 仅返回 `status IN (open, resolved)` 且 `created_at ≥ now - 72h` 的帖子，按 `comment_count ÷ hours_since_create` 降序、最多 8 条

#### Scenario: 已解决帖子带徽标（H4-1）

- **WHEN** 返回列表中含 `status = resolved` 的帖子
- **THEN** 该帖子响应 `resolved = true`，前端展示已解决徽标

#### Scenario: 排序逻辑可独立验证

- **WHEN** 对乱序 mock 数据执行 `rankHotPosts(posts, now)`（`now` 显式传入保证可复现）
- **THEN** 仅保留 72 小时内、状态合法的帖子，返回至多 8 条且热度分数单调不增（用 Node 内置 `node --test` 验证）

### Requirement: 举报评论摘要屏蔽

系统 SHALL 在帖子列表摘要中屏蔽存在 pending 举报的评论内容，以 `[removed pending review]` 占位，且接口不得因该情形返回 500。

#### Scenario: pending 举报评论不展示内容（H4-2）

- **WHEN** 帖子下存在 `pending` 举报的评论
- **THEN** 列表摘要不展示该评论内容（显示 `[removed pending review]`），接口返回 200 且不返回 500

### Requirement: 帖子卡片内容

系统 SHALL 为每条帖子展示标题、摘要、作者与热度指标（评论数），resolved 帖子额外展示徽标。

#### Scenario: 单条内容完整

- **WHEN** 查看任一帖子条目
- **THEN** 可见标题、摘要、作者名与评论数；`resolved` 帖子可见已解决徽标
