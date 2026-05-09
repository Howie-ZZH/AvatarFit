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

在 `app/` 目录执行：

```bash
flutter pub get
flutter run
```

使用真实后端：

```bash
flutter run \
  --dart-define=FITGAME_USE_REMOTE_API=true \
  --dart-define=FITGAME_API_BASE_URL=http://127.0.0.1:8080
```

本地联调地址按运行环境选择：

- iOS 模拟器：`http://127.0.0.1:8080`
- iPhone 真机：Mac 的局域网 IP，例如 `http://192.168.x.x:8080`
- Android 模拟器：`http://10.0.2.2:8080`
- Android 真机：Mac 的局域网 IP，例如 `http://192.168.x.x:8080`

iOS 工程已为本地 HTTP 调试配置 `NSAllowsLocalNetworking`。真机访问本机后端时，需要确保手机和 Mac 在同一网络，且 macOS 防火墙允许访问 8080 端口。

## 切换真实 Unity

当前默认使用 Mock Unity。Android 接入真实 Unity 导出模块后，用 Dart define 切换：

```bash
flutter run \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```

真实 Unity 导出模块放置位置：

```text
app/android/unityLibrary/
```

Android Gradle 会在该目录存在时自动 `include(":unityLibrary")` 并让 `:app` 依赖它。Flutter 的 `UnityAvatarView` 会切换成 `AndroidView(viewType: "fitgame/unity_view")`，Android 原生层负责创建 UnityPlayer 并挂载到页面内。

原生 Android 通道：

- `fitgame/unity_commands`：Flutter 调用 `postMessage`，转发到 Unity 场景里的 `UnityBridge.PostMessage`
- `fitgame/unity_events`：Unity 调用 `MainActivity.emitUnityEvent(json)`，回传给 Flutter

如果 `FITGAME_USE_NATIVE_UNITY=true` 但没有 `unityLibrary`，页面会显示 Unity runtime 未接入，并通过事件流返回 `UNITY_UNAVAILABLE`。

### iOS

iOS 平台工程已生成，并注册了同一个 `fitgame/unity_view`。Flutter 的 `UnityAvatarView` 在 iOS 会切换为：

```dart
UiKitView(viewType: 'fitgame/unity_view')
```

iOS 原生层会动态查找并加载：

```text
Runner.app/Frameworks/UnityFramework.framework
```

Unity 导出文件先放到：

```text
app/ios/UnityLibrary/
```

然后在 Xcode 的 Runner target 中把 `UnityFramework.framework` 加入 `Frameworks, Libraries, and Embedded Content`，设置为 `Embed & Sign`，并把 Unity `Data` 资源复制到 App bundle。

iOS 事件回传使用 Unity C# 调用：

```csharp
FitGameEmitUnityEvent(json)
```

对应 Swift 侧 `@_cdecl("FitGameEmitUnityEvent")` 会把事件写回 `fitgame/unity_events`。
