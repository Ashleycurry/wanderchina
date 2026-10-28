# Project Context

## Purpose

WanderChina：基于 Harness（Qoder）+ OpenSpec + Superpowers 的 AI coding 全栈开发项目。
当前阶段为前后端地基（无业务）：前端可构建，后端已声明 MySQL / Flyway / Spring AI 骨架（依赖待安装、数据库待就绪），后续业务通过 OpenSpec 变更提案逐步演进。

## Tech Stack

- 后端：Java 21 + Spring Boot 3.5.x + Spring AI 1.0.x（Maven 单模块，端口 8080），包根 `com.wanderchina`
- 前端：Next.js 14.2（App Router）+ React 18.3 + TypeScript 5.9 + Tailwind CSS 3.4 + shadcn/ui（npm 管理，端口 3000），开发环境 `/api` 由 rewrites 代理到 8080
- 数据库：MySQL 8 + Flyway（JdbcTemplate 访问，不引入 JPA/MyBatis）；迁移脚本位于 `backend/src/main/resources/db/migration/`
- 工程方法：OpenSpec（规范驱动开发）+ Superpowers 技能库
- 选型硬约束（版本基线与「刻意不引入」清单）：见 `AGENTS.md` → 技术选型约束

## Project Conventions

### Code Style

- Java：4 空格缩进，类/方法注释用中文 Javadoc；REST 控制器按业务域分包（如 `health`、`common`）
- TypeScript：函数组件 + Hooks，单引号、无分号；类型定义就近声明
- 提交信息引用 OpenSpec 变更名（如 `feat(0002): ...`）

### Architecture Patterns

- 根仓库为 AIWorkSpace（仅 Harness + OpenSpec + 脚本）；前后端为两个独立 git 子仓库（submodule）：`backend/`（REST API）与 `frontend/`（SPA），各自独立构建与提交
- 统一响应结构 `ApiResponse<T>`：`{ code, message, data }`，code=0 成功；失败时 code 与 HTTP 状态一致
- 全局异常处理：缺参/非法参数 → 400，未捕获异常 → 500（不泄露内部细节）

### Testing Strategy

- TDD：先写失败测试（RED）再实现（GREEN）
- 后端：Spring Boot 集成测试（`@SpringBootTest` 随机端口 + JDK HttpClient 真实 HTTP 断言），`mvn test` 全绿
- 前端：`npm run build`（next build）必须通过

### Git Workflow

- 主干开发；变更按 OpenSpec `changes/<name>/` 组织，评审后实施、完成后归档
- 子仓库（`frontend/`、`backend/`）内提交并推送后，根仓库提交新的 gitlink；克隆后需 `git submodule update --init --recursive`
- 不提交 `node_modules/`、`target/`、`.next/`

## Domain Context

WanderChina 面向中国旅行场景（具体业务待后续变更定义）。当前骨架提供健康检查与回显接口用于联调验证。

## Important Constraints

- Spring Boot 3.5.x（Spring AI 1.0 兼容基线；4.x 不被 Spring AI 支持）要求 Java 17+，本机使用 Java 21
- 数据库前置：本地 MySQL 8 并执行 `CREATE DATABASE wanderchina CHARACTER SET utf8mb4;`
- 前端包管理使用 npm（本机未安装 pnpm）
- Windows 环境：PowerShell 5.1 语法（分号分隔命令）

## External Dependencies

- Maven 中央仓库（本机配置 aliyun 镜像）、npm registry（本机为官方源，必要时用 npmmirror 镜像）
- AI 模型服务：OpenAI 兼容接口（`AI_BASE_URL` / `AI_API_KEY` / `AI_MODEL` 环境变量配置）
