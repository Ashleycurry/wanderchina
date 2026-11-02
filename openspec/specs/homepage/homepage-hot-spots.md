# homepage-hot-spots Specification

## Purpose

首页热门景点推荐：仅取 `status = published` 景点，按近 7 日浏览与编辑权重加权排序，最多 8 条；无浏览数据时退化为编辑权重排序。数据先用 mock 契约占位，真实接口由后续独立 spec 承接。

技术栈约束：Next.js 14 App Router（Server Component）+ Tailwind CSS 3.4 + `next/image`；排序与格式化逻辑为纯函数。

## 1. 模块边界

### 1.1 包含

| 项 | 说明 |
| --- | --- |
| 数据口径 | 仅 `status = published`；最多 8 条 |
| 排序规则 | `近 7 日 view_count × 0.7 + popularity_score × 0.3` 降序 |
| 退化规则 | 全部无浏览数据时按 `popularity_score` 降序 |
| 卡片内容 | 封面（`next/image`）、名称、格式化浏览量、链接 `/city/<slug>` |
| mock 契约 | `src/mocks/hot-spots.ts`：`PopularDestination` × 8 条乱序 |
| 纯函数 | `src/lib/rank-spots.ts`：`rankHotSpots()`；`src/lib/format-views.ts`：`formatViews()` |

### 1.2 不包含

| 项 | 归属 |
| --- | --- |
| 景点详情页 | 后续独立 spec（本期链接指向城市页） |
| 真实浏览量统计与埋点上报 | 后续独立 spec |
| 城市切换逻辑本身 | `homepage-city-grid`（本模块只响应数据变化） |
| 编辑后台（录入权重/审核上架） | 后续独立 spec |

### 1.3 技术约束

- 列表为 Server Component，无客户端交互
- 排序/退化/格式化在纯函数中完成，组件只渲染
- 封面必须用 `next/image`（禁止裸 `<img>`），失败时渐变兜底
- 不新增 npm 依赖

## 2. 核心场景

### S1 仅返回 published 景点【正常】

- **WHEN** 数据中存在 `draft` / `archived` / `published` 三种状态
- **THEN** 仅返回 `status = published` 的景点
- **AND** 非 published 景点不出现在列表

### S2 加权分数降序 ≤8 条【正常】

- **WHEN** 有浏览数据且候选景点超过 8 条
- **THEN** 按 `view_count_7d × 0.7 + popularity_score × 0.3` 降序返回
- **AND** 最多 8 条

### S3 无浏览数据退化为编辑权重【正常】

- **WHEN** 该城市全部景点均无浏览数据（`view_count_7d` 为 `null` 或 0）
- **THEN** 排序退化为按 `popularity_score` 降序
- **AND** 仍只返回 `published` 景点，条数上限不变

### S4 部分景点无浏览数据【边界】

- **WHEN** 部分景点有浏览数据、部分为 `null`
- **THEN** `null` 视作 0 参与加权公式（不触发整体退化）
- **AND** 排序结果不因缺失值抛错

### S5 浏览量格式化【正常】

- **WHEN** 浏览量为 12300 / 980 / 1200000
- **THEN** 分别显示 `12.3k views` / `980 views` / `1.2m views`
- **AND** 数值与单位间无多余空格，四舍五入保留 1 位小数

### S6 空列表兜底【异常】

- **WHEN** 过滤后无任何景点
- **THEN** 区块显示兜底文案（如「该城市暂无热门景点」）
- **AND** 不出现空白网格或骨架常驻

### S7 封面加载失败【异常】

- **WHEN** 封面图 404 或加载失败
- **THEN** 卡片显示渐变占位底，名称与浏览量仍可读
- **AND** 布局不塌陷（固定宽高比）

### S8 区块降级【异常】

- **WHEN** `/api/home` 的 `hotSpots` 区块失败
- **THEN** 该区块展示骨架 + 重试
- **AND** 其余区块正常展示，页面不整页报错

### S9 城市切换重拉【正常】

- **WHEN** 用户切换城市（`SHA` → `BJA`）
- **THEN** 景点列表按新城市重新拉取并渲染
- **AND** 不残留上一城市数据

### S10 响应式卡片网格【正常】

