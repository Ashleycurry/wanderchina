# Agents

本目录存放 Qoder 子代理（subagent）定义。

## 格式

每个子代理是一个带 YAML frontmatter 的 Markdown 文件：

```markdown
---
name: <agent-name>
description: <一句话职责>
tools: Read, Grep, Glob, LSP, Bash
model: inherit
---

<系统提示词：职责 / 工作方式 / 边界>
```

## 规划

子代理将按 opsx 链路逐步添加，随课程进度补充：

- explorer：探索代码与规格
- planner：需求 → 变更提案
- executor：实施任务
- reviewer：评审实现
