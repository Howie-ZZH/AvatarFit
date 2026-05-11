# FitGame Rex 3D 角色 Unity 导入检查清单

本文档面向 Unity 集成同学，用于把 Rex 3D 角色资产导入 `AvatarHomeScene`，替换当前 2D billboard / 几何体占位，并接入 Flutter 指令驱动的角色展示、动作播放、换装、成长反馈和分享截图流程。

参考文档：

```text
docs/UNITY_SPEC.md
docs/3D_CHARACTER_DESIGN_BRIEF.md
docs/3D_CHARACTER_MODELING_HANDOFF.md
```

## 1. 导入前资产确认

- [ ] 确认基础模型优先使用 `rex_base_humanoid.fbx`，GLB / GLTF 仅作为补充或回退方案。
- [ ] 确认模型为 Unity Humanoid 可识别骨骼，源姿态为 T-Pose 或 A-Pose。
- [ ] 确认角色总面数目标为 20k-40k tris，移动端最高不超过 60k tris。
- [ ] 确认材质数量优先控制在 3-5 个。
- [ ] 确认主贴图源尺寸为 2K，移动端运行版可压缩到 1K。
- [ ] 确认所有资产无第三方品牌 Logo、近似商标、武器、复杂盔甲或不必要科幻装备。
- [ ] 确认动画至少包含以下 10 个 MVP Clip：

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

## 2. 推荐落盘目录

按项目规格将资产放入 Unity 工程对应目录：

```text
unity/Assets/App/Models/Avatar/Rex/
  rex_base_humanoid.fbx
  Materials/
  Textures/

unity/Assets/App/Animations/Avatar/Rex/
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

unity/Assets/App/Prefabs/Avatar/
  AvatarRoot.prefab
```

- [ ] 模型、动画、材质、贴图不要散落到 `Assets` 根目录。
- [ ] 资源名使用小写加下划线，和配置里的 animation key 保持可读对应关系。
- [ ] 动画 FBX 使用和基础模型一致的骨骼命名、比例和根节点。

## 3. FBX 导入设置

在 `rex_base_humanoid.fbx` 的 Import Settings 中检查：

### 3.1 Model

- [ ] `Scale Factor` 与角色实际尺寸匹配，导入后角色身高和场景相机框架一致。
- [ ] 未出现异常全局缩放，例如角色过小、过大或骨骼比例被压扁。
- [ ] `Read/Write Enabled` 默认关闭；只有运行时确实需要改网格时才开启。
- [ ] Mesh Compression 谨慎开启，确认脸部、手腕、鞋型和青绿色线条没有明显变形。
- [ ] Normals / Tangents 正常导入，法线贴图表现无黑斑、翻面或高光断裂。
- [ ] 不需要的 Camera、Light、空测试物体不随 FBX 导入到最终 Prefab。

### 3.2 Rig

- [ ] `Animation Type` 设置为 `Humanoid`。
- [ ] `Avatar Definition` 对基础模型使用 `Create From This Model`。
- [ ] 点击 `Configure...` 后无红色关键骨骼缺失。
- [ ] T-Pose / A-Pose 校准后肩、肘、膝、踝方向自然。
- [ ] 手指骨骼如已交付，应映射正确；未交付时确认不会影响 MVP 动作播放。

### 3.3 Animation

- [ ] 基础模型 FBX 如不承载动画，可关闭 `Import Animation`。
- [ ] 单独动画 FBX 开启 `Import Animation`。
- [ ] `Loop Time` 仅对训练循环动作开启：

```text
workout_squat
workout_jumping_jack
workout_plank
workout_stretch
idle_default
idle_confident
```

- [ ] `intro_hero`、`result_success`、`result_level_up`、`pose_share_01` 默认不循环。
- [ ] Root Motion 默认按 In Place 处理；除非产品和动画侧明确要求位移，否则不要依赖 Root Motion。
- [ ] 每个 Clip 起止帧准确，无多余空帧和明显顿挫。

## 4. Humanoid Avatar 检查

在 Avatar 配置界面逐项检查：

- [ ] `Head`、`Neck`、`Spine`、`Chest` / `UpperChest`、`Hips` 映射正确。
- [ ] 双臂 `UpperArm`、`LowerArm`、`Hand` 左右没有反向。
- [ ] 双腿 `UpperLeg`、`LowerLeg`、`Foot`、`Toes` 左右没有反向。
- [ ] 角色正面朝向 Unity 前向约定，播放动作时不会背对主相机。
- [ ] 肩部在 A-Pose / T-Pose 校正后不耸肩、不内扣。
- [ ] 膝盖、脚尖方向一致，深蹲和开合跳时不出现膝盖反折。
- [ ] 手腕配饰跟随手腕旋转稳定，不穿入前臂。
- [ ] 预览每个动画时，短裤裤脚、上衣下摆、帽子、腋下、髋部、膝部和鞋底没有严重穿模。

