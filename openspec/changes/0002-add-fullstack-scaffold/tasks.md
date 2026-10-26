# 实施任务 · 全栈开发框架

## 1. 后端工程初始化

- [x] 1.1 创建 `src/backend/pom.xml`：Spring Boot 4.1.2 parent、web/test starter、Java 21
- [x] 1.2 创建 `WanderchinaApplication` 与 `application.yml`（端口 8080）
- [x] 1.3 验证：`mvn -q compile` 通过

## 2. 后端接口（TDD）

- [x] 2.1 编写 `HealthControllerTest` 与 `EchoControllerTest`（RED：接口未实现，测试失败）
- [x] 2.2 实现 `ApiResponse<T>`、`HealthController`、`EchoController`（GREEN）
- [x] 2.3 验证：`mvn -q test` 全部通过

## 3. 全局异常处理

- [x] 3.1 编写异常场景测试：`/api/echo` 缺参 → 400 统一错误结构（RED）
- [x] 3.2 实现 `GlobalExceptionHandler`（GREEN）
- [x] 3.3 验证：`mvn -q test` 全部通过

## 4. 前端工程

- [x] 4.1 在 `src/frontend/` 用 Vite 模板创建 React + TypeScript 工程
- [x] 4.2 配置 `vite.config.ts`：`/api` 代理到 `http://localhost:8080`
- [x] 4.3 实现示例首页：页面显示 hello
- [x] 4.4 验证：`npm run build` 成功产出 `dist/index.html`

## 5. 联调与文档

- [x] 5.1 人工联调：后端 8080 + 前端 5173，页面展示健康数据
- [x] 5.2 更新 `README.md`：前后端启动命令与联调说明
- [x] 5.3 更新 `openspec/project.md`：技术栈、目录约定、运行方式
- [x] 5.4 运行 `openspec validate 0002-add-fullstack-scaffold --strict` 通过
