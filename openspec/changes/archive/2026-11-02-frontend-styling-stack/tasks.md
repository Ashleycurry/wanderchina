# Tasks: 前端样式技术栈基线（frontend-styling-stack）

> 实施记录（2026-11-02）：配置四项核对通过；`button.tsx` / `input.tsx` 已落地；四项禁止项检查无命中；`tsc --noEmit` 与 `next build`（`✓ Compiled successfully`）均通过。
> 说明：4.2 未临时改 `page.tsx`，改用 `tsc --noEmit` 覆盖全部 `src` 文件验证导入路径与类型。

## 1. 配置基线校验（只读，不改配置）

- [x] 1.1 核对 `frontend/tailwind.config.ts`：`content: ['./src/**/*.{ts,tsx}']`、`darkMode: ['class']`、插件仅 `tailwindcss-animate`
  - 验证：读取文件逐项比对规格第 4.1 节
- [x] 1.2 核对 `frontend/src/app/globals.css`：三条 `@tailwind` 指令 + `:root` / `.dark` 变量 + `body` 应用 `bg-background text-foreground`
  - 验证：读取文件比对规格第 4.2 节变量表
- [x] 1.3 核对 `frontend/components.json`：`new-york` / `neutral` / `cssVariables: true` / `iconLibrary: lucide` / aliases 指向 `@/components`、`@/lib/utils`
  - 验证：读取文件比对规格第 4.3 节
- [x] 1.4 核对 `frontend/src/lib/utils.ts`：`cn()` 为 `twMerge(clsx(...))`
  - 验证：读取文件比对（已确认符合，无需改动）

## 2. vendored 组件基线

- [x] 2.1 新增 `frontend/src/components/ui/button.tsx`：`cva` 声明 `variant`（default / secondary / outline / ghost / destructive）与 `size`（default / sm / lg / icon），`cn()` 合并，`focus-visible:ring-2`
  - 验证：文件存在且无 `#hex` / `rgb(`
- [x] 2.2 新增 `frontend/src/components/ui/input.tsx`：受控 `input`，`cn()` 合并，`focus-visible:ring-2`，`disabled:opacity-50`
  - 验证：文件存在，`React.forwardRef` + `displayName` 完整
- [x] 2.3 与 `components.json` 别名一致（`@/lib/utils`），不 import 任何第三方 UI 包
  - 验证：文件内 import 仅 `react` / `@/lib/utils` / `class-variance-authority`

## 3. 禁止项检查（不新增工具依赖）

- [x] 3.1 禁止依赖检查：`Select-String -Path frontend/package.json -Pattern 'bootstrap|@mui|antd|@chakra-ui|styled-components|@emotion|sass|less|framer-motion'`
  - 验证：无命中
- [x] 3.2 硬编码色值检查：`Select-String -Path frontend/src/**/*.tsx -Pattern '#[0-9a-fA-F]{3,6}\b|rgb\('`
  - 验证：无命中（`globals.css` 不在检查范围）
- [x] 3.3 断点检查：`Select-String -Path frontend/src/**/*.tsx -Pattern 'max-(sm|md|lg|xl):'`
  - 验证：无命中
- [x] 3.4 样式预处理文件检查：`Get-ChildItem frontend/src -Recurse -Include *.module.css,*.scss,*.less`
  - 验证：无结果

## 4. 构建验证

- [x] 4.1 同步到 NTFS 副本并构建：`robocopy` 同步 `frontend` → `D:\wanderchina-frontend`（排除 node_modules / .next / .git），执行 `npm run build`
  - 验证：`✓ Compiled successfully`，无类型错误
- [x] 4.2 在页面中临时引用 Button / Input 编译一次后回滚（验证导入路径可用）
  - 验证：构建通过后撤销临时引用

## 5. 验收（AC）

- [x] AC1 配置四件套全部符合规格（第 1 节 4 项核对通过）
- [x] AC2 `button.tsx` / `input.tsx` 存在，变体走 cva、类名走 cn，无硬编码色值
- [x] AC3 禁止项四项检查全部无命中
- [x] AC4 `npm run build` 通过
- [x] AC5 未新增 npm 依赖（`package.json` 与 `package-lock.json` 无变化）

## 6. 提交

- [x] 6.1 `frontend` 子仓库提交：`src/components/ui/button.tsx`、`src/components/ui/input.tsx`
- [x] 6.2 根仓库提交：`openspec/changes/frontend-styling-stack/`（proposal + delta spec + tasks）