重点动作检查：

- [ ] `workout_squat`：髋部、短裤、膝盖、鞋底接触自然。
- [ ] `workout_jumping_jack`：肩袖、腋下、手腕配饰和脚部落点稳定。
- [ ] `workout_plank`：帽子、上衣下摆、短裤和膝踝角度不崩坏。
- [ ] `workout_stretch`：肩、肘、髋、膝大幅弯曲时不塌陷。

## 5. 材质与贴图导入

推荐材质：

```text
mat_rex_skin
mat_rex_hair_black
mat_rex_outfit_black_teal
mat_rex_shoes_black_teal
mat_rex_eye
```

推荐贴图：

```text
tex_rex_skin_basecolor.png
tex_rex_skin_normal.png
tex_rex_hair_basecolor.png
tex_rex_hair_normal.png
tex_rex_outfit_black_teal_basecolor.png
tex_rex_outfit_black_teal_normal.png
tex_rex_outfit_black_teal_mask.png
tex_rex_shoes_black_teal_basecolor.png
tex_rex_shoes_black_teal_normal.png
tex_rex_eye_basecolor.png
```

导入检查：

- [ ] 材质使用 Unity URP Lit / PBR。
- [ ] Base Color 贴图颜色空间使用 sRGB。
- [ ] Normal 贴图类型设置为 `Normal map`，方向无反转问题。
- [ ] Mask 贴图按工程约定打包 Metallic / Roughness / AO；如未打包，需要在材质说明中标注每张图用途。
- [ ] 青绿色 Emission 如存在，只用于小面积能量线和几何标记，并可在 Unity 中关闭或调低。
- [ ] 移动端运行版贴图压缩到 1K 后，黑灰服装层次、脸部、鞋型和青绿色高光仍可读。
- [ ] 透明材质尽量避免用于头发主体；如使用透明，确认分享截图无透明排序错误。
- [ ] 鞋底白 / 浅灰区域压缩后无明显脏边、色块或锯齿。

移动端建议：

- [ ] iOS 贴图压缩格式使用项目当前移动端默认设置，避免保留未压缩 2K 贴图进入运行包。
- [ ] 小型配饰优先合图，不为腕带等小物件单独占用大贴图。
- [ ] 不为青绿色线条增加大量独立发光材质，避免无意义增加 draw call。

## 6. Animator Controller 配置

建议创建或更新角色 Animator Controller，并由 `AvatarAnimationController` 通过 animation key 触发播放。

基础状态建议：

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

参数建议：

```text
string/enum animationKey 由代码侧映射，不建议直接依赖字符串参数驱动状态机
bool isLooping
trigger playIntroHero
trigger playResultSuccess
trigger playResultLevelUp
trigger playSharePose
```

配置检查：

- [ ] 默认状态为 `IdleDefault`。
- [ ] `IdleDefault` 和 `IdleConfident` 可长时间循环。
- [ ] 训练动作使用可循环状态，并能被停止或切回 idle。
- [ ] 结果动画播放完成后自然回到 `IdleDefault` 或 `IdleConfident`。
- [ ] 转场时间默认控制在 0.15-0.25 秒，和 Flutter `transitionSeconds` 指令保持兼容。
- [ ] 不依赖 Animator 中不可控的自动跳转完成指令响应；代码侧应能明确知道当前播放动作。
- [ ] 播放开始和结束时能触发或配合发送 `ANIMATION_STARTED`、`ANIMATION_FINISHED` 事件。

## 7. 动作映射

`AnimationMapConfig` 中应至少映射以下 Flutter 指令使用的 key：

| animationKey | Clip / State | 是否循环 | 用途 |
|---|---|---:|---|
| `idle_default` | `IdleDefault` | 是 | 首屏默认待机 |
| `idle_confident` | `IdleConfident` | 是 | 状态更好时待机 |
| `intro_hero` | `IntroHero` | 否 | 进入首屏 / 角色展示 |
| `result_success` | `ResultSuccess` | 否 | 训练完成成功反馈 |
| `result_level_up` | `ResultLevelUp` | 否 | 升级反馈 |
| `workout_squat` | `WorkoutSquat` | 是 | 深蹲训练 |
| `workout_jumping_jack` | `WorkoutJumpingJack` | 是 | 开合跳训练 |
| `workout_plank` | `WorkoutPlank` | 是 | 平板支撑训练 |
| `workout_stretch` | `WorkoutStretch` | 是 | 拉伸训练 |
| `pose_share_01` | `PoseShare01` | 否 | 分享截图姿势 |

