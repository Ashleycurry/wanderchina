# backend-scaffold 规格

## ADDED Requirements

### Requirement: Spring Boot 工程可构建并可运行

系统 SHALL 提供位于 `src/backend/` 的 Maven 单模块 Spring Boot 工程（Java 21，Spring Boot 4.1.2），`mvn test` 与 `mvn spring-boot:run` 均可成功执行。

#### Scenario: Maven 测试构建通过

- **WHEN** 在 `src/backend/` 下执行 `mvn -q test`
- **THEN** 构建成功且所有测试通过

#### Scenario: 应用启动并监听 8080

- **WHEN** 执行 `mvn spring-boot:run`
- **THEN** 应用在 8080 端口启动且日志无错误

### Requirement: 健康检查接口

系统 SHALL 提供 `GET /api/health` 接口，返回统一响应结构，包含应用名与状态。

#### Scenario: 健康检查成功

- **WHEN** 客户端请求 `GET /api/health`
- **THEN** 返回 HTTP 200，body 满足 `{"code": 0, "message": "ok", "data": {...}}`

### Requirement: 回显接口与参数校验

系统 SHALL 提供 `GET /api/echo?message=<text>` 接口回显消息；`message` 缺失或为空时返回统一错误响应。

#### Scenario: 正常回显

- **WHEN** 客户端请求 `GET /api/echo?message=hi`
- **THEN** 返回 HTTP 200 且 `data.message` 等于 `hi`

#### Scenario: 缺少参数

- **WHEN** 客户端请求 `GET /api/echo`（无 message 参数）
- **THEN** 返回 HTTP 400，且 body 为统一错误结构（`code` 非 0）

### Requirement: 统一响应与全局异常处理

系统 SHALL 通过 `ApiResponse<T>` 统一包装所有接口响应，并通过全局异常处理器将异常转换为统一错误结构。

#### Scenario: 业务异常被统一处理

- **WHEN** 任意控制器抛出 `IllegalArgumentException`
- **THEN** 响应 HTTP 400，body 为统一错误结构（`code` 非 0）

#### Scenario: 未知异常被统一处理

- **WHEN** 任意控制器抛出未捕获异常
- **THEN** 响应 HTTP 500，body 为统一错误结构（`code` 非 0）
