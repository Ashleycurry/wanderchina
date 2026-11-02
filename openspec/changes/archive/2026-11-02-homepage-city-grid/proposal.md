# Proposal: 首页城市入口与切换（homepage-city-grid）

## Why

首页目前只能展示默认城市上海的数据。入境游客的第一需求是「我去哪座城市」，而当前没有任何切换入口：`wc_city` cookie 虽然被 `homepage-shell` 读取，却没有任何模块写入它，城市维度形同虚设。

本变更交付 8 城入口网格与切换能力，把 cookie 的写入方（city-grid）与读取方（shell）接起来，让 picks / hotSpots / hotPosts 三个数据区块真正随城市变化。

## What Changes

- 新增 `src/mocks/cities.ts`：`City` 类型 + 8 条城市常量（slug ↔ cityCode ↔ 图标）
- 新增 `src/middleware.ts`：首次访问（无 cookie 或非法值）写入 `wc_city=SHA`，`matcher` 仅 `/`
- 新增 `src/components/homepage/city-grid.tsx`（Server）：标题 + 装配城市数据
- 新增 `src/components/homepage/city-switcher.tsx`（Client）：8 个 `<Link>` 网格，左键点击拦截 → 写 cookie → `router.refresh()`
- 改写 `src/components/homepage/regions/city-grid-region.tsx` 为薄壳 `<CityGrid />`
- 空态增强 `regions/hot-posts-region.tsx` / `regions/hot-spots-region.tsx`：空数组时显示英文兜底文案
- 规格：MODIFIED「城市入口与切换」（保留原 3 个 Scenario，新增网格条目、局部刷新、键盘与 `aria-current`）

## Impact

| 维度 | 影响 |
| --- | --- |
| capability | `homepage` |
| 新增文件 | 4（mocks / middleware / city-grid / city-switcher） |
| 修改文件 | 3（`city-grid-region`、`hot-posts-region`、`hot-spots-region`） |
| 数据接口 | 复用 `homepage-shell` 的 `/api/home`，不新增接口 |
| 城市上下文 | **本模块成为 `wc_city` 的唯一写入方**（shell 只读） |
| 新增依赖 | 无 |
| 上游依赖 | `homepage-shell`（`CityCode` / `CITY_COOKIE_NAME` / `page.tsx` 读 cookie） |

## 待确认（规格内部张力，需拍板）

1. **城市项的 href 与切换是两个动作**：模块规格 S2 要求每项 `href` 形如 `/city/<slug>`，S5 又要求点击后三区块联动刷新。本提案用「`<Link>` + 左键点击拦截」同时满足两者：普通左键 → 写 cookie + 局部刷新（URL 不变）；Cmd/Ctrl/中键 → 按 `href` 新标签页打开 `/city/<slug>`（本期 404，允许）。
   - 代价：JS 未加载时点击会跳到 404 而非切换城市。若更看重无 JS 可用性，可改为纯 `<button>` + 放弃 S2。
2. **cookie 写入失败无法做到「内存渲染」**：模块规格 S9 要求隐私模式下「按所选城市在内存中渲染」。真正实现需要把三个区块的数据全部镜像到客户端状态，超出本期范围。本提案收窄为：写入失败时不白屏、不弹错，页面保持当前服务端城市渲染。
3. **`middleware.ts` 不在模块规格的文件树里**：Server Component 不能写 cookie，首次访问种 cookie 只能放 middleware（或 Route Handler，但会多一跳）。属必要新增。
