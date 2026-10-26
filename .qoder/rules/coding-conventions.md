---
name: coding-conventions
description: 编码约定规则：命名、注释、测试、实现原则与提交规范
---

# 编码约定（Coding Conventions）

以下约定适用于本项目所有代码与文档：

## 命名

- 文件与目录：kebab-case（如 user-service.ts、spec-driven-workflow.md）
- 变量与函数：camelCase；类与接口：PascalCase；常量：UPPER_SNAKE_CASE
- OpenSpec 变更名：动词开头的 kebab-case（add- / update- / remove- / fix-）

## 注释

- 注释使用中文，与用户沟通语言一致
- 注释解释"为什么"，不重复"做什么"
- 公共 API 必须有简短说明

## 测试（TDD）

- 先写失败测试（RED），再写最小实现（GREEN），最后重构（REFACTOR）
- 未测试的代码视同不存在
- 禁止先实现后补测试；测试必须真实运行过

## 实现原则

- YAGNI：只做规格/提案范围内的事
- DRY：消除重复
- 证据优先：所有结论与进展声明须附文件路径、命令输出等可核查证据

## 提交规范

- Conventional Commits：`feat:` / `fix:` / `docs:` / `refactor:` / `test:` / `chore:`
