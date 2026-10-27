# openspec-workflow Specification（Delta）

## ADDED Requirements

### Requirement: 规范驱动开发流程

项目 SHALL 采用 OpenSpec 规范驱动开发流程，所有功能变更必须经过 提案（propose）→ 实施（apply）→ 归档（archive）。

#### Scenario: 创建变更提案
- **WHEN** 用户提出新功能需求
- **THEN** 代理必须先创建 `openspec/changes/<name>/` 提案（proposal.md、specs/、tasks.md）并等待评审确认
- **AND** 确认前不得编写实现代码

#### Scenario: 实施已确认提案
- **WHEN** 提案获得用户确认
- **THEN** 代理按 tasks.md 逐条实施并遵循 TDD
- **AND** 每条任务完成后提供验证证据

#### Scenario: 归档已完成变更
- **WHEN** 变更全部任务完成且上线
- **THEN** 变更归档到 `changes/archive/YYYY-MM-DD-<name>/`
- **AND** delta 规格合入 `openspec/specs/`

### Requirement: 代理配置目录

项目 SHALL 在 `.qoder/` 目录下组织 AI 编码框架配置（agents / commands / rules / skills）。

#### Scenario: 规则与技能齐备
- **WHEN** 会话开始
- **THEN** 代理应能读取 `.qoder/rules/` 中的规则
- **AND** 按需触发 `.qoder/skills/` 中的技能
