# 3D 游戏化健身 App 项目文档 v0.1

## 1. 项目概述

### 1.1 产品定位

一款同时支持 iOS 和 Android 的 3D 游戏化健身 App。用户通过真实训练、身体数据和持续打卡推动 3D 游戏角色成长。角色既是用户健身状态的可视化映射，也是一个可养成、可装扮、可分享、可商业化的虚拟形象。

核心体验：

> 今天练完，我的角色真的变强了。

### 1.2 产品类型

- 健身训练 App
- 3D 虚拟角色养成 App
- 游戏化习惯养成 App
- 可分享的虚拟形象社交产品
- 课程、皮肤、AI 教练商业化平台

### 1.3 核心目标

- 用 3D 游戏角色增强用户健身动力
- 将真实身体变化和训练行为映射到角色变化
- 通过角色分享形成传播
- 通过皮肤、课程、AI 教练实现商业化

## 2. 目标用户

### 2.1 首批用户

- 18-35 岁用户
- 有健身意愿但缺乏持续动力
- 喜欢游戏化、角色养成、虚拟形象、社交分享
- 健身新手到中级用户
- 对酷感游戏角色、虚拟形象、装备皮肤有兴趣的人

### 2.2 用户动机

- 想坚持健身，但普通打卡缺乏反馈
- 想看到训练成果被可视化表达
- 想拥有一个越来越强的虚拟角色
- 想分享自己的训练成果和角色形象
- 想获得个性化训练和 AI 教练建议

## 3. 产品核心闭环

```text
创建角色
  -> 输入身体数据和目标
  -> 获取训练计划
  -> 跟随 3D 角色完成训练
  -> 后端计算 XP 和属性成长
  -> Unity 展示角色成长反馈
  -> 解锁装备、动作、称号
  -> 生成分享图或短视频
  -> 用户继续训练或付费
```

## 4. MVP 范围

### 4.1 MVP 必做

- 注册 / 登录
- 创建 3D 游戏角色
- 输入身体数据
- 选择健身目标
- 初始角色生成
- 3 分钟测试训练
- 今日训练计划
- 训练动作展示
- 训练完成上报
- XP、等级、6 大属性成长
- 角色成长反馈
- 基础换装 / 皮肤
- 分享入口
- 第三方训练 API 接入
- AI 教练基础入口

### 4.2 MVP 暂不做

- 实时摄像头动作纠错
- 完整社交社区
- 好友系统
- 排行榜
- UGC 课程平台
- 复杂 3D 捏脸
- 高精度人体扫描
- 多人同屏 3D
- 大型开放训练场景
- 复杂赛季通行证

## 5. 首日用户流程

```text
启动页
  -> 登录 / 注册
  -> 创建角色
  -> 输入身体数据
  -> 选择健身目标
  -> 生成初始角色
  -> 3 分钟测试训练
  -> 首次成长反馈
  -> 分享或进入角色主页
```

### 5.1 首日流程目标

- 5 分钟内完成首次体验
- 让用户尽早看到 3D 角色
- 让用户第一次训练后看到角色变化
- 让用户理解训练和角色成长的关系
- 让用户有分享冲动

### 5.2 3 分钟测试训练

首版动作：

- 深蹲
- 开合跳
- 平板支撑
- 拉伸

训练结束后奖励：

- XP 增长
- 1-3 个属性增长
- 新手装备或称号
- 角色成功动作 / 成长动画

## 6. 角色系统

### 6.1 角色风格

- 3D 游戏角色
- 半写实卡通风格
- 偏酷感、力量感、运动机能风
- 不走可爱宠物路线
- 不做高度写实人体扫描

参考气质：

- 健身版游戏 Avatar
- Nike Training + RPG 角色养成
- NBA 2K MyPlayer 的成长感
- Fortnite / Valorant 的皮肤商业化逻辑

### 6.2 双轨成长机制

角色成长分为两条线：

#### 真实身体映射

慢变化，按周或按月更新。

影响因素：

- 身高
- 体重
- 体脂率
- 训练频率
- 健身目标
- 围度数据，后续加入
- 健康数据，后续接入

影响结果：

- 体型档位
- 肌肉线条
- 姿态
- 活力 / 疲劳状态
- 长期身体趋势

