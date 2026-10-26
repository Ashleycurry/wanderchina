---
name: opsx-propose
version: 1.0.0
description: 创建 OpenSpec 变更提案（proposal/specs/design/tasks），先评审后编码（opsx 链路第 2 步）
user-invocable: true
argument-hint: "<change-name，如 add-dark-mode>"
---

# opsx-propose

基于 OpenSpec 规范驱动开发流程创建变更提案：在写任何代码之前，先与用户对齐"要构建什么"。

## 用法

- `/opsx-propose <变更名>`，如 `/opsx-propose add-dark-mode`
- 变更名用 kebab-case、动词开头（add- / update- / remove- / fix-）

## 执行步骤

1. 阅读 `openspec/project.md` 与相关的 `openspec/specs/*/spec.md`
2. 确定受影响的能力（capability）与增量类型（ADDED / MODIFIED / REMOVED）
3. 创建 `openspec/changes/<name>/`，包含：
   - `proposal.md` — Why（动机）/ What Changes（变更内容）/ Impact（影响面）
   - `specs/<capability>/spec.md` — delta 规格：`## ADDED/MODIFIED/REMOVED Requirements`，每个 Requirement 配 `#### Scenario:`（WHEN/THEN 可验证场景）
   - `design.md` — 技术方案与决策（可选，复杂变更必填）
   - `tasks.md` — 2~5 分钟粒度、含具体文件路径与验证方式的实施清单
4. 自查：proposal 是否回答了"为什么"；spec 是否有可验证场景；tasks 是否可逐条执行
5. 校验（若安装 CLI）：`openspec validate <name> --strict`
6. 将提案要点呈现给用户评审，明确等待确认后再进入 `/opsx-apply`

## 规则

- 未获用户确认前，不得开始写代码
- delta 规格必须写清楚可验证的 WHEN/THEN 场景
