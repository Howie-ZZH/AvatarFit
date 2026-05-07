# Spring Boot 后端规格 v0.1

## 1. 目标

后端负责支撑 MVP 核心闭环：

```text
用户注册登录
  -> 创建身体档案
  -> 创建 3D 角色
  -> 获取今日训练
  -> 完成训练上报
  -> 计算 XP、等级、属性成长
  -> 返回 Unity 可消费的成长事件
```

后端不负责 3D 表现，只负责业务数据、成长结果和资源状态。

## 2. 技术栈

| 模块 | 技术 |
|---|---|
| 后端框架 | Spring Boot 3.x |
| Java | Java 17 或 Java 21 |
| 数据库 | PostgreSQL |
| 缓存 | Redis |
| 认证 | Spring Security + JWT |
| ORM | MyBatis-Plus 或 Spring Data JPA |
| 数据库迁移 | Flyway 或 Liquibase |
| 接口文档 | OpenAPI / Swagger |
| 文件存储 | S3 / 阿里云 OSS / 腾讯云 COS |
| 定时任务 | Spring Scheduler，后续可换 XXL-JOB |

## 3. 模块划分

```text
auth        登录、注册、JWT
user        用户基础信息、地区、语言
profile     身体数据、健身目标、训练经验
avatar      角色等级、XP、属性、状态、体型
workout     训练记录、动作完成情况
course      第三方课程、动作库、训练计划
growth      XP、等级、属性成长、解锁规则
asset       皮肤、装备、动作、资源
ai          AI 教练对话和上下文
payment     订单、订阅、IAP / Google Billing 预留
admin       后台管理预留
```

## 4. 核心表结构

### 4.1 users

```text
id
email
phone
password_hash
region
language
status
created_at
updated_at
```

说明：

- `region` 用于区分中国区和海外区。
- `language` 首版支持 `zh-CN` 和 `en-US`。
- 手机号登录、微信登录可后续补充。

### 4.2 user_profiles

```text
id
user_id
gender
age
height_cm
weight_kg
body_fat_percentage
fitness_goal
training_experience
weekly_training_days
created_at
updated_at
```

### 4.3 avatars

```text
id
user_id
name
base_type
style_type
body_type
energy_state
level
xp
xp_to_next_level
current_outfit_id
current_shoes_id
current_accessory_id
created_at
updated_at
```

### 4.4 avatar_attributes

```text
id
avatar_id
strength
endurance
core
flexibility
fat_burn
recovery
created_at
updated_at
```

### 4.5 exercises

```text
id
external_provider
external_id
name
name_i18n
description
training_type
primary_muscle_group
secondary_muscle_groups
difficulty
equipment
default_duration_seconds
default_sets
default_reps
calorie_estimate
avatar_animation_key
attribute_impact_json
media_url
status
created_at
updated_at
```

关键字段：

- `avatar_animation_key` 对应 Unity 动画。
- `attribute_impact_json` 描述动作对 6 大属性的影响。

示例：

```json
{
  "strength": 0.8,
  "endurance": 0.2,
  "core": 0.5,
  "flexibility": 0,
  "fatBurn": 0.3,
  "recovery": 0
}
```

### 4.6 courses

```text
id
external_provider
external_id
title
title_i18n
description
goal
difficulty
duration_days
is_paid
price_amount
price_currency
cover_url
status
created_at
updated_at
```

### 4.7 course_lessons

```text
id
course_id
day_index
title
description
estimated_duration_seconds
sort_order
created_at
updated_at
```

### 4.8 course_lesson_exercises

```text
id
lesson_id
exercise_id
sets
reps
duration_seconds
rest_seconds
sort_order
```

### 4.9 workout_sessions

```text
id
user_id
avatar_id
course_id
lesson_id
status
started_at
completed_at
duration_seconds
calories_burned_estimate
xp_gained
growth_result_json
created_at
updated_at
```

### 4.10 workout_session_exercises

```text
id
session_id
exercise_id
sets_planned
reps_planned
duration_planned_seconds
sets_completed
reps_completed
duration_completed_seconds
completed
created_at
updated_at
```

### 4.11 avatar_assets

