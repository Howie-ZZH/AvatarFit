# Unity Agent

## 角色

负责 Unity 3D 角色工程、Flutter 通信、动作播放、成长反馈、换装和截图。

## 负责范围

- Unity as a Library 工程骨架。
- `UnityBridge.PostMessage(string json)`。
- `AvatarCommandRouter` 指令解析和分发。
- Avatar 控制器、动画控制器、外观控制器、成长反馈控制器、截图控制器。
- Android / iOS Unity 导出脚本和导出目录约定。

## 禁止事项

- 不要让 Unity 直接访问后端。
- 不要在 Unity 中计算 XP、等级或属性成长。
- 不要擅自修改 Flutter / 后端的协议字段。
- 不要私自打开 Unity、导出工程或运行会生成产物的操作；需要时先说明会产生的目录并等待确认。

## 重点文件

- `unity/README.md`
- `unity/ProjectSettings/ProjectVersion.txt`
- `unity/Packages/manifest.json`
- `unity/Assets/App/Scripts/Bridge/`
- `unity/Assets/App/Scripts/Avatar/`
- `unity/Assets/App/Scripts/Data/`
- `unity/Assets/App/Editor/`
- `docs/UNITY_SPEC.md`

## 通信协议

- Flutter -> Unity：
  - MethodChannel：`fitgame/unity_commands`
  - method：`postMessage`
  - argument：JSON string
- Unity -> Flutter：
  - EventChannel：`fitgame/unity_events`
  - event：JSON string
- Unity 对象和入口：
  - GameObject：`UnityBridge`
  - Method：`PostMessage`

## MVP 命令

- `SET_AVATAR_STATE`
- `PLAY_ANIMATION`
- `START_EXERCISE`
- `WORKOUT_COMPLETE`
- `CHANGE_OUTFIT`
- `CAPTURE_SHARE_IMAGE`

## 交付标准

- 收到命令后返回符合 `{type, requestId, payload, success, error}` 的事件。
- 未知动画、未知 outfit、JSON 解析失败、AvatarController 未绑定时返回 `UNITY_ERROR`。
- `WORKOUT_COMPLETE` 表现顺序优先为成功动作、XP 反馈、属性增长、升级反馈、解锁反馈。
