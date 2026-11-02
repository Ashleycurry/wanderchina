# frontend-styling-stack Specification

## Purpose

WanderChina 前端样式技术栈基线：Next.js 14 App Router + Tailwind CSS 3.4 + shadcn/ui（源码 vendored、new-york / neutral 主题）+ lucide-react 图标，mobile-first。本文为跨模块样式约定，供首页 7 个模块规格共同引用。

## 1. 适用范围

### 1.1 适用

| 项 | 说明 |
| --- | --- |
| 全部前端页面与组件 | 首页 7 个区块及后续所有页面 |
| 样式实现方式 | Tailwind 工具类、主题令牌、组件变体 |
| 组件库接入方式 | shadcn/ui 源码 vendored（可改） |
| 响应式与无障碍基线 | mobile-first、断点、焦点、对比度、动效偏好 |

### 1.2 不适用

| 项 | 归属 |
| --- | --- |
| 各区块自身的布局细节与内容 | `homepage-*.md` 各模块规格 |
| 品牌视觉定稿（Logo、主色、字体选型） | 后续品牌/设计规范 |
| 后端样式无关实现 | 后端 spec |
| 暗色模式切换器 | 本期不做（仅保留 `.dark` 变量） |

### 1.3 硬性约束

- 样式只写 Tailwind 工具类；全仓唯一 CSS 文件为 `src/app/globals.css`
- 禁止 CSS-in-JS、Sass/Less、Bootstrap/MUI/AntD/Chakra 等黑盒 UI 库
- 禁止 `.module.css`；禁止 inline `style`（动态 CSS 变量除外）
- 结构性颜色必须走语义令牌（`bg-background` / `text-foreground` / `bg-primary` 等），禁止 `#hex` 硬编码
- 响应式只用 min-width 断点（默认样式 = 移动端），禁止 `max-*` 变体
- 不新增 npm 依赖

## 2. 技术选型

| 层 | 选型 | 版本（package.json） | 说明 |
| --- | --- | --- | --- |
| 框架 | Next.js（App Router） | `^14.2.33` | 唯一路由与构建方案 |
| 运行时 | React / React DOM | `18.3.1` | 与 Next 14 匹配 |
| 语言 | TypeScript | `~5.9.0` | 严格模式，`@/*` → `./src/*` |
| 样式引擎 | Tailwind CSS | `^3.4.17` | 唯一原子类方案 |
| 动画插件 | tailwindcss-animate | `^1.0.7` | 仅用于既有 accordion 等过渡 |
| 后处理 | postcss / autoprefixer | `^8.5.1` / `^10.4.20` | 自动补全前缀 |
| 组件层 | shadcn/ui（new-york / neutral） | 源码 vendored | `components.json` 配置，`src/components/ui/` |
| 变体管理 | class-variance-authority | `^0.7.1` | 组件 variant / size |
| 类名合并 | clsx + tailwind-merge | `^2.1.1` / `^2.6.0` | `cn()` 统一封装于 `src/lib/utils.ts` |
| 图标 | lucide-react | `^0.469.0` | 全站唯一图标源 |

### 刻意不引入

| 项 | 原因 |
| --- | --- |
| CSS-in-JS（styled-components / emotion） | 与 Tailwind + RSC 冲突，增加运行时开销 |
| 预处理器（Sass / Less / Stylus） | Tailwind 已覆盖需求 |
| 黑盒 UI 库（Bootstrap / MUI / AntD / Chakra） | 样式不可控，与 shadcn vendored 策略冲突 |
| framer-motion | 本期动效仅 CSS 过渡，避免新增运行时依赖 |
| 暗色模式切换器 | 本期只保留 `.dark` 变量，不做切换 UI |

## 3. 核心约定

### 3.1 Tailwind 使用规则

- 默认样式即移动端；断点只做「向上增强」
- 复杂类名用 `cn()` 合并，禁止手写字符串拼接 `className={a + ' ' + b}`
- 条件类名统一 `cn(base, cond && 'xxx')`
- 布局优先 `flex` / `grid`，避免负 margin 与绝对定位堆砌

### 3.2 shadcn/ui 接入规则

- 组件源码一律落 `src/components/ui/`，可直接修改，不依赖 npm 黑盒包
- 新增组件按 shadcn 等价源码手写 vendored（不联网执行 CLI）
- 引用路径使用 `@/components/ui/<name>`
- 组件样式扩展用 `className` 透传 + `cn()`，不复制整份组件再改

### 3.3 类名合并与变体

