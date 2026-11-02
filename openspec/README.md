# OpenSpec 工作区

本目录是 WanderChina 的规格单一事实来源（SSOT），遵循 [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) 的 `spec-driven` 模式。

## 目录结构

```
openspec/
├── project.md                 # 项目上下文：技术栈 / 约定 / 约束
├── config.yaml                # OpenSpec 配置（schema: spec-driven）
├── README.md                  # 本文件：结构与进度索引
├── specs/                     # 已生效规格（单一事实来源）
│   ├── openspec-workflow/spec.md
│   ├── backend-scaffold/spec.md
│   ├── frontend-scaffold/spec.md
│   └── homepage/
│       ├── spec.md            # capability 主规格（可校验，汇总 8 个模块）
│       ├── homepage-shell.md          # 模块手册：模块边界/全量场景/Props/AC
│       ├── homepage-hero.md
│       ├── homepage-feature-nav.md
│       ├── homepage-city-grid.md
│       ├── homepage-hot-posts.md
│       ├── homepage-hot-spots.md
│       ├── homepage-ai-launcher.md
│       └── frontend-styling-stack.md
└── changes/                   # 在途变更提案
    ├── 0003-todo-module/      # 搁置（未实施）
    ├── homepage-hero/
    ├── homepage-feature-nav/
    ├── homepage-city-grid/
    ├── homepage-hot-posts/
    ├── homepage-hot-spots/
    ├── homepage-ai-launcher/
    └── archive/               # 已完成变更（YYYY-MM-DD-<name>）
        ├── 2026-10-27-0001-bootstrap-openspec/
        ├── 2026-10-27-0002-add-fullstack-scaffold/
        ├── 2026-10-28-0004-update-frontend-stack/
        ├── 2026-10-28-0005-update-backend-stack/
        ├── 2026-11-02-frontend-styling-stack/
        └── 2026-11-02-homepage-shell/
```

## 规格分层约定

| 层 | 位置 | 作用 | 是否参与 `openspec validate` |
| --- | --- | --- | --- |
| capability 主规格 | `specs/<capability>/spec.md` | Purpose + Requirements + Scenario，验收事实来源 | 是 |
| 模块手册 | `specs/homepage/*.md` | 模块边界 / 全量场景 / Props / ACCEPTANCE 清单 | 否（CLI 忽略） |
| 变更 delta | `changes/<name>/specs/<capability>/spec.md` | `ADDED` / `MODIFIED` / `REMOVED` Requirements | 是 |
| 归档 | `changes/archive/YYYY-MM-DD-<name>/` | 历史提案与 delta 快照 | 否 |

> 归档时 delta 合入 `specs/<capability>/spec.md`；模块手册随实现同步更新，不参与合入。

## 当前进度

### 首页能力域（8 个单元）

| # | 单元 | 规格 | 提案 | 实施 | 归档 |
| --- | --- | --- | --- | --- | --- |
| 1 | `frontend-styling-stack` | ✅ `specs/homepage/frontend-styling-stack.md` | ✅ `changes/archive/2026-11-02-frontend-styling-stack/` | ✅ 已实施 | ✅ 2026-11-02 |
| 2 | `homepage-shell` | ✅ `specs/homepage/homepage-shell.md` | ✅ `changes/archive/2026-11-02-homepage-shell/` | ✅ 已实施 | ✅ 2026-11-02 |
| 3 | `homepage-hero` | ✅ `specs/homepage/homepage-hero.md` | ✅ `changes/homepage-hero/` | ⏳ 待实施 | — |
| 4 | `homepage-feature-nav` | ✅ `specs/homepage/homepage-feature-nav.md` | ✅ `changes/homepage-feature-nav/` | ⏳ 待实施 | — |
| 5 | `homepage-city-grid` | ✅ `specs/homepage/homepage-city-grid.md` | ✅ `changes/homepage-city-grid/` | ⏳ 待实施 | — |
| 6 | `homepage-hot-posts` | ✅ `specs/homepage/homepage-hot-posts.md` | ✅ `changes/homepage-hot-posts/` | ⏳ 待实施 | — |
| 7 | `homepage-hot-spots` | ✅ `specs/homepage/homepage-hot-spots.md` | ✅ `changes/homepage-hot-spots/` | ⏳ 待实施 | — |
| 8 | `homepage-ai-launcher` | ✅ `specs/homepage/homepage-ai-launcher.md` | ✅ `changes/homepage-ai-launcher/` | ⏳ 待实施 | — |

依赖拓扑：`frontend-styling-stack` → `homepage-shell` → 批 3（`hero` / `feature-nav` / `city-grid` 可并行）→ 批 4（`hot-posts` → `hot-spots` 需串行，两者共改 `load.ts` / `mock-data.ts`；`ai-launcher` 独立可并行）。

### 历史能力

| capability | 状态 | 来源 |
| --- | --- | --- |
| `openspec-workflow` | 已生效 | 0001-bootstrap-openspec |
| `backend-scaffold` | 已生效（含 0005 增量） | 0002 / 0005 |
| `frontend-scaffold` | 已生效（含 0004 增量） | 0002 / 0004 |
| `0003-todo-module` | 搁置（0/19 AC） | 0003 |

## 工作流

```
/opsx-explore   → 只读探索，梳理方案
/opsx-propose   → 创建 changes/<name>/（proposal + design + tasks + delta spec），等待评审
/opsx-apply     → 按 tasks.md 实施（TDD）
/opsx-archive   → 归档到 changes/archive/YYYY-MM-DD-<name>/，delta 合入 specs
```

## 校验

```powershell
D:\openspec\openspec.exe validate --all --strict
```

预期：所有 change 与 capability 均 `✓`，0 failed。

## 命名约定

- 变更名 kebab-case，不含 `add` 前缀；未归档提案带序号（`0003-todo-module`）
- 归档目录 `YYYY-MM-DD-<name>`
- 区块挂载位固定 `data-region` 取值：`hero` / `feature-nav` / `city-grid` / `hot-posts` / `hot-spots` / `ai-launcher`
