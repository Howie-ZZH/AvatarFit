# FitGame Flutter App

Flutter App 工程目录，当前已实现 MVP 首日流程和 Unity 嵌入边界。

## 已完成

- 启动页：全屏 Mock 3D 角色展示和开始入口。
- 登录 / 注册：邮箱账户表单骨架。
- 创建角色：角色名称、基础类型、风格类型和 Unity 状态同步。
- 身体数据：年龄、身高、体重、训练经验、每周训练天数。
- 健身目标：减脂、增肌、塑形、提升体能、保持健康。
- 初始角色：Lv.1、6 大属性、开始 3 分钟测试训练。
- 测试训练：深蹲、开合跳、平板支撑、拉伸，带倒计时、暂停、跳过、完成。
- 成长反馈：完成训练后更新等级、XP、属性和能量状态。
- 主 Tab：角色、训练、课程、教练、我的。
- Unity 桥接：
  - `MockUnityBridgeService`：无 Unity 工程时用于 App 侧开发。
  - `NativeUnityBridgeService`：预留原生 `MethodChannel` / `EventChannel` 接入真实 Unity as a Library。

## 目录

```text
lib/
  main.dart
  src/
    app/                 App 入口
    theme/               视觉主题
    models/              Avatar / Workout 数据模型
    features/
      onboarding/        首日流程
      training/          3 分钟测试训练
      home/              5 个主 Tab
      unity_bridge/      Flutter <-> Unity JSON 协议
```

## Unity 通道

Flutter 发送命令：

```text
MethodChannel: fitgame/unity_commands
method: postMessage
argument: JSON string
```

Unity / Native 回传事件：

```text
EventChannel: fitgame/unity_events
event: JSON string
```

命令格式遵循 `../docs/UNITY_SPEC.md`：

```json
{
  "type": "START_EXERCISE",
  "requestId": "flutter_1",
  "payload": {
    "exerciseId": "squat_basic",
    "animationKey": "workout_squat",
    "durationSeconds": 45,
    "sets": 2,
    "reps": 12
  }
}
```

## 运行

当前机器未安装 Flutter SDK。安装后在 `app/` 目录执行：

```bash
flutter create .
flutter pub get
flutter run
```

`flutter create .` 用于补齐 `android/`、`ios/` 等平台工程文件，不会替换现有 `lib/` 业务代码。

## 切换真实 Unity

当前 `OnboardingFlow` 默认使用 `MockUnityBridgeService`。接入原生 Unity 模块后，将实例替换为：

```dart
final UnityBridgeService unity = NativeUnityBridgeService();
```

原生 iOS / Android 需要把 `fitgame/unity_commands` 的 `postMessage` 转发给 Unity 场景里的 `UnityBridge.PostMessage`，并把 Unity 事件写入 `fitgame/unity_events`。
