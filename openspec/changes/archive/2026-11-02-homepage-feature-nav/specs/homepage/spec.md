## MODIFIED Requirements

### Requirement: 功能导航三入口

系统 SHALL 在 `feature-nav` 区块渲染恰好 3 张卡片，链接分别指向社区、景点、AI 三个目标路由；卡片为纯静态配置，不读取城市上下文、不发起请求、不进入降级态。

#### Scenario: 卡片数量与目标

- **WHEN** 访问 `/`
- **THEN** `feature-nav` 内恰好 3 张卡片
- **AND** 链接分别指向 `/community`、`/attractions`、`/ai`

#### Scenario: 静态区块隔离

- **WHEN** 城市切换或 `/api/home` 返回 `partialError`
- **THEN** 功能导航内容不变化，不进入降级态

#### Scenario: 卡片内容与可访问性

- **WHEN** 查看任一卡片
- **THEN** 包含装饰性图标（`aria-hidden="true"`）、标题与一句话描述
- **AND** 链接的可读名称等于卡片标题

#### Scenario: 响应式列数

- **WHEN** 视口宽度为 360px 或 ≥640px
- **THEN** 360px 下三张卡片纵向单列，无横向滚动、描述不溢出
- **AND** `sm` 及以上为等宽三列，卡片高度对齐