```text
id
asset_type
name
rarity
asset_key
thumbnail_url
resource_url
price_amount
price_currency
unlock_rule_json
is_paid
status
created_at
updated_at
```

### 4.12 user_avatar_assets

```text
id
user_id
asset_id
acquired_source
acquired_at
equipped
```

### 4.13 ai_conversations

```text
id
user_id
title
created_at
updated_at
```

### 4.14 ai_messages

```text
id
conversation_id
role
content
created_at
```

### 4.15 orders

```text
id
user_id
product_type
product_id
platform
amount
currency
status
external_order_id
created_at
updated_at
```

### 4.16 subscriptions

```text
id
user_id
plan_type
platform
status
started_at
expires_at
created_at
updated_at
```

## 5. 枚举

### 5.1 fitness_goal

```text
fat_loss
muscle_gain
body_shape
endurance
health
```

### 5.2 training_experience

```text
beginner
intermediate
advanced
```

### 5.3 body_type

```text
lean
normal
fit
muscular
strong
```

### 5.4 energy_state

```text
tired
normal
confident
peak
```

### 5.5 training_type

```text
strength
cardio
core
flexibility
recovery
mixed
```

### 5.6 asset_type

```text
outfit
shoes
accessory
material
pose
effect
background
```

## 6. MVP API

Flutter 远端首日最小顺序：

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

`Course`、`Asset`、`AI` 属于后续扩展能力，不应阻塞 Flutter 远端首日闭环。

### 6.1 Auth

```text
POST /api/auth/register
POST /api/auth/login
```

注册请求：

```json
{
  "email": "test@example.com",
  "password": "password123",
  "region": "CN",
  "language": "zh-CN"
}
```

登录响应：

```json
{
  "accessToken": "jwt",
  "refreshToken": "jwt",
  "expiresIn": 7200
}
```

说明：

- 当前 MVP 尚未提供独立刷新接口，`refreshToken` 暂时与 `accessToken` 同值，Flutter 首日流程只依赖 `accessToken`。
- 邮箱会按 trim + lowercase 规范化；重复注册返回 `409`，错误消息为 `邮箱已注册`。
- 登录邮箱或密码错误返回 `401`，错误消息为 `邮箱或密码错误`。
- 除注册、登录、Swagger 和 `/error` 外，所有接口都要求 `Authorization: Bearer <accessToken>`；缺失、过期或无效 token 返回 `401`。

### 6.2 User

```text
GET /api/users/me
```

响应：

```json
{
  "userId": "user_001",
  "email": "test@example.com",
  "region": "CN",
  "language": "zh-CN"
}
```

### 6.3 Profile

```text
POST /api/profiles
GET  /api/profiles/me
PUT  /api/profiles/me
```

请求：

```json
{
  "gender": "male",
  "age": 28,
  "heightCm": 178,
  "weightKg": 75,
  "bodyFatPercentage": 18,
  "fitnessGoal": "muscle_gain",
  "trainingExperience": "beginner",
  "weeklyTrainingDays": 3
}
```

响应：

```json
{
  "profileId": "uuid",
  "userId": "uuid",
  "gender": "male",
  "age": 28,
  "heightCm": 178,
  "weightKg": 75,
  "bodyFatPercentage": 18,
  "fitnessGoal": "muscle_gain",
  "trainingExperience": "beginner",
  "weeklyTrainingDays": 3
}
```

错误语义：

- `GET /api/profiles/me` 在用户尚未建档时返回 `404` 和 `身体档案不存在`，Flutter 可据此进入建档页。
- `POST /api/profiles` 对同一用户重复创建返回 `409` 和 `身体档案已存在`。
- `PUT /api/profiles/me` 在用户尚未建档时返回 `404` 和 `身体档案不存在`。
- 请求校验失败返回 `400` 和 `请求参数不合法`。

### 6.4 Avatar

```text
POST /api/avatars
GET  /api/avatars/me
GET  /api/avatars/me/attributes
```

创建角色请求：

```json
{
  "name": "Rex",
  "baseType": "male",
  "styleType": "balanced"
}
```

角色响应：

