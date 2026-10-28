# Tasks: 后端技术栈升级为 Spring Boot 3 + Spring AI + MySQL + Flyway

> 约束：本变更**只做声明与占位，不执行 `mvn`、不下载依赖、不连数据库**。执行粒度 2~5 分钟/条。

## 1. pom.xml 依赖声明（仅改文件，不下载）

- [x] 1.1 `backend/pom.xml`：parent 版本 `4.1.2` → `3.5.6`；新增属性 `<spring-ai.version>1.0.3</spring-ai.version>`
- [x] 1.2 `backend/pom.xml` 新增 `dependencyManagement` 导入 `org.springframework.ai:spring-ai-bom:${spring-ai.version}`（type pom / scope import）
- [x] 1.3 `backend/pom.xml` 新增依赖坐标：
  - `org.springframework.boot:spring-boot-starter-jdbc`（不写版本，parent 管理）
  - `com.mysql:mysql-connector-j`（runtime，不写版本）
  - `org.flywaydb:flyway-core`
  - `org.flywaydb:flyway-mysql`
  - `org.springframework.ai:spring-ai-starter-model-openai`（不写版本，BOM 管理）
- [x] 1.4 保留原有 `spring-boot-starter-web`、`spring-boot-starter-test`、`spring-boot-maven-plugin` 不变
- **验证**：`Select-String pom.xml` 检查 5 个新坐标存在、`4.1.2` 已无残留、Java 版本仍为 21；**不运行 mvn**

## 2. application.yml 配置占位

- [x] 2.1 新增 `spring.datasource`：`url: jdbc:mysql://localhost:3306/wanderchina?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai`、`username: ${DB_USERNAME:root}`、`password: ${DB_PASSWORD:}`
- [x] 2.2 新增 `spring.flyway`：`enabled: true`、`locations: classpath:db/migration`、`baseline-on-migrate: true`
- [x] 2.3 新增 `spring.ai.openai`：`base-url: ${AI_BASE_URL:https://api.openai.com}`、`api-key: ${AI_API_KEY:not-configured}`、`chat.options.model: ${AI_MODEL:gpt-4o-mini}`（占位默认值不得为真实密钥）
- **验证**：读取 `application.yml`，三个配置段均存在，凭据均为 env 占位

## 3. 迁移脚本占位

- [x] 3.1 新建 `backend/src/main/resources/db/migration/V1__init.sql`：仅含注释（说明「骨架占位，不建表；后续建表从 V2 开始」），无任何 DDL
- **验证**：文件存在、内容无 `CREATE` / `ALTER` / `DROP` 语句

## 4. 规范与文档同步

- [x] 4.1 `AGENTS.md` 技术选型约束：
  - 选型表「后端框架」行：`Spring Boot 4.1.2` → `Spring Boot 3.5.x`；新增「AI 接入 Spring AI 1.0.x」「数据库 MySQL 8」「数据迁移 Flyway」行；后端行职责补「工程骨架」
  - 「刻意不引入」清单：把「数据库/ORM」改为「JPA / MyBatis / H2」
  - 「固定约定」保持端口 8080 不变
- [x] 4.2 `openspec/project.md` Tech Stack：后端行改为 `Spring Boot 3.5.x + Java 21 + Maven`；新增数据库行 `MySQL 8 + Flyway`
- [x] 4.3 `README.md`：环境前置补 MySQL 8 说明（安装 + `CREATE DATABASE wanderchina CHARACTER SET utf8mb4;` + 设置 `DB_USERNAME` / `DB_PASSWORD` / `AI_API_KEY` 环境变量）
- **验证**：三处文档均无「Spring Boot 4」残留

## 5. 验收标准（AC）

- [x] AC1 `pom.xml` parent 为 `3.5.6`，`java.version` 仍为 `21`
- [x] AC2 `pom.xml` 含 `spring-boot-starter-jdbc` / `mysql-connector-j` / `flyway-core` / `flyway-mysql` / `spring-ai-bom` / `spring-ai-starter-model-openai` 六个坐标
- [x] AC3 `application.yml` 含 `spring.datasource` / `spring.flyway` / `spring.ai.openai` 三段，凭据全为 env 占位
- [x] AC4 `db/migration/V1__init.sql` 存在且不含 DDL
- [x] AC5 现有 Java 代码零改动（`git diff` 中无 `.java` 文件）
- [x] AC6 全程未执行 `mvn`、未新增 `~/.m2` 下载（本变更只改文件）
- [x] AC7 三处文档同步完成（AGENTS.md / project.md / README.md）
- [x] AC8 `openspec validate 0005-update-backend-stack --strict` 通过

## 6. 提交

- [x] 6.1 `backend` 子仓库提交：`pom.xml`、`application.yml`、`V1__init.sql`
- [x] 6.2 根仓库提交：提案四件套 + `AGENTS.md` / `project.md` / `README.md` + frontend/backend gitlink（backend 指针变更）

## 前置条件（本变更不执行，等用户确认）

- MySQL 8 安装并建库：`CREATE DATABASE wanderchina CHARACTER SET utf8mb4;`
- 依赖下载：`mvn -q test`（需联网；届时会拉取 Spring Boot 3.5.x + Spring AI 1.0.x 全部依赖）
- 环境变量：`DB_USERNAME` / `DB_PASSWORD` / `AI_API_KEY`（可选 `AI_BASE_URL` / `AI_MODEL`）
