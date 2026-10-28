## MODIFIED Requirements

### Requirement: Spring Boot 工程可构建并可运行

系统 SHALL 提供位于 `backend/` 的 Maven 单模块 Spring Boot 3.5.x 工程（Java 21）；在依赖已下载且数据库配置启用（取消 `application.yml` 中 datasource / flyway 注释）的前提下，`mvn test` 与 `mvn spring-boot:run` 均可成功执行。数据库配置留空期间，后端不可启动（属预期）。

#### Scenario: Maven 测试构建通过

- **WHEN** 数据库配置已启用，在 `backend/` 下执行 `mvn -q test`
- **THEN** 构建成功且所有测试通过

#### Scenario: 应用启动并监听 8080

- **WHEN** 数据库配置已启用，执行 `mvn spring-boot:run`
- **THEN** 应用在 8080 端口启动，Flyway 迁移执行成功，日志无错误

## ADDED Requirements

### Requirement: MySQL 数据源与数据访问

系统 SHALL 通过 `spring-boot-starter-jdbc`（JdbcTemplate）规划数据访问（不引入 JPA / MyBatis）；数据源配置在 `application.yml` 中以**注释模板**形式保留，本阶段不启用，后续配置时取消注释即可生效。

#### Scenario: 数据源配置留空待启用

- **WHEN** 查看 `application.yml`
- **THEN** `datasource` 配置以注释形式存在（含 `jdbc:mysql://localhost:3306/wanderchina` 模板与 `${DB_USERNAME}` / `${DB_PASSWORD}` 占位），未作为运行时配置生效

#### Scenario: 启用步骤最小化

- **WHEN** 后续需要接入数据库
- **THEN** 取消 `datasource` 与 `flyway` 注释并按需设置 `DB_USERNAME` / `DB_PASSWORD` 即可，无需改动 Java 代码

### Requirement: Flyway 数据库迁移

系统 SHALL 使用 Flyway（`flyway-core` + `flyway-mysql`）管理数据库 schema 版本；迁移脚本已就位于 `classpath:db/migration`，Flyway 配置以注释模板保留，启用后应用启动时自动执行。

#### Scenario: 迁移脚本就位且配置留空

- **WHEN** 查看 `application.yml` 与 `src/main/resources/db/migration/`
- **THEN** Flyway 配置以注释形式存在，`V1__init.sql` 已就位且不含 DDL

#### Scenario: 启用后空库首次启动自动迁移

- **WHEN** 数据库配置已启用且对空库首次启动应用
- **THEN** Flyway 创建 `flyway_schema_history` 并记录版本 V1，应用启动成功

#### Scenario: 迁移脚本命名与位置规范

- **WHEN** 新增数据库变更脚本
- **THEN** 脚本位于 `src/main/resources/db/migration/` 且命名符合 `V<版本>__<描述>.sql`（如 `V2__create_trip_table.sql`）

### Requirement: Spring AI 模型接入骨架

系统 SHALL 声明 Spring AI 1.0.x BOM 与 `spring-ai-starter-model-openai`，并在配置中提供 `spring.ai.openai` 占位段（`base-url` / `api-key` / `model` 均可由环境变量覆盖，默认值不得为明文密钥）；本变更不包含任何模型调用代码。

#### Scenario: AI 配置以环境变量占位

- **WHEN** 查看 `application.yml`
- **THEN** 存在 `spring.ai.openai` 配置段，`api-key` 引用环境变量占位而非明文

#### Scenario: 未配置密钥不阻塞现有接口

- **WHEN** 未设置 AI 密钥（配置使用默认占位）且依赖已安装，启动应用
- **THEN** `GET /api/health` 与 `GET /api/echo?message=hi` 正常工作
