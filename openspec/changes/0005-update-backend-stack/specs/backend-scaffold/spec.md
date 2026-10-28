## MODIFIED Requirements

### Requirement: Spring Boot 工程可构建并可运行

系统 SHALL 提供位于 `backend/` 的 Maven 单模块 Spring Boot 3.5.x 工程（Java 21），在依赖已下载且本地 MySQL 8 已建库的前提下，`mvn test` 与 `mvn spring-boot:run` 均可成功执行。

#### Scenario: Maven 测试构建通过

- **WHEN** 本地 MySQL 已建库，在 `backend/` 下执行 `mvn -q test`
- **THEN** 构建成功且所有测试通过

#### Scenario: 应用启动并监听 8080

- **WHEN** 本地 MySQL 已建库，执行 `mvn spring-boot:run`
- **THEN** 应用在 8080 端口启动，Flyway 迁移执行成功，日志无错误

## ADDED Requirements

### Requirement: MySQL 数据源与数据访问

系统 SHALL 通过 `spring-boot-starter-jdbc`（JdbcTemplate）接入 MySQL 8，默认连接 `localhost:3306/wanderchina`，账号密码由环境变量注入，不在配置文件中出现明文凭据；不引入 JPA / MyBatis。

#### Scenario: 数据源默认指向本地 wanderchina 库

- **WHEN** 查看 `application.yml`
- **THEN** `spring.datasource.url` 默认指向 `localhost:3306/wanderchina`，`username` / `password` 引用环境变量占位（如 `${DB_USERNAME:root}`）

#### Scenario: 环境就绪后连接可用

- **WHEN** MySQL 已建库、依赖已安装，执行 `mvn spring-boot:run`
- **THEN** 应用启动成功，无数据源连接错误

### Requirement: Flyway 数据库迁移

系统 SHALL 使用 Flyway（`flyway-core` + `flyway-mysql`）管理数据库 schema 版本，迁移脚本位于 `classpath:db/migration`，应用启动时自动执行。

#### Scenario: 空库首次启动自动迁移

- **WHEN** 对空库首次启动应用
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
