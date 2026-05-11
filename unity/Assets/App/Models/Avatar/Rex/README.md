# Rex Model Drop Folder

Place the first production 3D character model here:

```text
rex_base_humanoid.fbx
Materials/
Textures/
```

Follow `docs/3D_CHARACTER_MODELING_HANDOFF.md` before importing.

## Current placeholder

This folder now includes a low-fidelity source/export placeholder:

```text
rex_lowfi_blockout.blend
rex_lowfi_blockout_blender.fbx
rex_lowfi_blockout_blender.glb
rex_lowfi_blockout.glb
```

`rex_lowfi_blockout_blender.fbx` is a real Blender-exported FBX model, but it is not a
production Humanoid rig. It is only for validating import, scale, materials, scene
composition, and placeholder visuals.

Source generation scripts live outside Unity `Assets` to avoid importer noise:

```text
tools/rex_asset_generation/generate_rex_lowfi_blender.py
tools/rex_asset_generation/generate_rex_lowfi_glb.py
```

Unity runtime placeholder generation is handled by `FitGame/Generate Rex Playable
Placeholder` and the fallback path in `FitGame/Create Avatar Demo Scene`.
