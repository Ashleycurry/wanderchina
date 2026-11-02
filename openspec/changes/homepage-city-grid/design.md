# Design: 首页城市入口与切换（homepage-city-grid）

## D1 复用 `src/lib/home/` 的城市常量，不新建第二套

`CityCode` / `CITY_COOKIE_NAME` / `DEFAULT_CITY_CODE` / `isCityCode` 全部从 `@/lib/home/city` 与 `@/lib/home/types` 引入。`mocks/cities.ts` 只负责「城市展示数据」：slug、name、icon。

模块手册 3.1 把这三个常量又写了一遍。若照抄，shell 与 city-grid 会各持一份枚举，任何增删城市都可能只改一边。读写双方共用同一份定义，是这个模块能安全工作的前提。

## D2 `City.icon` 用 `LucideIcon` 而非 `string`

模块手册写 `icon: string`（lucide 图标名或 emoji）。本提案改为 `LucideIcon` 组件引用：

- 编译期能校验图标确实存在，拼错名字直接报错
- 省掉「字符串 → 组件」的映射表
- 与 `homepage-feature-nav` 的 `FeatureNavItem.icon` 保持一致

`CitySwitcher` 是 Client Component，但图标只在**服务端渲染阶段**作为 prop 传入；`CityGrid`（Server）把 `CITY_LIST` 直接传给 Client 组件时，`LucideIcon` 是函数组件引用——**不能跨 RSC 边界序列化**。

因此实际做法：`CitySwitcher` 不在 props 里收 `cities`，而是自己 `import { CITY_LIST }`（静态常量，同 bundle）。`CityGrid` 只传 `currentCode`。

> 修正：模块手册 3.2 的 `CitySwitcherProps` 只有 `currentCode` + `onSelect`，本提案保留该形状并去掉 `onSelect`（内部完成 cookie + refresh，无需外部回调）。

## D3 城市项 = `<Link>` + 左键拦截

```tsx
<Link href={`/city/${city.slug}`} aria-current={active ? 'true' : undefined} onClick={handleSelect} />
```

`handleSelect` 逻辑：

1. `event.metaKey || ctrlKey || shiftKey || altKey || button !== 0` → 直接 return，交给浏览器原生行为（新标签页 / 新窗口）
2. 否则 `preventDefault()` → 写 cookie → `startTransition(() => router.refresh())`

这样一份 DOM 同时满足两组要求：`href` 可被爬虫/新标签页消费（S2），左键点击走站内切换（S5 / S6）。`aria-current="true"` 只加在当前城市项上。

## D4 首次访问种 cookie 放 middleware

Server Component 没有写 cookie 的能力（Next 14 只允许 Server Action / Route Handler / middleware）。`page.tsx` 只能读。

`src/middleware.ts`：读 `wc_city`，缺失或非法则 `response.cookies.set('wc_city', 'SHA', { path: '/', maxAge: 30d, sameSite: 'lax' })`。

`matcher: '/'` 只拦首页——其他页面（含 `/api/home`）不需要种 cookie，`/api/home` 自身已有 `readCityCode` 回退。

注意：middleware 只改**响应** cookie，本次请求的 `page.tsx` 仍读不到（读到 undefined → `readCityCode` 回退 SHA）。两者结果一致，无副作用。

## D5 cookie 写入失败：保证不白屏，不承诺内存渲染

`document.cookie` 写入被浏览器拒绝时不会抛错。写入后 `router.refresh()` 服务端仍读到旧值（或没有值 → SHA），页面照常渲染。

模块规格 S9 的「按所选城市在内存中渲染」需要客户端持有三个区块的全部数据副本，本期不做。delta 中该 Scenario 的措辞收窄为「页面正常渲染、不报错、不白屏」。

## D6 空区块兜底落在两个占位组件

规格 S7 要求切换后空数据显示兜底文案。当前 `hot-posts-region` / `hot-spots-region` 是占位组件，直接渲染「待实现（0 条）」。

本变更在这两个文件加 3 行空数组判断，输出英文空态 `<p>No community posts for this city yet.</p>` / `<p>No attractions for this city yet.</p>`。

这是跨模块的最小改动，理由是：空态是「切换城市」这条链路的终点，由 city-grid 单独立项无法交付完整效果；后续 hot-posts / hot-spots 模块实现时直接继承该语义，不会返工。

## D7 切换中的视觉反馈

`useTransition()` 的 `isPending` 给网格加 `opacity-60`。这是纯 opacity，无 transition 类，`prefers-reduced-motion` 下无影响。不加 spinner：局部刷新通常 < 300ms，骨架闪现反而干扰。

## 文件结构

```
frontend/src/
├── middleware.ts                              # 新增：仅 matcher '/' 种 cookie
├── mocks/cities.ts                            # 新增：City 类型 + 8 条常量
└── components/homepage/
    ├── city-grid.tsx                          # 新增：Server
    ├── city-switcher.tsx                      # 新增：'use client'
    └── regions/
        ├── city-grid-region.tsx               # 改写：薄壳
        ├── hot-posts-region.tsx               # 改：空态兜底
        └── hot-spots-region.tsx               # 改：空态兜底
```

## 城市清单

| 顺序 | slug | code | name | icon |
| --- | --- | --- | --- | --- |
| 1 | shanghai | SHA | Shanghai | `Landmark` |
| 2 | beijing | BJA | Beijing | `Building2` |
| 3 | xian | SIA | Xi'an | `Castle` |
| 4 | chengdu | CTU | Chengdu | `Trees` |
| 5 | hangzhou | HGH | Hangzhou | `Waves` |
| 6 | guilin | KWL | Guilin | `Mountain` |
| 7 | lijiang | LJG | Lijiang | `Sun` |
| 8 | suzhou | SUZ | Suzhou | `Home` |

默认城市排第一，与 `aria-current` 的初始位置一致。

## cookie 参数

`path=/; max-age=2592000; samesite=lax`（30 天）。不设 `secure`，因为本地开发是 http。
