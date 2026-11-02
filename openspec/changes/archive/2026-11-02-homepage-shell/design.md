# Design: 首页骨架与聚合契约（homepage-shell）

## D1 数据获取：服务端直连 `loadHome()`，不自请求 `/api/home`

**决策**：`page.tsx`（Server Component）调用 `loadHome(cityCode)`，而不是在服务端 `fetch('/api/home')`。

**理由**：
- Node 环境 `fetch` 不接受相对路径，需拼接 origin，增加环境变量与部署耦合
- 自请求多一跳，SSR 首屏变慢
- `loadHome` 与 `/api/home` 的 Route Handler 共享同一数据源，输出必然一致

**代价**：数据获取逻辑需在 `load.ts` 收敛，后续接后端时只改 `load.ts` 一处的 fetch。

## D2 `/api/home` 用 Route Handler 作为契约桩

**决策**：新增 `src/app/api/home/route.ts`，本期返回 mock，支持 `?fail=picks,hotSpots` 注入 `partialError`。

**理由**：
- 后端 `/api/home` 尚未实现（后端只有 health/echo），前端需要可运行的契约用于联调与验收断言
- 契约桩与 `loadHome` 同源，避免两份假数据漂移

**已知影响**：Next `rewrites` 是 afterFiles，`/api/home` 会被本地 route 命中，不会代理到 8080；其余 `/api/*` 仍走代理。**后端就绪后删除该 route 文件即恢复代理**，proposal 已声明。

**备选（未采用）**：`next.config.mjs` 中把 `/api/home` 排除在 rewrite 外——需要改配置且后端仍无接口，无收益。

## D3 `RegionBoundary` 为 Client Component，重试 = `router.refresh()`

**决策**：`region-boundary.tsx` 标记 `'use client'`，内部 `useRouter()`，重试按钮调用 `router.refresh()` 重新触发服务端取数；`onRetry` 保留为可选 prop（供测试/特殊场景覆盖）。

**理由**：
- 骨架与重试需要交互，必须 Client
- Server Component 无法向 Client 传函数，所以默认行为不能依赖 `onRetry`
- `children` 由 Server 渲染后作为 props 传入 Client，符合 RSC 组合模式

**约束**：骨架高度按 `skeleton` 档位（`card-row` / `card-grid` / `text-block`）预留 `min-h-*`，减少 CLS。

## D4 区块占位文件隔离，避免并行改 `page.tsx`

**决策**：`page.tsx` 只 import `src/components/homepage/regions/` 下 6 个占位组件：

```
hero-region.tsx / feature-nav-region.tsx / city-grid-region.tsx
hot-posts-region.tsx / hot-spots-region.tsx / ai-launcher-region.tsx
```

区块模块实现时**只替换自己的占位文件内容**，`page.tsx` 不动。

**理由**：6 个模块并行时若都改 `page.tsx`，会产生必然的合并冲突；文件隔离后每个模块的改动面收敛到单文件。

**与规格的关系**：规格要求「骨架不 import 任何区块组件」——占位组件属于骨架自有，不是区块实现，不违反该约束。

## D5 城市上下文只读消费，写入归 city-grid

**决策**：本变更新增 `readCityCode(cookies)`：读 `wc_city` → 校验 8 个合法值 → 非法/缺失回退 `SHA`；**不写 cookie、不做切换 UI**。

**理由**：写入与切换属于 `homepage-city-grid` 的职责；shell 只需要「拿到一个合法 cityCode」即可取数。

**边界**：`CITY_COOKIE_NAME` 与 `DEFAULT_CITY_CODE` 常量定义在 `src/lib/home/city.ts`，city-grid 变更后续 import 同一常量，避免两处各写一遍字符串。

## D6 mock 数据形态

**决策**：`src/lib/home/mock-data.ts` 导出 `MOCK_HOME: Record<CityCode, Omit<HomeResponse, 'cityCode' | 'partialError'>>`。

覆盖点：
- `SHA`：picks 3 条（其中 1 条 `guide` 非 published，验证剔除）+ hotSpots 5 条 + hotPosts 4 条
- `BJA`：picks 2 条 + hotSpots 3 条 + hotPosts 3 条（验证城市切换后数据替换）
- 其余 6 城：三个数组均为 `[]`（验证空区块兜底）
- `?fail=` 指定区块时，该键写入 `partialError: true` 且数组置空

**理由**：一套 mock 同时覆盖正常、剔除、空数据、降级四种验收路径，不需要额外 fixture 文件。

## 文件清单

```
frontend/src/
├── app/
│   ├── layout.tsx                        # 修改：description
│   ├── page.tsx                          # 改写：6 个 data-region
│   └── api/home/route.ts                 # 新增：契约桩
├── components/homepage/
│   ├── region-boundary.tsx               # 新增：'use client' 骨架+重试
│   └── regions/                          # 新增：6 个占位
│       ├── hero-region.tsx
│       ├── feature-nav-region.tsx
│       ├── city-grid-region.tsx
│       ├── hot-posts-region.tsx
│       ├── hot-spots-region.tsx
│       └── ai-launcher-region.tsx
└── lib/home/
    ├── types.ts                          # CityCode / EditorPick / HomeResponse / RegionKey
    ├── city.ts                           # CITY_COOKIE_NAME / DEFAULT_CITY_CODE / readCityCode
    ├── mock-data.ts                      # MOCK_HOME
    └── load.ts                           # loadHome(cityCode, { fail })
```

## 风险

| 风险 | 缓解 |
| --- | --- |
| Route Handler 遮蔽后端 `/api/home` 代理 | 后端就绪后删除 `route.ts`；proposal 已声明 |
| 占位文件被误认为区块实现 | 文件名统一 `*-region.tsx`，首行注释标注归属模块 |
| `router.refresh()` 重试无 loading 反馈 | 重试按钮 `disabled` + 骨架保持显示，refresh 完成后消失 |
