# iOS Demo 2 验收记录

## 当前结论

Demo 2 的 iOS Native Unity 构建链路已跑通。

已验证：

- `UnityFramework.framework` 已构建在 `app/ios/UnityLibrary/Build/DerivedData/Build/Products/Debug-iphonesimulator/`。
- `flutter build ios --debug --simulator --dart-define=FITGAME_USE_NATIVE_UNITY=true` 构建成功。
- 构建后的 `Runner.app` 已包含：
  - `Frameworks/UnityFramework.framework`
  - `Frameworks/UnityFramework.framework/Data`
  - `Frameworks/UnityFramework.framework/Frameworks/UnityRuntime.framework`
- `flutter run -d B1C6135E-824B-40C9-AAA4-6033624E33D3 --no-resident --dart-define=FITGAME_USE_NATIVE_UNITY=true` 可启动到 iPhone 17 模拟器。
- 模拟器截图已保存到 `artifacts/demo2-native-unity.png`。

## 本次 UI 调整

- 默认隐藏 Unity 调试标签，不再在演示画面展示 `idle_confident` 这类 animation key。
- 角色页和训练页增加底部留白，避免内容被底部导航遮挡。
- 角色页增加“今日训练已完成 / 待完成”状态。
- 角色页增加 XP 升级进度。
- 角色状态本地化展示，例如 `confident` 显示为“自信”。
- 分享按钮增加占位反馈，不再是空点击。

## 验证命令

```bash
cd app
flutter build ios \
  --debug \
  --simulator \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```

```bash
cd app
flutter run \
  -d B1C6135E-824B-40C9-AAA4-6033624E33D3 \
  --no-resident \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```

```bash
cd app
flutter test
```

## 测试结果

- Flutter 测试通过：12 个测试全部通过。
- iOS Native Unity debug simulator build 通过。
- iPhone 17 模拟器启动通过。

## 剩余风险

- 当前 Unity 角色仍是占位模型，适合技术 Demo，不适合作为正式产品视觉。
- 还需要逐条现场验证 Flutter -> Unity 指令：
  - `SET_AVATAR_STATE`
  - `START_EXERCISE`
  - `WORKOUT_COMPLETE`
  - `CHANGE_OUTFIT`
- 还需要逐条现场验证 Unity -> Flutter 事件回传。
- 真机签名、局域网后端地址、iOS 本地网络权限仍需进入 Demo 3 阶段验证。

## 下一步

进入 Demo 3 前，建议先做一次完整录屏验收：

```text
启动 App
  -> 创建角色
  -> 进入角色页
  -> 播放训练动作
  -> 完成训练
  -> 查看 XP / 属性 / Unity 成长反馈
  -> 点击换装
```

录屏通过后，再切到真实后端和真机环境。
