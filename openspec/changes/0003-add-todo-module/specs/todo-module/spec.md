# todo-module 规格

## ADDED Requirements

### Requirement: 用户身份识别与数据隔离

系统 SHALL 通过请求头 `X-User-Id`（1~64 字符，`^[A-Za-z0-9_-]+$`）识别用户，所有 Todo 数据按用户隔离，互不可见。

#### Scenario: 缺少用户标识

- **WHEN** 请求未携带 `X-User-Id` 头
- **THEN** 返回 HTTP 400 与统一错误结构
- **AND** message 提示缺少用户标识

#### Scenario: 用户标识非法

- **WHEN** `X-User-Id` 为空串、超过 64 字符或包含非法字符
- **THEN** 返回 HTTP 400 与统一错误结构

#### Scenario: 用户数据隔离

- **WHEN** 用户 A 与用户 B 分别创建 Todo 后查询各自列表
- **THEN** 各自只能看到自己创建的 Todo

### Requirement: 创建 Todo

系统 SHALL 支持 `POST /api/todos` 创建 Todo。请求需携带 `X-User-Id` 与 `Idempotency-Key`（UUID v4）。请求体字段：`title` 必填（trim 后 10~100 字符）；`description` 可选（≤500 字符）；`priority` 可选（枚举 `LOW`/`MEDIUM`/`HIGH`，缺省 `MEDIUM`）；`tags` 可选（≤5 个，每个 1~20 字符，重复自动去重，缺省 `[]`）；`dueAt` 可选（ISO-8601 或 null，缺省 null）。创建结果的 `status` 固定为 `TODO`。

#### Scenario: 正常创建

- **WHEN** 携带合法请求头与 `{"title":"买牛奶顺路取快递"}` 调用创建接口
- **THEN** 返回 HTTP 200，`code=0`
- **AND** data 包含 id、title、status=TODO、priority=MEDIUM、tags=[]、dueAt=null、createdAt、updatedAt

#### Scenario: 标题少于 10 字符

- **WHEN** `title` 缺失、为空串、仅由空格组成或 trim 后不足 10 字符
- **THEN** 返回 HTTP 400 与统一错误结构
- **AND** message 提示标题至少需要 10 个字符
- **AND** 不产生任何 Todo 数据

#### Scenario: 标题超长

- **WHEN** `title` trim 后长度超过 100 字符
- **THEN** 返回 HTTP 400 与统一错误结构

#### Scenario: 描述超长

- **WHEN** `description` 长度超过 500 字符
- **THEN** 返回 HTTP 400 与统一错误结构

#### Scenario: 标签超限

- **WHEN** `tags` 数量超过 5 个，或单个标签 trim 后为空 / 超过 20 字符
- **THEN** 返回 HTTP 400 与统一错误结构

#### Scenario: 标签重复自动去重

- **WHEN** 提交 `{"tags":["工作","工作","生活"]}`
- **THEN** 返回 HTTP 200
- **AND** data.tags 去重后为 `["工作","生活"]`

#### Scenario: 非法优先级

- **WHEN** `priority` 不是 `LOW`、`MEDIUM` 或 `HIGH`
- **THEN** 返回 HTTP 400 与统一错误结构

#### Scenario: 非法截止时间

- **WHEN** `dueAt` 不是合法的 ISO-8601 格式
- **THEN** 返回 HTTP 400 与统一错误结构

#### Scenario: 重复点击创建

- **WHEN** 使用相同 `Idempotency-Key` 重复提交创建请求
- **THEN** 仅创建一条 Todo
- **AND** 重复请求返回首次创建结果（HTTP 200，id 与首次相同）

#### Scenario: 缺少幂等键

- **WHEN** 创建请求缺少 `Idempotency-Key` 头或其值不是合法 UUID
- **THEN** 返回 HTTP 400 与统一错误结构

### Requirement: 查询 Todo 列表

系统 SHALL 支持 `GET /api/todos` 返回当前用户的全部 Todo，按 `createdAt` 降序排列。

#### Scenario: 正常查询

- **WHEN** 当前用户已有若干 Todo 时查询列表
- **THEN** 返回 HTTP 200，`code=0`
- **AND** data 为按 createdAt 降序的 Todo 数组

#### Scenario: 空列表

- **WHEN** 当前用户没有任何 Todo
- **THEN** 返回 HTTP 200，data 为空数组

### Requirement: 更新 Todo

系统 SHALL 支持 `PATCH /api/todos/{id}` 部分更新 `title`（10~100）、`description`（≤500）、`status`、`priority`、`tags`（整体替换）、`dueAt`（传 null 表示清除），至少提供一项，更新成功后 `updatedAt` 刷新。

#### Scenario: 正常更新状态

- **WHEN** 对本人存在的 Todo 提交 `{"status":"DONE"}`
- **THEN** 返回 HTTP 200，data.status=DONE
- **AND** data.updatedAt 晚于或等于原值

#### Scenario: 正常更新标签与优先级

- **WHEN** 提交 `{"tags":["紧急"],"priority":"HIGH","dueAt":"2026-11-01T10:00:00+08:00"}`
- **THEN** 返回 HTTP 200
- **AND** data.tags/priority/dueAt 均为新值

#### Scenario: 更新时字段校验失败

- **WHEN** 提交的 `title` 不在 10~100 字符、`description` 超过 500 字符、`tags` 超过 5 个或单标签超长
- **THEN** 返回 HTTP 400 与统一错误结构

#### Scenario: 更新非法枚举或格式

- **WHEN** 提交的 `status`、`priority` 不是合法枚举值，或 `dueAt` 不是合法 ISO-8601
- **THEN** 返回 HTTP 400 与统一错误结构

#### Scenario: 更新不存在的 id

- **WHEN** 使用合法 UUID 但数据库中不存在的 id 发起更新
- **THEN** 返回 HTTP 404
- **AND** message 为 `Todo 不存在`

#### Scenario: 越权更新

- **WHEN** 用户 A 尝试更新用户 B 的 Todo
- **THEN** 返回 HTTP 404
- **AND** 该 Todo 保持不变且不泄露其是否存在

#### Scenario: id 非 UUID

- **WHEN** 路径参数 id 不是合法 UUID 格式
- **THEN** 返回 HTTP 400 与统一错误结构

### Requirement: 删除 Todo

系统 SHALL 支持 `DELETE /api/todos/{id}` 物理删除当前用户的 Todo。

#### Scenario: 正常删除

- **WHEN** 删除本人存在的 Todo
- **THEN** 返回 HTTP 200，`code=0`
- **AND** 后续列表查询不再包含该 Todo

#### Scenario: 越权删除

- **WHEN** 用户 A 尝试删除用户 B 的 Todo
- **THEN** 返回 HTTP 404
- **AND** 该 Todo 保持不变

#### Scenario: 删除不存在

- **WHEN** 删除不存在或已被删除的 Todo
- **THEN** 返回 HTTP 404 与统一错误结构

### Requirement: 统一响应与异常

系统 SHALL 对所有接口返回统一响应结构 `{code, message, data}`；异常统一由全局异常处理转换为错误结构，不泄露内部实现细节。

#### Scenario: 错误结构一致

- **WHEN** 任意校验失败或业务异常发生
- **THEN** 响应体均为 `{"code":<错误码>,"message":"<原因>","data":null}`
- **AND** 错误码与 HTTP 状态一致（400 / 404）

#### Scenario: 未捕获异常

- **WHEN** 服务端发生未预期异常
- **THEN** 返回 HTTP 500 与 `{"code":500,"message":"服务器内部错误","data":null}`
