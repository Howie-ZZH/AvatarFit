# Unity iOS Library

将 Unity 导出的 iOS Library 放在这个目录下。

推荐导出结构：

```text
ios/UnityLibrary/
  UnityFramework.framework
  Data/
  NativeCallProxy.h
  NativeCallProxy.mm
```

当前 Runner 侧使用动态加载方式查找：

```text
Runner.app/Frameworks/UnityFramework.framework
```

因此接入真实 Unity 导出后，需要在 Xcode 的 Runner target 中完成：

- 将 `UnityFramework.framework` 加入 `Frameworks, Libraries, and Embedded Content`
- 设置为 `Embed & Sign`
- 将 Unity `Data` 资源复制进 App bundle，保持 UnityFramework 能按导出配置找到数据包
- 确保 Unity 场景中存在名为 `UnityBridge` 的 GameObject，并挂载 `UnityBridge.cs`

Flutter 运行开关：

```bash
flutter run --dart-define=FITGAME_USE_NATIVE_UNITY=true
```
