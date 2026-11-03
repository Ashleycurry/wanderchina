# homepage-hero Specification

## Purpose

首页首屏 Hero 区：品牌主视觉背景、品牌标语、副标题与搜索框。本期为纯静态区块——背景用占位资源 + 渐变兜底、文案用占位常量、搜索仅 UI 占位，不依赖数据接口，不参与城市切换联动与区块降级。

技术栈约束：React 18.3 + Next.js 14 App Router + TypeScript 5.9 + Tailwind CSS 3.4 + shadcn/ui（源码 vendored）。

## 1. 模块边界

### 1.1 包含

| 项 | 说明 |
| --- | --- |
| 品牌主视觉背景 | `next/image` 渲染（`fill` + `object-cover`），本地占位资源 `public/images/hero-placeholder.svg`；渐变叠加层作为兜底与文字对比度保障 |
| 品牌标语 | `<h1>`，来自 `HeroContent.headline`（当前为占位常量，定稿后只换常量） |
| 副标题 | `<p>`，来自 `HeroContent.subheadline` |
| 搜索框 UI | `role="search"` 容器 + `label`（sr-only）+ shadcn `Input` + `Button`；提交展示「搜索即将上线」提示（`aria-live="polite"`） |
| 响应式排版 | mobile-first（360px 起单列），`md:` 以上内容居中、限制最大宽度 |
| 无障碍 | landmark 语义、焦点可见、`prefers-reduced-motion` 适配 |

### 1.2 不包含

| 项 | 归属 |
| --- | --- |
| 真实搜索（全站搜索、结果页、搜索 API） | 后续独立 spec（本期提交只展示提示） |
| 城市选择与城市上下文（`wc_city` / `cityCode`） | `homepage-city-grid` |
| 任何数据请求（`/api/home` 等） | `homepage-shell` + 各数据区块 |
| AI 助手唤起 / Ask 跳转 | `homepage-ai-launcher` |
| 背景图运营配置、CDN 上传 | 后续内容运营 spec（本期仅本地占位资源） |
| 多语言 / 国际化文案体系 | 后续独立 spec |

### 1.3 技术约束

- **运行环境**：Next.js 14 App Router；`Hero` 为 Server Component，唯一客户端边界是 `SearchBox`（`'use client'`）
- **样式**：只用 Tailwind 工具类；不自写 CSS 文件
- **组件**：shadcn/ui 组件源码落 `src/components/ui/`（`Input`、`Button`）；不执行联网 CLI，按等价源码 vendored
- **图片**：必须使用 `next/image`（禁止裸 `<img>`）；背景图 `fill` + `sizes="100vw"` + `priority`（LCP）
- **响应式**：mobile-first，断点仅用 `sm` / `md` / `lg`
- **动效**：仅允许 transform/opacity 过渡；`prefers-reduced-motion: reduce` 时全部关闭

## 2. 核心场景

> 每条场景格式：WHEN / THEN / AND；标注【正常】【异常】【边界】【隔离】。

### S1 首次渲染【正常】

- **WHEN** 用户访问 `/`
- **THEN** Hero 区渲染品牌标语（`h1`）、副标题与搜索框
- **AND** 背景由 `next/image` 渲染且带 `priority`

### S2 移动端布局（360px）【正常】

- **WHEN** 视口宽度为 360px
- **THEN** 内容单列、文字不溢出、搜索框占满可用宽度
- **AND** 页面无横向滚动条

### S3 桌面布局（≥768px）【正常】

- **WHEN** 视口宽度 ≥768px
- **THEN** 内容居中，最大宽度由 `main` 外壳的 `max-w-screen-md`（768px）限定，两侧留白（`mx-auto`）
- **AND** Hero 最小高度足够容纳完整文案与搜索框（不裁切）

### S4 搜索提交【正常】

- **WHEN** 用户输入关键词并提交
- **THEN** 展示 `Search is coming soon.` 提示（`aria-live="polite"`，可由 `search.hint` 覆写）
- **AND** 页面不跳转、URL 不变、无任何网络请求

### S5 空输入提交【边界】

