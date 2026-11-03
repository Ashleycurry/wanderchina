# homepage-ai-launcher Specification

## Purpose

首页 AI 助手入口：悬浮按钮 + 占位对话面板，并提供 Ask 入口跳转到 `/ask?cityCode=<当前城市>`；本期纯前端实现（无真实对话能力），真实对话由后续独立 spec 承接。

技术栈约束：Next.js 14 App Router（Client Component）+ Tailwind CSS 3.4 + shadcn/ui（`Button`、`Sheet`/`Dialog` 源码 vendored）+ lucide-react 图标。

## 1. 模块边界

### 1.1 包含

| 项 | 说明 |
| --- | --- |
| 悬浮按钮 | 固定右下角，含可访问名称「AI 助手」，`data-region="ai-launcher"` 容器 |
| 占位面板 | `role="dialog"`，含「AI 助手即将上线」与关闭按钮；ESC / 遮罩 / 关闭按钮均可关闭 |
| Ask 入口 | 跳转 `/ask?cityCode=<当前城市>`；无需登录即可发起第 1 次提问 |
| 无障碍 | 打开时焦点进入面板、关闭后焦点回到触发按钮、`aria-expanded` / `aria-controls` |

### 1.2 不包含

| 项 | 归属 |
| --- | --- |
| 真实对话、消息流、流式响应 | 后续独立 spec |
| `/ask` 页面实现、会话存储 | 后续独立 spec（本期只保证跳转链接正确） |
| 登录、鉴权、配额限制 | 后续独立 spec（本期免登录可用） |
| 后端 AI 接口（Spring AI） | 后续后端 spec |

### 1.3 技术约束

- 唯一 `'use client'` 组件；状态仅 `open: boolean`
- 面板使用 shadcn `Dialog`/`Sheet` 等价源码（`src/components/ui/`），不引入黑盒包
- 全程无网络请求（本期）
- 悬浮按钮 `position: fixed`，移动端考虑 `safe-area-inset-bottom`
- 悬浮按钮与关闭按钮的触摸目标 ≥ 44×44px（`h-11 w-11` 或等效）
- 不做颜色过渡：动效基线只允许 transform / opacity，`prefers-reduced-motion` 由 `globals.css` 全局媒体查询兜底

## 2. 核心场景

### S1 悬浮按钮存在【正常】

- **WHEN** 查看 `/` 的 DOM
- **THEN** 存在 `[data-region="ai-launcher"]` 容器
- **AND** 其中包含可访问名称为「AI 助手」的按钮

### S2 打开占位面板【正常】

- **WHEN** 点击 AI 助手悬浮按钮
- **THEN** 出现 `role="dialog"` 面板，含「AI 助手即将上线」文案
- **AND** `aria-expanded` 变为 `true`

### S3 关闭面板【正常】

- **WHEN** 点击面板关闭按钮（或按 ESC、或点遮罩）
- **THEN** 面板消失，回到初始状态
- **AND** 焦点回到悬浮按钮

### S4 无网络请求【隔离】

- **WHEN** 打开并关闭面板
- **THEN** 浏览器 Network 中无新增请求
- **AND** 不产生任何后端调用

### S5 点 Ask 跳转携带 cityCode【正常】

- **WHEN** 用户点击 Ask（当前城市为 `SHA`）
- **THEN** 跳转 `/ask?cityCode=SHA`
- **AND** 无需登录即可发起第 1 次提问（由 `/ask` 页面承接）

### S6 切换城市后 Ask 携带新城市【正常】

- **WHEN** 用户将城市从 `SHA` 切换到 `BJA` 后点击 Ask
- **THEN** 跳转 `/ask?cityCode=BJA`
- **AND** 入口不缓存旧城市代码

### S7 键盘可达与焦点管理【正常】

- **WHEN** 用户仅用键盘操作
- **THEN** Tab 可聚焦悬浮按钮，Enter/Space 打开面板
- **AND** 打开后焦点进入面板内首个可聚焦元素，关闭后焦点回到按钮

### S8 移动端不遮挡关键内容【正常】

- **WHEN** 视口 360px
- **THEN** 按钮固定在右下角，避开 `safe-area-inset-bottom`
- **AND** 不遮挡页面底部可点击元素（`main` 底部预留 ≥ 96px 内边距）

### S9 区块降级不影响入口【隔离】

