# Design: 首页 Hero 区块（homepage-hero）

## D1 固定深色主视觉，文字不随主题反转

Hero 背景是装饰性主视觉（深色渐变 + 城市剪影），文字固定用 `text-white` 系列，不跟随 `dark` 主题。若改用 `text-foreground`，浅色主题下会变成白底白字。

渐变允许使用 Tailwind 调色板类（`from-neutral-950 via-neutral-900 to-amber-900`）作为**装饰性**例外；结构性颜色（边框、卡片、按钮）仍严格使用语义令牌。这与 styling-stack「禁止硬编码色值」不冲突——禁止的是 `#hex` / `rgb()`，不是调色板类名。

## D2 背景图走 `next/image`，本地 SVG 不配 `dangerouslyAllowSVG`

`<Image fill priority sizes="100vw" alt="" aria-hidden />`。Next.js 14 对本地 `.svg` 会自动设 `unoptimized`，因此无需在 `next.config.mjs` 打开 `dangerouslyAllowSVG`（该开关只影响优化器，且会放宽安全边界）。

渐变兜底放在图片下层（`-z-20`），图片 `opacity-60`，再叠一层 `to-transparent` 的暗角（`-z-10`）：图片 404 或慢网时，兜底层与暗角仍然存在，文字对比度与布局都不受影响。容器固定 `min-h-[440px] md:min-h-[520px]`，`fill` 不产生 CLS。

## D3 搜索交互全部关在 `search-box.tsx`

`hero.tsx` 保持 Server Component，唯一客户端边界是 `search-box.tsx`。提示用常驻 `<p aria-live="polite">` 承载（`min-h-5` 占位防抖动），**不引入任何 transform/opacity 动效**，因此 `prefers-reduced-motion` 天然满足，不需要额外 `motion-reduce` 类。

`role="search"` 放在 `<form>` 上：表单语义与搜索 landmark 合并，避免多包一层 `div`。

## D4 空输入用 `disabled`，而不是提交后拦截

提交按钮在 `query.trim() === ''` 时为 `disabled`。这样空输入连提交事件都不会产生，无需在 `onSubmit` 里二次判断并给出提示——比"提交后说请输入关键词"少一轮无效交互。

副作用：空输入时按钮不可聚焦，Tab 顺序实际为「输入框 →（输入后）按钮」。这是原生 `disabled` 的标准行为，符合规格 S5 与 S8 的组合要求。

## D5 薄壳替换，`page.tsx` 保持不动

`regions/hero-region.tsx` 内容改为 `export function HeroRegion() { return <Hero /> }`。这是 `homepage-shell` 定下的隔离契约：后续任何区块实现只替换自己那份 `*-region.tsx`，骨架文件不参与。

## 文件结构

```
frontend/
├── public/images/hero-placeholder.svg      # 新增：自建 SVG
└── src/components/homepage/
    ├── hero.tsx                            # 新增：Server Component
    ├── search-box.tsx                      # 新增：'use client'
    └── regions/hero-region.tsx             # 改写：薄壳
```

## 数据与常量

```ts
export const DEFAULT_HERO_CONTENT: HeroContent = {
  eyebrow: 'EXPLORE CHINA',
  headline: 'China, one city at a time.',
  subheadline: 'Locally verified city guides, top attractions, and real answers from travelers.',
  background: { src: '/images/hero-placeholder.svg', alt: '' },
  search: {
    placeholder: 'Search cities, attractions, or questions',
    submitLabel: 'Search',
    hint: 'Search is coming soon.',
  },
}
```
