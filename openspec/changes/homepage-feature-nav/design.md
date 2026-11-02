# Design: 首页功能导航（homepage-feature-nav）

## D1 用元组类型锁死「恰好 3 项」

`items` 的类型定为 `readonly [FeatureNavItem, FeatureNavItem, FeatureNavItem]`，而不是 `FeatureNavItem[]`。

模块规格 3.3 要求「多于/少于 3 项视为配置错误」。若用数组 + 运行期长度校验，错误只能在渲染时发现；用元组把约束前移到编译期，`tsc` 直接拦住传 2 项或 4 项的情况，运行期零校验代码。

代价：调用方无法传任意长度数组。但本区块的业务定义就是三入口，这不是限制而是契约。

## D2 不引入 Card 组件

`src/components/ui/` 目前只有 `button` / `input`。为避免为一个静态卡片再 vendored 一份 `card.tsx`，卡片直接用 `<Link>` + Tailwind 类实现：`rounded-lg border border-border bg-card p-5`。

样式全部走语义令牌（`border-border` / `bg-card` / `text-muted-foreground` / `text-primary`），符合 styling-stack 约束。

## D3 图标存组件而非字符串

`FeatureNavItem.icon` 类型为 `LucideIcon`，常量里直接写 `Users` / `Map` / `Sparkles`。

Server Component 可以直接渲染组件引用，不需要序列化；若存字符串图标名，反而要维护一张「名字 → 组件」映射表，并丢失类型检查。

图标统一 `aria-hidden="true"`，可读名称由卡片标题承担（规格 S3）。

## D4 用 `<nav aria-label>` 而不是普通 `<div>`

功能导航是一组站内主导航链接，用 `<nav aria-label="Primary features">` 提供 landmark，屏幕阅读器可以按区域跳转。卡片数量断言（3 个链接）在 `nav` 内计数即可，不影响选择器。

## 文件结构

```
frontend/src/components/homepage/
├── feature-nav.tsx                  # 新增：Server Component + 3 项常量
└── regions/feature-nav-region.tsx   # 改写：薄壳
```

## 数据与常量

```ts
export const DEFAULT_FEATURE_NAV_ITEMS: FeatureNavItems = [
  { key: 'community',   title: 'Community',    description: 'Ask and answer with fellow travelers.',   href: '/community',   icon: Users },
  { key: 'attractions', title: 'Attractions',  description: 'Curated guides to must-see places.',      href: '/attractions', icon: Map },
  { key: 'ai',          title: 'AI Assistant', description: 'Plan your trip with an AI copilot.',      href: '/ai',          icon: Sparkles },
]
```
