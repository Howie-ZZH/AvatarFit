# 临时角色占位说明

## 当前结论

当前项目里出现过三类角色方案：

1. Unity 几何体 / 程序化 Rex 占位
2. Flutter 侧 2D 高质量角色立绘
3. 未来正式 3D Humanoid 高保真角色

用户已明确要求最终角色必须是高保真效果。因此：

- 不再继续打磨 Unity primitive / blockout 作为最终视觉。
- 程序化 Rex 只保留为工程占位，用来验证 Unity 通信、动画 key、场景结构和导出链路。
- 当前 2D 角色立绘只保留为 App 视觉过渡方案。
- 最终需要采购 / 下载 / 外包制作真实高保真 Humanoid 角色资产。

## 当前占位资产

```text
app/assets/images/avatar_hero_fitgame.png
unity/Assets/App/Textures/avatar_hero_fitgame.png
unity/Assets/App/Models/Avatar/Rex/rex_lowfi_blockout.blend
unity/Assets/App/Models/Avatar/Rex/rex_lowfi_blockout_blender.fbx
unity/Assets/App/Models/Avatar/Rex/rex_lowfi_blockout_blender.glb
```

说明：

- `avatar_hero_fitgame.png` 是 2D 立绘，视觉较好，但不是 3D。
- `rex_lowfi_blockout_blender.fbx` 是 Blender 导出的低保真 FBX，但没有最终 Humanoid 骨骼和高质量绑定。
- `FitGame -> Generate Rex Playable Placeholder` 可生成 Unity 程序化占位 prefab、材质、Animator 和 `.anim` clips。
- 这些资产不能替代最终高保真角色。

## 高保真角色路线

优先选择路线 A：

### 路线 A：现成高质量 Unity Humanoid 资产

适合 Demo 快速推进。

来源：

```text
Unity Asset Store
Ready Player Me
VRoid / VRM 生态
其他明确可商用的 FBX / Humanoid 角色包
```

搜索关键词：

```text
anime male humanoid character
stylized male humanoid character
sportswear male character
rigged humanoid animated male
free anime character humanoid
```

要求：

- 可导入 Unity
- 最好已配置 Humanoid
- 有清晰商用授权
- 风格接近半写实动漫 / 运动主角
- 可替换或调整服装材质为黑灰 + 青绿色

### 路线 B：外包定制 Rex

质量最高，但成本和周期更高。

必须交付：

```text
rex_base_humanoid.fbx
rex_idle_default.fbx
rex_idle_confident.fbx
rex_workout_squat.fbx
rex_workout_jumping_jack.fbx
...
```

详见：

```text
docs/3D_CHARACTER_FINAL_ART_PACKAGE.md
docs/3D_CHARACTER_MODELING_HANDOFF.md
docs/3D_CHARACTER_ANIMATION_SPEC.md
```

### 路线 C：继续程序化 Blender / Unity 占位

不推荐作为产品视觉路线。

用途仅限：

- 验证 Unity 场景结构
- 验证 Flutter -> Unity animation key
- 验证导出 iOS Library
- 验证训练动作触发链路

## Unity 当前操作

如果只是要让工程链路继续跑：

```text
FitGame -> Generate Rex Playable Placeholder
FitGame -> Create Avatar Demo Scene
```

如果要做高保真，不要继续执行新的 primitive 设计任务；应先拿到高质量角色资产。

## 决策记录

- 用户认为几何体 / lowfi blockout 太丑，不接受作为最终效果。
- 当前高质量 2D 立绘能满足首屏视觉过渡，但不是 3D。
- 高保真 3D 的关键不是 FBX Exporter，而是角色模型资产本身。
- 如果用户不会做角色，优先购买 / 下载现成可商用 Humanoid 资产，或找外包定制。
- 工程侧已经准备好接入真实 3D 角色：`AnimationMapConfig`、`OutfitMapConfig`、`AvatarRoot` 结构和导入计划已完成。
