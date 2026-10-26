---
name: openspec-apply-change
description: opsx 链路第 3 步：按已确认提案逐条实施任务（TDD），更新勾选并验证
---

# openspec-apply-change（实施变更）

## 前置条件

- 提案已获用户确认

## 流程

1. 读 `openspec/changes/<name>/` 的 proposal.md / design.md / tasks.md 与 delta specs
2. 按 tasks.md 顺序逐条实施：
   - 每条任务遵循 `test-driven-development`（RED-GREEN-REFACTOR）
   - 完成后立即验证，勾选 `[x]` 并附验证证据
3. 全部完成后运行完整测试套件，对照 specs 场景逐条验证（`verification-before-completion`）
4. 向用户汇报完成情况与验证证据

## 规则

- 只做提案内的事（YAGNI）；发现提案缺陷回到 propose 修正
- 未验证的任务不得标记完成
