# Backend

Spring Boot 后端工程。当前已初始化 Sprint 1 的最小可运行骨架，目标是先跑通 Flutter 真实首日流程：

```text
注册/登录 -> 获取当前用户 -> 创建身体档案 -> 创建/获取初始角色 -> 创建训练 session -> 完成训练
```

## 职责

- 用户注册 / 登录
- 身体档案
- 角色状态
- 训练记录
- XP、等级、属性成长计算
- 第三方课程 API 适配
- 皮肤资产接口
- AI 教练接口
- 支付和订阅预留

## 推荐技术栈

- Java 21
- Spring Boot 3.5.x
- PostgreSQL
- Spring Security + JWT
- Spring Data JPA
- Flyway
- springdoc-openapi / Swagger UI

本地默认使用 H2 内存库，方便快速启动；连接 PostgreSQL 时通过环境变量覆盖 datasource。

## 本地运行

```bash
./mvnw spring-boot:run
```

默认端口：`8080`

Swagger UI：`http://localhost:8080/swagger-ui.html`

常用环境变量：

```text
SPRING_DATASOURCE_URL
SPRING_DATASOURCE_USERNAME
SPRING_DATASOURCE_PASSWORD
SPRING_DATASOURCE_DRIVER
APP_JWT_SECRET
APP_JWT_ACCESS_TTL_SECONDS
```

## 已实现接口

除 `POST /api/auth/register` 和 `POST /api/auth/login` 外，接口都需要：

```text
Authorization: Bearer <accessToken>
```

```text
POST /api/auth/register
POST /api/auth/login
GET  /api/users/me

POST /api/profiles
GET  /api/profiles/me
PUT  /api/profiles/me

POST /api/avatars
GET  /api/avatars/me
GET  /api/avatars/me/attributes

GET  /api/workouts/today
POST /api/workouts/sessions
POST /api/workouts/sessions/{sessionId}/complete
```

## Flutter 首日联调契约

推荐端侧顺序：

```text
POST /api/auth/register 或 POST /api/auth/login
GET  /api/users/me
GET  /api/profiles/me
POST /api/profiles              # 仅在 404 身体档案不存在时创建
GET  /api/avatars/me
POST /api/avatars               # 仅在 404 角色不存在时创建
GET  /api/avatars/me
GET  /api/workouts/today        # 训练页先拉动作、时长和 Unity animationKey
POST /api/workouts/sessions
POST /api/workouts/sessions/{sessionId}/complete
```

关键响应和错误语义：

- Auth 响应包含 `accessToken`、`refreshToken`、`expiresIn`。当前 MVP 的 `refreshToken` 与 `accessToken` 同值，还没有独立刷新接口。
- `GET /api/users/me` 返回 `userId`、`email`、`region`、`language`。
- Profile 响应返回 `profileId`、`userId`、身体指标、`fitnessGoal`、`trainingExperience`、`weeklyTrainingDays`。
- Avatar 响应返回 `avatarId`、外观类型、`bodyType`、`energyState`、`level`、`xp`、`xpToNextLevel`、`attributes`、`equipment`，Flutter 可直接交给 Unity 初始化角色状态。
- 缺失或无效 token 返回 `401`。
- 首次登录用户访问 `GET /api/profiles/me` 返回 `404` 和 `身体档案不存在`，访问 `GET /api/avatars/me` 返回 `404` 和 `角色不存在`。
- 重复注册返回 `409` 和 `邮箱已注册`；重复创建 Profile 返回 `409` 和 `身体档案已存在`；重复创建 Avatar 返回 `409` 和 `角色已存在`。
- 请求校验失败返回 `400` 和 `请求参数不合法`。

训练闭环现在会返回 Unity 可消费的 `WORKOUT_COMPLETE` 事件：

```json
{
  "type": "WORKOUT_COMPLETE",
  "payload": {
    "sessionId": "...",
    "xpGained": 80,
    "levelBefore": 1,
    "levelAfter": 1,
    "attributeDelta": {
      "strength": 2,
      "endurance": 4,
      "core": 3,
      "flexibility": 2,
      "fatBurn": 3,
      "recovery": 1
    },
    "unlockedItems": []
  }
}
```

`POST /api/workouts/sessions/{sessionId}/complete` 是幂等接口。首次完成会更新 XP、等级和属性，并保存完成结果快照；同一个 session 后续重复提交会返回首次完成的同一份结果，不会二次增长，方便 Flutter 在网络重试或 Unity 回调重放时安全联调。

## 规格文档

详见 [../docs/BACKEND_SPEC.md](../docs/BACKEND_SPEC.md)。
