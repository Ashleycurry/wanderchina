## MODIFIED Requirements

### Requirement: AI 入口与 Ask 跳转

系统 SHALL 在 `ai-launcher` 提供悬浮入口与占位面板，面板展示 `AI 助手即将上线` 且不发起任何网络请求；`Ask` 按钮跳转 `/ask?cityCode=<当前城市>`。

#### Scenario: 打开与关闭面板

- **WHEN** 用户点击悬浮入口
- **THEN** 打开 `role="dialog"` 占位面板，焦点移入面板
- **AND** 可通过关闭按钮、ESC、点击遮罩三种方式关闭

#### Scenario: Ask 跳转

- **WHEN** 当前城市为 `SHA` 且用户点击 `Ask`
- **THEN** 跳转 `/ask?cityCode=SHA`
- **AND** 无需登录即可发起第 1 次提问

#### Scenario: 无网络请求

- **WHEN** 打开并关闭占位面板
- **THEN** Network 中无新增请求
- **AND** 组件源码不含 `fetch` / `axios` 调用

#### Scenario: 切换城市后携带新城市

- **WHEN** 用户将城市从 `SHA` 切换到 `BJA` 后点击 `Ask`
- **THEN** 跳转 `/ask?cityCode=BJA`
- **AND** 入口不缓存旧城市代码

## ADDED Requirements

### Requirement: AI 入口无障碍与响应式

系统 SHALL 使 AI 入口可纯键盘操作、焦点在打开与关闭之间正确流转，并在移动端避开安全区、不遮挡页面底部内容。

#### Scenario: 键盘可达与焦点管理

- **WHEN** 用户仅用键盘操作
- **THEN** Tab 可聚焦悬浮按钮，Enter / Space 打开面板
- **AND** 打开后焦点进入面板，关闭后焦点回到悬浮按钮

#### Scenario: 移动端安全区

- **WHEN** 视口宽度为 360px
- **THEN** 按钮固定在右下角并避开 `safe-area-inset-bottom`
- **AND** 不遮挡页面底部可点击元素

#### Scenario: 降级隔离

- **WHEN** `/api/home` 某区块返回 `partialError`
- **THEN** AI 入口正常渲染与交互
- **AND** 不显示骨架或重试入口
