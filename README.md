# wanderchina

基于 **Harness（Qoder）+ OpenSpec + Superpowers** 三合一理念的 AI coding 全栈项目（AIWorkSpace 工作区）。

根仓库是 **AIWorkSpace**：只承载 Harness、规范与脚本；前后端分别作为独立 git 子仓库（submodule）：`frontend/` → [wanderchina-frontend](https://github.com/Ashleycurry/wanderchina-frontend)，`backend/` → [wanderchina-backend](https://github.com/Ashleycurry/wanderchina-backend)。

## 三大支柱

- **Harness（`.qoder/`）**：代理运行框架，提供子代理（agents）、斜杠命令（commands）、规则（rules）与技能（skills）。
- **OpenSpec（`openspec/`）**：规范驱动开发（Spec-Driven Development）。先写规格、评审确认，再写代码；`specs/` 是系统行为的单一事实来源。
- **Superpowers（`.qoder/skills/`）**：技能化开发方法论——头脑风暴、编写计划、TDD、子代理驱动开发、系统化调试、完成前验证。

## 工作流

```
需求 → /explore 探索现状与候选方案
     → /propose 创建 openspec/changes/<name>/ 提案（proposal + specs + design + tasks）
     → 用户评审确认
     → /apply 按任务清单实施（TDD + 子代理驱动）
     → 验证（verification-before-completion）
     → /archive 归档变更，delta 合入 specs/
```

## 目录结构

```
.
├── .qoder/                 # AI 编码框架（Harness 层）
│   ├── agents/             # 子代理定义（规划见 agents/README.md）
│   ├── commands/opsx/      # 斜杠命令：opsx-explore / opsx-propose / opsx-apply / opsx-archive
│   ├── rules/              # 规则：coding-conventions / spec-driven-workflow
│   └── skills/             # opsx 链路技能 + Superpowers 技能库
├── openspec/               # 规范层（单一事实来源）
│   ├── changes/            # 进行中的变更提案（归档后进入 archive/）
│   ├── specs/              # 已合入的规格
│   ├── config.yaml         # OpenSpec 配置
│   └── project.md          # 项目上下文（技术栈、约定、约束）
├── frontend/               # 前端子仓库（submodule → wanderchina-frontend）
│                           #   Next.js 14 App Router + React 18 + TypeScript + Tailwind + shadcn/ui，端口 3000
├── backend/                # 后端子仓库（submodule → wanderchina-backend）
│                           #   Spring Boot 4.1.2 + Java 21，端口 8080
├── .gitmodules             # 子模块配置
├── .gitignore
├── AGENTS.md               # 所有 AI 代理的根级指令
└── README.md
```

## 快速开始

### 1. 安装 OpenSpec CLI（可选，用于校验）

```powershell
irm https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/scripts/binary/install.ps1 | iex
```

或 `npm install -g @fission-ai/openspec@latest`（需 Node.js 20.19+）。

### 2. 开始一个变更

在 AI 编码代理中输入：

```
/opsx-explore 我想做 XXX       # 探索现状与方案
/opsx-propose add-xxx          # 创建变更提案，等待评审
/opsx-apply                    # 按提案实施（TDD）
/opsx-archive                  # 完成后归档
```

### 3. 启动前后端（本地开发）

> 首次克隆本仓库后，先执行 `git submodule update --init --recursive` 初始化 `frontend/` 与 `backend/` 子模块。

Windows 下双击根目录 **`start.bat`** 即可一键启动（自动开两个服务窗口并打开浏览器）。

也可手动分别启动（环境要求：JDK 21+、Maven 3.9+、Node.js 20+）：

```powershell
# 后端（端口 8080）
cd backend
mvn spring-boot:run

# 前端（端口 3000，/api 由 rewrites 代理到 8080）
cd frontend
npm install
npm run dev
```

验证：浏览器打开 http://localhost:3000 ，页面应显示 hello。

后端接口：

- `GET /api/health` — 健康检查（返回统一响应 `{code, message, data}`）
- `GET /api/echo?message=...` — 回显（缺少 message 时返回 400 统一错误）

测试与构建：

```powershell
cd backend; mvn test        # 后端集成测试
cd frontend; npm run build  # 前端生产构建（next build）
```

### 4. 参考

- OpenSpec: https://github.com/Fission-AI/OpenSpec
- Superpowers: https://github.com/obra/superpowers
