## MODIFIED Requirements

### Requirement: 前端样式技术栈基线

系统 SHALL 以 Tailwind CSS 3.4（唯一原子类方案）+ shadcn/ui（源码 vendored、new-york / neutral）+ lucide-react（唯一图标源）作为前端样式基线；全仓唯一 CSS 入口为 `src/app/globals.css`，结构性颜色必须使用语义令牌（`bg-background`、`text-foreground`、`bg-primary` 等），禁止硬编码色值。完整规格见 `openspec/specs/homepage/frontend-styling-stack.md`。

#### Scenario: 配置符合基线

- **WHEN** 检查 `frontend/tailwind.config.ts`、`src/app/globals.css`、`components.json`、`src/lib/utils.ts`
- **THEN** `content` 覆盖 `./src/**/*.{ts,tsx}`，`darkMode: ['class']`，插件仅 `tailwindcss-animate`
- **AND** `globals.css` 含三条 `@tailwind` 指令与 `:root` / `.dark` 主题变量，`body` 应用 `bg-background text-foreground`
- **AND** `cn()` 由 `twMerge(clsx(...))` 实现，`components.json` 为 `new-york` / `neutral` / `cssVariables: true` / `iconLibrary: lucide`

#### Scenario: 无禁止依赖

- **WHEN** 检查 `frontend/package.json` 的依赖声明
- **THEN** 不含 `bootstrap`、`@mui/*`、`antd`、`@chakra-ui/*`、`styled-components`、`@emotion/*`、`sass`、`less`、`framer-motion`

## ADDED Requirements

### Requirement: shadcn 组件源码基线

系统 SHALL 在 `frontend/src/components/ui/` 提供可编辑的 vendored 组件源码，首个基线包含 `button.tsx` 与 `input.tsx`；组件变体使用 `cva` 声明，类名合并使用 `cn()`，不通过联网 CLI 生成，不引入黑盒 UI 包。

#### Scenario: 基线组件可导入

- **WHEN** 业务组件中 `import { Button } from '@/components/ui/button'` 与 `import { Input } from '@/components/ui/input'`
- **THEN** TypeScript 类型检查与 `npm run build` 通过，组件可正常渲染（Button 支持 `variant` / `size`，Input 支持受控输入）

#### Scenario: 变体与类名规范

- **WHEN** 检查 `button.tsx` 与 `input.tsx`
- **THEN** 变体通过 `cva` 的 `variants` / `defaultVariants` 声明，类名合并通过 `cn()`，文件内无硬编码色值（`#hex` / `rgb(`）

### Requirement: 样式约束可校验

系统 SHALL 使样式禁止项可通过命令检查：无硬编码色值、无 `max-*` 响应式变体、无 `.module.css` / `.scss` / `.less`、无 inline `style`（动态 CSS 变量除外）、不新增 npm 依赖。

#### Scenario: 禁止项检查无命中

- **WHEN** 按 tasks 中的 grep 命令检查 `frontend/src`
- **THEN** 硬编码色值、`max-(sm|md|lg|xl):`、样式预处理文件、内联 `style` 四项检查均无命中（`globals.css` 的主题变量定义除外）

#### Scenario: 构建通过

- **WHEN** 在 `frontend/` 执行 `npm run build`（NTFS 副本 `D:\wanderchina-frontend`）
- **THEN** 构建成功，无 TypeScript 或 ESLint 错误