- **WHEN** 视口 360px / ≥768px
- **THEN** 360px 单列（或 2 列小卡），≥768px 4 列网格
- **AND** 卡片等高、封面比例一致

### S11 权重越界【边界】

- **WHEN** `popularity_score` 超出 0-100（脏数据）
- **THEN** 按原值参与排序但不渲染异常样式
- **AND** 不因越界值导致排序崩溃

## 3. 数据结构

### 3.1 mock 契约

```ts
export type SpotStatus = 'published' | 'draft' | 'archived';

export interface PopularDestination {
  id: string;
  /** 必填；城市 slug，链接 /city/<slug> */
  slug: string;
  /** 必填；展示名，1-40 字符 */
  name: string;
  /** 必填；封面图路径，/images/ 开头或远程 CDN（本期用本地占位） */
  coverImage: string;
  status: SpotStatus;
  /** 近 7 日浏览量；无数据为 null */
  viewCount7d: number | null;
  /** 编辑手工权重，0-100 */
  popularityScore: number;
}
```

### 3.2 纯函数签名

```ts
/** 加权排序 + 截断（仅保留 published 由调用方或函数内部完成） */
export function rankHotSpots(spots: PopularDestination[], limit = 8): PopularDestination[];

/** 浏览量格式化：12300 → "12.3k views" */
export function formatViews(views: number): string;
```

### 3.3 组件 Props

```ts
/** src/components/homepage/hot-spots.tsx —— Server Component */
export interface HotSpotsProps {
  spots: PopularDestination[];
  className?: string;
}
```

### 3.4 约束与默认值

| 项 | 约束 | 默认值 |
| --- | --- | --- |
| 加权公式 | `viewCount7d × 0.7 + popularityScore × 0.3`（`null` 视作 0） | — |
| 退化条件 | 全部 `viewCount7d` 为 `null` 或 0 | 按 `popularityScore` 降序 |
| 条数 | 最多 8 条 | 8 |
| 封面 | `next/image` + 固定宽高比（如 4:3）+ `sizes` 声明 | — |
| 格式化 | ≥1e6 用 `m`，≥1e3 用 `k`，保留 1 位小数 | — |

### 3.5 文件与依赖

```
frontend/src/
├── mocks/hot-spots.ts                 # 8 条乱序数据（含 draft/archived 与 null 浏览）
├── lib/
│   ├── rank-spots.ts                  # rankHotSpots
│   └── format-views.ts                # formatViews
└── components/homepage/hot-spots.tsx  # Server Component 卡片网格

frontend/tests/rank-spots.test.mjs     # node --test 断言（排序 + 退化）
```

## 4. 验收标准（ACCEPTANCE Checklist）

### 4.1 数据口径

- [ ] 仅返回 `published`，`draft` / `archived` 不出现
- [ ] 按 `viewCount7d × 0.7 + popularityScore × 0.3` 降序，最多 8 条
- [ ] 全部无浏览数据时按 `popularityScore` 降序
- [ ] 部分 `null` 视作 0 参与加权，不触发整体退化

### 4.2 内容与展示

- [ ] 每张卡片含封面、名称、格式化浏览量
- [ ] `12300 → 12.3k views`、`980 → 980 views`、`1200000 → 1.2m views`
- [ ] 空列表显示兜底文案，无空白容器
- [ ] 封面失败时渐变兜底，布局不塌陷

### 4.3 排序验证（node --test）

- [ ] `rankHotSpots` 对乱序输入返回 ≤8 条且分数单调不增
- [ ] 退化用例（全 `null`）按 `popularityScore` 单调不增
- [ ] `formatViews` 三档数值断言通过

### 4.4 交互与隔离

- [ ] 切换城市后列表按新城市重拉，无旧数据残留
- [ ] `hotSpots` 区块 `partialError` 时显示骨架 + 重试，其余区块正常
- [ ] 360px 单列/2 列、≥768px 4 列，卡片等高

### 4.5 手动验证步骤

1. `node --test frontend/tests/`，确认排序、退化和格式化断言通过
2. `npm run build && npm run start`，`curl` 断言 8 张卡片与格式化文案
3. 阻断封面图请求，检查渐变兜底与布局
4. 切换城市确认列表刷新；模拟 `partialError` 检查骨架 + 重试