指令验收：

- [ ] `PLAY_ANIMATION` 可根据 `animationKey` 播放对应动作。
- [ ] `START_EXERCISE` 可映射到训练动作，并按 `loop` 播放。
- [ ] `WORKOUT_COMPLETE` 可触发 `result_success` 或 `result_level_up`。
- [ ] `SET_POSE` 或截图流程可切到 `pose_share_01`。
- [ ] 未知 `animationKey` 返回 `UNITY_ERROR`，不要静默失败。
- [ ] 动作切换时角色不瞬移、不背对相机、不产生异常缩放。

## 8. Prefab 结构

最终 `AvatarRoot.prefab` 应符合 Unity 规格：

```text
AvatarRoot.prefab
- CharacterModel
- Animator
- OutfitRoot
- ShoesRoot
- AccessoryRoot
- BodyHighlightRoot
- EffectAnchor
```

建议层级：

```text
AvatarRoot
  CharacterModel
    Rex_Root
      Body
      Head
      Hair
      OutfitTop
      OutfitBottom
      Leggings
      Shoes
      WristAccessory_L
      WristAccessory_R
  OutfitRoot
  ShoesRoot
  AccessoryRoot
  BodyHighlightRoot
  EffectAnchor
```

检查项：

- [ ] `AvatarRoot` 位于世界原点附近，旋转和缩放归一。
- [ ] `Animator` 绑定在稳定根节点上，Avatar 指向 `rex_base_humanoid` 生成的 Humanoid Avatar。
- [ ] 可换装部件按 `OutfitRoot`、`ShoesRoot`、`AccessoryRoot` 组织，便于 `AvatarAppearanceController` 管理。
- [ ] `BodyHighlightRoot` 预留给属性成长高亮、青绿色能量反馈或部位提示。
- [ ] `EffectAnchor` 放在角色胸口或身体中心附近，用于升级和属性反馈特效挂点。
- [ ] Prefab 中没有测试相机、测试灯光、临时网格或未使用材质实例。
- [ ] Prefab Variant 如用于不同配色，需要命名清晰，例如 `AvatarRoot_Rex_BlackTeal.prefab`。

## 9. AvatarHomeScene 首屏相机验收

目标场景结构：

```text
AvatarHomeScene
- Main Camera
- Directional Light
- Rim Light
- Environment
- AvatarRoot
- EffectRoot
- CaptureCamera
```

首屏检查：

- [ ] `AvatarRoot` 在 `AvatarHomeScene` 中居中展示。
- [ ] 竖屏下全身可见，头部和鞋子不被裁切。
- [ ] `Lv.1 Rex` 标题和角色不重叠。
- [ ] 角色缩小到手机显示尺寸后，脸部、头发轮廓、黑灰服装层次、青绿色高光和鞋型仍可读。
- [ ] 主相机和角色距离稳定，不因播放 `intro_hero`、深蹲、开合跳等动作造成出框。
- [ ] 暗色背景和轮廓光能突出角色，不把黑灰运动服压成一整块。
- [ ] `CaptureCamera` 截图时角色清晰，无透明错误、严重锯齿、裁脚或裁头。
- [ ] `pose_share_01` 中手臂不遮挡脸、胸前识别点或关键服装细节。

建议验收分辨率：

```text
iPhone 竖屏常用比例
小屏设备竖屏
高分辨率设备竖屏
分享截图目标尺寸
```

## 10. iPhone 模拟器性能检查

在接入 Unity as a Library 后，于 iPhone 模拟器进行基础性能验收：

- [ ] App 首屏进入 Unity 角色页无明显卡顿或长时间黑屏。
- [ ] `AvatarHomeScene` 加载后角色、材质和动画均正常显示。
- [ ] 循环播放 `idle_default` 30 秒无明显掉帧、抖动或内存持续上涨。
- [ ] 连续触发 `workout_squat`、`workout_jumping_jack`、`workout_plank`、`workout_stretch`，无 Animator 卡死。
- [ ] 触发 `WORKOUT_COMPLETE` 后成功播放结果动画和升级 / 属性反馈特效。
- [ ] 分享截图流程不会造成明显卡顿、透明异常或截图内容缺失。
- [ ] Profiler 中角色相关 draw call、纹理内存、动画开销符合移动端 MVP 预期。
- [ ] 未出现 FBX 导入警告、材质丢失、Shader 不兼容导致的运行时错误。

性能排查优先级：

1. 先检查贴图是否仍以未压缩 2K 进入运行包。
2. 再检查材质数量和透明材质是否过多。
3. 再检查网格面数是否超过 60k tris。
4. 最后检查 Animator 状态机是否存在频繁重进、重复实例化或事件循环。

