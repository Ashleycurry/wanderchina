# Proposal: 首页功能导航（homepage-feature-nav）

## Why

首页骨架已落地，`feature-nav` 仍是占位块。这个区块是站内三大能力（社区 / 景点 / AI 助手）的唯一入口，内容完全静态：没有它，游客看完 Hero 就无路可走。

区块本身没有数据、没有状态、没有客户端交互，是本批三个模块里最轻的一个，适合与 Hero 并行推进。

## What Changes

- 新增 `src/components/homepage/feature-nav.tsx`（Server Component）：3 张入口卡片常量 + `next/link`
- 改写 `src/components/homepage/regions/feature-nav-region.tsx` 为薄壳 `<FeatureNav />`，`page.tsx` 不改动
- 规格：MODIFIED「功能导航三入口」（保留原 2 个 Scenario，新增卡片可访问性与响应式列数）

## Impact

| 维度 | 影响 |
| --- | --- |
| capability | `homepage` |
| 新增文件 | 1 |
| 修改文件 | 1（`regions/feature-nav-region.tsx`） |
| 数据接口 | 无 |
| 城市上下文 | 无 |
| 新增依赖 | 无（图标用已安装的 `lucide-react`） |
| 上游依赖 | `homepage-shell`（`data-region="feature-nav"` 挂载位） |

## 待确认

1. **目标路由尚不存在**：`/community`、`/attractions`、`/ai` 本期点击会落到 404。模块规格 S4 明确允许，由后续路由变更承接；本提案不改动路由。
2. **UI 文案语言**：与 Hero 一致采用英文（Community / Attractions / AI Assistant）。
