# Unity 3D 角色系统规格 v0.1

## 1. 目标

Unity 负责 3D 角色展示、动作播放、换装、成长反馈和分享截图。

核心闭环：

```text
Flutter 发送指令
  -> Unity 展示角色
  -> 播放训练动作
  -> 接收训练完成事件
  -> 播放 XP / 升级 / 属性成长反馈
  -> 换装
  -> 截图分享
```

## 2. 技术方案

- Unity as a Library
- 嵌入 Flutter iOS / Android App
- Flutter 和 Unity 使用 JSON 指令通信
- MVP 使用现成 Humanoid 角色和 Mixamo 动画验证
- 后续替换为自有 / 外包商业级资产

## 3. Unity 工程目录

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

## 4. 场景结构

### 4.1 AvatarHomeScene

```text
AvatarHomeScene
- Main Camera
- Directional Light
- Rim Light
- Environment
- AvatarRoot
- EffectRoot
- CaptureCamera
```

### 4.2 场景风格

- 酷感训练空间
- 暗色背景 + 强轮廓光
- 不做复杂大场景
- 重点突出角色轮廓、动作和成长反馈

## 5. Prefab 结构

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

## 6. 核心类职责

| 类 | 职责 |
|---|---|
| UnityBridge | Flutter 和 Unity 的唯一通信入口 |
| AvatarCommandRouter | 解析 JSON 指令并分发 |
| AvatarController | 角色系统总入口，协调子模块 |
| AvatarAnimationController | 管理 Animator 和动作播放 |
| AvatarAppearanceController | 换装、换材质、鞋子、配饰 |
| AvatarGrowthController | XP、升级、属性增长、身体高亮 |
| AvatarCaptureController | 分享截图 |

## 7. 通信协议

### 7.1 Flutter -> Unity 指令

```json
{
  "type": "COMMAND_TYPE",
  "requestId": "uuid",
  "payload": {}
}
```

### 7.2 Unity -> Flutter 事件

```json
{
  "type": "EVENT_TYPE",
  "requestId": "uuid",
  "payload": {},
  "success": true,
  "error": null
}
```

### 7.3 MVP 必做指令

```text
SET_AVATAR_STATE
PLAY_ANIMATION
START_EXERCISE
WORKOUT_COMPLETE
CHANGE_OUTFIT
```

### 7.4 P1 指令

```text
END_EXERCISE
SET_POSE
CAPTURE_SHARE_IMAGE
```

### 7.5 Unity 事件

```text
UNITY_READY
ANIMATION_STARTED
ANIMATION_FINISHED
OUTFIT_CHANGED
SHARE_IMAGE_CAPTURED
UNITY_ERROR
```

## 8. 指令示例

### 8.1 SET_AVATAR_STATE

```json
{
  "type": "SET_AVATAR_STATE",
  "requestId": "req_001",
  "payload": {
    "avatarId": "avatar_001",
    "level": 3,
    "xp": 40,
    "xpToNextLevel": 140,
    "bodyType": "normal",
    "energyState": "confident",
    "attributes": {
      "strength": 12,
      "endurance": 8,
      "core": 10,
      "flexibility": 6,
      "fatBurn": 9,
      "recovery": 7
    },
    "equipment": {
      "outfitId": "outfit_starter_black",
      "shoesId": "shoes_basic_01",
      "accessoryId": null
    }
  }
}
```

### 8.2 PLAY_ANIMATION

```json
{
  "type": "PLAY_ANIMATION",
  "requestId": "req_002",
  "payload": {
    "animationKey": "workout_squat",
    "loop": true,
    "transitionSeconds": 0.2
  }
}
```

### 8.3 START_EXERCISE

```json
{
  "type": "START_EXERCISE",
  "requestId": "req_003",
  "payload": {
    "exerciseId": "squat_basic",
    "animationKey": "workout_squat",
    "durationSeconds": 45,
    "sets": 2,
    "reps": 12
  }
}
```

### 8.4 WORKOUT_COMPLETE

```json
{
  "type": "WORKOUT_COMPLETE",
  "requestId": "req_004",
  "payload": {
    "xpGained": 80,
    "levelBefore": 1,
    "levelAfter": 2,
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
    ]
  }
}
```

### 8.5 CHANGE_OUTFIT

```json
{
  "type": "CHANGE_OUTFIT",
  "requestId": "req_005",
  "payload": {
    "outfitId": "outfit_starter_black",
    "shoesId": "shoes_basic_01",
    "accessoryId": null
  }
}
```

## 9. 动画系统

### 9.1 Animator 策略

MVP 使用 `CrossFade(animationKey)`，避免过早建立复杂 Animator 参数树。