## 11. 常见问题处理

### 11.1 Humanoid 映射失败

- [ ] 检查 FBX 是否包含完整骨骼层级和 Skin。
- [ ] 检查左右骨命名是否被导出工具改乱。
- [ ] 在 Avatar Configure 中手动补齐关键骨骼。
- [ ] 如果肩、膝、脚方向异常，回到 DCC 工具修正源姿态和骨骼朝向，不要只在 Unity 中硬调 Prefab 旋转。

### 11.2 动画无法重定向或比例异常

- [ ] 确认动画 FBX 和基础模型使用同一套骨骼命名、比例和根节点。
- [ ] 确认动画导入 Rig 使用 Humanoid，并复用兼容 Avatar。
- [ ] 确认 Root Motion 未意外开启导致角色位移或转向。
- [ ] 检查 Clip 起止帧，避免导入到空动画或错误 Take。

### 11.3 材质丢失或显示偏灰

- [ ] 确认材质已切换到 URP Lit。
- [ ] 确认 Base Color、Normal、Mask 贴图槽位正确。
- [ ] 检查贴图颜色空间，Base Color 使用 sRGB，Normal 使用 Normal map。
- [ ] 检查场景灯光，黑灰服装需要 Directional Light 和 Rim Light 共同拉开层次。

### 11.4 青绿色高光过曝或不可见

- [ ] 如果使用 Emission，降低强度并确认可由材质参数关闭。
- [ ] 如果只用 Base Color，检查暗色背景下是否仍能读出腿部能量线和胸前标记。
- [ ] 不要通过增加大量发光材质或独立小网格解决可读性问题，优先调整贴图明度和灯光。

### 11.5 动作穿模

- [ ] 深蹲优先检查短裤裤脚、髋部和膝部。
- [ ] 开合跳优先检查肩袖、腋下、手腕配饰和鞋底。
- [ ] 平板支撑优先检查帽子、上衣下摆、短裤和膝踝。
- [ ] 拉伸优先检查肩、肘、髋、膝大角度变形。
- [ ] 轻微穿模可通过权重和局部网格调整解决；严重穿模应回到模型 / 绑定 / 动画侧修正。

### 11.6 首屏裁切或标题重叠

- [ ] 先确认 `AvatarRoot` 缩放和位置没有被 Prefab 覆盖。
- [ ] 再调整 `Main Camera` 的距离、FOV / Orthographic Size 和角色竖向偏移。
- [ ] 用 `intro_hero`、`idle_default`、`workout_squat`、`workout_jumping_jack` 分别检查最大动作范围。
- [ ] 确保 `Lv.1 Rex` 标题区域和角色头部在小屏竖屏下不重叠。

### 11.7 Flutter 指令触发后无动作

- [ ] 检查 `AnimationMapConfig` 是否包含对应 `animationKey`。
- [ ] 检查 Animator Controller 中 State 名称和 Clip 绑定。
- [ ] 检查 `AvatarCommandRouter` 是否把 `PLAY_ANIMATION`、`START_EXERCISE`、`WORKOUT_COMPLETE` 分发到 `AvatarAnimationController`。
- [ ] 未知 key 应返回 `UNITY_ERROR`，并在日志中包含 requestId 和 animationKey。

### 11.8 分享截图异常

- [ ] 确认截图前已切到 `pose_share_01`，且动画到达稳定帧。
- [ ] 确认 `CaptureCamera` 的 Layer、Clear Flags、背景和抗锯齿设置正确。
- [ ] 检查透明头发、透明特效或半透明材质是否造成排序错误。
- [ ] 确认角色没有裁头、裁脚，手臂没有遮挡脸和胸前标记。

## 12. 最终导入验收清单

- [ ] `rex_base_humanoid.fbx` 已导入并生成可用 Humanoid Avatar。
- [ ] 10 个 MVP 动画均可在 Unity Animator 中播放。
- [ ] 训练动作可循环，结果动作可播放后回到 idle。
- [ ] Flutter 指令可触发深蹲、开合跳、平板支撑、拉伸、训练完成和分享姿势。
- [ ] 材质贴图接近 Rex 三视图和材质细节设定。
- [ ] `AvatarRoot.prefab` 层级符合项目规格，并预留换装、鞋子、配饰、身体高亮和特效挂点。
- [ ] `AvatarHomeScene` 竖屏首屏全身可见，`Lv.1 Rex` 不与角色重叠。
- [ ] iPhone 模拟器运行不卡顿，无明显导入警告导致的运行时错误。
- [ ] 分享截图角色清晰，无透明错误和严重锯齿。
- [ ] 已记录面数、骨骼数量、材质数量、贴图尺寸、压缩设置和授权 / 商用可用说明。
