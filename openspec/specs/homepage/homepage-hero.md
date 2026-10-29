# homepage-hero Specification

## Purpose

首页首屏 Hero 区：品牌主视觉背景、品牌标语、副标题与搜索框。本期为纯静态区块——背景用渐变占位、文案用占位常量、搜索仅 UI 占位，不依赖数据接口，不参与城市切换联动与区块降级。

## Requirements

### Requirement: Hero 区渲染

系统 SHALL 在首页 Hero 区渲染品牌主视觉背景、品牌标语文本、副标题与搜索框；搜索框使用 `role="search"`，包含可见输入框与提交按钮。背景为 CSS 渐变占位（不下载图片资源），标语与副标题为占位常量，定稿后仅替换常量。

#### Scenario: 标语与搜索框渲染

- **WHEN** 查看 `/` 的 Hero 区 DOM
- **THEN** 存在品牌标语文本、副标题文本，以及 `role="search"` 容器（内含 input 与提交按钮）

#### Scenario: 无图片资源请求

- **WHEN** 首次加载 `/`
- **THEN** Hero 背景由 CSS 渐变渲染，不产生图片资源请求

### Requirement: 搜索框占位交互

系统 SHALL 仅提供搜索框 UI 占位：提交时展示「搜索即将上线」提示，不跳转、不发起网络请求。

#### Scenario: 提交搜索不跳转

- **WHEN** 在搜索框输入内容并提交
- **THEN** 页面不跳转，展示「搜索即将上线」提示，且无网络请求

> 交互场景按 Manual Verification 用 Browser 子代理点验。

### Requirement: Hero 与城市上下文隔离

系统 SHALL 将 Hero 视为静态区块：不依赖 `cityCode` 数据，城市切换时不重新拉取，其它区块降级时照常渲染。

#### Scenario: 切换城市不影响 Hero

- **WHEN** 用户把城市从 `SHA` 切换到 `BJA`
- **THEN** Hero 区内容不变，且不触发任何数据请求

#### Scenario: 其它区块 partialError 不影响 Hero

- **WHEN** `/api/home` 某区块返回 `partialError`
- **THEN** Hero 区正常渲染，不显示骨架或重试入口
