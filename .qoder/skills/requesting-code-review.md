---
name: requesting-code-review
description: 提交评审前的自检清单：对照计划与规格核对变更，分级报告问题
---

# requesting-code-review（请求代码评审）

## 何时触发

- 任务间或变更完成后、提交/合并前

## 评审方式

1. 对照依据：变更提案（proposal/specs）与任务清单（tasks.md）
2. 第一轮：规格符合性 — 每条需求/场景是否有对应实现
3. 第二轮：代码质量 — 命名、DRY、错误处理、测试覆盖、安全性
4. 问题分级：
   - critical：阻断合并/继续
   - major：合并前必须修复
   - minor：建议改进
5. 输出问题清单（附文件与行号）与结论

## 规则

- critical 未解决前不得继续后续任务
- 评审不修改代码，问题交还实施者修复
