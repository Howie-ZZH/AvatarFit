# FitGame 3D 角色美术执行任务拆解

本文档面向 3D 角色设计师 / 外包团队，用于把当前 2D 临时角色推进为 Unity 可用的 3D Humanoid 角色。视觉、格式和基础交付要求以 `docs/3D_CHARACTER_DESIGN_BRIEF.md` 为准；本文补充执行节奏、阶段产出和验收检查。

## 0. 当前参考材料

开始前先查看以下文件：

```text
docs/3D_CHARACTER_DESIGN_BRIEF.md
assets/design/rex_3view_model_sheet.png
app/assets/images/avatar_hero_fitgame.png
artifacts/hero-artwork-preview-ios-v2.png
```

其中 `assets/design/rex_3view_model_sheet.png` 是第一版正面 / 侧面 / 背面建模参考；`app/assets/images/avatar_hero_fitgame.png` 是当前 App 内 2D 占位角色；`artifacts/hero-artwork-preview-ios-v2.png` 是当前首屏产品构图截图。

## 1. 项目目标

交付一个可导入 Unity、可重定向 Humanoid 动画、适合移动端首屏展示的 FitGame 主角 `Rex`。

角色定位：

- 半写实动漫 / 3D 游戏角色，不做 Q 版宠物、机器人或低模方块人
- 年轻、健康、有训练感，能成为健身 RPG / 角色养成产品的主角
- 黑 / 深灰运动服为主视觉，青绿色科技健身能量作为识别高光
- 适合手机竖屏首屏展示，全身清晰，动作幅度可读

最终核心资产：

- Unity Humanoid 可识别的 FBX 角色模型
- T-Pose 或 A-Pose 源文件
- PBR / URP Lit 可用材质和贴图
- 至少 10 个 MVP 动画
- Unity 导入预览截图、动作播放录屏和技术规格说明

## 2. Day 1-3：概念确认与三视图

### Day 1：视觉方向确认

目标：在建模前锁定角色比例、运动服设计和 FitGame 识别点，避免后期大改。

设计师任务：

- 阅读 `docs/3D_CHARACTER_DESIGN_BRIEF.md`，确认模型格式、面数、贴图、动画和命名要求
- 基于当前 2D 临时角色方向，输出 2-3 个快速概念方案
- 明确角色年龄感、体型、脸部风格、发型、服装层次和配色比例
- 确认青绿色能量高光的位置，例如胸口线条、袖口、鞋底、手腕配饰或压缩裤线条
- 避免第三方品牌 Logo、复杂盔甲、武器、过度写实扫描感

Day 1 产出：

- 2-3 张正面概念草图或色块方案
- 1 张推荐方案说明，包含主色、辅色、材质方向和角色关键词
- 风险标注：哪些细节可能影响建模工期、面数或移动端性能

确认标准：

- 产品方确认 1 个主方案
- 明确哪些元素必须保留，哪些元素可在建模阶段简化
- 确认首套配色为 `outfit_starter_black_teal`

### Day 2：三视图与服装结构

目标：为建模提供清晰参考，减少模型阶段的比例和结构返工。

设计师任务：

- 输出角色正面、侧面、背面三视图
- 标注头身比例、肩宽、腿长、鞋型、发型轮廓和身体主要转折
- 拆分服装层级：上衣、短裤、压缩裤、运动鞋、手腕配饰
- 标注材质差异：哑光布料、弹力压缩裤、鞋底橡胶、轻微发光能量线
- 确认面部风格：眼睛大小、鼻口简化程度、表情中性偏自信

Day 2 产出：

- 三视图设计图
- 服装 / 材质标注图
- 可选：头部近景和鞋子近景设计

确认标准：

- 三视图比例一致，可直接作为建模参考
- 服装结构不依赖复杂布料模拟
- 能量线和配饰不影响 Humanoid 绑定和动作变形

### Day 3：建模规格冻结

目标：冻结可执行的技术规格，进入 3D 制作。

设计师任务：

- 确认模型拆分策略
- MVP 可先交付整套 outfit；推荐拆分为 `Body`、`Hair`、`OutfitTop`、`OutfitBottom`、`Leggings`、`Shoes`、`WristAccessory`
- 评估三角面数预算，目标 20k-40k tris，移动端最高不超过 60k tris
- 规划材质数量，优先控制在少量材质球内，避免移动端 draw call 过高
- 确认动画清单和动作幅度参考

Day 3 产出：

- 冻结版三视图
- 模型拆分说明
- 预计面数、材质数量、贴图尺寸说明
- 动画制作清单确认

阶段通过条件：

- 产品方确认概念、三视图、配色和建模拆分
- 设计师确认后续改动只接受小范围细节调整
- 进入 Day 4-7 建模、绑定和动画制作

## 3. Day 4-7：建模、绑定、动作与 Unity 检查

