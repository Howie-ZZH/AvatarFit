# Agent 操作规范

## 项目背景

- 本项目是 3D 游戏化健身 App，核心体验是“真实训练驱动 3D 角色成长”。
- MVP 核心闭环：
  - 注册 / 登录
  - 创建身体档案
  - 创建 3D 角色
  - 获取今日 3 分钟训练
  - 创建训练 session
  - 完成训练并计算 XP、等级和 6 大属性成长
  - Flutter 将后端返回的 Unity 事件转发给 Unity 播放成长反馈
- 首日体验优先级高于扩展功能。课程、AI、支付、完整资产系统属于后续能力，不应阻塞首日闭环。

## 回复语言

- 始终使用中文回复用户。
- 说明操作时保持简洁、直接，优先给出结论和下一步。

## 构建与编译

- 不要私自运行构建、编译、打包或会产生编译产物的命令。
- 如需运行测试、构建、Flutter/Android/iOS/Unity/Maven/Gradle 相关命令，必须先说明原因、可能产生的目录或文件，并等待用户确认。
- 常见可能产生的目录或文件包括但不限于：
  - `app/build/`
  - `app/.dart_tool/`
  - `app/android/.gradle/`
  - `app/ios/Flutter/ephemeral/`
  - `backend/target/`
  - `.tooling/`

## 项目结构

- `docs/`：产品、后端、App、Unity 和 Sprint 规格，需求判断优先参考这里。
- `backend/`：Spring Boot 后端，Java 21、Spring Boot 3.5.x、Spring Security + JWT、Spring Data JPA、Flyway。
- `app/`：Flutter App，当前包含首日流程、Mock API、远端 API、Mock Unity 和 Native Unity 桥接边界。
- `unity/`：Unity 2022.3 LTS 工程骨架，负责 3D 角色展示、动画、换装、成长反馈和截图。
- `assets/`：设计、3D 和参考资源。

## 关键文档

- 产品总览：`README.md`、`docs/PROJECT_PLAN.md`
- 后端契约：`docs/BACKEND_SPEC.md`、`backend/README.md`
- Flutter 页面和服务边界：`docs/APP_WIREFRAME.md`、`app/README.md`
- Unity 通信和表现：`docs/UNITY_SPEC.md`、`unity/README.md`
- 排期和优先级：`docs/SPRINT_PLAN.md`

## 模块边界

- Flutter 负责首日流程、页面状态、API 调用、Unity 指令封装和失败降级。
- 后端负责认证、用户、身体档案、角色、训练 session、成长计算、幂等和 Unity 可消费事件。
- Unity 负责 3D 表现，不负责业务计算，也不直接访问后端。
- 第三方训练 API、AI、支付、对象存储等外部能力必须经后端适配，App 不直接持有第三方 API Key。

## 后端约定

- 包名根路径为 `com.fitgame.backend`，现有模块包括 `auth`、`user`、`profile`、`avatar`、`workout`、`security`、`common`。
- 本地默认 H2 内存库，生产或联调用环境变量覆盖 PostgreSQL datasource。
- 数据库结构通过 Flyway migration 管理，不要用临时 SQL 或 JPA 自动建表替代迁移。
- 除 `POST /api/auth/register`、`POST /api/auth/login`、Swagger 和 `/error` 外，接口默认需要 `Authorization: Bearer <accessToken>`。
- `POST /api/workouts/sessions/{sessionId}/complete` 必须保持幂等：重复提交同一个 session 返回首次完成结果，不重复增加 XP、等级或属性。
- 后端返回给 Flutter 的 `unityEvent` 应可直接转发给 Unity，不要让 Flutter 重新计算成长结果。

## Flutter 约定

- API 配置通过 Dart define 控制：
  - `FITGAME_USE_REMOTE_API`
  - `FITGAME_API_BASE_URL`
  - `FITGAME_ACCESS_TOKEN`
  - `FITGAME_USE_NATIVE_UNITY`
- 默认走 Mock 服务，接远端后端时再打开 `FITGAME_USE_REMOTE_API=true`。
- 页面不要直接拼 Unity JSON，应通过 `UnityBridgeService` 或同类服务封装发送命令。
- 训练完成后以服务端 `WorkoutCompletion.unityEvent` 为准，直接转发给 Unity。
- Unity 初始化失败、动画缺失、原生 Unity 未接入时，Flutter 必须保留可用降级体验，不能丢失训练完成结果。

## Unity 约定

- Unity 版本优先使用 `2022.3 LTS`。
- Flutter -> Unity 命令入口是 `UnityBridge.PostMessage(string json)`。
- Android 原生层调用 Unity 对象名和方法：
  - GameObject：`UnityBridge`
  - Method：`PostMessage`
- 通道名称保持一致：
  - MethodChannel：`fitgame/unity_commands`
  - EventChannel：`fitgame/unity_events`
- MVP 支持命令：
  - `SET_AVATAR_STATE`
  - `PLAY_ANIMATION`
  - `START_EXERCISE`
  - `WORKOUT_COMPLETE`
  - `CHANGE_OUTFIT`
  - `CAPTURE_SHARE_IMAGE`
- Unity -> Flutter 事件应遵循 `{type, requestId, payload, success, error}` 结构。

## 核心数据和枚举

- 角色 6 大属性：
  - `strength`
  - `endurance`
  - `core`
  - `flexibility`
  - `fatBurn`
  - `recovery`
- 体型档位：
  - `lean`
  - `normal`
  - `fit`
  - `muscular`
  - `strong`
- 能量状态：
  - `tired`
  - `normal`
  - `confident`
  - `peak`
- 首版训练动作和动画 key：
  - 深蹲：`squat_basic` / `workout_squat`
  - 开合跳：`jumping_jack_basic` / `workout_jumping_jack`
  - 平板支撑：`plank_basic` / `workout_plank`
  - 拉伸：`stretch_basic` / `workout_stretch`

## 首日远端联调顺序

- `POST /api/auth/register` 或 `POST /api/auth/login`
- `GET /api/users/me`
- `GET /api/profiles/me`
- `POST /api/profiles`，仅在 404 身体档案不存在时创建
- `GET /api/avatars/me`
- `POST /api/avatars`，仅在 404 角色不存在时创建
- `GET /api/avatars/me`
- `GET /api/workouts/today`
- `POST /api/workouts/sessions`
- `POST /api/workouts/sessions/{sessionId}/complete`

## 依赖与下载源

- 构建项目或下载依赖时，尽量使用中国大陆可以访问的源。
- 如需联网安装依赖，应优先说明将使用的源和安装范围。

## Git 操作

- 不要私自提交、推送、重置、变基或丢弃用户改动。
- 执行会修改 Git 状态或历史的操作前，必须先获得用户明确确认。
- 当前工作区存在用户改动时，应保留并绕开无关改动。

## 项目约定

- 优先遵循项目现有结构、代码风格和工具链。
- 修改应聚焦当前需求，避免无关重构。
- 涉及前端或移动端体验时，保持界面实用、克制、适合反复使用。
- 新增功能时先判断是否属于 MVP 首日闭环；不属于时应避免把 P1/P2 能力做成 P0 依赖。
- 跨 Flutter、后端、Unity 的改动必须维护 JSON 字段名、枚举值和错误语义的一致性。
- 不要在 Flutter 中绕过后端直接接第三方训练、AI、支付或资产服务。
- 不要把 Unity 作为业务状态源；角色等级、XP、属性和装备状态以后端返回为准。
