# Unity

Unity 3D 角色工程目录。

## 职责

- 3D 角色展示
- 训练动作播放
- 角色成长反馈
- 换装和材质切换
- 分享截图
- Flutter / Unity JSON 通信

## 当前交付

已按 `../docs/UNITY_SPEC.md` 添加桥接脚本骨架：

```text
Assets/App/Scripts/Bridge/
  UnityBridge.cs
  AvatarCommandRouter.cs
  AvatarCommand.cs
  AvatarEvent.cs
```

`UnityBridge.PostMessage(string json)` 是 Flutter 原生层调用 Unity 的入口。当前 Router 已识别：

- `SET_AVATAR_STATE`
- `PLAY_ANIMATION`
- `START_EXERCISE`
- `WORKOUT_COMPLETE`
- `CHANGE_OUTFIT`

真实 Unity 项目接入时，需要在 `AvatarHomeScene` 中创建一个 GameObject，挂载：

- `UnityBridge`
- `AvatarCommandRouter`

并把 `UnityBridge.commandRouter` 指向同场景里的 Router。后续再把 Router 里的事件分发接到：

- `AvatarAnimationController`
- `AvatarAppearanceController`
- `AvatarGrowthController`
- `AvatarCaptureController`

## Flutter 通信约定

Flutter 原生层接收：

```text
MethodChannel: fitgame/unity_commands
method: postMessage
argument: JSON string
```

Unity 回传事件给 Flutter：

```text
EventChannel: fitgame/unity_events
event: JSON string
```

移动端原生层需要把 Unity 的事件从 `Debug.Log("UNITY_EVENT:...")` 替换或转发为 EventChannel 输出。

当前 `UnityBridge.cs` 已在 Android 非 Editor 环境调用：

```text
com.example.fitgame_app.MainActivity.emitUnityEvent(json)
```

## Android 导出位置

从 Unity 导出 Android Library 后，把导出的 `unityLibrary` 放到：

```text
../app/android/unityLibrary/
```

Flutter Android 工程会自动发现该目录并引入模块。Unity 场景内需要有名为 `UnityBridge` 的 GameObject，并挂载 `UnityBridge.cs`，因为 Android 原生层会调用：

```text
UnitySendMessage("UnityBridge", "PostMessage", json)
```

## iOS 导出位置

从 Unity 导出 iOS Library 后，把导出文件放到：

```text
../app/ios/UnityLibrary/
```

Runner 侧已经实现：

- `fitgame/unity_view` 的 `UiKitView` 宿主
- `fitgame/unity_commands` 到 UnityFramework 的 `sendMessageToGOWithName:functionName:message:`
- `FitGameEmitUnityEvent(json)` 到 Flutter `fitgame/unity_events`

Xcode 中还需要把 `UnityFramework.framework` embed 到 Runner target，并复制 Unity `Data` 资源到 App bundle。

## 规格文档

详见 [../docs/UNITY_SPEC.md](../docs/UNITY_SPEC.md)。
