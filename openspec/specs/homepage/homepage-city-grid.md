# homepage-city-grid Specification

## Purpose

首页城市快速入口：以图标网格提供 8 个 MVP 城市的跳转入口；同时维护城市上下文（`wc_city` cookie、默认城市 SHA、请求头 `cityCode`），支撑城市切换后的区块联动。城市清单与切换联动先用 mock 数据占位。

## Requirements

### Requirement: 城市快速入口网格

系统 SHALL 在首页渲染恰好 8 个城市入口项，每项包含图标与城市名，并链接到 `/city/<slug>`；8 个 slug 为：`beijing`、`shanghai`、`xian`、`chengdu`、`hangzhou`、`guilin`、`lijiang`、`suzhou`。

#### Scenario: 渲染 8 个城市项

- **WHEN** 查看 `/` 的城市网格 DOM
- **THEN** 存在恰好 8 个城市项

#### Scenario: 每项链接形如 /city/<slug>

- **WHEN** 查看任一城市项
- **THEN** 其 `href` 形如 `/city/<slug>`，且 slug 属于上述 8 个之一

### Requirement: 城市上下文与默认城市

系统 SHALL 以 `wc_city` cookie 维护当前城市；请求无该 cookie 时默认使用 `SHA`，写入 `wc_city` 并在后续请求头中回传 `cityCode`。

#### Scenario: 首次访问无 cookie（H1-1）

- **WHEN** 用户首次打开首页且无 `wc_city` cookie
- **THEN** 系统返回默认城市（`SHA`）的内容，并写入 `wc_city` cookie，后续请求头中回传 `cityCode`

### Requirement: 城市切换联动

系统 SHALL 在城市切换后刷新全部依赖城市维度的区块，并保持 URL 干净。

#### Scenario: 切换到 BJA（H1-2）

- **WHEN** 用户切换城市到 `BJA`
- **THEN** 三个区块（editor picks / 热门景点 / 热门帖子）数据全部替换为北京，URL 不含脏参数，空区块显示兜底文案而非空白网格
