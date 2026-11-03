# homepage-city-grid Specification

## Purpose

首页城市快速入口：以图标网格提供 8 个 MVP 城市的跳转入口；同时维护城市上下文（`wc_city` cookie、默认城市 SHA、服务端按请求解析城市），支撑城市切换后的区块联动。城市清单与联动先用 mock 数据占位。

技术栈约束：Next.js 14 App Router（`CityGrid` 为 Server Component，切换交互为 Client 组件）+ Tailwind CSS 3.4。

## 1. 模块边界

### 1.1 包含

| 项 | 说明 |
| --- | --- |
| 城市网格 | 8 个城市项（图标 + 城市名），链接 `/city/<slug>`，mobile-first 网格 |
| 城市清单 | `src/mocks/cities.ts`：`City` 类型 + 8 条占位数据（slug ↔ cityCode 映射） |
| 城市上下文 | `wc_city` cookie 读写、默认城市 `SHA`；服务端每次请求按 cookie 解析城市（`/api/home` 另支持 `?cityCode=` 覆盖） |
| 城市切换联动 | 切换后刷新依赖城市维度的三个区块（picks / hotSpots / hotPosts） |
| 空区块兜底 | 切换后某区块无数据时展示兜底文案，不出现空白网格 |

### 1.2 不包含

| 项 | 归属 |
| --- | --- |
| 城市详情页 `/city/<slug>` | 后续独立 spec（本期允许占位/404） |
| 真实城市列表接口 | 后续后端 spec（本期 mock） |
| 各区块内部渲染 | 各区块 spec |
| 登录态、用户偏好存储 | 后续独立 spec |

### 1.3 技术约束

- `CityGrid` 为 Server Component；城市切换交互（写 cookie + 触发刷新）抽为 Client 组件
- RSC 只能读 cookie 不能写：`wc_city` 的唯一写入点是城市切换组件的点击处理
- cookie 名固定 `wc_city`，值域为 8 个 `CityCode`；不使用 localStorage 存城市
- 切换后走 `router.refresh()`（或等效）重新拉取 `/api/home`，不整页硬刷新
- URL 不得写入 `cityCode` 等查询参数（避免脏参数）
- 不新增 npm 依赖

## 2. 核心场景

### S1 渲染恰好 8 个城市项【正常】

- **WHEN** 查看 `/` 的城市网格 DOM
- **THEN** 存在恰好 8 个城市项
- **AND** 每项包含可见图标与城市名

### S2 链接形如 /city/<slug>【正常】

- **WHEN** 检查任一城市项 `href`
- **THEN** 形如 `/city/<slug>`
- **AND** slug 属于 `beijing`、`shanghai`、`xian`、`chengdu`、`hangzhou`、`guilin`、`lijiang`、`suzhou`

### S3 首次访问无 cookie 默认 SHA【正常】

- **WHEN** 用户首次打开首页且请求中无 `wc_city` cookie
- **THEN** 系统返回默认城市 `SHA` 的内容
- **AND** 不主动写入 cookie：页面为 Server Component，cookie 仅在用户主动切换城市时由 Client 组件写入

### S4 服务端按 cookie 解析城市【正常】

- **WHEN** `wc_city` 已存在
- **THEN** 首页 Server Component 直接读该 cookie 解析城市，不额外发起请求
- **AND** `/api/home` 支持 `?cityCode=` 覆盖 cookie（优先），供契约桩与后续调试使用

### S5 切换到 BJA 三区块联动【正常】

- **WHEN** 用户切换城市到 `BJA`
- **THEN** editor picks、热门景点、热门帖子三个区块数据全部替换为北京
- **AND** 切换为局部刷新（`router.refresh()`），不整页重载

### S6 URL 不含脏参数【正常】

- **WHEN** 完成城市切换
- **THEN** 地址栏 URL 不新增 `cityCode`/`city` 等查询参数
- **AND** 直接复制 URL 打开仍按 cookie 城市渲染

### S7 空区块兜底文案【异常】

- **WHEN** 切换后某区块无数据（返回空数组）
- **THEN** 该区块显示兜底文案（如「该城市暂无内容」）
- **AND** 不出现空白网格或骨架常驻

### S8 cookie 被篡改为非法值【异常】

- **WHEN** `wc_city` 值不在 8 个合法 `CityCode` 内
- **THEN** 系统回退到默认城市 `SHA`
- **AND** 页面不报错；不主动重写 cookie（等用户下次切换时自然覆盖）

### S9 cookie 写入失败（隐私模式）【异常】

- **WHEN** 浏览器禁用 cookie 导致 `document.cookie` 写入被丢弃
- **THEN** 页面保持当前服务端城市继续渲染，不阻塞浏览
- **AND** 不出现错误提示弹窗或白屏；用户可反复切换（每次仍尝试写入）

### S10 键盘可达与当前城市标识【正常】