```json
{
  "avatarId": "avatar_001",
  "name": "Rex",
  "baseType": "male",
  "styleType": "balanced",
  "bodyType": "normal",
  "energyState": "normal",
  "level": 1,
  "xp": 0,
  "xpToNextLevel": 100,
  "attributes": {
    "strength": 5,
    "endurance": 5,
    "core": 5,
    "flexibility": 5,
    "fatBurn": 5,
    "recovery": 5
  },
  "equipment": {
    "outfitId": "outfit_starter_black",
    "shoesId": "shoes_basic_01",
    "accessoryId": null
  }
}
```

错误语义：

- `GET /api/avatars/me` 在用户尚未建角时返回 `404` 和 `角色不存在`，Flutter 可据此进入建角页。
- `POST /api/avatars` 对同一用户重复创建返回 `409` 和 `角色已存在`。
- `GET /api/avatars/me/attributes` 在用户尚未建角时返回 `404` 和 `角色不存在`。
- 当前已实现创建、获取和属性读取；装备切换接口尚未实现，不应作为首日流程依赖。

### 6.5 Course

```text
GET /api/courses
GET /api/courses/{courseId}
GET /api/courses/{courseId}/lessons/{lessonId}
```

课程列表响应：

```json
{
  "items": [
    {
      "courseId": "course_beginner_001",
      "title": "新手 7 天启动训练",
      "goal": "health",
      "difficulty": "beginner",
      "durationDays": 7,
      "isPaid": false,
      "coverUrl": "https://cdn.example.com/course.png"
    }
  ]
}
```

### 6.6 Workout

```text
GET  /api/workouts/today
POST /api/workouts/sessions
POST /api/workouts/sessions/{sessionId}/complete
```

今日训练响应：

```json
{
  "workoutId": "test_3_minute_foundation",
  "title": "3 分钟基础测试",
  "estimatedDurationSeconds": 155,
  "exercises": [
    {
      "exerciseId": "squat_basic",
      "name": "深蹲",
      "animationKey": "workout_squat",
      "durationSeconds": 45,
      "sets": 2,
      "reps": 12,
      "instruction": "脚跟稳定，膝盖跟随脚尖方向，下蹲后主动站起。"
    }
  ]
}
```

创建训练 Session 响应：

```json
{
  "sessionId": "uuid",
  "status": "in_progress",
  "startedAt": "2026-05-06T13:00:00Z",
  "workout": {
    "workoutId": "test_3_minute_foundation"
  }
}
```

完成训练请求：

```json
{
  "clientRequestId": "req_workout_001",
  "durationSeconds": 155,
  "exercises": [
    {
      "exerciseId": "squat_basic",
      "durationSeconds": 45,
      "setsCompleted": 2,
      "repsCompleted": 12
    }
  ]
}
```

完成训练响应：

```json
{
  "sessionId": "uuid",
  "status": "completed",
  "durationSeconds": 155,
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
  "unlockedItems": [],
  "avatar": {},
  "unityEvent": {
    "type": "WORKOUT_COMPLETE",
    "requestId": "backend_uuid",
    "success": true,
    "payload": {
      "sessionId": "uuid",
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
    },
    "error": null
  }
}
```

完成训练接口必须按 session 幂等处理：首次成功完成后保存增长结果快照；同一个 `sessionId` 后续重复提交返回首次完成时的同一份 `200 OK` 响应，不再次增加 XP、等级或属性。这样 Flutter 的 HTTP 重试、Unity 事件转发重放不会造成重复成长，也不会因为 `409` 阻塞端侧闭环。

训练首日依赖说明：

- `POST /api/workouts/sessions` 要求用户已经创建 Avatar；未建角返回 `404` 和 `角色不存在`。
- `POST /api/workouts/sessions/{sessionId}/complete` 只允许完成当前登录用户自己的 session；找不到或不属于当前用户时返回 `404` 和 `训练 session 不存在`。
- 完成请求可以只传 `clientRequestId`，或不传 body；后端会按今日训练全部动作计算 XP 和属性增量。
- `unityEvent.payload` 包含 `sessionId`、`xpGained`、`levelBefore`、`levelAfter`、`attributeDelta`、`unlockedItems`，可直接转发给 Unity 消费。

### 6.7 Asset

```text
GET  /api/assets
GET  /api/assets/me
POST /api/assets/{assetId}/equip
```

资产响应：