### Day 4：基础模型与低模拓扑

目标：完成可检查的角色 3D 基础形体。

设计师任务：

- 建立角色身体、头部、头发、服装和鞋子的基础模型
- 保持三视图比例，优先保证竖屏首屏可读性
- 完成移动端友好的拓扑，重点优化肩、肘、髋、膝、踝等变形区域
- 避免过多小型悬浮装饰，减少动作穿模和移动端渲染压力

Day 4 产出：

- 灰模或低模预览
- 正面、侧面、背面截图
- 初步 tris 统计

检查重点：

- 角色轮廓是否有主角感
- 头身比例是否符合半写实动漫方向
- 运动服层次是否清楚
- 小屏缩放后青绿色识别点是否仍可见

### Day 5：细化模型、UV 与材质贴图

目标：完成接近最终效果的模型、UV 和首套材质。

设计师任务：

- 细化头发、面部、服装褶皱、鞋底和手腕配饰
- 完成 UV 展开，保证主要可见区域贴图清晰
- 制作首套 `outfit_starter_black_teal` 材质
- 按需输出 Base Color、Normal、Roughness / Metallic 贴图
- 主贴图使用 2K，确保后续可在移动端压缩到 1K

Day 5 产出：

- 带材质模型预览
- 贴图文件和材质说明
- tris、材质球数量、贴图尺寸统计

检查重点：

- 黑 / 深灰主体不要糊成一团，衣服层次需要在手机上可读
- 青绿色高光面积适中，不要像科幻盔甲或电竞皮肤
- 无第三方品牌标识
- 贴图边缘无明显接缝、拉伸和脏边

### Day 6：绑定与 Humanoid 骨骼

目标：完成 Unity 可识别的 Humanoid 绑定，保证基础动作不严重穿模。

设计师任务：

- 使用标准 Humanoid 兼容骨骼命名和层级
- 角色保持 T-Pose 或 A-Pose
- 完成权重绘制，重点检查肩、肘、手腕、髋、膝、脚踝和脖子
- 检查压缩裤、短裤、鞋口、上衣下摆在大幅动作中的穿模
- 导出 `rex_base_humanoid.fbx`

Day 6 产出：

- 绑定完成的 FBX
- T-Pose 或 A-Pose 截图
- 基础弯曲 / 抬腿 / 手臂上举测试截图或视频

检查重点：

- Unity 导入后 Avatar 可配置为 Humanoid
- 骨骼识别无关键缺失
- 手脚朝向正确，模型比例正常
- 常规训练动作下无严重塌陷或异常拉伸

### Day 7：MVP 动画与 Unity 导入检查

目标：交付首批动作，并完成 Unity 侧导入验证。

设计师任务：

- 制作或适配以下 MVP 动画：
  - `idle_default`
  - `idle_confident`
  - `intro_hero`
  - `result_success`
  - `result_level_up`
  - `workout_squat`
  - `workout_jumping_jack`
  - `workout_plank`
  - `workout_stretch`
  - `pose_share_01`
- 训练动作需要可循环，动作幅度在手机小屏上清楚
- 导出单独动画 FBX 或按 Unity 团队要求拆分 Clip
- 在 Unity 中完成导入检查，验证 Humanoid、材质、贴图和动作播放

Day 7 产出：

- 角色模型 FBX
- 10 个 MVP 动画 FBX / Clip
- Unity 预览截图
- 动作播放录屏
- 最终规格说明：面数、材质数量、贴图尺寸、动画列表、授权说明

检查重点：

- `AvatarHomeScene` 中角色居中展示
- 竖屏首屏全身可见，头部和鞋子不被裁切
- `Lv.1 Rex` 标题和角色不重叠
- 深蹲、开合跳、平板支撑、拉伸动作能被触发并循环播放
- 成功和升级反馈动作能正常播放
- 分享姿势截图清晰，无透明错误和严重锯齿

## 4. 验收里程碑

### 里程碑 A：概念冻结

时间：Day 1 结束前。

必须通过：

- 确认主角方向、体型、脸部风格和发型
- 确认黑 / 深灰 + 青绿色高光配色
- 确认不使用第三方品牌 Logo
- 确认角色不是 Q 版、机器人、胶囊人或低模占位风格

未通过处理：

- 不进入三视图和建模
- 只允许围绕比例、服装和配色快速返工

### 里程碑 B：三视图冻结

时间：Day 3 结束前。

必须通过：

- 正面、侧面、背面比例一致
- 服装结构、配饰、鞋子和材质标注清楚
- 模型拆分策略明确
- 面数、贴图、材质数量目标明确
- MVP 动画清单确认

未通过处理：

- 不进入正式高质量建模
- 优先修正比例、服装结构和绑定风险点

### 里程碑 C：模型与材质验收

时间：Day 5 结束前。

必须通过：

