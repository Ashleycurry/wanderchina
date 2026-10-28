# Design: 后端技术栈升级为 Spring Boot 3 + Spring AI + MySQL + Flyway

## 目标结构

```text
backend/
├── pom.xml                          # parent 3.5.x + Spring AI BOM + jdbc/mysql/flyway
└── src/main/
    ├── java/com/wanderchina/        # 现有代码零改动
    └── resources/
        ├── application.yml          # datasource / flyway / spring.ai 配置占位
        └── db/
            └── migration/
                └── V1__init.sql     # 空迁移占位（仅注释）
```

## 决策

### D1：Spring Boot 4.1.2 → 3.5.x（降级）

- **理由**：Spring AI 1.0 官方兼容矩阵只覆盖 Spring Boot 3.4 / 3.5，4.x 无法接入；本项目的核心增量是 AI 能力，Boot 3.5 是当前唯一可行基线
- **否决**：Boot 4 + 手写 HTTP 调模型（失去 ChatClient / Advisor / 自动重试等 Spring AI 抽象）
- **兼容性评估**：现有代码仅使用 Spring MVC 标准注解（`@RestController` / `@RestControllerAdvice` / `@ExceptionHandler`）与 JDK HttpClient 测试，Boot 3.5 完全兼容，无需改动

### D2：Spring AI 1.0.x + OpenAI 兼容 starter

- **理由**：OpenAI 协议已是事实标准，`spring.ai.openai.base-url` 可指向 DeepSeek / DashScope / Ollama 等兼容服务，避免过早绑定单一供应商
- **否决**：按供应商分别引入 starter（本次只做骨架，不应绑定）
- **配置**：`base-url` / `api-key` / `model` 全部走环境变量占位，默认值不得为真实密钥

### D3：数据访问用 JdbcTemplate，不引入 JPA / MyBatis

- **理由**：MVP 数据操作少，SQL 显式可控；schema 已由 Flyway 管理，JPA 的 `ddl-auto` 无价值
- **否决**：JPA（隐式行为多、调试成本高）、MyBatis（额外 XML / 注解层，MVP 过重）
- **边界**：后续出现复杂动态查询时，可另行提案引入 MyBatis，不属本变更

### D4：Flyway（`flyway-core` + `flyway-mysql`）

- **理由**：Flyway 10+ 将 MySQL 支持拆为独立模块，必须同时声明 `flyway-mysql`
- **位置**：默认 `classpath:db/migration`
- **V1 语义**：空迁移仅用于打通迁移链路；后续建表用 V2 起，**不得修改已执行的 V1**（checksum 校验会失败）

### D5：配置留空策略（数据库后配）

- 用户决策：数据库部分先留空，后续再配置。`datasource` 与 `flyway` 以注释模板形式保留在 `application.yml`，不作为运行时配置生效
- **留空期**：引入 `spring-boot-starter-jdbc` 后无 datasource 配置，`mvn spring-boot:run` 与 3 个 `@SpringBootTest` 会因缺少数据源失败，属预期状态（与前端「依赖未装」对称）
- **启用步骤**（后续配置时）：① 本地安装 MySQL 8 并 `CREATE DATABASE wanderchina CHARACTER SET utf8mb4;` ② 取消 `application.yml` 中 datasource / flyway 注释 ③ 按需设置 `DB_USERNAME` / `DB_PASSWORD`
- **否决**：引入 H2 作默认库（用户选型无 H2，双数据库语义会掩盖真实问题）；全局排除 DataSourceAutoConfiguration（会让启用数据库多一个易遗忘的开关，偏离最小改动）

### D6：版本基线

| 组件 | 基线 | 说明 |
| --- | --- | --- |
| spring-boot-starter-parent | 3.5.6 | 3.5.x 线最新补丁，安装时确认 |
| spring-ai-bom | 1.0.3 | 1.0.x 线最新补丁，安装时确认 |
| mysql-connector-j | Boot BOM 管理 | 不写死版本 |
| flyway-core / flyway-mysql | Boot BOM 管理 | 不写死版本 |

版本统一收敛到 `pom.xml` 属性（`spring-ai.version`），便于后续升级；若安装时发现更高补丁，以最新补丁为准并同步本文件。

### D7：占位策略（不下载）

- 本变更只做三件事：改 `pom.xml` 声明依赖、改 `application.yml` 配置占位、新增 `V1__init.sql` 空占位
- **不执行 `mvn`、不触发依赖下载、不改动 `~/.m2`**
- 验证方式：静态检查（配置项存在、依赖坐标正确、目录结构正确）

## 风险

| 风险 | 影响 | 缓解 |
| --- | --- | --- |
| Boot 4 → 3.5 降级 | 未来若需 Boot 4 新特性需重评 | 现有代码零改动，已确认兼容；升级路径留给后续提案 |
| Spring AI 补丁版 API 漂移 | 1.0.x 小版本间配置键可能调整 | 依赖统一走 BOM；安装后跑一次启动验证 |
| 现有测试暂时变红 | 3 个 `@SpringBootTest` 无 MySQL 时失败 | 属预期「依赖未就绪」；MySQL 就绪后恢复 |
| 迁移链路未验证 | V1 空迁移可能未被执行过 | 安装依赖 + 建库后按 tasks 验证 `flyway_schema_history` |
| 凭据泄露 | 配置中出现明文密码 | 全部 env 占位（`${DB_PASSWORD:}`），默认值仅本地开发 |