```json
{
  "assetId": "outfit_starter_black",
  "assetType": "outfit",
  "name": "Starter Black",
  "rarity": "common",
  "assetKey": "outfit_starter_black",
  "thumbnailUrl": "https://cdn.example.com/outfits/starter_black.png",
  "owned": true,
  "equipped": true,
  "isPaid": false
}
```

装备响应：

```json
{
  "equipped": true,
  "avatar": {
    "currentOutfitId": "outfit_starter_black",
    "currentShoesId": "shoes_basic_01",
    "currentAccessoryId": null
  },
  "unityEvent": {
    "type": "CHANGE_OUTFIT",
    "payload": {
      "outfitId": "outfit_starter_black",
      "shoesId": "shoes_basic_01",
      "accessoryId": null
    }
  }
}
```

### 6.8 AI

```text
POST /api/ai/chat
```

请求：

```json
{
  "message": "我今天应该练什么？",
  "context": {
    "includeProfile": true,
    "includeAvatar": true,
    "includeRecentWorkouts": true
  }
}
```

响应：

```json
{
  "reply": "你这周力量训练完成得不错，但核心训练偏少。今天建议做一个 12 分钟核心训练。",
  "recommendedWorkoutId": "core_beginner_001"
}
```

## 7. 成长计算规则 v0.1

### 7.1 XP

```text
base_xp = duration_minutes * 10
xp_gained = base_xp * difficulty_multiplier * completion_multiplier
```

难度倍率：

```text
beginner: 1.0
intermediate: 1.2
advanced: 1.5
```

完成度倍率：

```text
100% 完成: 1.0
70%-99% 完成: 0.8
低于 70%: 0.5
```

等级经验：

```text
xp_to_next_level = 100 + level * 20 + level^2 * 2
```

### 7.2 属性增长

```text
attribute_delta = sum(exercise.attribute_impact * completion_ratio)
```

每次训练结果需要同时返回：

- 本次增长 `attributeDelta`
- 增长后总属性 `attributesAfter`
- Unity 成长事件 `unityEvent`

### 7.3 解锁规则

MVP 解锁来源：

- 首次完成训练
- 升级
- 连续训练
- 完成指定课程
- 购买资产，后续接入

### 7.4 已落地的训练 MVP 接口

当前后端已实现最小训练闭环：

```text
GET  /api/workouts/today
POST /api/workouts/sessions
POST /api/workouts/sessions/{sessionId}/complete
```

完成训练后，后端会：

1. 根据默认 3 分钟训练计划计算 XP。
2. 汇总动作对 6 大属性的影响。
3. 更新当前用户的 Avatar 等级、XP、能量状态和属性。
4. 返回 Flutter 可直接转发给 Unity 的 `WORKOUT_COMPLETE` 事件。

`WORKOUT_COMPLETE` 的 payload 包含：

```json
{
  "sessionId": "uuid",
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
```

## 8. 第三方课程 API 适配

### 8.1 接入方式

```text
App -> 自有后端 -> 第三方训练 API
```

### 8.2 适配层职责

- 拉取第三方动作库
- 拉取第三方课程
- 映射到自有动作模型
- 生成 `avatar_animation_key`
- 生成 `attribute_impact_json`
- 做内容缓存
- 处理多语言字段

### 8.3 动画降级

- 有 `avatar_animation_key`：Unity 播放 3D 动作。
- 无 `avatar_animation_key`：App 显示第三方视频或动图。

## 9. Sprint 任务

### Sprint 1：账号、档案、角色基础

- Spring Boot 项目初始化
- PostgreSQL 连接和迁移工具
- JWT 登录注册
- 当前用户接口
- 创建 / 更新身体档案
- 创建初始角色
- 获取角色状态和属性
- Swagger 文档

### Sprint 2：课程、训练、成长计算

- 动作库表和课程表
- 第三方 API 适配 mock 版
- 今日训练接口
- 创建训练 session
- 完成训练上报
- XP、等级、属性成长计算
- 返回 Unity 事件

### Sprint 3：皮肤、AI、商业化预留

- 皮肤 / 装备列表
- 用户拥有资产
- 装备皮肤
- AI 教练基础聊天接口
- 订单 / 订阅表结构预留
- 简单后台管理预留
