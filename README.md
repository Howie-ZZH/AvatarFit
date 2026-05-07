# 3D 游戏化健身 App

这是一个 iOS / Android 跨平台健身 App 项目。产品核心是通过真实训练和身体数据驱动 3D 游戏角色成长，让用户在训练后看到角色属性、状态、外观和装备的变化。

## 项目目标

MVP 先验证一个核心闭环：

```text
创建 3D 角色
  -> 完成 3 分钟训练
  -> 角色播放训练动作
  -> 后端计算 XP 和属性成长
  -> Unity 展示成长反馈
  -> 用户换装或分享
```

## 目录结构

```text
docs/                 项目文档
backend/              Spring Boot 后端工程
app/                  Flutter App 工程
unity/                Unity 3D 角色工程
assets/               设计、3D、参考资源
  design/             UI、角色概念、分享图模板
  3d/                 模型、动画、材质、特效资源
  references/         竞品、风格、课程 API 参考
```

## 文档入口

- [项目总计划](docs/PROJECT_PLAN.md)
- [Spring Boot 后端规格](docs/BACKEND_SPEC.md)
- [App 页面需求](docs/APP_WIREFRAME.md)
- [Unity 角色系统规格](docs/UNITY_SPEC.md)
- [3D 资产采购与外包规范](docs/ASSET_GUIDE.md)
- [MVP 开发排期与任务看板](docs/SPRINT_PLAN.md)

## 技术选型

| 模块 | 技术 |
|---|---|
| App | Flutter |
| 3D | Unity as a Library |
| 后端 | Spring Boot 3.x |
| 数据库 | PostgreSQL |
| 缓存 | Redis |
| 文件存储 | S3 / 阿里云 OSS / 腾讯云 COS |
| 认证 | Spring Security + JWT |
| 接口文档 | OpenAPI / Swagger |

## 推荐开发顺序

1. 先做 Unity 技术验证：角色展示、动作播放、训练完成成长反馈。
2. 同时启动 Spring Boot 后端：认证、身体档案、角色状态、训练完成成长计算。
3. 再做 Flutter 骨架：首日流程、Unity 嵌入、训练流程。
4. 最后接入课程 API、AI 教练入口、换装和分享。

## 第一阶段验收标准

- App 内能稳定展示 3D 角色。
- 至少支持 5 个训练动作。
- 用户完成一次训练后能看到 XP 和属性成长。
- Unity 能响应 `SET_AVATAR_STATE`、`PLAY_ANIMATION`、`WORKOUT_COMPLETE`、`CHANGE_OUTFIT`。
- 后端能跑通注册、建档、建角、训练上报、成长计算。
- 中端手机角色页目标 30 FPS 以上。

## 下一步

建议优先创建两个可运行工程：

1. `backend/`：Spring Boot 工程骨架。
2. `unity/`：Unity 角色原型工程。

Flutter 工程可以在 Unity 嵌入方案跑通后再正式初始化，避免早期页面开发和 3D 嵌入方式冲突。