- 模型轮廓符合半写实动漫运动主角方向
- tris 控制在 20k-40k，特殊情况不得超过 60k
- 主材质和贴图能在 Unity URP Lit / PBR 流程使用
- 服装、鞋子、头发、面部和手腕配饰完整
- 小屏预览下角色层次和高光可读

未通过处理：

- 先修正大轮廓、比例和材质可读性
- 暂缓追加材质变体和换装拆分

### 里程碑 D：绑定与动画验收

时间：Day 7 结束前。

必须通过：

- Unity Avatar 可识别为 Humanoid
- T-Pose 或 A-Pose 正确
- 至少 10 个 MVP 动画可播放
- 训练动作可循环，不严重穿模
- 动作幅度适合手机小屏观看
- 可重定向到 Unity Humanoid

未通过处理：

- 优先修复骨骼识别、权重和动作穿模
- 非关键表情、材质变体、换装拆分可后移

### 里程碑 E：Unity 首屏集成验收

时间：美术资产交付后由 Unity 侧检查。

必须通过：

- 资源可放入建议目录：
  - `unity/Assets/App/Models/Avatar/Rex/`
  - `unity/Assets/App/Animations/Avatar/Rex/`
  - `unity/Assets/App/Prefabs/Avatar/`
- `AvatarHomeScene` 首屏居中，全身可见
- 标题 `Lv.1 Rex` 不与角色重叠
- Flutter 指令可触发训练动作
- iPhone 模拟器运行不卡顿
- 分享截图角色清晰

未通过处理：

- Unity 侧记录截图和复现步骤
- 美术侧按问题类型修复模型比例、材质、动画或导出设置

## 5. 风险点与处理原则

### 风险 1：视觉过复杂导致移动端性能压力

表现：

- 面数接近或超过 60k
- 材质球过多
- 小装饰、发丝、鞋底细节过密

处理：

- 优先保留整体轮廓、脸部识别、服装层次和青绿色高光
- 简化小装饰和不可见细节
- 控制材质数量，贴图优先合并

### 风险 2：Humanoid 绑定不兼容 Unity

表现：

- Avatar 无法识别为 Humanoid
- 骨骼方向异常
- 动画重定向后手脚扭曲

处理：

- 使用标准 Humanoid 骨骼结构
- 在 Day 6 就进行 Unity 导入试验
- 绑定问题优先级高于材质变体和额外动作

### 风险 3：训练动作穿模严重

表现：

- 深蹲时短裤 / 压缩裤穿模
- 开合跳时上衣下摆、手腕配饰或鞋口异常
- 平板支撑时肩颈、髋部塌陷

处理：

- Day 6 绑定阶段提前做大幅动作测试
- 对高风险服装区域留出间距
- 必要时简化衣摆、裤口和配饰厚度

### 风险 4：首屏构图不适合竖屏

表现：

- 角色导入后头部或鞋子被裁切
- `Lv.1 Rex` 与角色重叠
- 小屏看不清角色表情和动作

处理：

- 建模阶段保持清晰大轮廓
- 动作不要过度横向伸展
- Unity 检查时用真实竖屏比例截图确认

### 风险 5：风格偏离 FitGame 产品方向

表现：

- 角色像工具 App 插画，不像可养成主角
- 过度写实、过度科幻或过度可爱
- 黑灰服装缺少层次，青绿色高光过少或过多

处理：

- Day 1 必须完成概念确认
- 所有阶段都以“健身 RPG 主角”和“移动端可养成角色”为判断标准
- 偏差超过方向时先返工概念，不继续堆细节

## 6. 最终交付清单

- [ ] 冻结版概念图
- [ ] 正面 / 侧面 / 背面三视图
- [ ] 服装和材质标注图
- [ ] `rex_base_humanoid.fbx`
- [ ] T-Pose 或 A-Pose 源文件
- [ ] Unity Humanoid 可识别骨骼
- [ ] Base Color、Normal、Roughness / Metallic 等贴图
- [ ] `outfit_starter_black_teal` 首套材质
- [ ] 至少 10 个 MVP 动画
- [ ] Unity 首屏预览截图
- [ ] 动作播放录屏
- [ ] 面数、材质数量、贴图尺寸说明
- [ ] 授权 / 商用可用说明

## 7. 建议命名

模型：

```text
rex_base_humanoid.fbx
```

动画：

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

材质和贴图：

```text
mat_rex_outfit_black_teal
tex_rex_body_basecolor
tex_rex_body_normal
tex_rex_outfit_basecolor
tex_rex_outfit_normal
```

Unity 目录：

```text
unity/Assets/App/Models/Avatar/Rex/
unity/Assets/App/Models/Avatar/Rex/Materials/
unity/Assets/App/Models/Avatar/Rex/Textures/
unity/Assets/App/Animations/Avatar/Rex/
unity/Assets/App/Prefabs/Avatar/AvatarRoot.prefab
```
