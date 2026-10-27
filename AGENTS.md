# AGENTS.md

本文件是项目中所有 AI 编码代理（Agent）的根级指令，任何会话都必须遵循。

## 项目理念

本项目的工作流由三层构成：

1. **Harness（Qoder）**：`.qoder/` 下的 agents / commands / rules / skills 组成代理运行框架。
2. **OpenSpec**：`openspec/` 目录承载规范驱动开发（Spec-Driven Development）——系统行为以规格为准，先写规格、评审确认、再写代码。
3. **Superpowers**：`.qoder/skills/` 提供方法论技能——头脑风暴、编写计划、TDD、子代理驱动开发、系统化调试、完成前验证。

## 强制工作流

任何新功能、行为变更或架构调整，必须依次经过：

1. **explore**：需求模糊时先探索代码与方案（`/opsx-explore`），只读不改。
2. **propose**：创建 `openspec/changes/<name>/` 提案（proposal.md / specs/ / design.md / tasks.md），等待用户评审确认（`/opsx-propose`）。
3. **apply**：按 tasks.md 逐条实施，遵循 TDD 与任务级评审（`/opsx-apply`）。
4. **archive**：变更完成并上线后归档，delta 合入 `openspec/specs/`（`/opsx-archive`）。

> 未经用户确认的提案，禁止写任何实现代码。微小修复（拼写、单行 bug）可直接修复，但需同步更新受影响的规格。

## 核心规则

- 所有规则见 `.qoder/rules/`，必须遵守。
- 所有方法论技能见 `.qoder/skills/`，按触发条件强制使用；TDD 与完成前验证为硬性要求。
- `openspec/specs/` 是系统行为的单一事实来源；代码与规格冲突时以规格为准并推动修正。
- 每次会话开始先读 `openspec/project.md` 与相关 spec 再动手。
- 所有结论必须附证据（文件路径、命令输出），禁止臆测。

## 目录约定

根仓库是 AIWorkSpace：只承载 Harness、规范与脚本等协作配置，业务代码位于两个 git submodule。

| 目录 | 用途 |
| --- | --- |
| `openspec/` | 规格与变更提案（单一事实来源） |
| `frontend/` | 前端子仓库（submodule → wanderchina-frontend；Vite 7 + React 19 + TypeScript，端口 5173） |
| `backend/` | 后端子仓库（submodule → wanderchina-backend；Spring Boot 4.1.2 + Java 21，端口 8080） |
| `.qoder/` | 代理框架配置（agents / commands / rules / skills） |

## 子仓库（Submodule）约定

- `frontend/`、`backend/` 是独立 git 仓库，代码改动在对应子仓库内 commit / push，不通过根仓库提交
- 克隆根仓库后先初始化子模块：`git submodule update --init --recursive`
- 子仓库推送后，回根仓库提交新的 gitlink（根仓库只记录子仓库的 commit 指针）
- 本地开发：根目录双击 `start.bat` 一键启动，或在 `frontend/`、`backend/` 内分别启动

## 角色分工

- 子代理（subagent）定义位于 `.qoder/agents/`，规划说明见该目录下的 README.md
