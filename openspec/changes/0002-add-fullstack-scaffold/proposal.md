# 0002 · 全栈开发框架搭建（Spring Boot + React）

## Why

项目目前只有 AI 编码框架与 OpenSpec 规格骨架，`src/` 为空，没有任何可运行的代码。后续所有业务变更都需要一个标准化、可测试、可联调的前后端工程地基，避免每个变更重复解决工程配置问题。

## What Changes

- 新增 `src/backend/`：Spring Boot 4.1.2 + Maven 单模块（Java 21），含统一响应结构、全局异常处理、健康检查与回显接口
- 新增 `src/frontend/`：Vite + React + TypeScript SPA（npm 管理），配置 `/api` 代理，示例页面调用后端
- 前后端联调：Vite dev server 代理 `http://localhost:8080`
- 更新 `openspec/project.md`：填充真实技术栈与约定
- 更新 `README.md`：前后端启动与联调说明

不包含：数据库接入、认证授权、任何业务功能（YAGNI）。

## Impact

- 受影响规格：新增 `backend-scaffold`、`frontend-scaffold` 两个能力
- 代码：新增 `src/backend/` 与 `src/frontend/` 两个工程
- 依赖：本机已具备 Java 21、Maven 3.9.16、Node 24、npm 11
