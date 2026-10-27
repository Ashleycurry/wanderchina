# Change: 引导初始化 OpenSpec 工作流

## Why

项目需要一套可靠的 AI 编码工作流：在写代码之前先对齐"要构建什么"，让人类与 AI 在规格上达成一致，避免"聊完就忘、写完就跑偏"。为此引入 OpenSpec 规范驱动开发（SDD）+ Qoder Harness + Superpowers 技能方法论。

## What Changes

- 初始化 `openspec/` 骨架：config.yaml、project.md、specs/、changes/（含 archive/）
- 初始化 `.qoder/` 代理配置：
  - `rules/`：coding-conventions.md、spec-driven-workflow.md
  - `skills/`：opsx 链路四个技能（openspec-explore-change / openspec-propose-change / openspec-apply-change / openspec-archive-change）
  - `agents/`：README.md
- 新增根级 `AGENTS.md`（所有代理的根级指令）与 `README.md`
- 扩充 `.gitignore`

## Impact

- 影响面：仅新增基础设施文件，不影响 `src/` 业务代码
- 风险：低；后续所有变更将走 explore → propose → apply → archive 流程