#### 训练成就养成

快反馈，每次训练后更新。

影响因素：

- 完成训练
- 训练类型
- 训练时长
- 完成度
- 连续打卡
- 课程完成度

影响结果：

- XP
- 等级
- 6 大属性
- 装备解锁
- 动作解锁
- 称号
- 特效
- 角色表现状态

### 6.3 角色属性

首版 6 大属性：

- 力量 strength
- 耐力 endurance
- 核心 core
- 柔韧 flexibility
- 燃脂 fatBurn
- 恢复 recovery

### 6.4 体型档位

MVP 使用预设档位，不做高精度真实人体建模。

```text
lean
normal
fit
muscular
strong
```

### 6.5 角色状态

```text
tired
normal
confident
peak
```

## 7. 训练和角色映射规则

### 7.1 训练类型和属性影响

| 训练类型 | 主要影响 |
|---|---|
| 力量训练 | 力量、核心、肌肉成长 |
| 有氧训练 | 耐力、燃脂、活力 |
| 核心训练 | 核心、姿态、稳定性 |
| 拉伸训练 | 柔韧、恢复 |
| 恢复训练 | 恢复、疲劳下降 |
| 混合训练 | 多属性小幅增长 |

### 7.2 动作映射示例

| 动作 | 训练类型 | 属性影响 | Unity 动画 Key |
|---|---|---|---|
| 深蹲 | strength | 力量、核心 | workout_squat |
| 俯卧撑 | strength | 力量、核心 | workout_pushup |
| 平板支撑 | core | 核心 | workout_plank |
| 开合跳 | cardio | 耐力、燃脂 | workout_jumping_jack |
| 弓步 | strength | 力量、核心 | workout_lunge |
| 拉伸 | flexibility | 柔韧、恢复 | workout_stretch |

### 7.3 成长计算 v0.1

基础 XP：

```text
base_xp = duration_minutes * 10
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

最终 XP：

```text
xp_gained = base_xp * difficulty_multiplier * completion_multiplier
```

等级经验：

```text
xp_to_next_level = 100 + level * 20 + level^2 * 2
```

属性增长：

```text
attribute_delta = sum(exercise.attribute_impact * completion_ratio)
```

## 8. 主页面结构

### 8.1 5 个主 Tab

```text
角色
训练
课程
教练
我的
```

### 8.2 角色 Tab

功能：

- 3D 角色展示
- 等级和 XP
- 6 大属性
- 当前身体状态
- 今日建议
- 换装入口
- 分享入口
- 后续支持点击身体部位查看训练状态

### 8.3 训练 Tab

功能：

- 今日训练计划
- 预计时长
- 动作列表
- 开始训练
- 训练中倒计时 / 组数 / 休息
- 训练历史

### 8.4 课程 Tab

功能：

- 第三方课程列表
- 免费课程
- 付费课程
- 目标分类：减脂、增肌、塑形、体能
- 课程详情
- 加入计划

### 8.5 教练 Tab

功能：

- AI 对话
- 今日训练建议
- 训练记录分析
- 饮食建议，后续增强
- 角色口吻反馈

### 8.6 我的 Tab

功能：

- 个人资料
- 身体数据
- 成就
- 订单 / 订阅入口
- 语言 / 地区
- 隐私设置
- 退出登录

## 9. 第三方训练 API 接入

### 9.1 接入原则

App 不直接调用第三方 API。

```text
App -> 自有后端 -> 第三方训练 API
```

原因：

- 保护 API Key
- 统一数据结构
- 可缓存内容
- 可替换供应商
- 可做内容审核
- 可映射角色成长规则
- 支持多语言和地区差异

### 9.2 第三方 API 数据类型

- 动作库
- 课程 / 计划
- 分类标签
- 视频 / 动图 / 图片
- 难度
- 器械要求
- 肌群
- 商业授权信息

### 9.3 自有标准动作模型关键字段

```text
exercise_id
name
category
primary_muscle_group
secondary_muscle_groups
training_type
difficulty
equipment
duration
sets
reps
calorie_estimate
attribute_impact
avatar_animation_key
```

### 9.4 动画降级策略

- 有匹配 3D 动画：显示 Unity 角色动作
- 无匹配 3D 动画：显示第三方视频 / 动图
- 后续根据动作使用频率补充 3D 动画

## 10. 商业化设计

### 10.1 皮肤

- 服装
- 鞋子
- 发型
- 配饰
- 背景
- 特效
- 姿势
- 限时活动皮肤
- 打卡限定皮肤

### 10.2 课程

- 第三方课程
- 目标课程包
- 明星教练课程，后续
- 订阅课程，后续

### 10.3 AI 教练

MVP：

- 基础聊天问答
- 根据目标推荐训练
- 根据训练记录给反馈
- 用角色口吻提醒和鼓励

后续：

- 个性化周期计划
- 饮食建议
- 恢复建议
- 训练复盘
- 动作纠错，长期功能

## 11. 技术架构

### 11.1 总体架构

```text
Flutter App
  -> Unity as a Library
  -> Spring Boot 后端
  -> PostgreSQL / Redis / Object Storage
  -> 第三方训练 API
  -> AI 模型服务
