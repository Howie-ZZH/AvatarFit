# MVP iOS 下一阶段开发计划

## 1. 阶段定位

下一阶段采用 iOS First。目标不是一次性补齐所有 MVP 功能，而是尽快拿到可以实际看到、可以现场演示、可以继续迭代的 iOS 成果。

当前优先级：

```text
iOS 可运行可见 Demo
  -> iOS 调真实后端
  -> iOS 接真实 Unity
  -> 真机演示首日闭环
```

暂缓内容：

- Android 真机联调
- 完整课程体系
- AI 教练真实服务
- 支付 / 订阅
- 完整皮肤资产系统
- 复杂 3D 捏脸和高精度体型映射

## 2. 当前基础判断

项目已经具备 iOS 优先推进的基础：

- Flutter 工程已有首日流程、训练页、成长反馈和主 Tab。
- App 默认可以使用 Mock Unity 角色画面，不依赖 Unity 导出即可看到体验。
- Flutter API 层已支持 Mock / Remote 切换。
- 后端已实现注册、登录、建档、建角、今日训练、创建 session、完成训练、成长计算和幂等。
- iOS 原生层已注册 `fitgame/unity_view`，并预留 `UnityFramework.framework` 动态加载。
- Unity 未接入时，iOS 侧已有降级提示，不会直接阻断 App 展示。

最大风险：

- iOS 构建环境、签名、模拟器或真机配置。
- Unity iOS Library 导出和 Xcode Embed 配置。
- iOS App 访问本地后端时的网络地址、ATS、局域网权限和设备网络。

## 3. 可见成果里程碑

### Demo 0：iOS Flutter 可见 Demo

目标：先看到 App 能在 iOS 上跑起来，完整点通首日体验。

范围：

- 启动 App。
- 进入登录 / 注册页。
- 完成创建角色、身体数据、健身目标。
- 看到 Mock 3D 角色画面。
- 进入 3 分钟测试训练。
- 完成训练。
- 看到成长反馈。
- 进入角色主页。

技术策略：

- 使用 Flutter Mock API。
- 使用 Mock Unity 画面。
- 不依赖后端启动。
- 不依赖 UnityFramework。

验收标准：

- iOS 模拟器或真机能启动 App。
- 首日流程不会卡死。
- 训练完成后能看到 XP、等级或属性变化。
- Unity 未接入不影响 Demo 观看。

建议耗时：0.5-1 天。

### Demo 1：iOS + 真实后端 Demo

目标：让 iOS App 的首日流程改为真实后端数据闭环。

范围：

- 本地启动 Spring Boot 后端。
- iOS App 使用 `FITGAME_USE_REMOTE_API=true`。
- 注册 / 登录调用真实接口。
- `GET /api/profiles/me` 404 时进入建档。
- `GET /api/avatars/me` 404 时进入建角。
- 获取今日训练。
- 创建训练 session。
- 完成训练并上报。
- 直接使用后端返回的 `unityEvent` 驱动成长反馈。

验收标准：

- 后端日志能看到完整请求链路。
- App 展示的 XP、等级、属性来自后端响应。
- 重复点击完成训练不会重复加 XP。
- 后端不可用时 App 有明确错误状态，不丢失本地页面控制权。

建议耗时：1-2 天。

### Demo 2：iOS + UnityFramework Demo

目标：让 iOS App 页面内出现真实 Unity 画面，并响应 Flutter 指令。

范围：

- 在 Unity 中生成或确认 `AvatarHomeScene`。
- 导出 iOS Library 到 `app/ios/UnityLibrary/`。
- 在 Xcode Runner target 中嵌入 `UnityFramework.framework`。
- 复制 Unity `Data` 资源到 App bundle。
- 使用 `FITGAME_USE_NATIVE_UNITY=true` 启动 Flutter。
- Flutter 发送：
  - `SET_AVATAR_STATE`
  - `START_EXERCISE`
  - `WORKOUT_COMPLETE`
  - `CHANGE_OUTFIT`
- Unity 回传事件到 `fitgame/unity_events`。

验收标准：

- iOS 页面内不是 Mock 画面，而是真实 Unity View。
- 角色能响应至少 2 个训练动作或占位动作。
- 完成训练后 Unity 有明确成长反馈。
- Unity 未 ready 或命令失败时，Flutter 有降级反馈。

建议耗时：2-4 天，取决于 Unity 导出和 Xcode 配置问题。

### Demo 3：iPhone 真机演示版

目标：形成可以现场展示的 iPhone MVP。

范围：

