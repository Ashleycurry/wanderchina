---
name: systematic-debugging
description: 四阶段系统化调试：复现 → 定位根因 → 修复 → 验证；禁止猜测式修补
---

# systematic-debugging（系统化调试）

## 何时触发

- 出现 bug / 测试失败 / 意外行为时

## 四阶段流程

1. **复现**：先稳定复现问题，记录最小复现步骤；无法复现先取证再下结论
2. **定位**：沿调用链追溯根因（root-cause-tracing），读代码 + 日志 + 测试交叉验证，找到真正原因而非症状
3. **修复**：针对根因做最小修复；修复后补回归测试（参考 `test-driven-development`）
4. **验证**：确认原问题消失且无回归（参考 `verification-before-completion`）

## 反模式（禁止）

- 猜测式修补（"改一下试试"）
- 只修症状不修根因
- 未验证就宣称"修好了"
