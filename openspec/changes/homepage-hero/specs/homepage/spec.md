## MODIFIED Requirements

### Requirement: Hero 内容与搜索占位

系统 SHALL 在 Hero 区块渲染品牌主视觉、标语与可见搜索框（`role="search"`），搜索框仅做占位交互：提交后展示提示，不发起真实搜索请求、不改变 URL、不产生网络请求。

#### Scenario: 首屏渲染

- **WHEN** 访问 `/`
- **THEN** Hero 包含 `h1` 标语文本与 `role="search"` 搜索框
- **AND** 搜索框为空时提交按钮为 `disabled`

#### Scenario: 背景图降级

- **WHEN** Hero 背景图请求失败或网络较慢
- **THEN** CSS 渐变兜底层可见，不出现破图
- **AND** 容器高度固定，CLS 为 0，标语与搜索框保持可读

#### Scenario: 搜索占位交互

- **WHEN** 用户输入关键词并提交搜索框
- **THEN** 展示 `aria-live="polite"` 提示文案
- **AND** URL 不变、页面不跳转、Network 无新增请求

#### Scenario: 键盘与读屏语义

- **WHEN** 用户仅用键盘 Tab 或使用屏幕阅读器
- **THEN** 焦点顺序为输入框 → 提交按钮，且 `focus-visible` 环可见
- **AND** 搜索区被识别为 `search` landmark，输入框有 sr-only `label`，背景图 `alt=""` 且 `aria-hidden`

## ADDED Requirements

### Requirement: Hero 静态区块隔离

Hero SHALL 保持纯静态：不读取城市上下文、不请求数据接口、不随区块降级状态变化。

#### Scenario: 城市切换不影响 Hero

- **WHEN** 用户将城市从 `SHA` 切换到 `BJA`
- **THEN** Hero 的标语、副标题、搜索框与背景均不变
- **AND** 不触发额外数据请求

#### Scenario: 降级隔离

- **WHEN** `/api/home` 任一区块返回 `partialError`
- **THEN** Hero 正常渲染
- **AND** 不显示骨架或重试入口
