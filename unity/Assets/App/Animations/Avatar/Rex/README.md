# Rex Animation Drop Folder

Place the first MVP animation FBX files here:

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

Follow `docs/3D_CHARACTER_ANIMATION_SPEC.md` before importing.

## Current placeholder

`FitGame/Generate Rex Playable Placeholder` creates Unity `.anim` clips for all MVP
animation keys, including the required first-pass clips:

```text
idle_default
workout_squat
workout_jumping_jack
```

If Unity batchmode/licensing is unavailable, `AvatarAnimationController` still provides
procedural runtime fallback for those keys.
