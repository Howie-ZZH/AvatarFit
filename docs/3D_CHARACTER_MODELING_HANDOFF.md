# FitGame Rex 3D 角色建模交接文档

本文档面向 3D 建模、绑定、动画和 Unity 导入同学，用于把已冻结的 Rex 三视图推进为 Unity 可用的移动端 Humanoid 角色资产。视觉方向以 `assets/design/rex_3view_model_sheet.png` 为第一优先级，局部细节以 `assets/design/rex_material_detail_sheet.png` 为补充，执行规格以 `docs/3D_CHARACTER_DESIGN_BRIEF.md` 和 `docs/3D_CHARACTER_ART_TASKS.md` 为准。

## 0. 参考材料

开始建模前必须查看：

```text
assets/design/rex_3view_model_sheet.png
assets/design/rex_material_detail_sheet.png
app/assets/images/avatar_hero_fitgame.png
artifacts/hero-artwork-preview-ios-v2.png
docs/3D_CHARACTER_DESIGN_BRIEF.md
docs/3D_CHARACTER_ART_TASKS.md
```

其中 `rex_3view_model_sheet.png` 用于比例、轮廓和正侧背结构；`rex_material_detail_sheet.png` 用于头发分层、帽领、拉链、布料纹理、腕带、短裤、压缩裤、鞋面和鞋底细节。

## 1. 已冻结视觉方向

角色名称：`Rex`

角色定位：

- 半写实动漫 / 3D 游戏主角，不做 Q 版、机器人、胶囊人或低模占位风格。
- 年轻、健康、轻运动员体型，整体气质干净、自信、适合健身 RPG / 角色养成首屏。
- 手机竖屏首屏中需要全身可读，头发轮廓、上衣层次、腿部能量线和鞋型都要在缩小后仍可识别。

冻结外观要点：

- 头部：黑色短碎发，顶部和后脑有分层发束，发型外轮廓偏蓬松但不能过度尖刺化。
- 面部：动漫化年轻男性，眼睛偏大，鼻口简化，中性微笑或轻自信表情；避免过度写实皮肤毛孔和强硬肌肉脸。
- 上衣：黑 / 深灰短袖连帽运动外套，正面拉链，帽子体积明确，胸前保留小面积青绿色几何识别标记；袖口和侧边有青绿色线条。
- 下装：黑 / 深灰运动短裤，外侧有青绿色竖向条纹和小几何标记；下方搭配黑色压缩裤。
- 腿部：压缩裤贴身，侧小腿有青绿色能量线，造型要跟随腿部结构，不做厚重护甲。
- 鞋子：黑色运动鞋，白 / 浅灰中底，青绿色鞋面细节和鞋底点缀；鞋型偏跑鞋，不加第三方品牌 Logo。
- 手腕：双腕黑色运动腕带，青绿色小标记或细线，可作为轻量配饰。
- 主色比例：黑 / 深灰为主，青绿色为识别高光，白 / 浅灰只用于鞋底和少量分层。

禁止项：

- 不出现任何第三方品牌 Logo 或近似商标。
- 不加入武器、复杂盔甲、机械外骨骼、夸张科幻装备。
- 不把青绿色高光做成大面积发光盔甲；它应是运动科技感点缀。
- 不依赖复杂布料模拟完成基本轮廓，MVP 需要稳定可导入 Unity。

## 2. 模型拆分

目标规格：

- 格式：FBX 优先，GLB / GLTF 可作为补充。
- 骨骼：Unity Humanoid 可识别。
- 姿态：T-Pose 或 A-Pose，推荐 A-Pose 便于肩部权重。
- 面数：目标 20k-40k tris，移动端最高不超过 60k tris。
- 材质球：MVP 建议 3-5 个，避免过多 draw call。

推荐拆分：

```text
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
```

拆分要求：

