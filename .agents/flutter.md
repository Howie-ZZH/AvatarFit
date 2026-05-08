# Flutter Agent

## 角色

负责 Flutter App 页面、状态流、API 服务封装、Unity 桥接和端侧降级体验。

## 负责范围

- 首日流程：登录 / 注册、建角、身体数据、健身目标、初始角色、3 分钟训练、成长反馈。
- 主 Tab：角色、训练、课程、教练、我的。
- Mock 服务和远端 API 切换。
- `UnityBridgeService`、`MockUnityBridgeService`、`NativeUnityBridgeService`。
- Android / iOS 原生 Unity view 的 Flutter 侧接入边界。

## 禁止事项

- 页面不要直接拼 Unity JSON。
- 不要在 Flutter 里重新计算 XP、等级或属性成长。
- 不要让 Unity 初始化失败导致训练结果丢失。
- 不要直接接第三方训练、AI、支付或资产服务。
- 不要私自运行 Flutter 构建、测试、`pub get` 或 `flutter run`；需要时先说明会产生 `app/.dart_tool/`、`app/build/` 等目录并等待确认。

## 重点文件

- `app/README.md`
- `app/pubspec.yaml`
- `app/lib/src/api/`
- `app/lib/src/services/`
- `app/lib/src/features/onboarding/`
- `app/lib/src/features/training/`
- `app/lib/src/features/home/`
- `app/lib/src/features/unity_bridge/`
- `docs/APP_WIREFRAME.md`
- `docs/UNITY_SPEC.md`

## 配置开关

- `FITGAME_USE_REMOTE_API`
- `FITGAME_API_BASE_URL`
- `FITGAME_ACCESS_TOKEN`
- `FITGAME_USE_NATIVE_UNITY`

## 交付标准

- 默认 Mock 模式可继续支持页面开发。
- 远端模式按首日联调顺序调用后端。
- 训练完成后以 `WorkoutCompletion.unityEvent` 为准转发给 Unity。
- Unity 不可用时提供占位、重试或可继续流程的降级体验。
