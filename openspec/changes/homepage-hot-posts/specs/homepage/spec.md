## MODIFIED Requirements

### Requirement: 热门帖子热度排序

系统 SHALL 仅返回 `status IN (open, resolved)` 且 `created_at ≥ now-72h` 的帖子，按 `comment_count ÷ max(1, hours_since_create)` 降序取前 8 条；同分按 `created_at` 降序保持稳定顺序。

#### Scenario: 排序与条目上限

- **WHEN** 用户查看热门帖子
- **THEN** 结果按热度公式降序，数量 ≤ 8
- **AND** `resolved` 帖子返回 `resolved=true` 且前端显示徽标

#### Scenario: 举报内容屏蔽

- **WHEN** 帖子下存在 `pending` 举报的评论
- **THEN** 列表摘要不展示该评论内容，固定显示 `[removed pending review]`
- **AND** 接口不返回 500

#### Scenario: 脏数据稳定排序

- **WHEN** 出现 `createdAt` 晚于 `now` 或 `commentCount = 0` 的帖子
- **THEN** `hours_since_create` 取下限 1，零评论热度记 0 并排在末尾
- **AND** 排序不产生 `NaN`、不抛错

#### Scenario: 纯函数可独立验证

- **WHEN** 执行 `node --test frontend/tests/`
- **THEN** 过滤（hidden / 超 72h）、排序（含同分）、边界（未来时间戳 / 0 评论）用例全部通过
- **AND** 不引入任何第三方测试依赖

## ADDED Requirements

### Requirement: 热门帖子列表展示

系统 SHALL 以 Server Component 渲染帖子卡片，包含标题、摘要、作者与评论数，`resolved` 帖子显示文本徽标，空列表显示兜底文案。

#### Scenario: 卡片字段与徽标

- **WHEN** 列表有数据
- **THEN** 每张卡片包含标题、摘要、作者、评论数
- **AND** `resolved` 帖子显示「已解决」文本徽标（图标 `aria-hidden`，信息不仅靠颜色）

#### Scenario: 空列表兜底

- **WHEN** 过滤后无任何帖子
- **THEN** 区块显示兜底文案
- **AND** 不出现空白容器或常驻骨架

#### Scenario: 响应式列数

- **WHEN** 视口宽度为 360px 或 ≥768px
- **THEN** 360px 下为单列列表，`md` 及以上为两列网格
- **AND** 摘要超长时截断，不撑破卡片
