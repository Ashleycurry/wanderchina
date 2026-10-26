---
name: spec-driven-workflow
description: 规范驱动开发（SDD）工作流规则：先提案后编码，规格为单一事实来源
---

# 规范驱动开发工作流（Spec-Driven Workflow）

本项目采用 OpenSpec 规范驱动开发（SDD）。以下规则适用于所有会话：

## 强制流程（opsx 链路）

```
explore → propose → apply → archive
```

1. **explore**：需求模糊时先探索代码与方案（只读，不写代码）
2. **propose**：创建 `openspec/changes/<name>/` 提案（proposal.md / specs/ / design.md / tasks.md），等待用户评审确认
3. **apply**：按 tasks.md 逐条实施，遵循 TDD
4. **archive**：完成后归档到 `changes/archive/`，delta 合入 `specs/`

## 硬性规则

1. 未经用户确认的提案，禁止写任何实现代码。
2. 微小修复（拼写、样式微调、单行 bug）可在告知用户后直接修复，但需同步更新受影响规格。
3. `openspec/specs/` 是系统行为的单一事实来源；代码与规格不一致时，以规格为准并推动修正。
4. 提案文件结构固定：proposal.md（Why/What/Impact）、specs/（delta）、design.md（可选）、tasks.md（必填）。
5. 变更未完成不得归档。
6. 每次会话开始，先读 `openspec/project.md` 与相关 spec 再动手。
