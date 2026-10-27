# Design: Todo 模块技术设计

## 1. 数据模型（前后端统一驼峰命名）

长度口径：所有字符串长度按 **Unicode code point** 计数（emoji 计 1 个字符）；description 空串等价 null。

### Todo（响应对象）

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| id | string | UUID v4，36 字符 | 服务端生成 |
| title | string | 10~100 字符（trim 后） | 必填 |
| description | string \| null | 0~500 字符，空串等价 null | 可选，缺省 null |
| status | string 枚举 | `TODO` / `DONE` | 创建时固定 `TODO` |
| priority | string 枚举 | `LOW` / `MEDIUM` / `HIGH` | 可选，缺省 `MEDIUM` |
| tags | string[] | 最多 5 个，每个 1~20 字符（trim 后非空），重复自动去重 | 可选，缺省 `[]` |
| dueAt | string \| null | ISO-8601（如 2026-11-01T10:00:00+08:00） | 可选，缺省 null；允许过去时间 |
| createdAt | string | ISO-8601，如 2026-10-27T21:00:00Z | 服务端生成 |
| updatedAt | string | ISO-8601 | 每次成功更新后刷新 |

单用户 Todo 总量上限 **1000 条**，防止内存无限增长。

### 请求头

| 头 | 必填 | 格式 / 长度 | 说明 |
|---|---|---|---|
| X-User-Id | 是 | 1~64 字符，`^[A-Za-z0-9_-]+$` | 用户标识（v1 由调用方提供，可伪造，见安全边界） |
| Idempotency-Key | 仅创建接口必填 | UUID v4 格式（36 字符） | 幂等键，防重复点击 |

### 请求体

CreateTodoRequest：

| 字段 | 类型 | 必填 | 约束 |
|---|---|---|---|
| title | string | 是 | trim 后 10~100 字符 |
| description | string | 否 | ≤500 字符，空串等价 null；缺省 null |
| priority | string | 否 | `LOW` / `MEDIUM` / `HIGH`，缺省 `MEDIUM` |
| tags | string[] | 否 | ≤5 个，每个 1~20 字符，缺省 `[]` |
| dueAt | string | 否 | ISO-8601 格式，缺省 null |

UpdateTodoRequest（PATCH 语义）：

- 至少提供一项：未提供任何字段（空 body、`{}` 或全部字段缺失）→ 400
- 显式传 null 视为提供了该字段（description / dueAt 表示清除）
- 实现需区分「字段缺失」与「显式 null」（Jackson `JsonNullable` 或 Map 解析）

| 字段 | 类型 | 必填 | 约束 |
|---|---|---|---|
| title | string | 否 | trim 后 10~100 字符 |
| description | string \| null | 否 | ≤500 字符；null 清除描述 |
| status | string | 否 | `TODO` / `DONE` |
| priority | string | 否 | `LOW` / `MEDIUM` / `HIGH` |
| tags | string[] | 否 | 整体替换旧标签；≤5 个，每个 1~20 字符 |
| dueAt | string \| null | 否 | ISO-8601 或 null（清除截止时间） |

### 统一响应

- 成功：`{"code":0,"message":"ok","data":<T>}`
- 失败：`{"code":<400|404|500>,"message":"<原因>","data":null}`

## 2. API 设计

| 方法 | 路径 | 成功响应 | 说明 |
|---|---|---|---|
| POST | /api/todos | 200 + Todo | 创建（需 X-User-Id 与 Idempotency-Key） |
| GET | /api/todos | 200 + Todo[] | 当前用户全部，createdAt 降序、同刻按 id 升序 |
| PATCH | /api/todos/{id} | 200 + Todo | 部分更新 |
| DELETE | /api/todos/{id} | 200 + null | 物理删除 |

成功统一 HTTP 200（与现有 /api/health、/api/echo 一致，简化前端判断）。

## 3. 关键决策

### 安全边界（v1 已知限制）

- v1 无登录认证，`X-User-Id` 可被调用方任意伪造，**不得部署到公网**，仅限本地开发 / 受信内网使用
- 身份可信性由后续认证体系（另行提案）保证；本模块只负责按标识隔离数据
- 越权访问一律 404，不泄露资源存在性

### 单用户数量上限

单用户最多 1000 条 Todo，超出创建返回 400（`单用户最多支持 1000 条待办`）；通用接口限流不在 v1 范围。

### 校验顺序

多个错误并存时按以下顺序返回首个错误：
① `X-User-Id` → ② 路径 id（UUID 格式）→ ③ `Idempotency-Key`（仅创建）→ ④ 请求体解析与字段校验（按字段声明顺序）。

### 更新 / 删除不存在的 id

- 合法 UUID 但记录不存在 → **404**（`Todo 不存在`）
- 记录存在但属于其他用户（越权）→ **404**（同一响应，不泄露存在性）
- id 不是合法 UUID 格式 → **400**（`Todo id 格式非法`）

### 越权统一返回 404

访问不存在或不属于当前用户的 Todo 均返回 404（而非 403），避免泄露资源存在性，防探测。

### 标签处理

服务端对 `tags` 先 trim 再校验，重复标签静默去重后保存；更新时 `tags` 为整体替换语义。

### 幂等实现

- 内存 `Map<"<userId>:<idempotencyKey>", Todo>`，TTL 24 小时；过期后同 key 视为新请求
- 使用原子操作（`computeIfAbsent` 或分段锁）保证**并发**提交相同 key 时仅创建一次
- **不校验请求体是否一致**：同 key 恒返回首次创建结果（即使 body 不同）
- 写入时惰性清理过期条目；Map 容量上限 10 万条，超出淘汰最旧条目

### 内存存储

V1 使用 `ConcurrentHashMap<userId, Map<todoId, Todo>>`，重启数据丢失；后续数据库变更时保持 Repository 接口不变。

## 4. 错误码映射

| 场景 | HTTP | code | message 示例 |
|---|---|---|---|
| 缺 / 空 / 超长 / 非法 X-User-Id | 400 | 400 | 缺少或非法的用户标识 |
| 请求体非合法 JSON | 400 | 400 | 请求体格式非法 |
| 更新未提供任何字段（空更新） | 400 | 400 | 至少提供一个待更新字段 |
| title trim 后少于 10 字符 | 400 | 400 | 标题至少需要 10 个字符 |
| title 超过 100 字符 | 400 | 400 | 标题不能超过 100 字符 |
| description 超过 500 字符 | 400 | 400 | 描述不能超过 500 字符 |
| tags 超过 5 个 | 400 | 400 | 标签最多 5 个 |
| 单个标签为空或超过 20 字符 | 400 | 400 | 单个标签需为 1~20 字符 |
| 非法 priority 枚举 | 400 | 400 | 优先级只能是 LOW、MEDIUM 或 HIGH |
| 非法 status 枚举 | 400 | 400 | 状态只能是 TODO 或 DONE |
| dueAt 非 ISO-8601 | 400 | 400 | 截止时间格式非法 |
| 缺 / 非法 Idempotency-Key | 400 | 400 | 幂等键缺失或格式错误 |
| 路径 id 非 UUID | 400 | 400 | Todo id 格式非法 |
| 单用户超过 1000 条 | 400 | 400 | 单用户最多支持 1000 条待办 |
| id 不存在 / 非本人（越权） | 404 | 404 | Todo 不存在 |
| 未捕获异常 | 500 | 500 | 服务器内部错误 |
