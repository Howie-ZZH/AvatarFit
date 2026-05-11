# 3D 资产采购与外包规范 v0.1

## 1. 目标

为 3D 游戏化健身 App 的 MVP 准备可落地的角色、动画、服装、场景和特效资产。

首版重点是验证核心体验，不追求一次性完成商业级完整资产库。

```text
一个酷感 3D 游戏角色
  -> 能播放训练动作
  -> 能展示成长反馈
  -> 能换装
  -> 能生成分享图
```

## 1.1 当前角色资产决策

用户已明确要求最终角色达到高保真效果，因此后续不要继续把 Unity primitive / lowfi blockout 当作产品视觉方向。

当前策略：

- 低保真 Unity / Blender blockout：只用于工程占位和链路验证。
- 2D 高质量角色立绘：只用于 App 视觉过渡。
- 正式高保真 3D：优先通过现成 Unity Humanoid 资产、Ready Player Me / VRM 资产或外包定制获得。

关键判断：

- FBX Exporter 不是高保真来源，它只是导入 / 导出工具。
- 高保真的核心是模型、材质、绑定和动画资产本身。
- 如果团队没有 3D 角色美术能力，不应把时间投入到继续手搓几何体角色。

## 1.2 路线 A：现成资产优先

适用于快速做 Demo。

资产来源：

```text
Unity Asset Store
Ready Player Me
VRoid / VRM 生态
BOOTH / Sketchfab / CGTrader 等明确授权平台
```

搜索关键词：

```text
anime male humanoid character
stylized male humanoid character
sportswear male character
rigged humanoid animated male
free anime character humanoid
```

筛选条件：

- 可导入 Unity
- 最好支持 Humanoid
- 风格接近半写实动漫 / 运动主角
- 授权允许当前项目使用，商业化前必须复核许可证
- 材质可调整为黑 / 深灰 + 青绿色
- 面数和贴图适合移动端

成本判断：

- 免费资产可以试，但质量、授权和绑定稳定性不可控。
- 低价付费资产通常更省时间，适合先跑 MVP。
- 外包定制质量最高，但成本和周期明显更高。

## 1.3 现成资产验收清单

购买或下载前先检查：

- [ ] 有 Unity package、FBX、GLB、VRM 或明确 Unity 导入说明
- [ ] 骨骼为 Humanoid 或可转 Humanoid
- [ ] 模型不是静态无骨骼
- [ ] 有正面全身展示图
- [ ] 有材质 / 贴图文件
- [ ] 没有第三方品牌 Logo 或侵权元素
- [ ] 授权允许 Demo / 商业使用，或至少允许内部原型验证
- [ ] 面数不明显超出移动端预算
- [ ] 风格不偏 Q 版宠物、机器人或重甲战士

导入后检查：

- [ ] Unity Avatar 可配置为 Humanoid
- [ ] `idle_default` 可播放或可用 Mixamo / Unity 动画重定向
- [ ] 深蹲、开合跳等动作不严重穿模
- [ ] 竖屏首屏全身可见
- [ ] 黑灰服装和青绿色高光能通过材质调整接近 Rex

## 2. 角色视觉方向

### 2.1 风格

- 3D 游戏角色
- 半写实卡通
- 酷感、力量感、运动机能风
- 比例接近游戏角色，不走 Q 版宠物路线
- 肌肉变化明显，但不追求真实人体扫描

### 2.2 参考气质

- 健身版游戏 Avatar
- Nike Training + RPG 角色养成
- NBA 2K MyPlayer 的成长感
- Fortnite / Valorant 的皮肤商业化逻辑

### 2.3 不建议

- 过度写实人体
- 复杂布料模拟
- 超多自由捏脸参数
- 首版同时做大量体型和服装组合
- 需要高端手机才能运行的高面数角色

## 3. MVP 资产清单

### 3.1 必需资产

- 1 个 Humanoid 游戏角色模型
- 5-8 个训练动作动画
- 2-3 套服装或材质变体
- 1 个训练空间场景
- 1-2 个升级 / 属性增长特效
- 1 个分享姿势

### 3.2 建议动作

首批高频动作：

- 深蹲 `workout_squat`
- 俯卧撑 `workout_pushup`
- 平板支撑 `workout_plank`
- 开合跳 `workout_jumping_jack`
- 弓步 `workout_lunge`
- 卷腹 `workout_crunch`
- 波比跳 `workout_burpee`
- 拉伸 `workout_stretch`

### 3.3 建议展示动作

- 默认站立 `idle_default`
- 疲劳站立 `idle_tired`
- 自信站立 `idle_confident`
- 登场动作 `intro_hero`
- 成功动作 `result_success`
- 升级动作 `result_level_up`
- 分享姿势 `pose_share_01`

## 4. 角色模型规范

### 4.1 格式

优先：

```text
FBX
```

可接受：

```text
GLB / GLTF
```

### 4.2 骨骼

必须：

- Humanoid 骨骼
- 可导入 Unity Humanoid Avatar
- 骨骼命名清晰
- T-Pose 或 A-Pose 标准姿势
- 动画可重定向

不接受：

- 无骨骼静态模型
- 非标准骨骼且无法重定向
- 绑定严重错误

### 4.3 面数和性能

MVP 建议：

```text
角色主体：20k-40k tris
移动端上限：尽量不超过 60k tris
```

纹理建议：

```text
主体贴图：2K
移动端可压缩到 1K
法线 / 粗糙度 / 金属度按需
```

### 4.4 材质

建议使用：

- Unity URP Lit
- PBR 材质
- 尽量减少材质球数量
- 支持材质颜色变体