- **WHEN** 输入框为空（或仅空白字符）时
- **THEN** 提交按钮为禁用态（`disabled`）
- **AND** 不产生提示、不触发提交逻辑

### S6 背景图加载失败【异常】

- **WHEN** 占位背景图 404 或解码失败
- **THEN** 渐变叠加层仍可见，Hero 布局不塌陷
- **AND** 标语与副标题保持可读（文字与底色对比度 ≥ 4.5:1）

### S7 图片未加载完成 / 慢网【异常】

- **WHEN** 背景图仍在加载
- **THEN** 渐变占位先渲染，无布局抖动（CLS = 0：`fill` + 固定高度容器）
- **AND** 文案与搜索框不被背景加载阻塞

### S8 键盘可达与焦点【正常】

- **WHEN** 用户仅用键盘 Tab 导航且输入框非空
- **THEN** 焦点顺序为：输入框 → 提交按钮
- **AND** 输入为空时按钮 `disabled`、按 S5 不可聚焦，Tab 直接跳过该按钮
- **AND** 焦点样式可见（`focus-visible` 环），无焦点陷阱

### S9 屏幕阅读器语义【正常】

- **WHEN** 屏幕阅读器读取 Hero 区
- **THEN** 搜索区被识别为 `search` landmark
- **AND** 输入框有可读标签（`label` sr-only），装饰性背景图对 AT 隐藏（`alt=""` + `aria-hidden`）

### S10 减少动效偏好【正常】

- **WHEN** 系统开启 `prefers-reduced-motion: reduce`
- **THEN** Hero 内过渡/位移动效全部关闭
- **AND** 内容与功能不受影响

### S11 城市切换隔离【隔离】

- **WHEN** 用户将城市从 `SHA` 切换到 `BJA`
- **THEN** Hero 内容不变
- **AND** 不触发任何数据请求

### S12 区块降级隔离【隔离】

- **WHEN** `/api/home` 某区块返回 `partialError`
- **THEN** Hero 正常渲染
- **AND** 不显示骨架屏或重试入口

## 3. 数据结构（组件 Props）

### 3.1 文案与资源配置

```ts
/** 背景图配置：本地占位资源，装饰性图片 */
export interface HeroBackground {
  /** 必填；项目内路径，形如 /images/hero-placeholder.svg */
  src: string;
  /** 装饰性背景固定为空串（对 AT 隐藏） */
  alt: '';
  /** 可选 LQIP 占位（base64），无则用渐变兜底 */
  blurDataURL?: string;
}

/** 搜索框配置 */
export interface HeroSearchConfig {
  /** 必填；输入框 placeholder，1-40 字符 */
  placeholder: string;
  /** 必填；提交按钮文案，1-12 字符 */
  submitLabel: string;
  /** 可选；提交后的提示文案，默认「搜索即将上线」 */
  hint?: string;
}

/** Hero 全部内容 */
export interface HeroContent {
  /** 可选；小标签（eyebrow），≤ 24 字符 */
  eyebrow?: string;
  /** 必填；品牌标语，作为 h1，1-60 字符 */
  headline: string;
  /** 必填；副标题，1-120 字符 */
  subheadline: string;
  background: HeroBackground;
  search: HeroSearchConfig;
}
```

### 3.2 组件 Props

```ts
/** src/components/homepage/hero.tsx —— Server Component */
export interface HeroProps {
  /** 可选；缺省使用 DEFAULT_HERO_CONTENT（内置占位常量） */
  content?: HeroContent;
  /** 可选；透传容器类名（仅允许布局类，不改语义结构） */
  className?: string;
}

/** src/components/homepage/search-box.tsx —— Client Component（'use client'） */
export interface SearchBoxProps {
  placeholder: string;
  submitLabel: string;
  /** 可选；缺省用 DEFAULT_SEARCH_HINT（'Search is coming soon.'） */
  hint?: string;
  className?: string;
}
```

### 3.3 约束与默认值

