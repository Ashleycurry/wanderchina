---
name: openspec-explore-change
description: opsx 链路第 1 步：在写代码前探索代码库与需求，梳理候选方案并确认范围
---

# openspec-explore-change（探索变更）

## 触发时机

- 用户想做某件事，但"做什么"或"怎么做"还不清晰
- 在 `propose` 之前

## 流程

1. 询问用户想探索/实现的目标
2. 阅读 `openspec/project.md` 与相关 specs，检索代码现状（SearchCodebase / Grep / LSP）
3. 权衡 2~3 个候选方案（复杂度 / 风险 / 成本），给出推荐
4. 汇报发现，询问是否"就此立项"（进入 propose）

## 边界

- 只读，不写任何代码
- 不创建 openspec 变更目录（那是 propose 的职责）