- 所有组件类名合并必须经 `cn()`（`src/lib/utils.ts`：`twMerge(clsx(inputs))`）
- 多态样式（variant / size）必须用 `cva`，禁止 if/else 拼类名
- 默认变体在 `defaultVariants` 中声明，不在调用侧重复指定

### 3.4 响应式断点

| 前缀 | 最小宽度 | 典型用途 |
| --- | --- | --- |
| （无） | 0 | 移动端基线（360px 起） |
| `sm:` | 640px | 卡片由单列转多列 |
| `md:` | 768px | 页面容器居中 + 最大宽度 |
| `lg:` | 1024px | 多列网格增强 |
| `xl:` | 1280px | 宽屏留白 |

禁止 `max-sm:` / `max-md:` 等变体，保证 mobile-first 语义唯一。

### 3.5 颜色与主题令牌

- 结构色只用语义类：`bg-background`、`text-foreground`、`bg-card`、`text-muted-foreground`、`bg-primary`、`text-primary-foreground`、`border-border`、`ring-ring`、`bg-destructive`
- 装饰性渐变/遮罩允许 Tailwind 调色板 + 透明度（如 `bg-black/40`），但禁止 `#hex`、`rgb()` 硬编码
- 自定义颜色必须新增 CSS 变量并在 `tailwind.config.ts` 注册，不在组件内写色值
- 圆角统一 `rounded-lg` / `rounded-md` / `rounded-sm`（由 `--radius` 派生），禁止 `rounded-[7px]` 之类魔法值
- 本文档所称「品牌主色」当前即 `--primary`（neutral 0 0% 9%），品牌定稿后只改变量

### 3.6 图片与图标

- 图片必须 `next/image`：静态图用 `width/height`，铺满容器用 `fill` + `sizes`
- 装饰性图片 `alt=""` + `aria-hidden`
- 图标只用 `lucide-react`；尺寸用 `size-4` / `size-5` 等工具类
- 纯装饰图标 `aria-hidden="true"`，可读名称由相邻文本承担

### 3.7 动效与无障碍

- 动效仅限 `transform` / `opacity`，时长 150–300ms
- `prefers-reduced-motion: reduce` 时关闭过渡（`motion-reduce:transition-none` 等）
- 交互元素必须有 `focus-visible` 可见环（`focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring`）
- 正文文字对比度 ≥ 4.5:1；触摸目标 ≥ 44×44px
- 不用颜色单独传递状态（如「已解决」必须带文本或图标）

## 4. 数据结构（配置契约）

### 4.1 `tailwind.config.ts`

```ts
// 现状契约（节选）
const config = {
  darkMode: ['class'],
  content: ['./src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: { DEFAULT: 'hsl(var(--primary))', foreground: 'hsl(var(--primary-foreground))' },
        secondary: { DEFAULT: 'hsl(var(--secondary))', foreground: 'hsl(var(--secondary-foreground))' },
        destructive: { DEFAULT: 'hsl(var(--destructive))', foreground: 'hsl(var(--destructive-foreground))' },
        muted: { DEFAULT: 'hsl(var(--muted))', foreground: 'hsl(var(--muted-foreground))' },
        accent: { DEFAULT: 'hsl(var(--accent))', foreground: 'hsl(var(--accent-foreground))' },
        popover: { DEFAULT: 'hsl(var(--popover))', foreground: 'hsl(var(--popover-foreground))' },
        card: { DEFAULT: 'hsl(var(--card))', foreground: 'hsl(var(--card-foreground))' },
      },
      borderRadius: { lg: 'var(--radius)', md: 'calc(var(--radius) - 2px)', sm: 'calc(var(--radius) - 4px)' },
    },
  },
  plugins: [animate], // tailwindcss-animate
}
```

约束：
- `content` 必须覆盖 `./src/**/*.{ts,tsx}`，不得遗漏新目录
- 新增语义色必须在 `extend.colors` 注册为 `hsl(var(--x))` 形式
- 禁止引入第二套插件体系（除 `tailwindcss-animate`）

### 4.2 `src/app/globals.css` 主题变量

