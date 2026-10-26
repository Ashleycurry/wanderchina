---
name: openspec-archive-change
description: opsx 链路第 4 步：归档已完成变更，delta 合入 specs/
---

# openspec-archive-change（归档变更）

## 前置条件

- 变更全部任务完成且已上线/合并

## 流程

1. 确定要归档的变更名（若安装 CLI：`openspec list` 查看进行中变更）
2. 归档（若安装 CLI：`openspec archive <name> --yes`）或手动：
   - 移动 `openspec/changes/<name>/` → `openspec/changes/archive/YYYY-MM-DD-<name>/`
   - 将 delta 合入 `openspec/specs/<capability>/spec.md`（ADDED 并入 / MODIFIED 更新 / REMOVED 删除）
3. 校验（若安装 CLI）：`openspec validate --strict`
4. 汇报归档结果