- `Body` 包含头颈以下基础身体网格；如服装完全覆盖区域可保留简化体块，避免动作时露洞。
- `Head` 与 `Body` 可合并或分离，但需保证脖子和下颌变形自然。
- `Hair` 独立，便于后续替换发型；发束使用低成本片状 / 块面结构，不使用高透明复杂发片作为主方案。
- `OutfitTop` 包含短袖连帽外套、拉链、袖口、下摆和帽子；帽子可作为同一网格，也可拆成子网格，但需要跟随上胸 / 颈部动作稳定。
- `OutfitBottom` 包含运动短裤；裤脚需要给深蹲、平板支撑和开合跳留足变形空间。
- `Leggings` 为压缩裤，建议和腿部权重一致；青绿色线条可贴图实现，避免大量凸起几何。
- `Shoes` 左右可合并为一个对象；鞋舌、鞋带和鞋底尽量控制细节数量。
- `WristAccessory_L/R` 独立，便于后续换装；需绑定到手腕骨骼，避免手腕旋转时穿入前臂。

MVP 可接受方案：

- 身体、头部、头发、整套服装、鞋、腕带分为少量网格。
- 至少保证整套 outfit 后续可以整体替换。
- 鞋子独立替换是 P1，但第一版建议保留独立对象。

拓扑重点：

- 肩、肘、手腕、髋、膝、踝、脖子必须有足够环线支持训练动作。
- 短裤裤脚、上衣下摆、帽子和手腕配饰是主要穿模风险点，需要在绑定测试中重点检查。
- 青绿色线条优先通过贴图和轻微法线表现，不建议用过多凸起小零件。

## 3. 材质与贴图清单

Unity 目标材质：URP Lit / PBR。

贴图尺寸：

- 源贴图：2K。
- 移动端运行版：可压缩到 1K。
- 小型配饰贴图可合图，不单独占用 2K。

首套冻结配色：

```text
outfit_starter_black_teal
```

推荐材质清单：

```text
mat_rex_skin
mat_rex_hair_black
mat_rex_outfit_black_teal
mat_rex_shoes_black_teal
mat_rex_eye
```

推荐贴图清单：

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

贴图通道建议：

- `Base Color`：负责黑 / 深灰层次、青绿色识别线、皮肤、眼睛和鞋底颜色。
- `Normal`：负责衣料纹理、拉链、鞋面织物、轻微褶皱和鞋底结构。
- `Mask`：按 Unity 团队材质约定打包 Metallic / Roughness / AO；如果不打包，需要单独说明每张图用途。
- `Emission`：MVP 不强制。若制作青绿色轻发光，只用于小面积能量线和几何标记，强度需可在 Unity 中关闭或调低。

材质表现要求：

- 上衣和短裤为哑光运动布料，黑灰不能糊成一整块，需要有明度分层。
- 压缩裤比短裤略更紧、更细腻，可用 Roughness 差异区分。
- 鞋底白 / 浅灰区域保持干净，移动端压缩后不能出现明显脏边。
- 皮肤保持健康自然，不做高油光。
- 眼睛高光适中，首屏中能读出年轻自信感。

## 4. 动画清单

首批 MVP 动画必须交付以下 10 个 Clip：

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

- 所有动画可在 Unity Animator 中播放，并可重定向到 Unity Humanoid。
- 训练动作需要可循环：`workout_squat`、`workout_jumping_jack`、`workout_plank`、`workout_stretch`。
- 动作幅度要适合手机小屏观看，关键姿势清晰，不做过细微的写实动作。
- `idle_default`：自然呼吸、轻微重心变化，可长时间首屏循环。
- `idle_confident`：姿态更挺拔，可有轻微手臂或肩部变化，用于状态更好时展示。
- `intro_hero`：进入首屏或角色展示时使用，时间建议 1.5-2.5 秒，结尾能自然衔接 idle。
- `result_success`：训练完成反馈，积极但不过度夸张。
- `result_level_up`：升级反馈，动作比 success 更明显，可配合 Unity 侧特效。
- `pose_share_01`：分享截图姿势，角色正面或 3/4 面清晰，手臂不遮挡脸和胸前识别点。

动作穿模检查：

- 深蹲：短裤裤脚、上衣下摆、髋部和膝部。
- 开合跳：肩袖、腋下、手腕配饰、鞋底落地接触。
- 平板支撑：帽子、下摆、短裤、膝踝角度。
- 拉伸：肩、肘、髋、膝大幅弯曲时不能塌陷。

