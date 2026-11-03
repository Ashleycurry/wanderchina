# homepage-feature-nav Specification

## Purpose

首页功能导航：以三张静态入口卡片（旅游社区 / 景点攻略 / AI 助手）把网站三大能力暴露给首次访问的游客。目标路由本期为占位页，不依赖数据接口，不参与城市联动与区块降级。

技术栈约束：Next.js 14 App Router（Server Component，无客户端状态）+ Tailwind CSS 3.4 + lucide-react 图标。

## 1. 模块边界

### 1.1 包含

| 项 | 说明 |
| --- | --- |
| 三张入口卡片 | 旅游社区 `/community`、景点攻略 `/attractions`、AI 助手 `/ai` |
| 卡片内容 | 图标（lucide-react）+ 标题 + 一句话描述，整卡为链接 |
| 响应式网格 | mobile-first：360px 单列，`sm` 起三列 |
| 静态数据 | 卡片配置为模块内常量，可整体替换 |

### 1.2 不包含

| 项 | 归属 |
| --- | --- |
| 三个目标页面的实现 | 后续路由变更（本期允许占位页/404） |
| AI 悬浮面板与 Ask 跳转 | `homepage-ai-launcher` |
| 点击埋点 / 行为分析 | 后续独立 spec |
| 任何数据接口、城市上下文 | `homepage-shell` / `homepage-city-grid` |

### 1.3 技术约束

- Server Component，无 `'use client'`、无状态、无请求
- 卡片链接使用 `next/link`，`href` 为静态字符串
- 图标为装饰性，`aria-hidden="true"`；可读名称由卡片标题承担（`aria-labelledby` 绑定标题 id，描述不进 accessible name）
- 只用 Tailwind 工具类；不新增 npm 依赖

## 2. 核心场景

### S1 渲染恰好 3 张卡片【正常】

- **WHEN** 查看 `/` 的功能导航区 DOM
- **THEN** 存在恰好 3 个卡片链接
- **AND** 不出现第 4 个入口或重复卡片

### S2 目标链接正确【正常】

- **WHEN** 检查 3 张卡片的 `href`
- **THEN** 分别为 `/community`、`/attractions`、`/ai`

### S3 卡片内容完整【正常】

- **WHEN** 查看任一卡片
- **THEN** 包含可见图标、标题与一句话描述
- **AND** 图标对 AT 隐藏，标题即链接可读名称

### S4 目标路由占位【边界】

- **WHEN** 点击任一卡片
- **THEN** 跳转到对应 `href`
- **AND** 目标页本期可为占位页/404，由后续路由变更承接

### S5 移动端单列【正常】

- **WHEN** 视口 360px
- **THEN** 三张卡片纵向单列排列
- **AND** 无横向滚动、描述文本不溢出

### S6 桌面三列【正常】

- **WHEN** 视口 ≥640px（`sm`）
- **THEN** 三张卡片等宽三列，间距一致
- **AND** 卡片高度对齐（同色系边框/阴影）

### S7 键盘可达【正常】

- **WHEN** 用户仅用键盘 Tab 导航
- **THEN** 依次聚焦 3 个卡片链接
- **AND** 焦点样式可见（`focus-visible` 环）

### S8 城市切换隔离【隔离】

- **WHEN** 用户切换城市（`SHA` → `BJA`）
- **THEN** 卡片图标、标题、描述、`href` 均不变
- **AND** 不触发数据请求

### S9 区块降级隔离【隔离】

- **WHEN** `/api/home` 某区块返回 `partialError`
- **THEN** 功能导航区正常渲染
- **AND** 不显示骨架或重试入口

### S10 文案缺失兜底【异常】

- **WHEN** 某卡片配置缺少描述字段（配置错误）
- **THEN** 构建期类型报错（`description` 为必填）
- **AND** 运行期不渲染空描述卡片

## 3. 数据结构

### 3.1 卡片配置

```ts
import type { LucideIcon } from 'lucide-react';

/** 卡片唯一键，与目标页一一对应 */
export type FeatureNavKey = 'community' | 'attractions' | 'ai';

export interface FeatureNavItem {
  key: FeatureNavKey;
  /** 必填；卡片标题，1-12 字符 */
  title: string;
  /** 必填；一句话描述，1-40 字符，移动端最多 2 行 */
  description: string;
  /** 必填；站内路径，以 / 开头 */
  href: string;
  /** 必填；lucide 图标组件（装饰性） */
  icon: LucideIcon;
}
```

### 3.2 组件 Props

```ts
/** src/components/homepage/feature-nav.tsx —— Server Component */
export interface FeatureNavProps {
  /** 可选；缺省使用 DEFAULT_FEATURE_NAV_ITEMS（3 项常量） */
  items?: FeatureNavItem[];
  className?: string;
}
```

### 3.3 约束与默认值

| 项 | 约束 | 默认值 |
| --- | --- | --- |
| 数量 | 恰好 3 项；多于/少于 3 视为配置错误 | 3 项常量 |
| `key` | 唯一，取值限于 3 个枚举 | `community` / `attractions` / `ai` |
| `href` | 静态字符串，以 `/` 开头 | `/community`、`/attractions`、`/ai` |
| `description` | 必填，≤40 字符 | 占位文案（定稿只换常量） |
| 状态 | 无状态、无请求、无 `'use client'` | — |

### 3.4 文件与依赖

```
frontend/src/components/homepage/feature-nav.tsx   # Server Component + 3 项常量
```

图标来自已安装的 `lucide-react`（如 `Users` / `Map` / `Sparkles`），不新增依赖。

## 4. 验收标准（ACCEPTANCE Checklist）

### 4.1 渲染与内容

- [ ] 功能导航区渲染恰好 3 张卡片
- [ ] 3 个 `href` 分别为 `/community`、`/attractions`、`/ai`
- [ ] 每张卡片含可见图标、标题与一句话描述
- [ ] 图标 `aria-hidden="true"`，链接可读名称等于标题

### 4.2 布局与交互

- [ ] 360px：单列、无横向滚动、描述不溢出
- [ ] ≥640px：三列等宽、间距一致、卡片高度对齐
- [ ] Tab 依次可达 3 个卡片，焦点样式可见
- [ ] 点击卡片跳转到对应 `href`（目标页可 404）

### 4.3 隔离与架构

- [ ] 切换城市后卡片内容与 `href` 不变、无请求
- [ ] `/api/home` 某区块 `partialError` 时导航区正常渲染
- [ ] `feature-nav.tsx` 无 `'use client'`、无 `fetch`、无状态
- [ ] 未新增 npm 依赖

### 4.4 手动验证步骤

1. `npm run build && npm run start`，`curl http://localhost:3000/` 断言 3 个 `href`
2. 360px / 640px / 1440px 三档截屏检查列数与对齐
3. 键盘 Tab 三张卡片，检查焦点顺序与样式
4. 点击三张卡片，确认跳转目标与预期一致（允许 404）
