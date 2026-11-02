# homepage Specification

## Purpose

WanderChina 首页能力域：由一个骨架（`homepage-shell`）承载 6 个区块，并由一份样式基线（`frontend-styling-stack`）约束实现方式。本文件是 OpenSpec 可校验的 capability 主规格，只保留验收级 Requirement 与 Scenario；每个模块的完整条款（模块边界 / 全量场景 / Props / ACCEPTANCE）见同目录下的模块手册：

| 模块 | 详细规格 |
| --- | --- |
| 骨架与聚合契约 | `homepage-shell.md` |
| Hero | `homepage-hero.md` |
| 功能导航 | `homepage-feature-nav.md` |
| 城市入口 | `homepage-city-grid.md` |
| 热门帖子 | `homepage-hot-posts.md` |
| 热门景点 | `homepage-hot-spots.md` |
| AI 入口 | `homepage-ai-launcher.md` |
| 样式技术栈 | `frontend-styling-stack.md` |

## Requirements

### Requirement: 首页骨架与挂载位

系统 SHALL 在 `GET /` 渲染恰好 6 个固定顺序的区块挂载位，取值依次为 `hero`、`feature-nav`、`city-grid`、`hot-posts`、`hot-spots`、`ai-launcher`；页面为 Server Component，骨架不 import 任何区块实现，区块以 `src/components/homepage/regions/` 下的占位组件形式挂载。完整规格见 `openspec/specs/homepage/homepage-shell.md`。

#### Scenario: 首页可访问且区块齐全

- **WHEN** 客户端请求 `GET /`
- **THEN** 返回 HTTP 200
- **AND** DOM 中存在恰好 6 个 `[data-region]` 元素，取值顺序为 `hero` → `feature-nav` → `city-grid` → `hot-posts` → `hot-spots` → `ai-launcher`

#### Scenario: SEO 元数据

- **WHEN** 查看 `/` 的 HTML `<head>`
- **THEN** 存在包含 `WanderChina` 的 `<title>`
- **AND** 存在非空 `description` meta

#### Scenario: 响应式布局

- **WHEN** 视口宽度为 360px / 768px / 1440px
- **THEN** 页面无横向滚动，区块垂直间距一致
- **AND** 内容容器在 `md` 及以上居中并限制最大宽度

#### Scenario: 骨架与区块解耦

- **WHEN** 检查 `src/app/page.tsx`
- **THEN** 其仅 import `src/components/homepage/regions/` 下的占位组件与 `region-boundary.tsx`
- **AND** 不 import 任何 `homepage-hero` 等区块实现

### Requirement: 首页聚合接口契约

系统 SHALL 提供 `GET /api/home?cityCode=<CODE>`，返回 `{ cityCode, picks, hotSpots, hotPosts, partialError? }`；`picks` 按 `position` 升序且失效引用直接剔除、不补位；未携带 `cityCode` 时按 `wc_city` cookie 取值，缺失或非法回退 `SHA`，并在响应中回显实际使用的 `cityCode`。

#### Scenario: 编辑精选按 position 升序

- **WHEN** 请求 `GET /api/home?cityCode=SHA`，且该城市有 3 条生效中的 `editor_pick`
- **THEN** `picks` 长度为 3 且按 `position` 升序
- **AND** 每项包含 `type`、`refId`、`title`、`imageUrl`、`lastVerifiedAt`、`openingDate`

#### Scenario: 失效引用自动剔除

- **WHEN** 某条置顶攻略 `status ≠ published`，或帖子 `status = hidden`
- **THEN** 该项从 `picks` 中剔除，接口仍返回 200
- **AND** 不做补位（保持 `position` 语义）

#### Scenario: 城市参数回退

- **WHEN** 请求 `/api/home` 未携带 `cityCode`，且 `wc_city` cookie 缺失或取值非法
- **THEN** 服务端回退 `SHA` 取数
- **AND** 响应 `cityCode` 字段回显 `SHA`

### Requirement: 区块级降级

系统 SHALL 对 `picks` / `hotSpots` / `hotPosts` 三个数据区块做独立降级：单区块失败时该区块返回空数组并在 `partialError` 中标记，其余区块正常返回；前端按区块展示骨架与重试入口，不出现整页错误页。

#### Scenario: 单区块失败

- **WHEN** 请求 `GET /api/home?fail=hotSpots`
- **THEN** `hotSpots` 为 `[]` 且 `partialError.hotSpots === true`
- **AND** `picks`、`hotPosts` 数据正常返回

#### Scenario: 前端按区块降级

- **WHEN** 某区块响应带 `partialError`
- **THEN** 该区块渲染骨架与重试入口
- **AND** 其余区块正常展示，页面不跳转错误页

