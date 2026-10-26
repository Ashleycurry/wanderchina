---
name: subagent-driven-development
description: 每条任务派发独立子代理实施并评审，两阶段评审保证规格符合与代码质量
---

# subagent-driven-development（子代理驱动开发）

## 何时触发

- 变更规模大、任务多，需要隔离上下文
- 用户选择"最彻底"的执行模式

## 执行方式

1. 主代理（orchestrator）持有完整计划，逐条派发任务给 executor 子代理
2. 每个子代理完成一条任务后，触发两阶段评审：
   - 第一阶段：规格符合性 — 对照 proposal/specs 核对实现是否达标
   - 第二阶段：代码质量 — 可读性、DRY、测试覆盖
3. critical 问题必须修复后才能派发下一条任务
4. 主代理持续记录进度，防止偏离计划
5. 全部完成后由主代理汇总验证证据并向用户汇报