```

### 11.2 技术选型

| 模块 | 技术 |
|---|---|
| App | Flutter |
| 3D | Unity as a Library |
| 后端 | Spring Boot 3.x |
| Java | Java 17 或 Java 21 |
| 数据库 | PostgreSQL |
| 缓存 | Redis |
| 文件存储 | S3 / 阿里云 OSS / 腾讯云 COS |
| 数据库迁移 | Flyway / Liquibase |
| 接口文档 | OpenAPI / Swagger |
| 认证 | Spring Security + JWT |
| 支付 | Apple IAP / Google Play Billing / 微信 / 支付宝 |
| AI | 按地区接入 OpenAI 或国内大模型 |

## 12. Spring Boot 后端设计

### 12.1 模块划分

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
payment     订单、订阅、IAP/Google Billing 预留
admin       后台管理预留
```

### 12.2 核心数据表

```text
users
user_profiles
avatars
avatar_attributes
exercises
courses
course_lessons
course_lesson_exercises
workout_sessions
workout_session_exercises
avatar_assets
user_avatar_assets
ai_conversations
ai_messages
orders
subscriptions
```

### 12.3 MVP API

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
PUT  /api/avatars/me/equipment

GET  /api/courses
GET  /api/courses/{courseId}
GET  /api/courses/{courseId}/lessons/{lessonId}

GET  /api/workouts/today
POST /api/workouts/sessions
POST /api/workouts/sessions/{sessionId}/complete
GET  /api/workouts/history

GET  /api/assets
GET  /api/assets/me
POST /api/assets/{assetId}/equip

POST /api/ai/chat
```

### 12.4 训练完成响应示例

```json
{
  "sessionId": "session_001",
  "xpGained": 80,
  "levelBefore": 1,
  "levelAfter": 2,
  "xpAfter": 20,
  "xpToNextLevel": 140,
  "energyState": "confident",
  "attributeDelta": {
    "strength": 2,
    "endurance": 1,
    "core": 1,
    "flexibility": 0,
    "fatBurn": 1,
    "recovery": 0
  },
  "unlockedItems": [
    {
      "type": "outfit",
      "id": "starter_gloves",
      "assetKey": "outfit_starter_gloves"
    }
  ],
  "unityEvent": {
    "type": "WORKOUT_COMPLETE",
    "payload": {
      "xpGained": 80,
      "levelBefore": 1,
      "levelAfter": 2
    }
  }
}
```

## 13. Flutter + Unity 通信设计

### 13.1 通信原则

- Flutter 负责页面和业务流程
- Unity 负责 3D 展示和动画
- 通信使用 JSON
- 后端返回的成长结果可直接转发给 Unity

### 13.2 Flutter -> Unity 指令格式

```json
{
  "type": "COMMAND_TYPE",
  "requestId": "uuid",
  "payload": {}
}
```

### 13.3 Unity -> Flutter 事件格式

```json
{
  "type": "EVENT_TYPE",
  "requestId": "uuid",
  "payload": {},
  "success": true,
  "error": null
}
```

### 13.4 核心指令

```text
SET_AVATAR_STATE
PLAY_ANIMATION
START_EXERCISE
END_EXERCISE
WORKOUT_COMPLETE
CHANGE_OUTFIT
SET_POSE
CAPTURE_SHARE_IMAGE
```

### 13.5 核心事件

```text
UNITY_READY
ANIMATION_STARTED
ANIMATION_FINISHED
OUTFIT_CHANGED
SHARE_IMAGE_CAPTURED
UNITY_ERROR
```

## 14. Unity 工程设计

### 14.1 Unity 目录结构

```text
Assets/
  App/
    Scenes/
      AvatarHomeScene.unity
    Scripts/
      Bridge/
        UnityBridge.cs
        AvatarCommandRouter.cs
        AvatarCommand.cs
        AvatarEvent.cs
      Avatar/
        AvatarController.cs
        AvatarAnimationController.cs
        AvatarAppearanceController.cs
        AvatarGrowthController.cs
        AvatarCaptureController.cs
      Data/
        AvatarStateData.cs
        AvatarAttributesData.cs
        AvatarEquipmentData.cs
        WorkoutCompleteData.cs
        AttributeDeltaData.cs
        UnlockedItemData.cs
      Config/
        AnimationMapConfig.cs
        OutfitMapConfig.cs
      Utils/
        JsonUtil.cs
        UnityEventDispatcher.cs
    Prefabs/
      Avatar/
        AvatarRoot.prefab
      Effects/
        LevelUpEffect.prefab
        AttributeGlowEffect.prefab
    Animations/
    Models/
    Materials/
    Textures/
