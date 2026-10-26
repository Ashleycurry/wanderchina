---
name: openspec-propose-change
description: opsx 链路第 2 步：创建 OpenSpec 变更提案（proposal/specs/design/tasks）并严格校验
---

# openspec-propose-change（创建提案）

## 触发时机

- 需求已明确或探索已确认，写代码之前

## 流程

1. 读 `openspec/project.md`；了解既有变更与规格（若安装 CLI：`openspec list`、`openspec list --specs`）
2. 确定动词开头的 kebab-case 变更名（add- / update- / remove- / fix-）
3. 创建 `openspec/changes/<name>/`：
   - `proposal.md`：Why（动机）/ What Changes（变更内容）/ Impact（影响面）
   - `specs/<capability>/spec.md`：`## ADDED/MODIFIED/REMOVED Requirements` + WHEN/THEN 可验证场景
   - `design.md`：技术决策（复杂变更必填）
   - `tasks.md`：2~5 分钟粒度、含文件路径与验证步骤的实施清单
4. 校验（若安装 CLI）：`openspec validate <name> --strict`，修复所有问题
5. 呈现提案等待用户评审确认；确认前不写代码