#### Scenario: 全部区块失败仍可访问

- **WHEN** `picks`、`hotSpots`、`hotPosts` 全部失败
- **THEN** `GET /` 仍返回 200
- **AND** 三个区块均渲染骨架与重试入口

#### Scenario: 重试可键盘触发

- **WHEN** 焦点位于重试按钮并按 Enter 或 Space
- **THEN** 触发重新取数，骨架保持到数据返回

### Requirement: 降级容器契约

系统 SHALL 提供 `RegionBoundary`（Client Component）统一承载骨架与重试，支持 `skeleton` 档位 `card-row` / `card-grid` / `text-block`，骨架高度按档位预留以减小布局抖动；重试默认调用 `router.refresh()`。

#### Scenario: 骨架档位生效

- **WHEN** 区块以 `skeleton="card-grid"` 传入 `RegionBoundary` 并处于错误态
- **THEN** 渲染与卡片网格高度近似的骨架
- **AND** 显示可聚焦的重试按钮

#### Scenario: 无交互依赖

- **WHEN** 调用方未传 `onRetry`
- **THEN** 点击重试仍能重新取数（默认 `router.refresh()`）
- **AND** 组件不因缺少回调而报错或禁用按钮

### Requirement: Hero 内容与搜索占位

系统 SHALL 在 Hero 区块渲染品牌主视觉、标语与可见搜索框（`role="search"`），搜索框仅做占位交互：提交后展示提示，不发起真实搜索请求、不改变 URL、不产生网络请求。

#### Scenario: 首屏渲染

- **WHEN** 访问 `/`
- **THEN** Hero 包含 `h1` 标语文本与 `role="search"` 搜索框
- **AND** 搜索框为空时提交按钮为 `disabled`

#### Scenario: 背景图降级

- **WHEN** Hero 背景图请求失败或网络较慢
- **THEN** CSS 渐变兜底层可见，不出现破图
- **AND** 容器高度固定，CLS 为 0，标语与搜索框保持可读

#### Scenario: 搜索占位交互

- **WHEN** 用户输入关键词并提交搜索框
- **THEN** 展示 `aria-live="polite"` 提示文案
- **AND** URL 不变、页面不跳转、Network 无新增请求

#### Scenario: 键盘与读屏语义

- **WHEN** 用户仅用键盘 Tab 或使用屏幕阅读器
- **THEN** 焦点顺序为输入框 → 提交按钮，且 `focus-visible` 环可见
- **AND** 搜索区被识别为 `search` landmark，输入框有 sr-only `label`，背景图 `alt=""` 且 `aria-hidden`

### Requirement: Hero 静态区块隔离

Hero SHALL 保持纯静态：不读取城市上下文、不请求数据接口、不随区块降级状态变化。

#### Scenario: 城市切换不影响 Hero

- **WHEN** 用户将城市从 `SHA` 切换到 `BJA`
- **THEN** Hero 的标语、副标题、搜索框与背景均不变
- **AND** 不触发额外数据请求

#### Scenario: 降级隔离

- **WHEN** `/api/home` 任一区块返回 `partialError`
- **THEN** Hero 正常渲染
- **AND** 不显示骨架或重试入口

### Requirement: 功能导航三入口

系统 SHALL 在 `feature-nav` 区块渲染恰好 3 张卡片，链接分别指向社区、景点、AI 三个目标路由；卡片为纯静态配置，不读取城市上下文、不发起请求、不进入降级态。

#### Scenario: 卡片数量与目标

- **WHEN** 访问 `/`
- **THEN** `feature-nav` 内恰好 3 张卡片
- **AND** 链接分别指向 `/community`、`/attractions`、`/ai`

#### Scenario: 静态区块隔离

- **WHEN** 城市切换或 `/api/home` 返回 `partialError`
- **THEN** 功能导航内容不变化，不进入降级态

#### Scenario: 卡片内容与可访问性

- **WHEN** 查看任一卡片
- **THEN** 包含装饰性图标（`aria-hidden="true"`）、标题与一句话描述
- **AND** 链接的可读名称等于卡片标题

#### Scenario: 响应式列数

- **WHEN** 视口宽度为 360px 或 ≥640px
- **THEN** 360px 下三张卡片纵向单列，无横向滚动、描述不溢出
- **AND** `sm` 及以上为等宽三列，卡片高度对齐

### Requirement: 城市入口与切换

系统 SHALL 在 `city-grid` 渲染恰好 8 个城市项（`href` 形如 `/city/<slug>`），以 `wc_city` cookie 维护当前城市，默认 `SHA`；切换城市后数据区块全部替换且 URL 不含查询参数。