不建议：

- 复杂自定义 Shader
- 依赖高端设备的透明、毛发、布料 Shader

## 5. 服装和皮肤规范

### 5.1 MVP 分类

```text
outfit      整套衣服
shoes       鞋子
accessory   配饰
material    材质 / 配色变体
```

### 5.2 首版策略

- 优先做整套 outfit 切换。
- 鞋子可以独立切换。
- 配饰数量控制在 1-2 个。
- 材质换色作为低成本皮肤。
- 不做复杂布料物理。

### 5.3 命名规范

```text
outfit_starter_black
outfit_street_01
outfit_power_01
shoes_basic_01
accessory_wristband_01
material_neon_blue
```

### 5.4 穿模要求

服装必须适配：

- 默认体型 `normal`
- 训练动作大幅运动时不能严重穿模
- 深蹲、俯卧撑、开合跳、弓步必须检查

首版如果支持体型档位，至少检查：

```text
normal
fit
muscular
```

## 6. 体型变化规范

### 6.1 MVP 方案

首版不做高精度人体扫描，使用：

- 3-5 个体型预设
- 少量 BlendShape
- 或同骨骼下的模型变体

体型档位：

```text
lean
normal
fit
muscular
strong
```

### 6.2 注意事项

- 体型变化会影响服装权重和穿模。
- MVP 可以先只展示 `normal` 和 `fit`。
- 真实身体映射以周 / 月为单位更新，不需要每天大变。

## 7. 动画规范

### 7.1 格式

优先：

```text
FBX animation
```

要求：

- 可重定向到 Unity Humanoid
- 动作循环点干净
- 训练动作节奏自然
- 起止姿势可平滑过渡

### 7.2 命名规范

```text
idle_default
idle_tired
idle_confident
intro_hero
workout_squat
workout_pushup
workout_plank
workout_jumping_jack
workout_lunge
workout_crunch
workout_burpee
workout_stretch
result_success
result_level_up
result_tired
pose_victory
pose_share_01
```

### 7.3 动画验收

每个训练动作检查：

- 手脚不严重滑动
- 角色重心自然
- 关节不明显扭曲
- 运动幅度符合动作
- 动作循环不突兀
- 移动端播放稳定

## 8. 场景规范

### 8.1 MVP 场景

1 个训练空间即可。

风格：

- 酷感训练空间
- 暗色背景
- 强轮廓光
- 轻量科技感元素
- 不做复杂开放场景

### 8.2 性能要求

- 低面数场景
- 少量动态光
- 优先烘焙或简单灯光
- 移动端 30 FPS 以上

## 9. 特效规范

### 9.1 MVP 特效

- 升级特效 `LevelUpEffect`
- 属性增长特效 `AttributeGlowEffect`

### 9.2 属性特效建议

| 属性 | 表现 |
|---|---|
| strength | 红 / 橙力量光效 |
| endurance | 蓝色能量环 |
| core | 躯干高亮 |
| flexibility | 柔和线条光效 |
| fatBurn | 燃脂火花 / 热量光效 |
| recovery | 蓝绿色恢复光效 |

### 9.3 性能要求

- 控制粒子数量
- 避免全屏高成本后处理
- 支持低端机关闭部分特效

## 10. 资源命名规范

### 10.1 模型

```text
char_base_male_01.fbx
char_base_female_01.fbx
```

### 10.2 服装

```text
outfit_starter_black.fbx
outfit_street_01.fbx
outfit_power_01.fbx
```

### 10.3 动画

```text
anim_workout_squat.fbx
anim_workout_pushup.fbx
anim_result_level_up.fbx
```

### 10.4 材质

```text
mat_outfit_starter_black.mat
mat_skin_default.mat
mat_shoes_basic_01.mat
```

### 10.5 贴图

```text
tex_outfit_starter_black_basecolor.png
tex_outfit_starter_black_normal.png
tex_outfit_starter_black_roughness.png
```

## 11. 采购 / 外包验收清单

### 11.1 角色模型

- 能导入 Unity
- Humanoid 骨骼识别正常
- T-Pose / A-Pose 正常
- 材质贴图完整
- 面数适合移动端
- 动画重定向正常

### 11.2 动画

- 动作命名符合规范
- 循环动作循环点干净
- 动作幅度符合训练动作
- 无严重脚滑
- 无严重关节扭曲
- 可在目标角色上正常播放

### 11.3 服装

- 与默认角色适配
- 不严重穿模
- 材质完整
- 命名符合规范
- 可独立启用 / 禁用

### 11.4 场景

- 移动端性能可接受
- 不依赖复杂插件
- 灯光效果能突出角色
- 资源命名清晰

## 12. 资产来源建议

### 12.1 原型阶段

- 现成 Humanoid 角色模型
- Mixamo 动画
- 简单训练空间场景
- 材质换色做皮肤

### 12.2 商业化阶段

- 外包定制主角
- 外包定制高质量皮肤
- 自有动作库
- 自有品牌风格场景
- 联名皮肤，后续

## 13. 设计师交付物

设计师需要先输出：

- 角色风格板
- 角色三视图或概念图
- 训练空间视觉方向
- 2-3 套皮肤概念
- 成长反馈视觉参考
- 分享图模板

## 14. 第一阶段验收标准

- 一个角色能在 Unity 中稳定展示
- 至少 5 个训练动作可播放
- 至少 2 套皮肤或材质变体可切换
- 升级 / 属性增长有可见反馈
- 分享姿势可用于截图
- iOS / Android 中端机目标 30 FPS 以上
