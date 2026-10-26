# Design: 引导初始化 OpenSpec 工作流

## Context

项目当前为空骨架（仅 .gitignore / LICENSE），需要先搭好"怎么工作"的框架，再开始业务开发。

## Goals / Non-Goals

- Goals：建立先规格后编码的 SDD 流程；技能按 opsx 链路自动触发；规格成为单一事实来源
- Non-Goals：不引入具体技术栈与业务代码（由后续变更处理）

## Decisions

1. **采用 OpenSpec 的 changes/specs 双目录模型**：进行中变更放 `changes/`，稳定规格放 `specs/`，完成归档进 `changes/archive/`。理由：纯 Markdown、简单、可评审。
   - 替代方案：Spec Kit（太重、阶段门禁僵硬）；无规格直接开发（不可控）
2. **`.qoder` 分层 agents / commands / rules / skills**：命令是入口、规则是约束、技能是方法论、代理是执行者。
3. **技能命名采用 opsx 链路**：`openspec-{explore,propose,apply,archive}-change`，与官方 `/opsx:*` 命令对齐。
4. **规则拆分为两个文件**：编码约定（coding-conventions）与 SDD 工作流（spec-driven-workflow），职责单一、便于单独维护。

## Risks / Trade-offs

- 流程开销 vs 可预测性：小改动也需提案，可能显得重。缓解：微小修复豁免条款（见 spec-driven-workflow 规则）。
