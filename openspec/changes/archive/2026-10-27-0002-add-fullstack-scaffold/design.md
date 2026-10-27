# 设计 · 全栈开发框架

## 决策 1：前后端分离、同仓两工程

- 目录：`src/backend/`（Maven）、`src/frontend/`（npm），各自独立构建与运行
- 理由：边界清晰、可独立部署；一个仓库便于规格与代码同步演进
- 备选：全栈单体（Thymeleaf 服务端渲染）——被否，日后向 SPA 演进成本高

## 决策 2：后端 Spring Boot 4.1.2 + Maven 单模块（Java 21）

- 版本取自 start.spring.io 官方元数据（2026-10 默认稳定版 4.1.2.RELEASE）
- 单模块起步（YAGNI），需要分层时再拆多模块
- 包名 `com.wanderchina`，服务端口 8080

## 决策 3：前端 Vite + React + TypeScript（npm）

- 用户选定 React；pnpm 本机未安装，统一使用 npm
- dev server 端口 5173，代理 `/api` → `http://localhost:8080`

## 决策 4：暂不接入数据库

- 不引入 JPA / MyBatis / 连接池，不配置数据源
- 接口数据为内存中的静态值或计算结果

## 决策 5：统一响应结构 `ApiResponse<T>`

```json
{ "code": 0, "message": "ok", "data": {} }
```

- `code = 0` 表示成功，非 0 表示失败
- 全局异常处理器：`IllegalArgumentException` → HTTP 400；其他未捕获异常 → HTTP 500，均返回统一错误结构
