# FitGame Rex 3D 角色最终设计包

## 1. 当前状态

Rex 的设计侧工作已进入可交付给 3D 建模 / 绑定 / 动画 / Unity 集成的阶段。

当前 App 里仍使用 2D 角色图作为临时视觉占位，最终目标是替换为 Unity 可用的真实 3D Humanoid 角色。

用户已明确要求高保真角色效果。因此低保真 Unity primitive / Blender blockout 只保留为工程占位，不再作为视觉目标继续打磨。

## 2. 设计参考文件

### 2.1 三视图

```text
assets/design/rex_3view_model_sheet.png
```

用途：

- 锁定角色正面、侧面、背面比例
- 作为建模的第一优先级参考
- 确认发型轮廓、上衣、短裤、压缩裤、鞋子和腕带位置

### 2.2 材质和局部细节板

```text
assets/design/rex_material_detail_sheet.png
```

用途：

- 头发分层
- 帽领和拉链结构
- 黑灰运动布料纹理
- 青绿色高光线条
- 腕带几何标记
- 短裤、压缩裤、鞋面和鞋底细节

### 2.3 当前 App 首屏参考

```text
artifacts/hero-artwork-preview-ios-v2.png
```

用途：

- 确认手机竖屏首屏构图
- 确认 `Lv.1 Rex`、角色全身、FitGame 标题和 CTA 的相对关系
- Unity 首屏集成时需要接近此构图

## 3. 核心文档

```text
docs/3D_CHARACTER_DESIGN_BRIEF.md
docs/3D_CHARACTER_ART_TASKS.md
docs/3D_CHARACTER_MODELING_HANDOFF.md
docs/3D_CHARACTER_ANIMATION_SPEC.md
docs/3D_CHARACTER_UNITY_IMPORT_CHECKLIST.md
docs/3D_CHARACTER_ENGINEERING_INTEGRATION_PLAN.md
```

阅读顺序：

1. `3D_CHARACTER_DESIGN_BRIEF.md`：角色目标、资产格式、动画和验收标准
2. `3D_CHARACTER_ART_TASKS.md`：Day 1-7 执行拆解和里程碑
3. `3D_CHARACTER_MODELING_HANDOFF.md`：建模、材质、绑定、动画和 Unity 交接细节
4. `3D_CHARACTER_ANIMATION_SPEC.md`：10 个 MVP 动画的时长、关键姿势、循环和穿模要求
5. `3D_CHARACTER_UNITY_IMPORT_CHECKLIST.md`：FBX、Humanoid、材质、Animator、Prefab、首屏和性能检查
6. `3D_CHARACTER_ENGINEERING_INTEGRATION_PLAN.md`：资产交付后如何替换当前 2D 占位并接回 Unity

## 4. 已冻结方向

- 角色名：`Rex`
- 风格：半写实动漫 / 3D 游戏角色
- 定位：移动端健身 RPG / 角色养成主角
- 主色：黑 / 深灰
- 高光：青绿色科技健身线条
- 服装：短袖连帽运动外套、短裤、压缩裤、跑鞋、腕带
- 骨骼：Unity Humanoid
- 源姿态：A-Pose 推荐，T-Pose 可接受
- 面数：目标 20k-40k tris，最高不超过 60k tris
- 贴图：源 2K，移动端可压缩到 1K

## 5. 第一版必须交付

```text
rex_base_humanoid.fbx
rex_idle_default.fbx
rex_idle_confident.fbx
rex_intro_hero.fbx
rex_result_success.fbx
rex_result_level_up.fbx
rex_workout_squat.fbx
rex_workout_jumping_jack.fbx
rex_workout_plank.fbx
rex_workout_stretch.fbx
rex_pose_share_01.fbx
```

材质和贴图：

```text
mat_rex_skin
mat_rex_hair_black
mat_rex_outfit_black_teal
mat_rex_shoes_black_teal
mat_rex_eye
```

## 6. 目录结构

```text
unity/Assets/App/Models/Avatar/Rex/
unity/Assets/App/Models/Avatar/Rex/Materials/
unity/Assets/App/Models/Avatar/Rex/Textures/
unity/Assets/App/Animations/Avatar/Rex/
unity/Assets/App/Prefabs/Avatar/AvatarRoot.prefab
unity/Assets/App/Preview/Avatar/Rex/
```

## 7. 通过标准

设计侧完成后，需要满足：

- 3D 建模可直接按三视图开工
- 材质和局部细节可直接按细节板制作
- 动画师可按 10 个 MVP Clip 开工
- Unity 技术美术可按导入清单完成 Prefab 和 Animator
- iPhone 模拟器首屏能接近当前产品截图构图

## 8. 当前剩余动作

- 优先选择或采购一个高质量 Unity Humanoid / VRM / FBX 角色资产
- 如果找不到合适现成资产，再安排 3D 建模同学制作 `rex_base_humanoid.fbx`
- 绑定和动画同学按 MVP Clip 清单制作或适配动作
- Unity 侧替换当前 2D billboard / 临时占位角色
- Unity 侧完成 iPhone 模拟器首屏和训练动作验收

不要继续把 lowfi blockout 当作最终角色方向；它只用于验证工程链路。
