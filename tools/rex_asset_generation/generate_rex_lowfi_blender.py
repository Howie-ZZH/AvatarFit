#!/usr/bin/env python3
"""Generate a low-fidelity Rex 3D blockout with Blender.

This creates real DCC/export files for the Unity integration path. It is not a
final Humanoid production asset; it is a visual blockout that matches the Rex
design language closely enough to validate import, scale, materials, and scene
composition before the final rigged FBX arrives.
"""

from __future__ import annotations

from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parent
BLEND_OUT = ROOT / "rex_lowfi_blockout.blend"
GLB_OUT = ROOT / "rex_lowfi_blockout_blender.glb"
FBX_OUT = ROOT / "rex_lowfi_blockout_blender.fbx"


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def make_mat(name: str, color: tuple[float, float, float, float], roughness: float = 0.55):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = color
        bsdf.inputs["Roughness"].default_value = roughness
        bsdf.inputs["Metallic"].default_value = 0.0
    return mat


def assign(obj, mat) -> None:
    obj.data.materials.append(mat)


def cube(name: str, loc, scale, mat):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    assign(obj, mat)
    return obj


def sphere(name: str, loc, scale, mat, segments: int = 32):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=16, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    assign(obj, mat)
    return obj


def cylinder(name: str, loc, radius: float, depth: float, mat, vertices: int = 24):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc)
    obj = bpy.context.object
    obj.name = name
    assign(obj, mat)
    return obj


def limb(name: str, loc, radius: float, depth: float, mat, rotation=(0.0, 0.0, 0.0)):
    obj = cylinder(name, loc, radius, depth, mat)
    obj.rotation_euler = rotation
    return obj


def add_hair_cluster(hair_mat):
    pieces = [
        ("HairTop", (0, 2.16, -0.02), (0.34, 0.16, 0.32)),
        ("HairBack", (0, 2.03, 0.14), (0.38, 0.24, 0.20)),
        ("HairBang_L", (-0.12, 2.03, -0.24), (0.12, 0.20, 0.10)),
        ("HairBang_C", (0.02, 2.05, -0.27), (0.10, 0.22, 0.10)),
        ("HairBang_R", (0.15, 2.02, -0.23), (0.12, 0.18, 0.10)),
    ]
    for name, loc, scale in pieces:
        obj = sphere(name, loc, scale, hair_mat, segments=16)
        obj.rotation_euler[2] = 0.2 if "_L" in name else -0.15


