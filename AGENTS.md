# AGENTS.md

本文件是项目中所有 AI 编码代理（Agent）的根级指令，任何会话都必须遵循。

## 项目理念

本项目的工作流由三层构成：

1. **Harness（Qoder）**：`.qoder/` 下的 agents / commands / rules / skills 组成代理运行框架。
2. **OpenSpec**：`openspec/` 目录承载规范驱动开发（Spec-Driven Development）——系统行为以规格为准，先写规格、评审确认、再写代码。
3. **Superpowers**：`.qoder/skills/` 提供方法论技能——头脑风暴、编写计划、TDD、子代理驱动开发、系统化调试、完成前验证。

## 强制工作流

任何新功能、行为变更或架构调整，必须依次经过：

1. **explore**：需求模糊时先探索代码与方案（`/explore`），只读不改。
2. **propose**：创建 `openspec/changes/<name>/` 提案（proposal.md / specs/ / design.md / tasks.md），等待用户评审确认（`/propose`）。
3. **apply**：按 tasks.md 逐条实施，遵循 TDD 与任务级评审（`/apply`）。
4. **archive**：变更完成并上线后归档，delta 合入 `openspec/specs/`（`/archive`）。

> 未经用户确认的提案，禁止写任何实现代码。微小修复（拼写、单行 bug）可直接修复，但需同步更新受影响的规格。

## 核心规则

- 所有规则见 `.qoder/rules/`，必须遵守。
- 所有方法论技能见 `.qoder/skills/`，按触发条件强制使用；TDD 与完成前验证为硬性要求。
- `openspec/specs/` 是系统行为的单一事实来源；代码与规格冲突时以规格为准并推动修正。
- 每次会话开始先读 `openspec/project.md` 与相关 spec 再动手。
- 所有结论必须附证据（文件路径、命令输出），禁止臆测。

## 目录约定

| 目录 | 用途 |
| --- | --- |
| `openspec/` | 规格与变更提案（单一事实来源） |
| `src/` | 源代码 |
| `.qoder/` | 代理框架配置（agents / commands / rules / skills） |

## 角色分工

- 子代理（subagent）定义位于 `.qoder/agents/`，规划说明见该目录下的 README.md