#### Scenario: 首次访问默认城市

- **WHEN** 用户首次打开首页且无 `wc_city` cookie
- **THEN** 返回默认城市 `SHA` 的内容
- **AND** 响应写入 `wc_city` cookie（`Path=/`、`Max-Age` ≥ 30 天），后续请求按该 cookie 取数

#### Scenario: 切换城市联动

- **WHEN** 用户切换到 `BJA`
- **THEN** 三个数据区块全部替换为北京数据，URL 不含脏参数
- **AND** 空区块显示兜底文案而非空白网格

#### Scenario: cookie 非法回退

- **WHEN** `wc_city` 取值为非法城市码，或 cookie 写入被浏览器拒绝
- **THEN** 非法值按默认城市 `SHA` 取数；写入失败时保持当前服务端城市
- **AND** 页面正常渲染，不报错、不白屏

#### Scenario: 城市网格条目与链接

- **WHEN** 查看 `city-grid` 的 DOM
- **THEN** 存在恰好 8 个城市项，每项含可见图标与城市名
- **AND** `href` 分别为 `/city/shanghai`、`/city/beijing`、`/city/xian`、`/city/chengdu`、`/city/hangzhou`、`/city/guilin`、`/city/lijiang`、`/city/suzhou`

#### Scenario: 切换为局部刷新

- **WHEN** 用户左键点击非当前城市项
- **THEN** 仅触发 `router.refresh()` 局部刷新，页面不整页重载
- **AND** 地址栏 URL 保持 `/`，不新增 `cityCode` / `city` 等查询参数

#### Scenario: 键盘可达与当前城市标识

- **WHEN** 用户仅用键盘 Tab 导航
- **THEN** 8 个城市项依次可达，`focus-visible` 环可见
- **AND** 当前城市项带 `aria-current="true"`

### Requirement: 热门帖子热度排序

系统 SHALL 仅返回 `status IN (open, resolved)` 且 `created_at ≥ now-72h` 的帖子，按 `comment_count ÷ max(1, hours_since_create)` 降序取前 8 条；同分按 `created_at` 降序保持稳定顺序。

#### Scenario: 排序与条目上限

- **WHEN** 用户查看热门帖子
- **THEN** 结果按热度公式降序，数量 ≤ 8
- **AND** `resolved` 帖子返回 `resolved=true` 且前端显示徽标

#### Scenario: 举报内容屏蔽

- **WHEN** 帖子下存在 `pending` 举报的评论
- **THEN** 列表摘要不展示该评论内容，固定显示 `[removed pending review]`
- **AND** 接口不返回 500

#### Scenario: 脏数据稳定排序

- **WHEN** 出现 `createdAt` 晚于 `now` 或 `commentCount = 0` 的帖子
- **THEN** `hours_since_create` 取下限 1，零评论热度记 0 并排在末尾
- **AND** 排序不产生 `NaN`、不抛错

#### Scenario: 纯函数可独立验证

- **WHEN** 执行 `node --test tests/rank-posts.test.mjs`
- **THEN** 过滤（hidden / 超 72h）、排序（含同分）、边界（未来时间戳 / 0 评论）用例全部通过
- **AND** 不引入任何第三方测试依赖

### Requirement: 热门帖子列表展示

系统 SHALL 以 Server Component 渲染帖子卡片，包含标题、摘要、作者与评论数，`resolved` 帖子显示文本徽标，空列表显示兜底文案。

#### Scenario: 卡片字段与徽标

- **WHEN** 列表有数据
- **THEN** 每张卡片包含标题、摘要、作者、评论数
- **AND** `resolved` 帖子显示「已解决」文本徽标（图标 `aria-hidden`，信息不仅靠颜色）

#### Scenario: 空列表兜底

- **WHEN** 过滤后无任何帖子
- **THEN** 区块显示兜底文案 `No trending posts for this city yet.`
- **AND** 不出现空白容器或常驻骨架

#### Scenario: 响应式列数

- **WHEN** 视口宽度为 360px 或 ≥768px
- **THEN** 360px 下为单列列表，`md` 及以上为两列网格
- **AND** 摘要超长时截断，不撑破卡片

### Requirement: 热门景点加权排序

系统 SHALL 仅返回 `status = published` 的景点，按 `view_count_7d × 0.7 + popularity_score × 0.3` 降序取前 8 条；全部无浏览数据时退化为按 `popularity_score` 降序。

#### Scenario: 加权排序

- **WHEN** 用户查看热门景点
- **THEN** 结果按 `viewCount7d × 0.7 + popularityScore × 0.3` 降序，数量 ≤ 8
- **AND** 卡片显示格式化后的浏览量

