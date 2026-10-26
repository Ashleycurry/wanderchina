# wanderchina

基于 **Harness（Qoder）+ OpenSpec + Superpowers** 三合一理念初始化的 AI coding 全栈开发项目骨架。

## 三大支柱

- **Harness（`.qoder/`）**：代理运行框架，提供子代理（agents）、斜杠命令（commands）、规则（rules）与技能（skills）。
- **OpenSpec（`openspec/`）**：规范驱动开发（Spec-Driven Development）。先写规格、评审确认，再写代码；`specs/` 是系统行为的单一事实来源。
- **Superpowers（`.qoder/skills/`）**：技能化开发方法论——头脑风暴、编写计划、TDD、子代理驱动开发、系统化调试、完成前验证。

## 工作流

```
需求 → /explore 探索现状与候选方案
     → /propose 创建 openspec/changes/<name>/ 提案（proposal + specs + design + tasks）
     → 用户评审确认
     → /apply 按任务清单实施（TDD + 子代理驱动）
     → 验证（verification-before-completion）
     → /archive 归档变更，delta 合入 specs/
```

## 目录结构

```
.
├── .qoder/                 # AI 编码框架（Harness 层）
│   ├── agents/             # 子代理定义（规划见 agents/README.md）
│   ├── commands/           # 斜杠命令：explore / propose / apply / archive
│   ├── rules/              # 规则：coding-conventions / spec-driven-workflow
│   └── skills/             # opsx 链路技能 + Superpowers 技能库
├── openspec/               # 规范层（单一事实来源）
│   ├── changes/            # 进行中的变更提案（归档后进入 archive/）
│   ├── specs/              # 已合入的规格
│   ├── config.yaml         # OpenSpec 配置
│   └── project.md          # 项目上下文（技术栈、约定、约束）
├── src/                    # 源代码
├── .gitignore
├── AGENTS.md               # 所有 AI 代理的根级指令
└── README.md
```

## 快速开始

### 1. 安装 OpenSpec CLI（可选，用于校验）

```powershell
irm https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/scripts/binary/install.ps1 | iex
```

或 `npm install -g @fission-ai/openspec@latest`（需 Node.js 20.19+）。

### 2. 开始一个变更

在 AI 编码代理中输入：

```
/explore 我想做 XXX          # 探索现状与方案
/propose add-xxx             # 创建变更提案，等待评审
/apply                       # 按提案实施（TDD）
/archive                     # 完成后归档
```

### 3. 参考

- OpenSpec: https://github.com/Fission-AI/OpenSpec
- Superpowers: https://github.com/obra/superpowers
