# iOS Demo 1 运行手册

## 1. Demo 目标

Demo 1 验证 iOS App 调真实 Spring Boot 后端完成首日闭环：

```text
注册 / 登录
  -> 保存身体档案
  -> 创建角色
  -> 获取今日训练
  -> 创建训练 session
  -> 完成训练上报
  -> 后端计算 XP / 属性成长
  -> App 展示训练完成反馈
```

Unity 仍使用 Mock 画面。真实 UnityFramework 放到 Demo 2。

## 2. 前置条件

- Flutter 已安装：`/Users/zhangzh/develop/flutter`
- Xcode 可用。
- CocoaPods 可用。
- iPhone 17 模拟器可被 Flutter 识别。
- 本地后端使用默认 H2 内存库。

检查命令：

```bash
flutter doctor -v
flutter devices
```

## 3. 启动后端

在 `backend/` 目录执行：

```bash
./mvnw spring-boot:run
```

默认地址：

```text
http://127.0.0.1:8080
```

Swagger：

```text
http://127.0.0.1:8080/swagger-ui.html
```

## 4. 启动 iOS App

在 `app/` 目录执行：

```bash
flutter run \
  -d B1C6135E-824B-40C9-AAA4-6033624E33D3 \
  --dart-define=FITGAME_USE_REMOTE_API=true \
  --dart-define=FITGAME_API_BASE_URL=http://127.0.0.1:8080
```

说明：

- `FITGAME_USE_REMOTE_API=true` 切到真实后端。
- `FITGAME_API_BASE_URL=http://127.0.0.1:8080` 适用于 iOS 模拟器访问 Mac 本机后端。
- iOS 真机需要换成 Mac 的局域网 IP，例如 `http://192.168.x.x:8080`。

## 5. App 验收路径

### 新账号路径

1. 启动 App。
2. 点击开始创建角色。
3. 使用默认生成的演示邮箱注册，或点击“换一个演示账号”生成新邮箱。
4. 输入身体数据。
5. 选择健身目标。
6. 创建角色。
7. 开始 3 分钟测试训练。
8. 点击完成训练。
9. 查看训练完成页。
10. 进入角色主页。

验收点：

- 注册成功后进入身体数据页。
- 保存资料不报错。
- 创建角色不报错。
- 今日训练动作来自后端。
- 完成训练后显示后端返回的 `+80 XP` 和属性成长。

### 已有账号路径

1. 启动 App。
2. 输入已有邮箱和密码。
3. 点击已有账号登录。
4. 继续按页面流程走。

说明：

- 如果身体档案已存在，App 会使用 `PUT /api/profiles/me` 更新。
- 如果角色已存在，App 会读取 `GET /api/avatars/me`。

### 重新开始 Demo

进入主页后，打开“我的”Tab，点击“重新开始 Demo”。

说明：

- App 会清空当前内存里的角色、档案、token 和流程状态。
- 会回到登录 / 注册页。
- 登录页默认邮箱每次会生成唯一值，适合 H2 内存库重启后的新演示。
- 如果后端重启导致旧 token 失效，App 会自动回到登录页并提示重新登录。

## 6. 常见问题

### App 显示网络错误

确认后端是否仍在运行：

```bash
curl -I http://127.0.0.1:8080/swagger-ui.html
```

### iOS HTTP 请求失败

App 已在 `Info.plist` 中配置：

```text
NSAppTransportSecurity -> NSAllowsLocalNetworking = true
```

如果改用局域网 IP 仍失败，确认 Mac 和 iPhone 是否在同一网络，并检查 macOS 防火墙。

### 重复注册失败

重复注册同一个邮箱会返回 `409 邮箱已注册`。Demo 时可以：

- 点击已有账号登录。
- 或改用新邮箱，例如 `demo+时间戳@fitgame.local`。

### 训练完成重复点击

后端完成训练接口是幂等的。同一个 session 重复提交不会重复增加 XP。

## 7. Demo 1 通过标准

- iOS App 能使用真实后端注册或登录。
- 后端日志能看到完整请求链路。
- 训练完成结果来自后端，不使用 MockWorkoutService。
- App 能展示训练完成反馈并进入角色主页。
- Unity 仍为 Mock 画面，但不影响后端闭环验收。
