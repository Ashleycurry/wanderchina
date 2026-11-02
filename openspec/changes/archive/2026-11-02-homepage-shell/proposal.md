# Proposal: 首页骨架与聚合契约（homepage-shell）

## Why

首页 6 个区块要在多个变更里并行实现，但当前 `src/app/page.tsx` 只有一个 `hello` 标题页：

1. 没有稳定的挂载位与顺序，6 个区块无法独立开发、独立验收（谁先改 `page.tsx` 谁阻塞别人）
2. `/api/home` 契约只写在规格里，没有可运行的契约桩，前端无法在后端就绪前开发
3. 缺少统一的区块级降级容器，各区块会各自造骨架与重试逻辑，失败时容易整页报错

本变更是 6 个区块变更的**唯一前置**：先定挂载位、接口契约、降级容器，后续区块只替换自己的占位文件。

## What Changes

- 新增能力：`homepage-shell`（ADDED）
- `src/app/page.tsx`：改为 6 个固定顺序的 `data-region` 挂载位（500 行模板 → 组合式骨架）
- 新增 6 个区块占位组件：`src/components/homepage/regions/*.tsx`（模块实现时只替换自己的文件，不改 page.tsx）
- 新增降级容器：`src/components/homepage/region-boundary.tsx`（Client，骨架 + 重试）
- 新增首页数据层：`src/lib/home/{types,mock-data,city,load}.ts`
- 新增契约桩：`src/app/api/home/route.ts`（GET，返回 `HomeResponse`，支持 `?fail=` 注入 partialError）
- `src/app/layout.tsx`：`description` 从「前端应用」改为面向入境游客的描述

## Impact

- 修改 capability：`homepage-shell`（ADDED）
- 新增文件 10 个，修改 2 个（`page.tsx`、`layout.tsx`）
- 依赖 `frontend-styling-stack`（重试按钮复用 `@/components/ui/button`）
- **路由影响**：`/api/home` 被本地 Route Handler 命中，不再代理到 8080；其余 `/api/*` 代理不变。后端就绪后删除该 route 即恢复代理
- 不新增 npm 依赖；不引入状态管理库

## Out of Scope

- 6 个区块的真实 UI 与交互（各模块变更）
- 城市上下文的写入与切换（`homepage-city-grid`）——本变更只做 cookie **只读消费**
- 后端 `/api/home` 与数据库实现（后续后端 spec）
- 真实搜索、AI 对话