基础状态：

```text
Idle
Workout
Result
Pose
```

### 9.2 第一批动画 Key

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

### 9.3 动画映射

第三方训练动作通过后端字段映射：

```json
{
  "exerciseId": "squat_basic",
  "avatarAnimationKey": "workout_squat"
}
```

如果没有对应动画，Flutter 降级展示第三方视频或动图。

## 10. 角色状态表现

### 10.1 energyState

```text
tired       播放 idle_tired
normal      播放 idle_default
confident   播放 idle_confident
peak        播放 idle_confident + 强光效
```

### 10.2 bodyType

MVP 使用预设档位：

```text
lean
normal
fit
muscular
strong
```

首版可以先不做实时体型变形，用不同模型或 BlendShape 预留。

## 11. 成长反馈

### 11.1 WORKOUT_COMPLETE 表现顺序

```text
播放 result_success
  -> 显示 XP 增长反馈
  -> 播放属性增长光效
  -> 如果升级，播放 result_level_up
  -> 如果解锁装备，展示装备获得反馈
  -> 切到 pose_share_01
```

### 11.2 属性反馈

| 属性 | 表现建议 |
|---|---|
| strength | 上肢 / 全身力量光效 |
| endurance | 呼吸光效、能量环 |
| core | 躯干高亮、姿态稳定 |
| flexibility | 柔和拉伸光效 |
| fatBurn | 燃脂进度光效 |
| recovery | 冷却、恢复、蓝绿色光效 |

## 12. 换装系统

### 12.1 MVP 资产类型

```text
outfit
shoes
accessory
material
```

### 12.2 MVP 实现策略

- 优先用整套 outfit prefab 切换。
- 鞋子和配饰可独立切换。
- 材质变体可作为低成本皮肤。
- 不做复杂布料物理。
- 不做大量体型适配。

## 13. 分享截图

### 13.1 指令

```text
SET_POSE
CAPTURE_SHARE_IMAGE
```

### 13.2 流程

```text
Flutter 发送 SET_POSE
  -> Unity 切换分享姿势
  -> Flutter 发送 CAPTURE_SHARE_IMAGE
  -> Unity 使用 CaptureCamera 截图
  -> 返回 imagePath
  -> Flutter 合成海报或系统分享
```

## 14. JSON 解析建议

Unity `JsonUtility` 对动态嵌套 JSON 支持有限。MVP 建议使用：

```text
Newtonsoft.Json for Unity
```

这样可以稳定解析 `payload` 内的复杂对象。

## 15. 错误处理

必须处理：

- 动画 key 不存在
- outfitId 不存在
- Unity 未 ready
- 截图失败
- 指令 JSON 无法解析
- App 切后台后恢复

错误事件：

```json
{
  "type": "UNITY_ERROR",
  "requestId": "req_002",
  "success": false,
  "payload": {},
  "error": {
    "code": "ANIMATION_NOT_FOUND",
    "message": "Animation key workout_unknown not found"
  }
}
```

## 16. 联调顺序

1. Unity 本地按钮触发 `PLAY_ANIMATION`
2. Flutter 发送 `PLAY_ANIMATION`
3. Flutter 发送 `SET_AVATAR_STATE`
4. 后端返回训练结果
5. Flutter 转发 `WORKOUT_COMPLETE`
6. Unity 播放成长反馈
7. Flutter 发送 `CHANGE_OUTFIT`
8. Unity 回调 `OUTFIT_CHANGED`
9. 增加分享截图

## 17. Unity Sprint

### 第 1 周：角色展示和动画跑通

- 创建 Unity 项目
- 搭建 `AvatarHomeScene`
- 导入 Humanoid 角色模型
- 导入 5 个训练动画
- 实现 `AvatarAnimationController`
- 基础灯光、镜头、训练空间

### 第 2 周：Flutter 通信和训练反馈

- 实现 `UnityBridge`
- 实现 `AvatarCommandRouter`
- 接入 `PLAY_ANIMATION`
- 接入 `SET_AVATAR_STATE`
- 接入 `WORKOUT_COMPLETE`
- 增加升级动画和基础特效

### 第 3 周：换装、截图、移动端测试

- 实现基础换装 / 换材质
- 接入 `CHANGE_OUTFIT`
- 实现分享截图
- iOS / Android 嵌入测试
- 性能优化

## 18. 验收标准

- App 内能稳定展示 Unity 角色
- 支持至少 5 个训练动作
- 支持训练完成成长反馈
- 支持至少 2-3 套皮肤或材质变体
- 能返回 Unity 事件给 Flutter
- 中端手机角色页目标 30 FPS 以上
