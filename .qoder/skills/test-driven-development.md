---
name: test-driven-development
description: 强制 RED-GREEN-REFACTOR 循环：先写失败测试、再写最小实现、最后重构
---

# test-driven-development（测试驱动开发）

## 何时触发

- 任何实现任务开始前（强制性，见 `.qoder/rules/quality-gates.md`）

## RED-GREEN-REFACTOR 循环

1. **RED**：先写一条会失败的测试，运行并确认它因预期原因失败
2. **GREEN**：写最小实现让测试通过，运行确认通过
3. **REFACTOR**：重构消除重复、提升可读性，测试保持全绿
4. 循环通过后提交

## 硬性规则

- 禁止先写实现再补测试
- 发现"先于测试写出的代码"应删除重写
- 测试必须真实失败过（不能只写不跑）
- 不测试的代码视同不存在
