# homepage-hot-spots Specification

## Purpose

首页热门景点推荐：仅取 `status = published` 景点，按近 7 日浏览与编辑权重加权排序，最多 8 条；无浏览数据时退化为编辑权重排序。数据先用 mock 契约占位，真实接口由后续独立 spec 承接。

## Requirements

### Requirement: 热门景点卡片列表

系统 SHALL 仅返回 `status = published` 的景点，最多 8 条；排序键为 `近 7 日 view_count × 0.7 + popularity_score × 0.3` 降序；当无任何浏览数据时，退化为按 `popularity_score`（编辑手工权重）降序。每张卡片包含封面、名称、格式化浏览量，并链接到 `/city/<slug>`。

#### Scenario: 按加权分数降序返回 ≤8 条（H3-1）

- **WHEN** 用户查看热门景点，且该城市有浏览数据
- **THEN** 返回 `status = published` 的景点 ≤8 条，按 `近 7 日 view_count × 0.7 + popularity_score × 0.3` 降序

#### Scenario: 无浏览数据退化为编辑权重排序（H3-1）

- **WHEN** 该城市无任何浏览数据
- **THEN** 排序退化为按 `popularity_score`（编辑手工权重）降序，仍只返回 `published` 景点

#### Scenario: 卡片内容与链接

- **WHEN** 查看任一景点卡片
- **THEN** 可见封面、名称与格式化浏览量（如 `12.3k views`），且 `href` 形如 `/city/<slug>`

#### Scenario: 排序逻辑可独立验证

- **WHEN** 对乱序 mock 数据执行 `rankHotSpots(spots)`，且 mock 中含权重字段与浏览数
- **THEN** 返回结果按加权分数单调不增；浏览数据全为空时按 `popularity_score` 单调不增（用 Node 内置 `node --test` 验证）
