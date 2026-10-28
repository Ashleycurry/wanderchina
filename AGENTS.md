# AGENTS.md

本文件是项目中所有 AI 编码代理（Agent）的根级指令，任何会话都必须遵循。

## 项目理念

本项目的工作流由三层构成：

1. **Harness（Qoder）**：`.qoder/` 下的 agents / commands / rules / skills 组成代理运行框架。
2. **OpenSpec**：`openspec/` 目录承载规范驱动开发（Spec-Driven Development）——系统行为以规格为准，先写规格、评审确认、再写代码。
3. **Superpowers**：`.qoder/skills/` 提供方法论技能——头脑风暴、编写计划、TDD、子代理驱动开发、系统化调试、完成前验证。

## 强制工作流

任何新功能、行为变更或架构调整，必须依次经过：

1. **explore**：需求模糊时先探索代码与方案（`/opsx-explore`），只读不改。
2. **propose**：创建 `openspec/changes/<name>/` 提案（proposal.md / specs/ / design.md / tasks.md），等待用户评审确认（`/opsx-propose`）。
3. **apply**：按 tasks.md 逐条实施，遵循 TDD 与任务级评审（`/opsx-apply`）。
4. **archive**：变更完成并上线后归档，delta 合入 `openspec/specs/`（`/opsx-archive`）。

> 未经用户确认的提案，禁止写任何实现代码。微小修复（拼写、单行 bug）可直接修复，但需同步更新受影响的规格。

## 核心规则

- 所有规则见 `.qoder/rules/`，必须遵守。
- 所有方法论技能见 `.qoder/skills/`，按触发条件强制使用；TDD 与完成前验证为硬性要求。
- `openspec/specs/` 是系统行为的单一事实来源；代码与规格冲突时以规格为准并推动修正。
- 每次会话开始先读 `openspec/project.md` 与相关 spec 再动手。
- 所有结论必须附证据（文件路径、命令输出），禁止臆测。

## 目录约定

根仓库是 AIWorkSpace：只承载 Harness、规范与脚本等协作配置，业务代码位于两个 git submodule。

| 目录 | 用途 |
| --- | --- |
| `openspec/` | 规格与变更提案（单一事实来源） |
| `frontend/` | 前端子仓库（submodule → wanderchina-frontend；Next.js 14 App Router + React 18 + TypeScript，端口 3000） |
| `backend/` | 后端子仓库（submodule → wanderchina-backend；Spring Boot 3.5.x + Spring AI + Java 21 + MySQL 8 + Flyway，端口 8080） |
| `.qoder/` | 代理框架配置（agents / commands / rules / skills） |

## 子仓库（Submodule）约定

- `frontend/`、`backend/` 是独立 git 仓库，代码改动在对应子仓库内 commit / push，不通过根仓库提交
- 克隆根仓库后先初始化子模块：`git submodule update --init --recursive`
- 子仓库推送后，回根仓库提交新的 gitlink（根仓库只记录子仓库的 commit 指针）
- 本地开发：根目录双击 `start.bat` 一键启动，或在 `frontend/`、`backend/` 内分别启动

## 技术选型约束

技术选型是硬约束：新增或更换框架、引入关键依赖，必须先提 `openspec/changes/<name>/` 提案并经用户确认，禁止在实现过程中顺手引入。

| 层 | 选型 | 版本基线 |
| --- | --- | --- |
| 前端框架 | React + Next.js（App Router） | React 18.3.1 / Next.js 14.2.x |
| 前端路由 | App Router | 目录即路由（`src/app/**/page.tsx`） |
| 前端样式 | Tailwind CSS + shadcn/ui | Tailwind 3.4 / shadcn new-york |
| 前端语言 | TypeScript | 5.9 |
| 前端包管理 | npm | 不使用 pnpm / yarn |
| 后端框架 | Spring Boot（`spring-boot-starter-web`） | 3.5.x |
| 后端 AI | Spring AI（`spring-ai-starter-model-openai`，OpenAI 兼容协议） | 1.0.x |
| 后端数据访问 | JdbcTemplate（`spring-boot-starter-jdbc`） | 不引入 JPA / MyBatis |
| 数据库 | MySQL | 8.x（配置暂留空，后续取消注释启用；凭据走环境变量） |
| 数据迁移 | Flyway（`flyway-core` + `flyway-mysql`） | 脚本位于 `db/migration`，启动自动执行 |
| 后端语言 | Java | 21 |
| 后端构建 | Maven + `spring-boot-maven-plugin` | 本机配置 aliyun 镜像 |

刻意不引入（引入需提案）：

- ORM 与内存库：无 JPA / MyBatis / H2，数据访问统一用 JdbcTemplate，schema 由 Flyway 管理
- 前端状态管理：无 Redux / Zustand / Jotai，优先 React 内置状态
- 前端黑盒 UI 库：组件统一用 shadcn/ui 生成到 `src/components/ui/`，源码可直接改
- 前端测试框架：验收依赖 `npm run build`（next build）

固定约定：

- 前端分工：React 负责组件拆分、Next.js 负责路由与页面组织、TypeScript 负责类型约束、Tailwind CSS 负责排版、shadcn/ui 负责可直接改源码的组件骨架
- 后端分工：Spring Boot 负责工程骨架、Spring AI 负责把模型能力接进业务、Java 21 统一语言版本、Maven 管依赖和构建、MySQL 存数据、Flyway 管数据库迁移
- 端口：前端 3000、后端 8080；开发环境 `/api` 由 Next.js rewrites 转发到 8080
- 后端包根 `com.wanderchina`，REST 控制器按业务域分包
- 字段命名前后端统一小驼峰（camelCase）

## 角色分工

- 子代理（subagent）定义位于 `.qoder/agents/`，规划说明见该目录下的 README.md