导出建议：

- 可交付一个带骨骼和 Skin 的 `rex_base_humanoid.fbx`，动画以单独 FBX 导出。
- 动画 FBX 不需要重复贴图，但需保持骨骼命名、比例和根节点一致。
- Root Motion 默认关闭，除非 Unity 团队另行确认需要。

## 5. Unity 导入验收

基础导入：

- `rex_base_humanoid.fbx` 导入后 Avatar 可设置为 Humanoid。
- 骨骼映射无关键缺失，手脚朝向正确，无比例缩放异常。
- T-Pose / A-Pose 校准无明显肩部扭曲。
- 材质自动或手动绑定后外观接近三视图参考。

首屏验收：

- 模型在 `AvatarHomeScene` 中居中展示。
- 竖屏首屏全身可见，头部和鞋子不被裁切。
- `Lv.1 Rex` 标题和角色不重叠。
- 缩小到手机显示尺寸后，黑灰服装层次、青绿色高光、脸部和鞋型仍可读。

动画验收：

- 10 个 MVP 动画均可播放。
- 训练动作可循环播放，无明显顿挫。
- 深蹲、开合跳、平板支撑、拉伸动作能被 Flutter 指令触发。
- 训练完成后能播放 `result_success` 或 `result_level_up`。
- 分享截图使用 `pose_share_01` 时角色清晰，无透明错误、严重锯齿或关键部位遮挡。

性能验收：

- 总面数目标 20k-40k tris，最高不超过 60k tris。
- 主贴图可由 2K 压缩到 1K 后保持可读。
- 材质数量优先控制在 3-5 个。
- iPhone 模拟器运行不卡顿，无明显导入警告导致的运行时错误。

交付时需附带：

- Unity 角色首屏预览截图。
- 10 个动画播放录屏或逐项预览视频。
- 面数、骨骼数量、材质数量、贴图尺寸说明。
- 授权 / 商用可用说明。

## 6. 待确认问题

以下问题不阻塞第一版建模，但需要在进入最终 Unity 集成前确认：

- A-Pose 还是 T-Pose 作为最终源姿态；当前建议 A-Pose。
- 青绿色高光是否需要真实 Emission，还是仅用 Base Color 表现。
- 胸前和腕带的小几何标记是否作为 FitGame 自有符号保留；需避免与第三方商标相似。
- `outfit_training_black_gold` 是否进入第一批，还是留到第二版材质变体。
- 面部是否需要 BlendShape；MVP 可不做，若后续需要表情反馈，建议至少预留 blink / smile。
- 鞋子是否在第一版就支持独立换装；当前建议独立建模和绑定。
- 动画是否需要 Root Motion；当前建议第一版全部 In Place。
- Unity 侧最终贴图压缩格式和通道打包规范需由工程侧确认。

## 7. 第一版交付目录结构

建议按以下结构交付到 Unity 项目：

```text
unity/Assets/App/Models/Avatar/Rex/
  rex_base_humanoid.fbx
  Rex_Modeling_Spec.md
  Materials/
    mat_rex_skin.mat
    mat_rex_hair_black.mat
    mat_rex_outfit_black_teal.mat
    mat_rex_shoes_black_teal.mat
    mat_rex_eye.mat
  Textures/
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

unity/Assets/App/Preview/Avatar/Rex/
  rex_unity_home_preview.png
  rex_animation_preview.mp4
  rex_import_checklist.md
```

外包 / DCC 源文件建议另存，不直接混入 Unity 运行目录：

```text
source/Avatar/Rex/
  rex_model_source.blend
  rex_model_source.ma
  rex_texture_source.spp
  rex_rig_source.blend
  rex_animation_source/
```

命名原则：

- 文件名前缀统一使用 `rex_`。
- 动画文件名与 Clip 名保持一致。
- 材质使用 `mat_` 前缀，贴图使用 `tex_` 前缀。
- 不使用中文文件名、空格或第三方品牌词。
