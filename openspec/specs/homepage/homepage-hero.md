# homepage-hero Specification

## Purpose

首页首屏 Hero 区：品牌主视觉背景、品牌标语、副标题与搜索框（本期仅 UI 占位，不做搜索功能）。

## Requirements

### Requirement: Hero 区渲染

系统 SHALL 在首页 Hero 区渲染品牌主视觉背景、品牌标语文本、副标题与搜索框；搜索框使用 `role="search"`，包含可见输入框与提交按钮。

#### Scenario: 标语与搜索框渲染

- **WHEN** 查看 `/` 的 Hero 区 DOM
- **THEN** 存在品牌标语文本、副标题文本，以及 `role="search"` 容器（内含 input 与提交按钮）

### Requirement: 搜索框占位交互

系统 SHALL 仅提供搜索框 UI 占位：提交时展示「搜索即将上线」提示，不跳转、不发起网络请求。

#### Scenario: 提交搜索不跳转

- **WHEN** 在搜索框输入内容并提交
- **THEN** 页面不跳转，展示「搜索即将上线」提示，且无网络请求

> 交互场景按 Manual Verification 用 Browser 子代理点验。
