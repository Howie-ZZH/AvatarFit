# iOS Demo 3 前置检查

## 当前结论

Demo 3 的模拟器前置链路已通过：

```text
本地 Spring Boot 后端
  -> iOS 模拟器访问真实 API
  -> Flutter 使用 Remote API
  -> Flutter 使用 Native Unity
  -> App 启动成功
```

## 已验证环境

- 当前可用设备：
  - `iPhone 17` 模拟器：`B1C6135E-824B-40C9-AAA4-6033624E33D3`
  - 暂未检测到 iPhone 真机
- Mac 局域网地址：
  - `10.66.0.86`
- 后端本地地址：
  - `http://127.0.0.1:8080`
- 真机后端访问地址建议：
  - `http://10.66.0.86:8080`

## 后端可达性

以下地址均返回 `302` 到 Swagger UI：

```text
http://127.0.0.1:8080/swagger-ui.html
http://10.66.0.86:8080/swagger-ui.html
```

这说明后端不仅本机可访问，也已绑定到局域网地址。真机联调时仍需确认 iPhone 与 Mac 在同一网络，并检查 macOS 防火墙。

## 模拟器启动命令

```bash
cd backend
./mvnw spring-boot:run
```

```bash
cd app
flutter run \
  -d B1C6135E-824B-40C9-AAA4-6033624E33D3 \
  --no-resident \
  --dart-define=FITGAME_USE_REMOTE_API=true \
  --dart-define=FITGAME_API_BASE_URL=http://127.0.0.1:8080 \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```

## 真机启动命令

真机接入后，把设备 ID 换成真实 iPhone，并把 API 地址改成 Mac 局域网 IP：

```bash
cd app
flutter run \
  -d <IPHONE_DEVICE_ID> \
  --dart-define=FITGAME_USE_REMOTE_API=true \
  --dart-define=FITGAME_API_BASE_URL=http://10.66.0.86:8080 \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```

## 截图记录

- 模拟器 Native Unity 截图：`artifacts/demo2-native-unity.png`
- 模拟器 Remote API + Native Unity 截图：`artifacts/demo3-remote-native-unity.png`

## 下一步真机检查表

- 用 USB 或无线调试连接 iPhone。
- 运行 `flutter devices`，确认出现真实 iPhone。
- 在 Xcode Runner target 设置 Team 和 Bundle Identifier。
- 保持后端运行在 Mac 上。
- 用 iPhone Safari 打开 `http://10.66.0.86:8080/swagger-ui.html` 验证网络可达。
- 使用真机启动命令安装 App。
- 完整录屏：
  - 创建角色
  - 保存身体档案
  - 创建初始角色
  - 进入角色页看到真实 Unity
  - 开始训练
  - 完成训练
  - 看到 XP / 属性成长
  - 点击换装

## 剩余阻塞

- 当前没有检测到 iPhone 真机，因此 Demo 3 的真机安装、签名和 iOS 本地网络弹窗还未验证。
- Unity 角色仍是占位模型，需要后续替换为更接近产品视觉的临时健身角色模型。
