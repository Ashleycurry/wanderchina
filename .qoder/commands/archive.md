---
name: archive
description: 归档已完成的 OpenSpec 变更，并将 delta 规格合入 specs/
---

# /archive

将已上线/已完成的变更从 `openspec/changes/<name>/` 归档。

## 执行步骤

1. 确认变更对应的任务全部完成、代码已合并/上线
2. 将变更目录移动到 `openspec/changes/archive/YYYY-MM-DD-<name>/`
3. 将该变更的 delta（ADDED/MODIFIED/REMOVED）合入 `openspec/specs/<capability>/spec.md`：
   - ADDED 的 Requirement 直接并入
   - MODIFIED 的更新原条目
   - REMOVED 的删除原条目
4. 校验规格一致性（若安装 CLI：`openspec validate --strict`）
5. 汇报归档结果

## 规则

- 未完成的变更不得归档
- 归档后 `specs/` 必须反映当前系统的真实规格（单一事实来源）