- **WHEN** 用户仅用键盘 Tab 导航
- **THEN** 8 个城市项依次可达，焦点样式可见
- **AND** 当前城市项带 `aria-current="true"`

### S11 移动端两行四列【正常】

- **WHEN** 视口 360px
- **THEN** 城市项按 4 列 × 2 行排列
- **AND** 无横向滚动；`md` 以上单行 8 列

### S12 区块降级时切换仍可用【隔离】

- **WHEN** `/api/home` 某区块返回 `partialError`
- **THEN** 城市网格正常渲染与切换
- **AND** 切换只影响失败区块的重试，不阻断整体页面

## 3. 数据结构

### 3.1 城市数据

```ts
export type CityCode = 'SHA' | 'BJA' | 'SIA' | 'CTU' | 'HGH' | 'KWL' | 'LJG' | 'SUZ';
export type CitySlug = 'beijing' | 'shanghai' | 'xian' | 'chengdu' | 'hangzhou' | 'guilin' | 'lijiang' | 'suzhou';

export interface City {
  /** 必填；URL slug，小写，与 CityMeta.slug 一致 */
  slug: CitySlug;
  /** 必填；大写三字码，写入 wc_city */
  code: CityCode;
  /** 必填；展示名（中文或英文，1-20 字符） */
  name: string;
  /** 必填；图标标识（lucide 图标名或 emoji） */
  icon: string;
}

export const DEFAULT_CITY_CODE: CityCode = 'SHA';
export const CITY_COOKIE_NAME = 'wc_city';
```

### 3.2 组件 Props

```ts
/** src/components/homepage/city-grid.tsx —— Server Component */
export interface CityGridProps {
  /** 必填；8 项城市数据 */
  cities: City[];
  /** 必填；当前城市代码，用于 aria-current 高亮 */
  currentCode: CityCode;
  className?: string;
}

/** src/components/homepage/city-switcher.tsx —— Client Component（'use client'） */
export interface CitySwitcherProps {
  /** 必填；当前城市，用于 aria-current 与「点击当前项不刷新」判断 */
  currentCode: CityCode;
  className?: string;
}
```

### 3.3 约束与默认值

| 项 | 约束 | 默认值 |
| --- | --- | --- |
| 数量 | 恰好 8 项，`slug`/`code` 均唯一 | 8 条 mock 常量 |
| cookie 名 | 固定 `wc_city`，禁止改名 | `wc_city` |
| cookie 值 | 仅 8 个 `CityCode`；非法值回退 `SHA` | `SHA` |
| cookie 生命周期 | `Path=/`，`Max-Age` ≥ 30 天，`SameSite=Lax` | 30 天 |
| URL | 切换不写查询参数 | — |
| 刷新方式 | 局部刷新（`router.refresh()`），禁止 `location.reload()` | — |

### 3.4 文件与依赖

```
frontend/src/
├── mocks/cities.ts                        # City 类型 + 8 条数据 + 常量
└── components/homepage/
    ├── city-grid.tsx                      # Server Component（网格）
    └── city-switcher.tsx                  # 'use client'（cookie + refresh）
```

不新增 npm 依赖。

## 4. 验收标准（ACCEPTANCE Checklist）

### 4.1 渲染与链接

- [ ] 城市网格渲染恰好 8 个城市项，每项含图标与城市名
- [ ] 每项 `href` 形如 `/city/<slug>`，8 个 slug 与 mock 一致
- [ ] 当前城市项带 `aria-current="true"`

### 4.2 城市上下文

- [ ] 无 `wc_city` cookie 首次访问：页面按 `SHA` 渲染（不主动写 cookie）
- [ ] 已有 `wc_city` 时服务端按 cookie 解析城市；`/api/home?cityCode=` 优先于 cookie
- [ ] cookie 值为非法代码时回退 `SHA`，页面不报错
- [ ] cookie 写入失败时保持当前服务端城市、不白屏、不弹错

### 4.3 切换联动

- [ ] 切换到 `BJA`：picks / 热门景点 / 热门帖子三区块数据全部变为北京
- [ ] 切换为局部刷新，页面不整页重载
- [ ] 切换后 URL 不含 `cityCode`/`city` 等查询参数
- [ ] 切换后空区块显示兜底文案，不出现空白网格

### 4.4 布局与无障碍

- [ ] 360px：4 列 × 2 行，无横向滚动
- [ ] ≥768px：单行 8 列
- [ ] Tab 依次可达 8 项，焦点样式可见

### 4.5 手动验证步骤

1. 清空 cookie 后打开 `/`，确认按 `SHA` 渲染；点击任一城市后 `document.cookie` 出现 `wc_city=<CODE>`
2. 手改 `wc_city=XXX` 刷新，确认回退 `SHA` 且页面正常
3. 切换到 BJA，确认三区块内容变更、URL 无查询参数
4. DevTools 禁用 cookie（或隐私窗口限制）验证不阻塞浏览
5. 360px / 768px 两档截屏检查网格列数
