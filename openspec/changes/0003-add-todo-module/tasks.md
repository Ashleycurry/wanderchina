# 实施任务 · Todo 待办清单模块

## 验收标准（Acceptance Checklist）

- [ ] AC1 创建成功：合法请求返回 code=0，data 含 id / title / status=TODO / priority=MEDIUM / tags=[] / dueAt=null / createdAt / updatedAt
- [ ] AC2 标题下限：title 缺失、空串、纯空格或 trim 后 < 10 字符均返回 400，且不产生数据
- [ ] AC3 超长：title > 100 字符、description > 500 字符均返回 400
- [ ] AC4 越权：用户 A 读取 / 更新 / 删除用户 B 的 Todo 返回 404，数据保持不变
- [ ] AC5 重复点击：相同 Idempotency-Key 重复创建，仅产生一条数据且返回同一 id
- [ ] AC6 数据隔离：A、B 各自列表只包含本人数据
- [ ] AC7 状态枚举：status 仅接受 TODO / DONE，其他值返回 400
- [ ] AC8 删除：删除后列表不再包含；重复删除返回 404
- [ ] AC9 统一响应：所有成功 / 失败响应均为 {code, message, data} 结构
- [ ] AC10 全量测试：`mvn -q test` 全部通过
- [ ] AC11 标签：≤5 个、每个 1~20 字符，超限返回 400；重复标签自动去重
- [ ] AC12 优先级：仅接受 LOW / MEDIUM / HIGH，非法值返回 400；缺省 MEDIUM
- [ ] AC13 截止时间：可选 ISO-8601，非法格式返回 400；更新传 null 可清除
- [ ] AC14 更新不存在 id：合法 UUID 但不存在返回 404（message = Todo 不存在）

## 实施任务（TDD）

## 1. 模块骨架

- [ ] 1.1 创建 `com.wanderchina.todo` 包：`Todo` record（id/title/description/status/priority/tags/dueAt/createdAt/updatedAt）与 `TodoStatus`、`TodoPriority` 枚举
- [ ] 1.2 创建内存仓库 `TodoRepository`（`ConcurrentHashMap` 按 userId 隔离，支持 save/findById/findAllByUser/delete）
- [ ] 1.3 编写仓库单元测试（RED → GREEN）：增删改查 + 用户隔离

## 2. 用户标识与校验

- [ ] 2.1 编写测试：缺 / 空 / 超长 / 非法 `X-User-Id` → 400（RED）
- [ ] 2.2 实现 `X-User-Id` 解析与校验（过滤器或拦截器），失败抛 `IllegalArgumentException` 走全局异常（GREEN）
- [ ] 2.3 编写测试：title < 10 / > 100、description > 500、tags 超限或单标签超长、priority 非法、dueAt 格式非法 → 400（RED）
- [ ] 2.4 实现 `CreateTodoRequest` / `UpdateTodoRequest` 校验逻辑（含 tags trim、去重、枚举与 ISO-8601 校验）（GREEN）

## 3. 创建与幂等

- [ ] 3.1 编写测试：正常创建返回完整字段与默认值（priority=MEDIUM、tags=[]、dueAt=null）（RED）
- [ ] 3.2 实现 `TodoService.create` 与 `POST /api/todos`（GREEN）
- [ ] 3.3 编写测试：缺 / 非法 `Idempotency-Key` → 400；相同键重复提交仅一条数据（RED）
- [ ] 3.4 实现幂等支持（内存 Map + 24h TTL）（GREEN）

## 4. 查询

- [ ] 4.1 编写测试：列表按 createdAt 降序、空列表返回 `[]`、仅含本人数据（RED）
- [ ] 4.2 实现 `GET /api/todos`（GREEN）

## 5. 更新与删除

- [ ] 5.1 编写测试：正常更新 status / priority / tags（整体替换）/ dueAt（含 null 清除）与 updatedAt 刷新（RED）
- [ ] 5.2 编写测试：更新字段校验失败 → 400；越权 → 404；不存在 id（合法 UUID）→ 404；id 非 UUID → 400（RED）
- [ ] 5.3 实现 `PATCH /api/todos/{id}`（GREEN）
- [ ] 5.4 编写测试：正常删除 → 后续列表不含；越权 / 重复删除 → 404（RED）
- [ ] 5.5 实现 `DELETE /api/todos/{id}`（GREEN）

## 6. 验收

- [ ] 6.1 对照 AC1~AC14 逐条验证并勾选
- [ ] 6.2 `mvn -q test` 全部通过
- [ ] 6.3 `openspec validate 0003-add-todo-module --strict` 通过
- [ ] 6.4 更新 `openspec/project.md`（若引入新约定）