- 真机安装 App。
- App 访问同一局域网中的后端。
- 完整走通首日闭环。
- 保留 Mock Unity 回退开关，避免现场因 UnityFramework 问题无法演示。

验收标准：

- 真机首屏 10 秒内可见。
- 训练闭环可在 5 分钟内演示完成。
- 失败时可以切回 Mock Unity 版本继续演示。

建议耗时：1-2 天。

## 4. 任务拆分

### P0：iOS 可运行基线

- 确认 Flutter iOS 依赖可获取。
- 确认 iOS 模拟器或真机可用。
- 跑通 Mock API + Mock Unity 首日流程。
- 记录启动命令、设备名、失败日志。

产出：

- iOS Demo 0 截图或录屏。
- `docs/IOS_DEMO_RUNBOOK.md` 运行手册。

### P0：远端后端联调

- 启动后端本地服务。
- 确认 iOS 模拟器访问 `http://127.0.0.1:8080`。
- 真机访问时改用 Mac 局域网 IP。
- Flutter 使用 `FITGAME_USE_REMOTE_API=true`。
- 补齐 App 对 401、404、409、网络失败的展示。

产出：

- iOS Demo 1 截图或录屏。
- 一组完整联调账号和测试步骤。

### P0：Unity iOS 接入

- 使用 Unity 菜单创建 Demo Scene。
- 导出 iOS Library。
- 在 Xcode 中 Embed `UnityFramework.framework`。
- 验证 `UiKitView` 可以挂载 Unity View。
- 验证 Flutter 命令能到 `UnityBridge.PostMessage`。
- 验证 Unity 事件能回到 Flutter。

产出：

- iOS Demo 2 截图或录屏。
- Unity iOS 接入检查表。

### P1：Demo 打磨

- 训练完成页强化 XP、等级、属性变化展示。
- Unity 不可用时展示更像正式产品的 Mock 角色画面。
- 角色主页补充“今日训练已完成”的状态。
- 分享入口先保留按钮和本地占位图，不阻塞闭环。

产出：

- 更适合展示的 Demo 版本。

## 5. 建议执行顺序

```text
Day 1
  - 跑通 iOS Mock Demo
  - 记录 iOS 运行手册

Day 2
  - 接本地后端
  - 跑通真实注册、建档、建角、训练完成

Day 3
  - 修复 iOS 远端联调问题
  - 增强错误状态和降级体验

Day 4-5
  - Unity 导出 iOS Library
  - Xcode 嵌入 UnityFramework
  - 验证 UiKitView 和命令路由

Day 6
  - 真机联调
  - 录制可演示流程

Day 7
  - Demo 打磨和问题清单收敛
```

## 6. 构建和运行注意事项

按项目规范，运行以下命令前需要确认，因为会产生构建或工具产物。

可能产生的目录或文件：

- `app/build/`
- `app/.dart_tool/`
- `app/ios/Flutter/ephemeral/`
- `backend/target/`
- `.tooling/`

### iOS Mock Demo

```bash
cd app
flutter pub get
flutter run -d ios
```

### iOS 真实后端 Demo

后端：

```bash
cd backend
./mvnw spring-boot:run
```

Flutter：

```bash
cd app
flutter run \
  --dart-define=FITGAME_USE_REMOTE_API=true \
  --dart-define=FITGAME_API_BASE_URL=http://127.0.0.1:8080
```

真机访问本地后端时，`FITGAME_API_BASE_URL` 需要换成 Mac 的局域网 IP，例如：

```text
http://192.168.x.x:8080
```

### iOS Unity Demo

```bash
cd app
flutter run \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```

若同时接真实后端：

```bash
cd app
flutter run \
  --dart-define=FITGAME_USE_REMOTE_API=true \
  --dart-define=FITGAME_API_BASE_URL=http://127.0.0.1:8080 \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```

## 7. 阻塞项清单

需要尽早确认：

- 本机是否安装 Flutter iOS 工具链。
- Xcode 是否可用。
- 是否有可用 iOS 模拟器。
- 是否需要真机签名和 Apple Developer Team。
- Unity 版本是否为 Unity 6.3 LTS，并已安装 iOS Build Support。
- Unity 是否能成功导出 iOS Library。
- 是否允许本地生成构建产物。

## 8. 下一步

建议下一步先执行 Demo 0：

1. 检查 Flutter / Xcode / iOS 设备状态。
2. 在 `app/` 下获取 Flutter 依赖。
3. 启动 iOS Mock Demo。
4. 截图或记录首日流程问题。

如果 Demo 0 能跑通，再进入 Demo 1 接真实后端。不要先处理 UnityFramework，避免把可见成果卡在导出和 Xcode 配置上。
