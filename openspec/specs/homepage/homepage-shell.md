# homepage-shell Specification

## Purpose

首页骨架：为 Hero、功能导航、城市入口、热帖、热门景点、AI 入口 6 个区块提供固定顺序的挂载位与全局悬浮挂载点；同时定义首页聚合接口（`/api/home`）契约与区块级降级策略，支撑各区块独立开发、独立交付。

## Requirements

### Requirement: 首页骨架与区块挂载位

系统 SHALL 在 `/` 渲染首页骨架，按固定顺序提供 6 个区块挂载位，每个挂载位带唯一 `data-region` 标识：`hero`、`feature-nav`、`city-grid`、`hot-posts`、`hot-spots`、`ai-launcher`。

#### Scenario: 首页可访问

- **WHEN** 客户端请求 `GET /`
- **THEN** 返回 HTTP 200

#### Scenario: 六个区块占位存在且顺序固定

- **WHEN** 查看 `/` 的 DOM
- **THEN** 存在恰好 6 个 `[data-region]` 元素，取值依次为 `hero`、`feature-nav`、`city-grid`、`hot-posts`、`hot-spots`、`ai-launcher`

### Requirement: 首页 SEO 元数据

系统 SHALL 为首页提供标题与描述元数据。

#### Scenario: 首页元数据存在

- **WHEN** 查看 `/` 的 HTML `<head>`
- **THEN** 存在 `<title>` 与 `description` meta，且标题包含 `WanderChina`

### Requirement: 首页聚合数据接口

系统 SHALL 提供 `GET /api/home?cityCode=<CODE>` 聚合接口，一次返回首页各城市维度区块数据（editor picks、热门景点、热门帖子），并按 `cityCode` 过滤。

#### Scenario: 编辑精选按 position 升序返回（H2-1）

- **WHEN** 请求 `GET /api/home?cityCode=SHA`，且该城市有 3 条生效中的 `editor_pick`
- **THEN** `picks` 数组长度为 3 且按 `position` 升序排列，每项包含 `type`、`refId`、`title`、`imageUrl`、`lastVerifiedAt`、`openingDate`

#### Scenario: 失效引用自动剔除且不补位（H2-2）

- **WHEN** 某条被置顶的攻略 `status ≠ published`，或帖子 `status = hidden`
- **THEN** 该项从 `picks` 中自动剔除且接口不报错，且不做补位（保持 `position` 语义，避免运营误判生效范围）

### Requirement: 区块级故障降级

系统 SHALL 在单个区块查询失败时仅降级该区块，不影响其它区块与整页渲染。

#### Scenario: 单区块失败返回 partialError（H5-2）

- **WHEN** `GET /api/home` 的某一区块查询失败
- **THEN** 该区块返回空数组并带 `partialError` 标记，其余区块正常返回

#### Scenario: 前端按区块降级（H5-2）

- **WHEN** 某区块响应带 `partialError`
- **THEN** 前端该区块展示骨架 + 重试入口，其余区块正常展示，不出现整页错误页
