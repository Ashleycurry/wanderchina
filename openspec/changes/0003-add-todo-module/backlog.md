# Backlog · Todo 模块（P2 延期项）

以下为 Spec 审查中的 P2 建议，v1 不实施，后续版本或数据库接入时跟进。

| 编号 | 位置 | 问题 | 建议 |
|---|---|---|---|
| B1 | design.md 数据模型（原 L15） | dueAt 接受任意时区偏移，未定义存储/返回是否归一化 | 明确"解析后归一化为 UTC（Z 结尾）存储与返回" |
| B2 | design.md 内存存储 | 无未来落库索引规划 | 补"user_id 索引 + (user_id, created_at) 复合索引 + 幂等键唯一索引" |
| B3 | design.md tags 处理 | `tags: []` 是否清除全部标签未明说 | spec 补场景或说明"提交 `[]` 清除全部标签" |
| B4 | design.md updatedAt / spec 更新场景 | 提交与当前相同的值时 updatedAt 是否刷新，语义模糊 | 明确一个口径：如"请求通过校验即刷新，即使值未变化" |
| B5 | spec 更新 Requirement | 并发更新同一 Todo（lost update）未声明 | v1 注明"最后写入生效，无乐观锁"；后续版本引入 version / If-Match |
| B6 | spec 统一响应 | 请求体大小上限与 Content-Type 未定义 | 设置 body 上限（如 64KB → 400）；非 JSON Content-Type 行为声明（如 415） |
| B7 | tasks.md AC9 | "所有成功/失败响应"范围界定模糊 | 改为"4 个接口 × {成功, 400, 404} 抽样各至少 1 例，均断言 code/message/data 三字段" |

## 来源

- 审查报告：2026-10-27（P0 6 条、P1 8 条已修订，P2 7 条收录于此）
