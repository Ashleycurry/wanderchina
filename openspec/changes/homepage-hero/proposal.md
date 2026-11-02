# Proposal: 首页 Hero 区块（homepage-hero）

## Why

首页骨架（`homepage-shell`）已落地，`hero` 挂载位目前只是一个虚线占位块。首屏是入境游客对 WanderChina 的第一印象，也是唯一承载品牌标语与搜索入口的位置；没有它，首页只是一个模块列表。

本变更把 Hero 从占位提升为纯静态首屏区块：品牌主视觉 + 标语 + 副标题 + 搜索框 UI 占位。不接数据、不接城市上下文，因此可以完全独立于批 3 其余两个模块推进。

## What Changes

- 新增 `public/images/hero-placeholder.svg`：自建主视觉占位资源（不下载外网图片）
- 新增 `src/components/homepage/hero.tsx`（Server Component）：背景图 + 渐变兜底 + `h1` 标语 + 副标题 + 搜索区
- 新增 `src/components/homepage/search-box.tsx`（Client Component）：受控输入 + 空值禁用 + 提交提示（`aria-live`）
- 改写 `src/components/homepage/regions/hero-region.tsx` 为薄壳 `<Hero />`，`page.tsx` 不改动
- 规格：MODIFIED「Hero 内容与搜索占位」（保留原 2 个 Scenario，新增搜索交互与无障碍），ADDED「Hero 静态区块隔离」

## Impact

| 维度 | 影响 |
| --- | --- |
| capability | `homepage` |
| 新增文件 | 4（1 SVG + 2 组件 + 1 薄壳改写） |
| 修改文件 | 1（`regions/hero-region.tsx`） |
| 数据接口 | 无（不请求 `/api/home`） |
| 城市上下文 | 无（不读 `wc_city`） |
| 新增依赖 | 无 |
| 上游依赖 | `frontend-styling-stack`（`Input` / `Button` / `cn`）、`homepage-shell`（`data-region="hero"` 挂载位） |

## 待确认

1. **UI 文案语言**：Hero 面向入境游客，本提案采用英文文案（`headline` / `subheadline` / `search`）；中文只用于代码注释与文档。若希望首屏中文，只需改 `DEFAULT_HERO_CONTENT` 常量。
2. **搜索提示文案**：定稿 `'Search is coming soon.'`（英文）。若后续搜索模块上线，替换为真实跳转即可。
