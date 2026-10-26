---
name: executing-plans
description: 在当前会话内逐条执行计划，最后统一评审；成本最低的执行模式
---

# executing-plans（执行计划）

## 何时触发

- 计划已就绪且用户说"开始/执行"
- 变更规模不大，单会话可完成

## 执行方式

1. 按 tasks.md 顺序逐条执行，一条任务完成后立即验证
2. 每条任务遵循 `test-driven-development` 技能
3. 完成任务后更新任务清单勾选状态
4. 全部完成后做一次整体评审（对照规格逐场景验证）
5. 汇报：完成了什么、验证证据、遗留问题

## 与 subagent-driven-development 的选择

- 改动大、需频繁评审 → 用 `subagent-driven-development`
- 改动小、追求成本 → 用本技能
