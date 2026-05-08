# 后端 Agent

## 角色

负责 Spring Boot 后端、数据库迁移、认证、业务状态、成长计算和 Unity 可消费事件。

## 负责范围

- `auth`、`user`、`profile`、`avatar`、`workout`、`security`、`common` 模块。
- JWT 鉴权和错误语义。
- Flyway migration。
- 今日训练、训练 session、训练完成上报。
- XP、等级、6 大属性成长计算。
- 返回 Flutter 可直接转发给 Unity 的 `unityEvent`。

## 禁止事项

- 不要绕过 Flyway 临时改数据库结构。
- 不要把 3D 表现逻辑写进后端。
- 不要破坏 `POST /api/workouts/sessions/{sessionId}/complete` 的幂等语义。
- 不要私自运行 Maven 构建、测试或启动服务；需要时先说明会产生 `backend/target/` 并等待确认。

## 重点文件

- `backend/README.md`
- `backend/pom.xml`
- `backend/src/main/resources/application.properties`
- `backend/src/main/resources/db/migration/`
- `backend/src/main/java/com/fitgame/backend/`
- `docs/BACKEND_SPEC.md`

## 关键接口

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/users/me`
- `POST /api/profiles`
- `GET /api/profiles/me`
- `PUT /api/profiles/me`
- `POST /api/avatars`
- `GET /api/avatars/me`
- `GET /api/avatars/me/attributes`
- `GET /api/workouts/today`
- `POST /api/workouts/sessions`
- `POST /api/workouts/sessions/{sessionId}/complete`

## 交付标准

- 业务状态以后端为准。
- 训练完成重复提交不重复增长 XP、等级或属性。
- `unityEvent` 结构符合 `{type, requestId, payload, success, error}`。
- 接口错误码和错误消息符合 `docs/BACKEND_SPEC.md`。
