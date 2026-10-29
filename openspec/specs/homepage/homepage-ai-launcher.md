# homepage-ai-launcher Specification

## Purpose

首页 AI 助手入口：悬浮按钮 + 占位对话面板，并提供 Ask 入口跳转到 `/ask?cityCode=<当前城市>`；本期纯前端实现（无真实对话能力），真实对话由后续独立 spec 承接。

## Requirements

### Requirement: AI 助手悬浮入口

系统 SHALL 在首页提供全局可见的 AI 助手悬浮按钮（固定于右下角，含可访问名称「AI 助手」）；点击后打开占位对话面板。

#### Scenario: 悬浮按钮存在

- **WHEN** 查看 `/` 的 DOM
- **THEN** 存在 `[data-region="ai-launcher"]` 容器，其中包含可访问名称为「AI 助手」的按钮

### Requirement: Ask 入口

系统 SHALL 提供 Ask 入口：点击后跳转 `/ask?cityCode=<当前城市>`，且用户无需登录即可发起第 1 次提问。

#### Scenario: 点 Ask 跳转携带 cityCode（H5-1）

- **WHEN** 用户点击 Ask（当前城市为 `SHA`）
- **THEN** 跳转 `/ask?cityCode=SHA`，且无需登录即可发起第 1 次提问

### Requirement: 占位对话面板

系统 SHALL 在点击悬浮入口后展示占位面板：`role="dialog"`，包含「AI 助手即将上线」文案与关闭按钮；关闭后面板消失，全程不发起网络请求。

#### Scenario: 打开占位面板

- **WHEN** 点击 AI 助手悬浮按钮
- **THEN** 出现 `role="dialog"` 面板，且包含「AI 助手即将上线」文案

#### Scenario: 关闭面板

- **WHEN** 点击面板关闭按钮（或按 ESC）
- **THEN** 面板消失，回到初始状态

#### Scenario: 无网络请求

- **WHEN** 打开并关闭面板
- **THEN** 浏览器 Network 中无任何请求

> 交互场景按 Manual Verification 用 Browser 子代理点验。