```

### 14.2 Unity 核心类

| 类 | 职责 |
|---|---|
| UnityBridge | Flutter 和 Unity 的通信入口 |
| AvatarCommandRouter | 解析并分发 JSON 指令 |
| AvatarController | 角色系统总入口 |
| AvatarAnimationController | 动画播放和切换 |
| AvatarAppearanceController | 换装和材质切换 |
| AvatarGrowthController | XP、升级、属性增长表现 |
| AvatarCaptureController | 分享截图 |

### 14.3 第一批动画 Key

```text
idle_default
idle_tired
idle_confident
intro_hero
workout_squat
workout_pushup
workout_plank
workout_jumping_jack
workout_lunge
workout_crunch
workout_burpee
workout_stretch
result_success
result_level_up
result_tired
pose_victory
pose_share_01
```

### 14.4 Prefab 结构

```text
AvatarRoot.prefab
- CharacterModel
- Animator
- OutfitRoot
- ShoesRoot
- AccessoryRoot
- BodyHighlightRoot
- EffectAnchor
```

## 15. 3D 资产需求

### 15.1 MVP 资产

- 1 个 Humanoid 游戏角色模型
- 5-8 个训练动作动画
- 2-3 套服装或材质变体
- 1 个训练空间场景
- 1-2 个升级 / 属性增长特效
- 1 个分享姿势

### 15.2 建议来源

- 采购现成角色模型
- 使用 Mixamo 动画做原型
- 外包定制角色和服装
- 设计师负责风格把控和验收

### 15.3 资产规范

- 使用统一 Humanoid 骨骼
- 动画命名和后端字段一致
- 服装尽量适配同一骨骼
- 首版用换材质和少量换装模型
- 避免复杂布料物理
- 控制移动端包体

## 16. 开发排期

### 16.1 总体阶段

| 阶段 | 时间 | 目标 |
|---|---|---|
| 产品与设计 | 第 1-2 周 | PRD、流程、角色风格、低保真 |
| 3D 验证 | 第 3-5 周 | Unity 角色、动作、嵌入验证 |
| MVP 开发 | 第 6-10 周 | 账号、角色、训练、后端、课程接入 |
| 商业化与分享 | 第 11-12 周 | 换装、分享、课程入口、AI 入口 |
| 测试与上线准备 | 第 13-14 周 | 真机测试、多语言、性能、合规 |

### 16.2 后端 Sprint

#### Sprint 1：账号、档案、角色基础

- Spring Boot 项目初始化
- PostgreSQL 连接
- 数据库迁移工具
- JWT 登录注册
- 用户身体档案
- 创建初始角色
- 获取角色状态和属性
- Swagger 文档

#### Sprint 2：课程、训练、成长计算

- 动作库表
- 课程表
- 第三方 API 适配 mock 版
- 今日训练接口
- 创建训练 session
- 完成训练上报
- XP 和属性成长计算
- 返回 Unity 可消费的成长事件

#### Sprint 3：皮肤、AI、商业化预留

- 皮肤 / 装备列表
- 用户拥有资产
- 装备皮肤
- AI 教练基础聊天接口
- 订单 / 订阅表结构预留
- 后台内容管理预留

### 16.3 Unity Sprint

#### 第 1 周：角色展示和动画跑通

- 创建 Unity 项目
- 搭建 AvatarHomeScene
- 导入 Humanoid 角色
- 导入 5 个训练动画
- 实现动画控制器
- 搭建基础灯光、镜头、训练空间

#### 第 2 周：Flutter 通信和训练反馈

- 实现 UnityBridge
- 实现命令路由
- 接入 PLAY_ANIMATION
- 接入 SET_AVATAR_STATE
- 接入 WORKOUT_COMPLETE
- 增加升级动画和基础特效

#### 第 3 周：换装、截图、移动端测试

- 实现基础换装 / 换材质
- 接入 CHANGE_OUTFIT
- 实现分享截图
- iOS / Android 嵌入测试
- 性能优化

## 17. 团队分工

### 17.1 用户 / 产品负责人

- 产品方向
- 商业模式
- 第三方课程合作
- 市场定位
- 优先级决策

### 17.2 设计师

- 角色风格板
- UI 流程设计
- 角色主页设计
- 训练页设计
- 成长反馈设计
- 皮肤概念
- 分享图模板
- 3D 资产风格验收

### 17.3 后端工程师

- Spring Boot 后端
- 数据库设计
- 用户和认证
- 训练记录
- 成长计算
- 第三方课程 API 适配
- 皮肤资产接口
- AI 教练接口
- 支付预留

### 17.4 3D / Unity 工程

- Unity 角色原型
- 动画系统
- 换装系统
- 训练反馈
- App 通信协议
- 分享截图
- 移动端性能优化
- 3D 资产接入规范

## 18. 风险和应对

### 18.1 主要风险

| 风险 | 说明 | 应对 |
|---|---|---|
| Unity 嵌入 Flutter 稳定性 | iOS / Android 均需测试 | 先做技术原型 |
| 3D 资产质量 | 商业级角色需要美术能力 | 采购 / 外包 + 设计师验收 |
| 动画适配 | 第三方动作和角色动画不完全一致 | 首版只做高频动作 |
| 换装穿模 | 服装和体型变化容易冲突 | MVP 用少量体型和材质换色 |
| 包体过大 | 3D 资源会增加安装包 | 控制首版资源数量 |
| 训练数据准确性 | 用户可能虚假打卡 | MVP 先接受，后续接健康数据 |
| 合规复杂 | 中国和海外隐私、支付不同 | 架构预留，分阶段上线 |
| AI 健身建议风险 | 可能涉及健康安全 | 明确免责声明，限制医疗建议 |

## 19. 第一阶段验收标准

### 19.1 产品验收

- 用户能在 5 分钟内完成首日流程
- 用户理解训练和角色成长的关系
- 训练结束有明确成长反馈
- 角色主页有继续探索动力

### 19.2 技术验收

- App 内能稳定展示 Unity 角色
- 至少支持 5 个训练动作
- 支持 SET_AVATAR_STATE
- 支持 PLAY_ANIMATION
- 支持 WORKOUT_COMPLETE
- 支持 CHANGE_OUTFIT
- 后端能完成注册、建档、建角、训练上报、成长计算
- 中端手机角色页目标 30 FPS 以上

### 19.3 商业化验收

- 皮肤系统有入口
- 课程系统有入口
- AI 教练有入口
- 支付字段和订单表预留

## 20. 下一步行动

### 20.1 立即执行

- 设计师输出角色风格板
- 后端工程师初始化 Spring Boot 项目
- Unity 原型开始验证角色展示和动画
- 产品侧筛选第三方训练 API

### 20.2 下一个文档建议

- `BACKEND_SPEC.md`：后端详细表结构和接口 DTO
- `APP_WIREFRAME.md`：App 页面级需求
- `UNITY_SPEC.md`：Unity 工程和通信协议
- `ASSET_GUIDE.md`：3D 资产采购 / 外包规范
- `SPRINT_PLAN.md`：开发排期和任务看板