- **WHEN** `/api/home` 某区块返回 `partialError`
- **THEN** AI 入口正常渲染与交互
- **AND** 不显示骨架或重试入口

### S10 减少动效【正常】

- **WHEN** 系统开启 `prefers-reduced-motion: reduce`
- **THEN** 面板打开/关闭无位移动效
- **AND** 功能不受影响

## 3. 数据结构

### 3.1 组件 Props

```ts
export type CityCode = 'SHA' | 'BJA' | 'SIA' | 'CTU' | 'HGH' | 'KWL' | 'LJG' | 'SUZ';

/** src/components/homepage/ai-launcher.tsx —— Client Component（'use client'） */
export interface AiLauncherProps {
  /** 必填；当前城市，用于拼接 Ask 链接 */
  cityCode: CityCode;
  /** 可选；Ask 目标地址，默认 `/ask?cityCode=${cityCode}` */
  askHref?: string;
  /** 可选；面板占位文案，默认「AI 助手即将上线」 */
  placeholderText?: string;
  className?: string;
}
```

### 3.2 内部状态与常量

```ts
interface AiLauncherState {
  open: boolean;   // 面板开关
}

export const DEFAULT_PLACEHOLDER = 'AI 助手即将上线';
export const ASK_LABEL = 'Ask';
export const LAUNCHER_ARIA_LABEL = 'AI 助手';
```

### 3.3 约束与默认值

| 项 | 约束 | 默认值 |
| --- | --- | --- |
| `askHref` | 必须以 `/ask?cityCode=` 开头，cityCode 取自 props | `/ask?cityCode=${cityCode}` |
| 面板语义 | `role="dialog"` + `aria-modal="true"` + 可读标题 | — |
| 关闭方式 | 关闭按钮 / ESC / 遮罩三种方式均可用 | — |
| 请求 | 组件内禁止 `fetch` / `axios` | — |
| 定位 | `fixed` 右下角，`z-index` 高于内容层，`pb-[env(safe-area-inset-bottom)]` | — |

### 3.4 文件与依赖

```
frontend/src/
├── components/homepage/ai-launcher.tsx   # 'use client'
└── components/ui/
    ├── button.tsx                        # shadcn 等价源码
    └── dialog.tsx                        # shadcn 等价源码（或 sheet.tsx）
```

不新增 npm 依赖。

## 4. 验收标准（ACCEPTANCE Checklist）

### 4.1 入口与面板

- [ ] `[data-region="ai-launcher"]` 容器存在，按钮可访问名称为「AI 助手」
- [ ] 点击按钮出现 `role="dialog"` 面板，含「AI 助手即将上线」
- [ ] 关闭按钮 / ESC / 遮罩三种方式均可关闭
- [ ] 打开时 `aria-expanded="true"`，关闭后恢复 `false`

### 4.2 Ask 入口

- [ ] 当前城市 `SHA` 时 Ask 跳转 `/ask?cityCode=SHA`
- [ ] 切换到 `BJA` 后 Ask 跳转 `/ask?cityCode=BJA`
- [ ] `/ask` 页面无需登录即可发起第 1 次提问（本期链接即满足）

### 4.3 无请求与隔离

- [ ] 打开/关闭面板全程 Network 无新增请求
- [ ] 组件内无 `fetch` / `axios`
- [ ] `/api/home` 某区块 `partialError` 时入口正常可用

### 4.4 无障碍与响应式

- [ ] 键盘 Tab 可达按钮，Enter/Space 可打开
- [ ] 打开后焦点进入面板，关闭后焦点回到按钮
- [ ] 360px 下按钮不遮挡底部可点击元素，避开 safe-area（`main` 底部 ≥ 96px）
- [ ] 悬浮按钮与关闭按钮触摸目标 ≥ 44×44px
- [ ] `prefers-reduced-motion: reduce` 下无位移动效

### 4.5 手动验证步骤

1. `npm run build && npm run start`，`curl` 断言 `data-region="ai-launcher"` 与按钮可访问名称
2. 浏览器点击打开面板，验证文案与三种关闭方式
3. 打开 DevTools Network，确认无请求；检查 Ask 跳转 URL 携带当前 cityCode
4. 切城市到 BJA 后再次点 Ask，确认 URL 为 `?cityCode=BJA`
5. 键盘走查：Tab → Enter 打开 → ESC 关闭 → 焦点回到按钮