| 字段 | 约束 | 默认值 |
| --- | --- | --- |
| `headline` | 非空，≤60 字符，唯一 `h1` | `DEFAULT_HERO_CONTENT.headline`（占位常量） |
| `subheadline` | 非空，≤120 字符 | 同上 |
| `background.src` | 必须 `/images/` 开头；本期指向 `hero-placeholder.svg` | `'/images/hero-placeholder.svg'` |
| `background.alt` | 固定 `''`（装饰性） | `''` |
| `search.hint` | 可选；非空则用于提交提示 | `'Search is coming soon.'`（`DEFAULT_SEARCH_HINT`） |
| `SearchBox` 内部状态 | `query`（string）、`showHint`（boolean）；不持有任何网络逻辑 | — |
| 禁止项 | 组件内不出现 `fetch` / `axios` / `router.push`（本期） | — |

### 3.4 文件与依赖

```
frontend/
├── public/images/hero-placeholder.svg        # 自建占位资源（不下载）
└── src/
    ├── components/homepage/
    │   ├── hero.tsx                          # Server Component
    │   └── search-box.tsx                    # 'use client'
    ├── components/ui/
    │   ├── button.tsx                        # shadcn 等价源码（vendored）
    │   └── input.tsx                         # shadcn 等价源码（vendored）
    └── lib/utils.ts                          # 已有 cn()
```

不新增 npm 依赖（`class-variance-authority`、`clsx`、`tailwind-merge`、`lucide-react` 已安装）。

## 4. 验收标准（ACCEPTANCE Checklist）

### 4.1 渲染与内容

- [ ] `GET /` 返回 200，Hero 位于 `[data-region="hero"]` 容器内
- [ ] 品牌标语渲染为唯一 `h1`，文案等于 `headline` 常量
- [ ] 副标题可见，文案等于 `subheadline` 常量
- [ ] `role="search"` 容器存在，内含 sr-only `label`、`Input`、`Button`

### 4.2 交互

- [ ] 输入关键词提交后显示 `Search is coming soon.`
- [ ] 提交后 URL 不变、页面不跳转、Network 无新增请求
- [ ] 空输入时提交按钮为 `disabled`，点击无任何反馈
- [ ] Tab 顺序为：输入框 → 按钮（空输入时按钮被跳过）；焦点样式可见

### 4.3 图片与性能

- [ ] 背景使用 `next/image`（`fill` + `sizes="100vw"` + `priority`），无裸 `<img>`
- [ ] 背景图 `alt=""` 且对 AT 隐藏
- [ ] 图片 src 为本地 `/images/hero-placeholder.svg`，无外网图片请求
- [ ] 图片加载失败时渐变兜底可见，布局不塌陷（无 CLS）
- [ ] `npm run build` 通过，构建产物无 ESLint 错误

### 4.4 响应式与无障碍

- [ ] 360px 视口：单列、无横向滚动、文字不溢出
- [ ] ≥768px：内容居中，最大宽度由 `main` 的 `max-w-screen-md` 限定，两侧留白
- [ ] 文字与背景对比度 ≥ 4.5:1（图片加载成功与失败两种状态）
- [ ] `prefers-reduced-motion: reduce` 下无过渡动效

### 4.5 隔离与架构

- [ ] 切换城市（`SHA` → `BJA`）后 Hero 内容不变、无请求
- [ ] `/api/home` 某区块 `partialError` 时 Hero 正常渲染，无骨架/重试
- [ ] `hero.tsx` 为 Server Component；`'use client'` 仅出现在 `search-box.tsx`
- [ ] 组件内无 `fetch` / 路由跳转代码
- [ ] 未新增 npm 依赖；shadcn `Input` / `Button` 为仓内源码

### 4.6 手动验证步骤（无测试框架约束下）

1. `npm run build && npm run start`（NTFS 副本 `D:\wanderchina-frontend`）
2. `curl http://localhost:3000/` 断言：`role="search"`、`h1` 文案、`/images/hero-placeholder.svg` 均出现在 SSR HTML
3. 浏览器 360px / 768px / 1440px 三档截屏检查布局
4. DevTools Network 勾选 Disable cache 后阻断背景图请求，检查渐变兜底与文字对比度
5. 输入关键词提交，确认提示出现且 Network 无请求
