# Tasks: 首页功能导航（homepage-feature-nav）

> 前置：`homepage-shell` 已提供 `[data-region="feature-nav"]` 挂载位。

## 1. 组件实现

- [x] 1.1 新增 `frontend/src/components/homepage/feature-nav.tsx`：导出 `FeatureNavKey` / `FeatureNavItem` / `FeatureNavItems`（三元组）/ `FeatureNavProps`
  - 验证：`npx tsc --noEmit` 通过；向 `items` 传 2 项应报类型错误（临时验证后改回）
- [x] 1.2 定义 `DEFAULT_FEATURE_NAV_ITEMS`：3 项，`href` 为 `/community` / `/attractions` / `/ai`，图标 `Users` / `Map` / `Sparkles`
  - 验证：常量恰好 3 项；`href` 均以 `/` 开头
- [x] 1.3 渲染：`<nav aria-label="Primary features" className="grid grid-cols-1 gap-4 sm:grid-cols-3">` 内 `next/link` 卡片，图标 `aria-hidden="true"`
  - 验证：SSR HTML 中 `feature-nav` 内恰好 3 个 `<a>`
- [x] 1.4 改写 `frontend/src/components/homepage/regions/feature-nav-region.tsx` 为薄壳 `<FeatureNav />`
  - 验证：文件 ≤ 6 行；`page.tsx` 未改动

## 2. 验证

- [x] 2.1 `robocopy` 同步到 `D:\wanderchina-frontend`，`npx tsc --noEmit` 与 `npm run build` 通过
  - 验证：`✓ Compiled successfully`
- [x] 2.2 `npm run start` 后断言 SSR：`[data-region="feature-nav"]` 内 3 个链接且 `href` 精确匹配、3 个 `aria-hidden="true"` 图标、每卡片含标题与描述
  - 验证：Node `fetch` + 正则逐项断言
- [x] 2.3 断言静态隔离：`Cookie: wc_city=SHA` 与 `wc_city=BJA` 两次响应中 `[data-region="feature-nav"]` 片段字符串相等
  - 验证：Node `fetch` 片段比对
- [x] 2.4 断言降级隔离：`/?fail=picks,hotSpots,hotPosts` 时该区块片段与正常访问完全一致
  - 验证：Node `fetch` 片段比对
- [x] 2.5 浏览器三档视口（360 / 640 / 1440）检查列数与对齐
  - 验证：360 下 `grid-template-columns` 单列、≥640 三列；无横向滚动

## 3. 验收与提交

- [x] AC1 `feature-nav` 内恰好 3 张卡片，`href` 为 `/community`、`/attractions`、`/ai`
- [x] AC2 每卡片含装饰性图标（`aria-hidden`）、标题、描述；链接可读名称等于标题
- [x] AC3 360px 单列、`sm` 起三列等宽，无横向滚动
- [x] AC4 无 `'use client'`、无 `fetch`、无状态
- [x] AC5 城市切换与 `/api/home` 降级均不改变该区块
- [x] AC6 未新增 npm 依赖；`npm run build` 通过
- [x] 3.1 `frontend` 子仓库提交（1 新增 + 1 修改）
- [x] 3.2 根仓库提交 `openspec/changes/homepage-feature-nav/`

## 实施记录（2026-11-02）

- 构建：`npx tsc --noEmit` exit 0；`npm run build` → `✓ Compiled successfully`
- SSR 断言：`[data-region="feature-nav"]` 内恰好 3 个 `<a>`，`href` 精确为 `/community`、`/attractions`、`/ai`；`aria-label="Primary features"`；3 个图标均 `aria-hidden="true"`
- 静态隔离：`Cookie: wc_city=SHA` / `wc_city=BJA` 两次响应片段字符串相等；`/?fail=hotSpots` 下片段与正常访问一致
- 类型锁死：`FeatureNavItems` 为三元组类型，`DEFAULT_FEATURE_NAV_ITEMS` 直接以该类型标注
- 无偏差
