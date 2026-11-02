# homepage-shell Specification

## Purpose

首页骨架：为 Hero、功能导航、城市入口、热帖、热门景点、AI 入口 6 个区块提供固定顺序的挂载位与全局悬浮挂载点；同时定义首页聚合接口（`/api/home`）契约与区块级降级策略，支撑各区块独立开发、独立交付。

技术栈约束：Next.js 14 App Router（Server Component 页面）+ TypeScript 5.9 + Tailwind CSS 3.4。本模块不含任何区块内部实现。

## 1. 模块边界

### 1.1 包含

| 项 | 说明 |
| --- | --- |
| 页面骨架 | `src/app/page.tsx`：6 个 `data-region` 挂载位（`hero` / `feature-nav` / `city-grid` / `hot-posts` / `hot-spots` / `ai-launcher`），顺序固定 |
| 布局与间距 | 区块间垂直节奏、页面最大宽度容器、mobile-first 响应式 |
| SEO 元数据 | `src/app/layout.tsx`：`title`（含 WanderChina）、`description` |
| 聚合接口契约 | `GET /api/home?cityCode=<CODE>` 响应结构：`picks` / `hotSpots` / `hotPosts` / `partialError` |
| 区块级降级容器 | 统一封装「骨架 + 重试」，供各数据区块复用 |

### 1.2 不包含

| 项 | 归属 |
| --- | --- |
| 6 个区块的内部 UI 与交互 | 各区块 spec（`homepage-hero` 等） |
| 后端接口与数据库实现 | 后续独立后端 spec（本文只定契约） |
| 城市上下文维护（cookie / cityCode） | `homepage-city-grid` |
| 真实搜索、AI 对话 | 后续独立 spec |

### 1.3 技术约束

- 页面为 Server Component，骨架不 import 任何区块组件（区块自己替换占位）
- `data-region` 是稳定验收锚点，不随样式调整改名
- 前端统一以相对路径 `/api/...` 调用，经 `next.config.mjs` rewrites 代理
- 不引入状态管理库；区块间不共享客户端状态

## 2. 核心场景

### S1 首页可访问【正常】

- **WHEN** 客户端请求 `GET /`
- **THEN** 返回 HTTP 200
- **AND** 页面包含完整 6 个区块容器

### S2 区块顺序固定【正常】

- **WHEN** 查看 `/` 的 DOM
- **THEN** 存在恰好 6 个 `[data-region]` 元素
- **AND** 取值依次为 `hero`、`feature-nav`、`city-grid`、`hot-posts`、`hot-spots`、`ai-launcher`

### S3 SEO 元数据【正常】

- **WHEN** 查看 `/` 的 HTML `<head>`
- **THEN** 存在 `<title>`（含 `WanderChina`）与 `description` meta

### S4 编辑精选按 position 升序【正常】

- **WHEN** 请求 `GET /api/home?cityCode=SHA`，且该城市有 3 条生效中的 `editor_pick`
- **THEN** `picks` 长度为 3 且按 `position` 升序
- **AND** 每项包含 `type`、`refId`、`title`、`imageUrl`、`lastVerifiedAt`、`openingDate`

### S5 失效引用自动剔除【异常】

- **WHEN** 某条置顶攻略 `status ≠ published`，或帖子 `status = hidden`
- **THEN** 该项从 `picks` 剔除，接口不报错
- **AND** 不做补位（保持 `position` 语义，避免运营误判生效范围）

### S6 单区块失败返回 partialError【异常】

- **WHEN** 某一区块查询失败
- **THEN** 该区块返回空数组并带 `partialError` 标记
- **AND** 其余区块正常返回

### S7 前端按区块降级【异常】

- **WHEN** 某区块响应带 `partialError`
- **THEN** 该区块展示骨架 + 重试入口
- **AND** 其余区块正常展示，不出现整页错误页

### S8 全部区块失败仍可访问【异常】

- **WHEN** `picks`、`hotSpots`、`hotPosts` 全部失败
- **THEN** `GET /` 仍返回 200
- **AND** 页面渲染骨架与重试入口，不跳转错误页

### S9 城市参数缺失【边界】

- **WHEN** 请求 `/api/home` 未携带 `cityCode`
- **THEN** 服务端按 `wc_city` cookie 取值；cookie 缺失时回退 `SHA`
- **AND** 响应回显实际使用的 `cityCode`

### S10 响应式布局【正常】

- **WHEN** 视口为 360px / 768px / 1440px
- **THEN** 页面无横向滚动，区块垂直间距一致
- **AND** 内容容器在 `md` 以上居中并限制最大宽度

