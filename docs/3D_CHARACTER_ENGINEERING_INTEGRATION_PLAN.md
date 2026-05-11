# Rex 3D 角色工程接入计划

## 1. 当前工程状态

当前 App 首屏默认使用 Flutter 侧 2D 角色立绘预览，Unity 侧也有同一张透明贴图 billboard 作为临时占位。

用户已明确要求高保真角色。当前工程占位只用于验证接入链路；正式产品视觉应接入现成高质量 Humanoid / VRM / FBX 角色资产，或外包定制 `rex_base_humanoid.fbx`。

已新增真实 3D 角色接入准备：

- Blender 已可用于生成低保真 Rex blockout，当前输出：
  - `unity/Assets/App/Models/Avatar/Rex/rex_lowfi_blockout.blend`
  - `unity/Assets/App/Models/Avatar/Rex/rex_lowfi_blockout_blender.fbx`
  - `unity/Assets/App/Models/Avatar/Rex/rex_lowfi_blockout_blender.glb`
  - 生成脚本放在 `tools/rex_asset_generation/`，不放进 Unity `Assets`
- `AnimationMapConfig`：把 Flutter 的 `animationKey` 映射到 Unity Animator state / clip
- `OutfitMapConfig`：把后端 / Flutter 的 `outfitId` 映射到 Unity outfit prefab / 材质
- `AvatarAnimationController`：有真实 Animator 时播放 Animator state，无 Animator 时回退到临时预览动画
- `AvatarAppearanceController`：支持后续按 outfit 配置换装
- `FitGame -> Prepare Rex 3D Asset Folders`：在 Unity 中创建 Rex 资源目录和占位配置
- `AvatarRoot` 场景结构已预留 `CharacterModel`、`OutfitRoot`、`ShoesRoot`、`AccessoryRoot`、`BodyHighlightRoot`、`EffectAnchor`

## 2. 资产到位后的接入顺序

### Step 1：放入资产

当前低保真 blockout 已存在，可先用于导入测试：

```text
unity/Assets/App/Models/Avatar/Rex/rex_lowfi_blockout_blender.fbx
unity/Assets/App/Models/Avatar/Rex/rex_lowfi_blockout_blender.glb
```

高保真阶段优先使用下载 / 购买 / 外包交付的生产资产：

```text
unity/Assets/App/Models/Avatar/Rex/rex_base_humanoid.fbx
unity/Assets/App/Models/Avatar/Rex/Materials/
unity/Assets/App/Models/Avatar/Rex/Textures/
unity/Assets/App/Animations/Avatar/Rex/
```

如果资产来自 VRM：

```text
unity/Assets/App/Models/Avatar/Rex/Rex.vrm
```

需要先安装并配置 UniVRM，再按 Unity 导入检查文档接入。

动画文件：

```text
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

### Step 2：Unity 导入检查

按以下文档执行：

```text
docs/3D_CHARACTER_UNITY_IMPORT_CHECKLIST.md
```

必须先确认：

- `rex_base_humanoid.fbx` 可识别为 Humanoid
- 10 个动画 Clip 可播放
- 材质贴图接近三视图和材质细节板
- 训练动作无严重穿模

### Step 3：创建 Animator Controller

建议状态名：

```text
IdleDefault
IdleConfident
IntroHero
ResultSuccess
ResultLevelUp
WorkoutSquat
WorkoutJumpingJack
WorkoutPlank
WorkoutStretch
PoseShare01
```

把 Controller 绑定到 `AvatarRoot/CharacterModel/Rex_Root` 或稳定的角色根节点。

### Step 4：配置 AnimationMapConfig

在 Unity 中执行：

```text
FitGame -> Prepare Rex 3D Asset Folders
```

生成后编辑：

```text
unity/Assets/App/Config/Rex/RexAnimationMapConfig.asset
```

映射关系：

```text
idle_default          -> IdleDefault
idle_confident        -> IdleConfident
intro_hero            -> IntroHero
result_success        -> ResultSuccess
result_level_up       -> ResultLevelUp
workout_squat         -> WorkoutSquat
workout_jumping_jack  -> WorkoutJumpingJack
workout_plank         -> WorkoutPlank
workout_stretch       -> WorkoutStretch
pose_share_01         -> PoseShare01
```

### Step 5：替换 AvatarHomeScene

在 `AvatarHomeScene` 中：

- 删除 / 隐藏 `HeroAvatarBillboard`
- 将 `rex_base_humanoid` 或 `AvatarRoot.prefab` 放入 `AvatarRoot/CharacterModel`
- 在 `AvatarAnimationController` 上绑定 Animator 和 `RexAnimationMapConfig`
- 在 `AvatarAppearanceController` 上绑定 `RexOutfitMapConfig` 和 `OutfitRoot`
- 保持 `AvatarController`、`AvatarCommandRouter`、`UnityBridge` 现有通信链路不变

### Step 6：Flutter 侧切回原生 Unity

当前 Flutter 默认启用 2D 角色预览：

```text
FITGAME_USE_HERO_ARTWORK_PREVIEW=true
```

完成 Unity 3D 角色接入后，运行时改为：

```bash
flutter run \
  -d <device-id> \
  --dart-define=FITGAME_USE_HERO_ARTWORK_PREVIEW=false \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```

## 3. 验收命令

Flutter：

```bash
cd app
env HOME=/Users/zhangzh/Documents/New\ project\ 2/.tooling/home flutter analyze
env HOME=/Users/zhangzh/Documents/New\ project\ 2/.tooling/home flutter test
```

Unity：

```text
FitGame -> Rebuild Avatar Scene and Export iOS Library
```

iOS：

```bash
cd app
env HOME=/Users/zhangzh/Documents/New\ project\ 2/.tooling/home \
flutter run -d <iPhone simulator id> \
  --dart-define=FITGAME_USE_HERO_ARTWORK_PREVIEW=false \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```

## 4. 回退策略

如果 3D 资产导入或 UnityLibrary 导出失败：

- 保留当前 Flutter 2D 角色预览
- 不阻塞登录、训练、成长和首页演示流程
- 修复 Unity 资产后再切回原生 Unity
