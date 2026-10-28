# Proposal: 后端技术栈升级为 Spring Boot 3 + Spring AI + MySQL + Flyway

## Why

当前后端是 Spring Boot 4.1.2 骨架：只有健康检查与回显接口，没有数据库，也没有模型能力。下一步要做的业务需要三块支撑：

- **模型能力进业务**：需要 Spring AI
- **数据持久化**：需要 MySQL
- **数据库版本化迁移**：需要 Flyway

而 **Spring AI 1.0 只支持 Spring Boot 3.4 / 3.5，不支持 4.x**，因此需要把 Spring Boot 从 4.1.2 降到 3.5.x。

> 需求原文中的「React 负责组件拆分」属前端职责，已由前端选型（0004）覆盖，本提案不重复。

## What Changes

### 技术选型（新基线）

| 层 | 旧 | 新 | 职责 |
| --- | --- | --- | --- |
| 工程骨架 | Spring Boot 4.1.2 | Spring Boot 3.5.x | 负责工程骨架 |
| AI 接入 | 无 | Spring AI 1.0.x（BOM + OpenAI 兼容 starter） | 把模型能力接进业务 |
| 语言 | Java 21 | Java 21（不变） | 统一语言版本 |
| 构建 | Maven | Maven（不变） | 管依赖和构建 |
| 数据库 | 无 | MySQL 8.x | 存数据 |
| 数据迁移 | 无 | Flyway（core + mysql） | 管数据库迁移 |
| 数据访问 | 无 | `spring-boot-starter-jdbc`（JdbcTemplate） | 轻量访问，不引入 JPA / MyBatis |

### 包含（In Scope）

- `pom.xml`：parent 改为 Spring Boot 3.5.x，保留 Java 21；新增 `spring-boot-starter-jdbc`、`mysql-connector-j`、`flyway-core`、`flyway-mysql`、`spring-ai-bom`（dependencyManagement）、`spring-ai-starter-model-openai`
- `application.yml`：新增 datasource（主机/库名固定，账号密码走环境变量占位）、Flyway（`classpath:db/migration`）、Spring AI（OpenAI 兼容协议，`base-url` 可指向兼容服务）配置段
- `src/main/resources/db/migration/V1__init.sql`：空迁移占位（仅注释，不建表）
- 规范同步：`AGENTS.md` 技术选型约束、`openspec/project.md` Tech Stack、`README.md` 环境前置要求

### 不包含（Out of Scope）

- **依赖下载与 Maven 构建：本变更不执行 `mvn`，不下载任何依赖**（用户明确要求「不要着急盲目下载」）
- MySQL 安装、建库建账号（环境前置条件，由用户自备）
- 任何业务表结构与 Repository / Service 代码（后续变更）
- 具体模型供应商的实现接入（本次仅骨架、依赖声明与配置占位）
- 现有接口行为改动（`/api/health`、`/api/echo` 保持不变）
- 前端任何改动

## Impact

- 修改 capability：`backend-scaffold`（Boot 版本 + 新增数据层、迁移、AI 接入三条 Requirement）
- 受影响文件：`backend/pom.xml`、`backend/src/main/resources/application.yml`、`backend/src/main/resources/db/migration/`、`AGENTS.md`、`openspec/project.md`、`README.md`
- 状态影响：完成后后端进入「骨架就绪、依赖未装」状态；运行须满足两个前置条件：① `mvn` 下载依赖 ② 本地 MySQL 8 已建库。在此之前 `mvn test` / `spring-boot:run` 均不可用（现有 3 个测试会因无数据源失败，属预期）
