# iOS Demo 2 Unity 接入手册

## 1. Demo 目标

Demo 2 的目标是在 iOS App 中显示真实 Unity View，而不是 Flutter Mock 角色画面。

验收闭环：

```text
iOS App 启动
  -> 角色页显示 Unity View
  -> Flutter 发送 SET_AVATAR_STATE
  -> 训练页发送 START_EXERCISE
  -> 训练完成发送 WORKOUT_COMPLETE
  -> 角色页可发送 CHANGE_OUTFIT
```

真实后端沿用 Demo 1，Unity 先使用占位角色和占位动作。

## 2. 当前状态

已具备：

- Flutter 已支持 `FITGAME_USE_NATIVE_UNITY=true`。
- iOS Runner 已注册 `fitgame/unity_view`。
- iOS Runner 已实现 `UnityFramework.framework` 动态加载。
- iOS Runner 已实现 Flutter -> Unity `postMessage`。
- iOS Runner 已实现 Unity -> Flutter 事件通知监听。
- Unity iOS 插件已提供 `FitGameEmitUnityEvent(json)`，并通过 `NSNotificationCenter` 转发给 Runner。
- Unity 工程已有菜单：
  - `FitGame -> Create Avatar Demo Scene`
  - `FitGame -> Export iOS Library`
  - `FitGame -> Export iOS Device Library`

当前状态：

- 已安装 Unity `6000.3.15f1`，属于 Unity 6.3 LTS。
- 已安装 iOS Build Support。
- Unity 已能批处理导出 iOS Simulator Library 到 `app/ios/UnityLibrary/`。
- Unity 6.3 导出的是 Xcode 工程和 `UnityFramework` target；`UnityFramework.framework` 是后续 Xcode 构建产物，不是导出完成后一定直接出现在目录里的文件。
- Flutter iOS Runner 已加入 `Embed Unity Framework` 构建脚本，会把已构建的 `UnityFramework.framework` 和 Unity `Data` 复制进 `Runner.app/Frameworks/UnityFramework.framework`。

## 3. Unity 安装检查

Unity 目标版本：

```text
Unity 6.3 LTS
```

Unity Hub 安装后，常见检查路径：

```text
/Applications/Unity/Hub/Editor/<Unity 6.3 LTS 具体版本>/Unity.app
```

正常情况下应存在：

```text
/Applications/Unity/Hub/Editor/<Unity 6.3 LTS 具体版本>/Unity.app/Contents/MacOS/Unity
/Applications/Unity/Hub/Editor/<Unity 6.3 LTS 具体版本>/Unity.app/Contents/PlaybackEngines/iOSSupport
```

如果不存在，需要在 Unity Hub 中安装或修复：

1. 打开 Unity Hub。
2. 进入 Installs。
3. 安装 Unity 6.3 LTS。
4. 在模块里勾选：
   - iOS Build Support
   - Mac Build Support，通常默认已有
5. 安装完成后重新打开本项目。
6. Unity 打开项目时会升级 `ProjectSettings/ProjectVersion.txt` 和可能的包/设置文件；这是预期变更，升级前应确认 Git 状态。

## 4. Unity 场景创建

在 Unity Hub 中打开：

```text
/Users/zhangzh/Documents/New project 2/unity
```

等待 Unity 编译完成，Console 不应有红色错误。

执行菜单：

```text
FitGame -> Create Avatar Demo Scene
```

验收：

- Project 中出现：
  ```text
  Assets/App/Scenes/AvatarHomeScene.unity
  ```
- Hierarchy 中出现：
  - `AvatarRoot`
  - `UnityBridge`
  - `Main Camera`
  - `TrainingFloor`
  - `Directional Light`
  - `Rim Light`
- `UnityBridge` 对象挂载：
  - `UnityBridge`
  - `AvatarCommandRouter`
- `AvatarRoot` 对象挂载：
  - `AvatarController`
  - `AvatarAnimationController`
  - `AvatarAppearanceController`
  - `AvatarGrowthController`
  - `AvatarCaptureController`

## 5. 导出 iOS Simulator Library

执行菜单：

```text
FitGame -> Export iOS Library
```

该菜单用于 iPhone 模拟器 Demo，导出时会设置：

```text
PlayerSettings.iOS.sdkVersion = SimulatorSDK
```

真机导出使用：

```text
FitGame -> Export iOS Device Library
```

导出目标：

```text
/Users/zhangzh/Documents/New project 2/app/ios/UnityLibrary
```

导出脚本会先清空该目录，再写入 Unity iOS 导出产物。

导出验收：

- Unity Console 显示：
  ```text
  FitGame iOS Unity export succeeded
  ```
- `app/ios/UnityLibrary/` 中至少出现：
  ```text
  Unity-iPhone.xcodeproj/
  UnityFramework/
  Data/
  Frameworks/UnityRuntime.framework/
  ```
