# homepage-feature-nav Specification

## Purpose

首页功能导航：以三张入口卡片（旅游社区 / 景点攻略 / AI 助手）把网站三大能力暴露给首次访问的游客。

## Requirements

### Requirement: 功能导航三卡片

系统 SHALL 在首页功能导航区渲染恰好 3 张入口卡片（旅游社区 / 景点攻略 / AI 助手），每张卡片包含图标、标题与一句话描述，并链接到对应目标：`/community`、`/attractions`、`/ai`。

#### Scenario: 三张卡片与目标链接

- **WHEN** 查看 `/` 的功能导航区 DOM
- **THEN** 存在恰好 3 个卡片链接，`href` 分别为 `/community`、`/attractions`、`/ai`

#### Scenario: 卡片内容完整

- **WHEN** 查看任一卡片
- **THEN** 包含可见图标、标题与一句话描述
