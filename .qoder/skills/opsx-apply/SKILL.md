---
name: opsx-apply
version: 1.0.0
description: 按已确认的 OpenSpec 变更提案逐条实施（TDD + 子代理驱动开发，opsx 链路第 3 步）
user-invocable: true
argument-hint: "<change-name>"
---

# opsx-apply

按已确认的 `openspec/changes/<name>/` 提案实施代码。

## 前置条件

- 变更提案已通过用户评审（`/opsx-propose` 完成）
- 知道要实施的变更名（`/opsx-apply <name>`）

## 执行步骤

1. 读取 `openspec/changes/<name>/` 的 proposal.md / specs/ / design.md / tasks.md
2. 按 `tasks.md` 逐条实施，使用 `.qoder/skills/` 中的技能：
   - `executing-plans` 或 `subagent-driven-development` — 每条任务独立完成 + 评审
   - `test-driven-development` — 每个实现先写失败测试（RED）再实现（GREEN）再重构（REFACTOR）
3. 每条任务完成后对照 tasks.md 打勾；任务间按需触发 `requesting-code-review`
4. 全部完成后：
   - 运行完整测试套件并确保通过
   - 对照 specs 场景逐条验证（`verification-before-completion`）
   - 向用户汇报完成情况与验证证据
5. 提交代码，等待用户决定是否归档（`/opsx-archive`）

## 规则

- 严禁实施提案之外的需求（YAGNI）
- 未通过测试/验证的任务不得标记为完成
- 发现提案缺陷时停止并回到 `propose` 修正，不得私自改范围