- `Unity-iPhone.xcodeproj` 中存在 target/scheme：
  ```text
  UnityFramework
  ```

说明：

- Unity 6.3 的 `UnityFramework/` 是源码/配置目录，不是最终 framework bundle。
- 最终 `UnityFramework.framework` 需要通过 Xcode 构建 `UnityFramework` target 后产生。
- 如果直接在 `app/ios/UnityLibrary/` 下找不到 `UnityFramework.framework`，不代表导出失败。
- 模拟器导出后，`Unity-iPhone.xcodeproj/project.pbxproj` 中应出现 `SDKROOT = iphonesimulator` 和 `--target-is-simulator`。

如果导出失败，优先检查：

- 是否安装 iOS Build Support。
- Unity Console 是否有 C# 编译错误。
- Xcode command line tools 是否可用。
- `app/ios/UnityLibrary/` 是否有写入权限。

## 6. 构建 UnityFramework

导出后先构建 Unity 的 framework 产物。推荐命令：

```bash
xcodebuild \
  -project app/ios/UnityLibrary/Unity-iPhone.xcodeproj \
  -scheme UnityFramework \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath app/ios/UnityLibrary/Build/DerivedData \
  build
```

验收：

- 构建成功。
- DerivedData 中出现：
  ```text
  app/ios/UnityLibrary/Build/DerivedData/Build/Products/Debug-iphonesimulator/UnityFramework.framework
  ```

## 7. Runner 自动嵌入 UnityFramework

Runner target 已有构建阶段：

```text
Embed Unity Framework
```

该脚本会：

- 从 `app/ios/UnityLibrary/Build/DerivedData/Build/Products/Debug-iphonesimulator/UnityFramework.framework` 复制 framework。
- 将 `app/ios/UnityLibrary/Data` 复制到 `Runner.app/Frameworks/UnityFramework.framework/Data`。
- 对复制后的 `UnityFramework.framework` 重新签名。

Flutter iOS 构建验证：

```bash
cd app
flutter build ios \
  --debug \
  --simulator \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```

构建成功后应存在：

```text
app/build/ios/iphonesimulator/Runner.app/Frameworks/UnityFramework.framework
app/build/ios/iphonesimulator/Runner.app/Frameworks/UnityFramework.framework/Data
```

## 8. Xcode 手动嵌入方案

打开：

```text
/Users/zhangzh/Documents/New project 2/app/ios/Runner.xcworkspace
```

在 Xcode 中：

1. 选择 Runner target。
2. 打开 General。
3. 在 `Frameworks, Libraries, and Embedded Content` 中添加：
   ```text
   UnityFramework.framework
   ```
4. 设置为：
   ```text
   Embed & Sign
   ```
5. 打开 Build Phases。
6. 确认 `UnityFramework.framework` 在 Link/Frameworks 和 Embed Frameworks 阶段。
7. 将 `app/ios/UnityLibrary/Data` 加入 Runner target 的资源复制阶段。
8. 确保最终 App bundle 内存在 Unity `Data` 资源。

说明：

- Runner 代码会从 `Runner.app/Frameworks/UnityFramework.framework` 动态加载 Unity。
- 如果 framework 没有 Embed 到 App bundle，会显示 `UnityFramework is not attached...`。
- 如果 `Data` 路径不对，UnityFramework 可能能加载但画面无法启动。

## 9. Flutter 启动命令

Mock 后端 + 真实 Unity：

```bash
cd app
flutter run \
  -d B1C6135E-824B-40C9-AAA4-6033624E33D3 \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```

真实后端 + 真实 Unity：

```bash
cd app
flutter run \
  -d B1C6135E-824B-40C9-AAA4-6033624E33D3 \
  --dart-define=FITGAME_USE_REMOTE_API=true \
  --dart-define=FITGAME_API_BASE_URL=http://127.0.0.1:8080 \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```

## 10. Demo 2 验收

通过标准：

- App 中不再显示 Flutter Mock 抽象小人。
- App 中不再显示 `UnityFramework is not attached...`。
- 角色页能看到 Unity 画面。
- 训练开始时 Unity 有动作或占位状态变化。
- 训练完成后 Unity 有成长反馈或占位效果。
- 点击“装备新手手套”后 Unity 有换装或颜色变化。

失败排查：

- 看到 `UnityFramework is not attached...`：framework 没有 Embed 到 `Runner.app/Frameworks`。
- 黑屏：检查 Unity `Data` 是否复制到 App bundle。
- 命令无响应：检查 Unity 场景中是否存在名为 `UnityBridge` 的 GameObject。
- Flutter 收不到事件：检查 Unity 是否调用 `FitGameEmitUnityEvent(json)`，以及 Runner 是否监听 `FitGameUnityEvent` 通知。