#### Scenario: 无浏览数据退化

- **WHEN** 该城市全部景点 `viewCount7d` 为 `null` 或 0
- **THEN** 排序退化为按 `popularityScore` 降序
- **AND** 仍只返回 `published` 景点

#### Scenario: 部分缺失按 0 参与

- **WHEN** 部分景点有浏览数据、部分为 `null`
- **THEN** `null` 视作 0 参与加权公式，不触发整体退化
- **AND** 排序不因缺失值抛错

#### Scenario: 纯函数可独立验证

- **WHEN** 执行 `node --test tests/rank-spots.test.mjs`
- **THEN** 排序（含同分）、退化、`formatViews` 三档数值用例全部通过
- **AND** 不引入任何第三方测试依赖

### Requirement: 热门景点卡片展示

系统 SHALL 以 Server Component 渲染景点卡片，包含 `next/image` 封面、名称与格式化浏览量，封面固定宽高比，空列表显示兜底文案。

#### Scenario: 卡片字段与格式化

- **WHEN** 列表有数据
- **THEN** 每张卡片含封面、名称、`formatViews` 结果
- **AND** `12300` 显示 `12.3k views`、`980` 显示 `980 views`、`1200000` 显示 `1.2m views`

#### Scenario: 封面失败兜底

- **WHEN** 封面图 404 或加载失败
- **THEN** 图片容器保留渐变底色，名称与浏览量仍可读
- **AND** 固定宽高比不塌陷

#### Scenario: 空列表兜底

- **WHEN** 过滤后无任何景点
- **THEN** 区块显示兜底文案 `No attractions for this city yet.`
- **AND** 不出现空白网格或常驻骨架

#### Scenario: 响应式卡片网格

- **WHEN** 视口宽度为 360px 或 ≥768px
- **THEN** 360px 下为单列（或两列小卡），`md` 及以上为四列网格
- **AND** 卡片等高、封面比例一致

### Requirement: AI 入口与 Ask 跳转

系统 SHALL 在 `ai-launcher` 提供悬浮入口与占位面板，面板展示 `AI 助手即将上线` 且不发起任何网络请求；`Ask` 按钮跳转 `/ask?cityCode=<当前城市>`。

#### Scenario: 打开与关闭面板

- **WHEN** 用户点击悬浮入口
- **THEN** 打开 `role="dialog"` 占位面板，焦点移入面板
- **AND** 可通过关闭按钮、ESC、点击遮罩三种方式关闭

#### Scenario: Ask 跳转

- **WHEN** 当前城市为 `SHA` 且用户点击 `Ask`
- **THEN** 跳转 `/ask?cityCode=SHA`
- **AND** 无需登录即可发起第 1 次提问

#### Scenario: 无网络请求

- **WHEN** 打开并关闭占位面板
- **THEN** Network 中无新增请求
- **AND** 组件源码不含 `fetch` / `axios` 调用

#### Scenario: 切换城市后携带新城市

- **WHEN** 用户将城市从 `SHA` 切换到 `BJA` 后点击 `Ask`
- **THEN** 跳转 `/ask?cityCode=BJA`
- **AND** 入口不缓存旧城市代码

### Requirement: AI 入口无障碍与响应式

系统 SHALL 使 AI 入口可纯键盘操作、焦点在打开与关闭之间正确流转，并在移动端避开安全区、不遮挡页面底部内容。

#### Scenario: 键盘可达与焦点管理

- **WHEN** 用户仅用键盘操作
- **THEN** Tab 可聚焦悬浮按钮，Enter / Space 打开面板
- **AND** 打开后焦点进入面板，关闭后焦点回到悬浮按钮

#### Scenario: 移动端安全区

- **WHEN** 视口宽度为 360px
- **THEN** 按钮固定在右下角并避开 `safe-area-inset-bottom`
- **AND** 不遮挡页面底部可点击元素

#### Scenario: 降级隔离

- **WHEN** `/api/home` 某区块返回 `partialError`
- **THEN** AI 入口正常渲染与交互
- **AND** 不显示骨架或重试入口

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

## Notes

- 实现顺序与状态：`frontend-styling-stack` → `homepage-shell` → 批 3（`hero` / `feature-nav` / `city-grid`）→ 批 4（`hot-posts` / `hot-spots` / `ai-launcher`），全部 8 个变更已实施并归档（`openspec/changes/archive/2026-11-02-*`）
- 本文件由 `changes/*/specs/homepage/spec.md` 的 delta 在归档时合入；模块手册不参与 CLI 校验，仅供实现参考
