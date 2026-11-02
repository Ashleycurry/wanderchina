## MODIFIED Requirements

### Requirement: 首页骨架与挂载位

系统 SHALL 在 `GET /` 渲染恰好 6 个固定顺序的区块挂载位，取值依次为 `hero`、`feature-nav`、`city-grid`、`hot-posts`、`hot-spots`、`ai-launcher`；页面为 Server Component，骨架不 import 任何区块实现，区块以 `src/components/homepage/regions/` 下的占位组件形式挂载。完整规格见 `openspec/specs/homepage/homepage-shell.md`。

#### Scenario: 首页可访问且区块齐全

- **WHEN** 客户端请求 `GET /`
- **THEN** 返回 HTTP 200
- **AND** DOM 中存在恰好 6 个 `[data-region]` 元素，取值顺序为 `hero` → `feature-nav` → `city-grid` → `hot-posts` → `hot-spots` → `ai-launcher`

#### Scenario: SEO 元数据

- **WHEN** 查看 `/` 的 HTML `<head>`
- **THEN** 存在包含 `WanderChina` 的 `<title>`
- **AND** 存在非空 `description` meta

#### Scenario: 响应式布局

- **WHEN** 视口宽度为 360px / 768px / 1440px
- **THEN** 页面无横向滚动，区块垂直间距一致
- **AND** 内容容器在 `md` 及以上居中并限制最大宽度

#### Scenario: 骨架与区块解耦

- **WHEN** 检查 `src/app/page.tsx`
- **THEN** 其仅 import `src/components/homepage/regions/` 下的占位组件与 `region-boundary.tsx`
- **AND** 不 import 任何 `homepage-hero` 等区块实现

### Requirement: 首页聚合接口契约

系统 SHALL 提供 `GET /api/home?cityCode=<CODE>`，返回 `{ cityCode, picks, hotSpots, hotPosts, partialError? }`；`picks` 按 `position` 升序且失效引用直接剔除、不补位；未携带 `cityCode` 时按 `wc_city` cookie 取值，缺失或非法回退 `SHA`，并在响应中回显实际使用的 `cityCode`。

#### Scenario: 编辑精选按 position 升序

- **WHEN** 请求 `GET /api/home?cityCode=SHA`，且该城市有 3 条生效中的 `editor_pick`
- **THEN** `picks` 长度为 3 且按 `position` 升序
- **AND** 每项包含 `type`、`refId`、`title`、`imageUrl`、`lastVerifiedAt`、`openingDate`

#### Scenario: 失效引用自动剔除

- **WHEN** 某条置顶攻略 `status ≠ published`，或帖子 `status = hidden`
- **THEN** 该项从 `picks` 中剔除，接口仍返回 200
- **AND** 不做补位（保持 `position` 语义）

#### Scenario: 城市参数回退

- **WHEN** 请求 `/api/home` 未携带 `cityCode`，且 `wc_city` cookie 缺失或取值非法
- **THEN** 服务端回退 `SHA` 取数
- **AND** 响应 `cityCode` 字段回显 `SHA`

### Requirement: 区块级降级

系统 SHALL 对 `picks` / `hotSpots` / `hotPosts` 三个数据区块做独立降级：单区块失败时该区块返回空数组并在 `partialError` 中标记，其余区块正常返回；前端按区块展示骨架与重试入口，不出现整页错误页。

#### Scenario: 单区块失败

- **WHEN** 请求 `GET /api/home?fail=hotSpots`
- **THEN** `hotSpots` 为 `[]` 且 `partialError.hotSpots === true`
- **AND** `picks`、`hotPosts` 数据正常返回

#### Scenario: 前端按区块降级

- **WHEN** 某区块响应带 `partialError`
- **THEN** 该区块渲染骨架与重试入口
- **AND** 其余区块正常展示，页面不跳转错误页

#### Scenario: 全部区块失败仍可访问

- **WHEN** `picks`、`hotSpots`、`hotPosts` 全部失败
- **THEN** `GET /` 仍返回 200
- **AND** 三个区块均渲染骨架与重试入口

#### Scenario: 重试可键盘触发

- **WHEN** 焦点位于重试按钮并按 Enter 或 Space
- **THEN** 触发重新取数，骨架保持到数据返回

## ADDED Requirements

### Requirement: 降级容器契约

系统 SHALL 提供 `RegionBoundary`（Client Component）统一承载骨架与重试，支持 `skeleton` 档位 `card-row` / `card-grid` / `text-block`，骨架高度按档位预留以减小布局抖动；重试默认调用 `router.refresh()`。

#### Scenario: 骨架档位生效

- **WHEN** 区块以 `skeleton="card-grid"` 传入 `RegionBoundary` 并处于错误态
- **THEN** 渲染与卡片网格高度近似的骨架
- **AND** 显示可聚焦的重试按钮

#### Scenario: 无交互依赖

- **WHEN** 调用方未传 `onRetry`
- **THEN** 点击重试仍能重新取数（默认 `router.refresh()`）
- **AND** 组件不因缺少回调而报错或禁用按钮
