## MODIFIED Requirements

### Requirement: 热门景点加权排序

系统 SHALL 仅返回 `status = published` 的景点，按 `view_count_7d × 0.7 + popularity_score × 0.3` 降序取前 8 条；全部无浏览数据时退化为按 `popularity_score` 降序。

#### Scenario: 加权排序

- **WHEN** 用户查看热门景点
- **THEN** 结果按 `viewCount7d × 0.7 + popularityScore × 0.3` 降序，数量 ≤ 8
- **AND** 卡片显示格式化后的浏览量

#### Scenario: 无浏览数据退化

- **WHEN** 该城市全部景点 `viewCount7d` 为 `null` 或 0
- **THEN** 排序退化为按 `popularityScore` 降序
- **AND** 仍只返回 `published` 景点

#### Scenario: 部分缺失按 0 参与

- **WHEN** 部分景点有浏览数据、部分为 `null`
- **THEN** `null` 视作 0 参与加权公式，不触发整体退化
- **AND** 排序不因缺失值抛错

#### Scenario: 纯函数可独立验证

- **WHEN** 执行 `node --test frontend/tests/`
- **THEN** 排序（含同分）、退化、`formatViews` 三档数值用例全部通过
- **AND** 不引入任何第三方测试依赖

## ADDED Requirements

### Requirement: 热门景点卡片展示

系统 SHALL 以 Server Component 渲染景点卡片，包含 `next/image` 封面、名称与格式化浏览量，封面固定宽高比，空列表显示兜底文案。

#### Scenario: 卡片字段与格式化

- **WHEN** 列表有数据
- **THEN** 每张卡片含封面、名称、`formatViews` 结果
- **AND** `12300` 显示 `12.3k views`、`980` 显示 `980 views`、`1200000` 显示 `1.2m views`

#### Scenario: 封面失败兜底

- **WHEN** 封面图 404 或加载失败
- **THEN** 图片容器保留渐变底色，名称与浏览量仍可读
- **AND** 固定宽高比不塌陷

#### Scenario: 空列表兜底

- **WHEN** 过滤后无任何景点
- **THEN** 区块显示兜底文案
- **AND** 不出现空白网格或常驻骨架

#### Scenario: 响应式卡片网格

- **WHEN** 视口宽度为 360px 或 ≥768px
- **THEN** 360px 下为单列（或两列小卡），`md` 及以上为四列网格
- **AND** 卡片等高、封面比例一致