### S11 骨架不依赖区块实现【正常】

- **WHEN** 检查 `src/app/page.tsx`
- **THEN** 6 个挂载位内部为占位块或区块组件挂载点
- **AND** 骨架本身不 import 任何区块组件（避免反向依赖）

## 3. 数据结构

### 3.1 聚合接口响应

```ts
/** 城市代码（大写三字码） */
export type CityCode = 'SHA' | 'BJA' | 'SIA' | 'CTU' | 'HGH' | 'KWL' | 'LJG' | 'SUZ';

/** 编辑精选条目 */
export interface EditorPick {
  type: 'guide' | 'post';
  refId: string;
  title: string;
  imageUrl: string;
  lastVerifiedAt: string; // ISO date
  openingDate: string;    // ISO date，场馆/景点开业日期
  position: number;       // 升序，唯一
}

/** 首页聚合响应 */
export interface HomeResponse {
  cityCode: CityCode;
  picks: EditorPick[];
  hotSpots: HotSpotCard[];
  hotPosts: HotPostCard[];
  /** 按区块标记降级；未出现在此对象中的区块为正常 */
  partialError?: Partial<Record<'picks' | 'hotSpots' | 'hotPosts', true>>;
}
```

### 3.2 组件 Props

```ts
/** 区块挂载位（page.tsx 内部使用） */
export interface RegionSlotProps {
  region: 'hero' | 'feature-nav' | 'city-grid' | 'hot-posts' | 'hot-spots' | 'ai-launcher';
  children?: React.ReactNode;
}

/** 区块降级容器：骨架 + 重试 */
export interface RegionBoundaryProps {
  loading?: boolean;
  error?: boolean;
  onRetry?: () => void;
  /** 骨架高度档位，避免布局抖动 */
  skeleton?: 'card-row' | 'card-grid' | 'text-block';
  children: React.ReactNode;
}
```

### 3.3 约束与默认值

| 项 | 约束 |
| --- | --- |
| `data-region` | 取值只能是 6 个固定值，且全页唯一 |
| `picks` | 每项 6 个必填字段；`position` 升序且唯一；剔除后不补位 |
| `partialError` | 只标记失败区块；失败区块数据一律空数组 `[]` |
| 降级渲染 | 骨架高度需与真实内容近似（CLS 最小化），重试按钮可键盘触发 |
| 超时 | 单区块查询超时按失败处理（写入 `partialError`） |

### 3.4 文件与依赖

```
frontend/src/
├── app/
│   ├── page.tsx                  # 6 个 data-region 挂载位
│   └── layout.tsx                # title / description
└── components/homepage/
    └── region-boundary.tsx       # 骨架 + 重试（供数据区块复用）
```

## 4. 验收标准（ACCEPTANCE Checklist）

### 4.1 骨架与结构

- [ ] `GET /` 返回 200
- [ ] DOM 中恰好 6 个 `[data-region]`，顺序为 hero → feature-nav → city-grid → hot-posts → hot-spots → ai-launcher
- [ ] `<title>` 含 `WanderChina`，存在 `description` meta
- [ ] `page.tsx` 不 import 任何区块组件
- [ ] 360px 无横向滚动；≥768px 内容居中且最大宽度受限

### 4.2 聚合接口契约

- [ ] `picks` 长度为该城市生效条数且按 `position` 升序，每项含 6 个字段
- [ ] 失效引用（攻略非 published / 帖子 hidden）被剔除，接口 200 且不补位
- [ ] 单区块失败时该区块返回 `[]` 且 `partialError` 对应键为 `true`，其余区块正常
- [ ] 三个区块全失败时 `GET /` 仍 200，页面显示骨架与重试
- [ ] 无 `cityCode` 时按 cookie → `SHA` 回退，响应回显实际 `cityCode`

### 4.3 降级交互

- [ ] `partialError` 区块显示骨架 + 重试入口，其余区块正常
- [ ] 重试按钮可键盘触发（Enter/Space），触发后重新请求
- [ ] 骨架高度与真实内容近似，切换时无明显布局跳动

### 4.4 手动验证步骤

1. `npm run build && npm run start`（NTFS 副本），`curl http://localhost:3000/` 断言 6 个 `data-region` 与 title
2. 用 mock 关闭 `hotSpots` 数据源模拟失败，确认该区块骨架 + 重试、其余区块正常
3. 三个区块同时失败，确认页面仍 200 且不出现整页错误页
4. 360px / 768px / 1440px 三档截屏检查布局
