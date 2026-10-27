# frontend-scaffold 规格

## ADDED Requirements

### Requirement: Vite + React SPA 工程可构建

系统 SHALL 提供位于 `src/frontend/` 的 Vite + React + TypeScript 工程（npm 管理），`npm run build` 成功产出静态文件。

#### Scenario: 生产构建通过

- **WHEN** 在 `src/frontend/` 下执行 `npm install` 后 `npm run build`
- **THEN** 构建成功并在 `dist/` 生成 `index.html`

### Requirement: 开发服务器代理后端 API

系统 SHALL 将 Vite dev server 的 `/api` 前缀请求代理到 `http://localhost:8080`。

#### Scenario: 代理转发

- **WHEN** 前端开发服务器运行且后端已启动，请求 `/api/health`
- **THEN** 请求被代理到后端并原样返回响应

### Requirement: 示例页面显示 hello

系统 SHALL 提供示例首页，页面显示 hello 文案。

#### Scenario: 页面显示 hello

- **WHEN** 用户打开 `http://localhost:5173`
- **THEN** 页面显示 hello