| 变量 | 浅色 | 深色 `.dark` |
| --- | --- | --- |
| `--background` | `0 0% 100%` | `0 0% 3.9%` |
| `--foreground` | `0 0% 3.9%` | `0 0% 98%` |
| `--card` | `0 0% 100%` | `0 0% 3.9%` |
| `--primary` | `0 0% 9%` | `0 0% 98%` |
| `--primary-foreground` | `0 0% 98%` | `0 0% 9%` |
| `--secondary` | `0 0% 96.1%` | `0 0% 14.9%` |
| `--muted` | `0 0% 96.1%` | `0 0% 14.9%` |
| `--muted-foreground` | `0 0% 45.1%` | `0 0% 63.9%` |
| `--destructive` | `0 84.2% 60.2%` | `0 62.8% 30.6%` |
| `--border` / `--input` | `0 0% 89.8%` | `0 0% 14.9%` |
| `--ring` | `0 0% 3.9%` | `0 0% 83.1%` |
| `--radius` | `0.5rem` | 同左 |

约束：变量值为 HSL 三元组（无 `hsl()` 包裹）；`body` 必须 `@apply bg-background text-foreground`；`*` 必须有 `@apply border-border`。

### 4.3 `components.json`

```json
{
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": { "config": "tailwind.config.ts", "css": "src/app/globals.css", "baseColor": "neutral", "cssVariables": true },
  "aliases": { "components": "@/components", "utils": "@/lib/utils", "ui": "@/components/ui", "lib": "@/lib", "hooks": "@/hooks" },
  "iconLibrary": "lucide"
}
```

### 4.4 组件变体契约（cva 模板）

```ts
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
        outline: 'border border-input bg-background hover:bg-accent hover:text-accent-foreground',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
      },
      size: { default: 'h-10 px-4 py-2', sm: 'h-9 px-3', lg: 'h-11 px-8', icon: 'h-10 w-10' },
    },
    defaultVariants: { variant: 'default', size: 'default' },
  },
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}
```

约束：新增变体只在 `variants` 内声明，不在调用侧覆盖颜色类。

## 5. 验收标准（ACCEPTANCE Checklist）

### 5.1 配置

- [ ] `tailwind.config.ts` 的 `content` 覆盖 `./src/**/*.{ts,tsx}`，`darkMode: ['class']`
- [ ] 插件仅 `tailwindcss-animate`，无第二套插件体系
- [ ] `globals.css` 含三条 `@tailwind` 指令与 `:root` / `.dark` 变量
- [ ] `body` 应用 `bg-background text-foreground`，`*` 应用 `border-border`
- [ ] `components.json` 为 `new-york` / `neutral` / `cssVariables: true` / `iconLibrary: lucide` / aliases 指向 `@/components` 与 `@/lib/utils`
- [ ] `src/lib/utils.ts` 导出 `cn()`（`twMerge(clsx(...))`）

### 5.2 代码规范

- [ ] 组件样式全部为 Tailwind 工具类，无 `style={{ ... }}`（动态 CSS 变量除外）
- [ ] 条件类名与合并统一 `cn()`；多态样式统一 `cva`
- [ ] 无 `#hex` / `rgb(` 硬编码颜色（抽查 `src/components`）
- [ ] 无 `max-*` 响应式变体
- [ ] 圆角只用 `rounded-lg` / `rounded-md` / `rounded-sm`
- [ ] shadcn 组件均位于 `src/components/ui/`，无第三方 UI 库 import
- [ ] 图片均使用 `next/image`；图标均来自 `lucide-react`
- [ ] 无 `.module.css` / `.scss` / `.less` 文件；仅 `globals.css` 一个样式入口

### 5.3 依赖与构建

- [ ] `package.json` 无禁止依赖（bootstrap / @mui / antd / @chakra-ui / styled-components / @emotion / sass / less / framer-motion）
- [ ] 未新增 npm 依赖
- [ ] `npm run build` 通过，无 ESLint / 类型错误

### 5.4 无障碍与响应式走查

- [ ] 交互元素有 `focus-visible` 可见环
- [ ] 正文对比度 ≥ 4.5:1（浅色/深色变量两套均检查）
- [ ] 触摸目标 ≥ 44×44px
- [ ] 360px / 768px / 1440px 三档无横向滚动、布局按断点生效
- [ ] `prefers-reduced-motion: reduce` 下无过渡动效
- [ ] 状态信息不单靠颜色（文字或图标伴随）

### 5.5 手动验证步骤

1. `rg -n "bootstrap|@mui|antd|styled-components|@emotion|sass|less" frontend/package.json` → 无命中
2. `rg -n "#[0-9a-fA-F]{3,6}\b|rgb\(" frontend/src` → 无命中（排除注释与 CSS 变量文件）
3. `rg -n "max-(sm|md|lg|xl):" frontend/src` → 无命中
4. `npm run build`（NTFS 副本）通过
5. 浏览器 360 / 768 / 1440 三档 + 键盘 Tab 走查焦点环与布局
