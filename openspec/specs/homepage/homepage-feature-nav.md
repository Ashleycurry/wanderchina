# homepage-feature-nav Specification

## Purpose

首页功能导航：以三张静态入口卡片（旅游社区 / 景点攻略 / AI 助手）把网站三大能力暴露给首次访问的游客。目标路由本期为占位页，不依赖数据接口，不参与城市联动与区块降级。

## Requirements

### Requirement: 功能导航三卡片

系统 SHALL 在首页功能导航区渲染恰好 3 张入口卡片（旅游社区 / 景点攻略 / AI 助手），每张卡片包含图标、标题与一句话描述，并链接到对应目标：`/community`、`/attractions`、`/ai`。

#### Scenario: 三张卡片与目标链接

- **WHEN** 查看 `/` 的功能导航区 DOM
- **THEN** 存在恰好 3 个卡片链接，`href` 分别为 `/community`、`/attractions`、`/ai`

#### Scenario: 卡片内容完整

- **WHEN** 查看任一卡片
- **THEN** 包含可见图标、标题与一句话描述

#### Scenario: 目标路由占位

- **WHEN** 点击任一卡片
- **THEN** 跳转到对应 `href`；目标页本期可为占位页/404，由后续路由变更承接

### Requirement: 静态隔离与 AI 入口分工

系统 SHALL 将功能导航视为静态区块：不依赖 `cityCode`，不参与 `/api/home` 区块降级。AI 助手卡片指向 `/ai` 占位页；站内即时唤起由 `homepage-ai-launcher` 的悬浮入口承担（含 Ask 跳转 `/ask?cityCode=<当前城市>`），两者分工不重叠。

#### Scenario: 切换城市不改变卡片

- **WHEN** 用户切换城市（如 `SHA` → `BJA`）
- **THEN** 三张卡片的图标、标题、描述与 `href` 均不变化，不触发数据请求

#### Scenario: AI 卡片与悬浮入口分工

- **WHEN** 用户点击功能导航中的「AI 助手」卡片
- **THEN** 跳转 `/ai` 占位页，不打开悬浮对话面板（悬浮面板由 `homepage-ai-launcher` 在页面任意位置唤起）

#### Scenario: 其它区块 partialError 不影响导航

- **WHEN** `/api/home` 某区块返回 `partialError`
- **THEN** 功能导航区正常渲染，不显示骨架或重试入口
