# FitGame 3D 角色设计交付 Brief

## 1. 背景

当前 App 首屏使用的是 2D 透明角色立绘占位：

```text
app/assets/images/avatar_hero_fitgame.png
unity/Assets/App/Textures/avatar_hero_fitgame.png
```

它只用于快速校准产品视觉方向，不是最终 3D 角色资产。下一步需要设计师 / 3D 美术交付一个可导入 Unity 的真实 3D 角色模型，用于替换当前 2D billboard 和早期几何体占位。

## 2. 目标视觉

角色方向：

- 半写实动漫 / 3D 游戏角色
- 年轻、健康、运动感强
- 黑灰运动服主视觉
- 青绿色科技 / 健身能量高光
- 适合移动端健身 RPG / 角色养成产品
- 首屏看起来像可养成的主角，而不是工具 App 的装饰插画

避免：

- Q 版宠物感
- 胶囊人、机器人、低模方块人
- 过度写实人体扫描
- 复杂盔甲、武器、奇幻装备
- 明显第三方品牌 Logo

## 3. 必须交付

### 3.1 角色模型

```text
格式：FBX 优先，GLB/GLTF 可接受
绑定：Unity Humanoid 可识别骨骼
姿态：T-Pose 或 A-Pose
面数：20k-40k tris，移动端最高不超过 60k tris
```

模型应包含：

- 头发
- 面部
- 上衣
- 短裤
- 压缩裤
- 运动鞋
- 手腕配饰

### 3.2 材质贴图

```text
主贴图：2K，移动端可压到 1K
材质：Unity URP Lit / PBR
贴图：Base Color、Normal、Roughness/Metallic 按需
```

首套配色：

- 主色：黑 / 深灰
- 辅色：青绿色
- 鞋底和小面积细节可用白 / 浅灰

### 3.3 动画

首批至少交付：

```text
idle_default
idle_confident
intro_hero
result_success
result_level_up
workout_squat
workout_jumping_jack
workout_plank
workout_stretch
pose_share_01
```

动画要求：

- 可在 Unity Animator 中播放
- 训练动作可循环
- 动作幅度清晰，适合手机小屏观看
- 不严重穿模
- 可重定向到 Unity Humanoid

## 4. 可选但推荐

### 4.1 换装拆分

如果工期允许，拆成以下部件：

```text
Body
Hair
OutfitTop
OutfitBottom
Leggings
Shoes
WristAccessory
```

MVP 至少支持整套 outfit 替换；鞋子独立替换是 P1。

### 4.2 材质变体

至少给 2 个配色变体：

```text
outfit_starter_black_teal
outfit_training_black_gold
```

用于对应 App 当前状态：

```text
tired      低饱和冷灰
confident  金色能量反馈
peak       高亮青蓝能量反馈
```

## 5. Unity 验收标准

导入 Unity 后需要满足：

- 模型在 `AvatarHomeScene` 居中展示
- 首屏竖屏下全身可见，头部和鞋子不被裁切
- `Lv.1 Rex` 标题和角色不重叠
- 深蹲、开合跳、平板支撑、拉伸动作能被 Flutter 指令触发
- 训练完成后能播放成功 / 升级反馈
- iPhone 模拟器上运行不卡顿
- 分享截图角色清晰，无透明错误和严重锯齿

## 6. 命名规范

建议文件结构：

```text
unity/Assets/App/Models/Avatar/Rex/Rex.fbx
unity/Assets/App/Models/Avatar/Rex/Materials/
unity/Assets/App/Models/Avatar/Rex/Textures/
unity/Assets/App/Animations/Avatar/Rex/
unity/Assets/App/Prefabs/Avatar/AvatarRoot.prefab
```

建议资源名：

```text
rex_base_humanoid.fbx
rex_idle_default.fbx
rex_idle_confident.fbx
rex_intro_hero.fbx
rex_workout_squat.fbx
rex_workout_jumping_jack.fbx
rex_workout_plank.fbx
rex_workout_stretch.fbx
mat_rex_outfit_black_teal
tex_rex_body_basecolor
tex_rex_body_normal
```

## 7. 交付检查清单

- [ ] FBX / GLB 角色模型
- [ ] Unity Humanoid 骨骼可识别
- [ ] T-Pose / A-Pose 源文件
- [ ] 主材质和贴图
- [ ] 至少 10 个 MVP 动画
- [ ] 角色首屏 Unity 预览截图
- [ ] 动作播放录屏
- [ ] 面数、贴图尺寸、材质数量说明
- [ ] 授权 / 商用可用说明