def add_rex_blockout():
    skin = make_mat("mat_rex_skin", (0.93, 0.66, 0.48, 1))
    hair = make_mat("mat_rex_hair_black", (0.025, 0.028, 0.032, 1), 0.45)
    outfit = make_mat("mat_rex_outfit_black_teal", (0.045, 0.055, 0.065, 1), 0.68)
    leggings = make_mat("mat_rex_leggings_black", (0.018, 0.022, 0.026, 1), 0.5)
    shoes = make_mat("mat_rex_shoes_black", (0.06, 0.065, 0.07, 1), 0.52)
    sole = make_mat("mat_rex_sole_light", (0.82, 0.86, 0.86, 1), 0.58)
    accent = make_mat("mat_rex_accent_teal", (0.02, 0.95, 0.78, 1), 0.35)
    eye = make_mat("mat_rex_eye_teal", (0.0, 0.75, 0.82, 1), 0.25)

    # Body and outfit.
    sphere("TorsoHoodie", (0, 1.22, 0), (0.36, 0.58, 0.25), outfit)
    cube("Hood", (0, 1.59, 0.12), (0.55, 0.16, 0.16), outfit)
    cube("Shorts", (0, 0.72, -0.01), (0.58, 0.18, 0.28), outfit)
    cube("Zipper_Teal", (0, 1.2, -0.265), (0.022, 0.44, 0.014), accent)
    cube("ChestMark_Teal", (0.16, 1.38, -0.27), (0.10, 0.035, 0.014), accent)
    cube("ShoulderStripe_L", (-0.33, 1.5, -0.03), (0.025, 0.34, 0.018), accent)
    cube("ShoulderStripe_R", (0.33, 1.5, -0.03), (0.025, 0.34, 0.018), accent)
    cube("ShortsStripe_L", (-0.28, 0.73, -0.15), (0.025, 0.22, 0.014), accent)
    cube("ShortsStripe_R", (0.28, 0.73, -0.15), (0.025, 0.22, 0.014), accent)

    # Head and hair.
    sphere("Head", (0, 1.88, -0.03), (0.27, 0.32, 0.24), skin)
    add_hair_cluster(hair)
    sphere("Eye_L", (-0.095, 1.91, -0.255), (0.035, 0.04, 0.012), eye, segments=16)
    sphere("Eye_R", (0.095, 1.91, -0.255), (0.035, 0.04, 0.012), eye, segments=16)

    # Limbs. Cylinders are vertical by default.
    limb("UpperArm_L", (-0.43, 1.23, 0), 0.07, 0.52, skin, rotation=(0.0, 0.0, -0.10))
    limb("UpperArm_R", (0.43, 1.23, 0), 0.07, 0.52, skin, rotation=(0.0, 0.0, 0.10))
    cube("WristBand_L", (-0.46, 0.86, -0.02), (0.13, 0.045, 0.10), accent)
    cube("WristBand_R", (0.46, 0.86, -0.02), (0.13, 0.045, 0.10), accent)

    limb("Legging_L", (-0.19, 0.23, 0), 0.085, 0.78, leggings)
    limb("Legging_R", (0.19, 0.23, 0), 0.085, 0.78, leggings)
    cube("CalfStripe_L", (-0.26, 0.20, -0.095), (0.018, 0.34, 0.014), accent)
    cube("CalfStripe_R", (0.26, 0.20, -0.095), (0.018, 0.34, 0.014), accent)
    cube("Shoe_L", (-0.19, -0.22, -0.08), (0.18, 0.07, 0.28), shoes)
    cube("Shoe_R", (0.19, -0.22, -0.08), (0.18, 0.07, 0.28), shoes)
    cube("Sole_L", (-0.19, -0.29, -0.08), (0.20, 0.035, 0.30), sole)
    cube("Sole_R", (0.19, -0.29, -0.08), (0.20, 0.035, 0.30), sole)
    cube("ShoeAccent_L", (-0.19, -0.19, -0.23), (0.11, 0.02, 0.014), accent)
    cube("ShoeAccent_R", (0.19, -0.19, -0.23), (0.11, 0.02, 0.014), accent)

    root = bpy.data.objects.new("Rex_Lowfi_Blockout_Root", None)
    bpy.context.collection.objects.link(root)
    for obj in bpy.context.scene.objects:
        if obj.type == "MESH":
            obj.parent = root

    # Camera and light for quick preview in Blender.
    bpy.ops.object.light_add(type="AREA", location=(0, 3.0, -2.5))
    light = bpy.context.object
    light.name = "Preview_Key_Light"
    light.data.energy = 450
    light.data.size = 4
    bpy.ops.object.camera_add(location=(0, 1.25, -5.8), rotation=(1.35, 0, 0))
    bpy.context.scene.camera = bpy.context.object


def export_files():
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_OUT))
    bpy.ops.export_scene.gltf(filepath=str(GLB_OUT), export_format="GLB")
    bpy.ops.export_scene.fbx(
        filepath=str(FBX_OUT),
        add_leaf_bones=False,
        bake_anim=False,
        object_types={"MESH", "EMPTY"},
    )
    print(BLEND_OUT)
    print(GLB_OUT)
    print(FBX_OUT)


def main():
    clear_scene()
    add_rex_blockout()
    export_files()


if __name__ == "__main__":
    main()
