using System.IO;
using FitGame.Config;
using FitGame.Avatar;
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;

namespace FitGame.Editor
{
    public static class FitGameRexAssetScaffolder
    {
        private const string RexModelPath = "Assets/App/Models/Avatar/Rex";
        private const string RexAnimationPath = "Assets/App/Animations/Avatar/Rex";
        private const string RexPrefabPath = "Assets/App/Prefabs/Avatar";
        private const string RexPreviewPath = "Assets/App/Preview/Avatar/Rex";
        private const string RexConfigPath = "Assets/App/Config/Rex";
        private const string RexAvatarPrefabPath = RexPrefabPath + "/AvatarRoot.prefab";
        private const string RexAnimatorControllerPath = RexAnimationPath + "/RexPlaceholder.controller";
        private const string RexAnimationMapPath = RexConfigPath + "/RexAnimationMapConfig.asset";
        private const string RexOutfitMapPath = RexConfigPath + "/RexOutfitMapConfig.asset";

        [MenuItem("FitGame/Prepare Rex 3D Asset Folders")]
        public static void PrepareRexAssetFolders()
        {
            CreateDirectory(RexModelPath);
            CreateDirectory($"{RexModelPath}/Materials");
            CreateDirectory($"{RexModelPath}/Textures");
            CreateDirectory(RexAnimationPath);
            CreateDirectory(RexPrefabPath);
            CreateDirectory(RexPreviewPath);
            CreateDirectory(RexConfigPath);

            CreateConfigAsset<AnimationMapConfig>(
                RexAnimationMapPath
            );
            CreateConfigAsset<OutfitMapConfig>(
                RexOutfitMapPath
            );
            CreateAvatarRootPrefab(RexAvatarPrefabPath);

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Debug.Log("FitGame Rex 3D asset folders and placeholder config assets are ready.");
        }

        [MenuItem("FitGame/Generate Rex Playable Placeholder")]
        public static void GenerateRexPlayablePlaceholder()
        {
            PrepareRexAssetFolders();

            var skin = CreateMaterialAsset("mat_rex_skin", new Color(0.93f, 0.66f, 0.48f), 0f, 0f);
            var hair = CreateMaterialAsset("mat_rex_hair_black", new Color(0.03f, 0.035f, 0.04f), 0f, 0f);
            var outfit = CreateMaterialAsset("mat_rex_outfit_black_teal", new Color(0.055f, 0.07f, 0.08f), 0f, 0.08f);
            var leggings = CreateMaterialAsset("mat_rex_leggings_black", new Color(0.025f, 0.03f, 0.035f), 0f, 0f);
            var shoes = CreateMaterialAsset("mat_rex_shoes_black_teal", new Color(0.08f, 0.085f, 0.09f), 0f, 0f);
            var sole = CreateMaterialAsset("mat_rex_shoe_sole_light", new Color(0.82f, 0.86f, 0.86f), 0f, 0f);
            var eye = CreateMaterialAsset("mat_rex_eye", new Color(0.08f, 0.12f, 0.14f), 0f, 0f);
            var accent = CreateMaterialAsset("mat_rex_accent_teal", new Color(0.13f, 0.83f, 0.65f), 0f, 0.55f);

            var clips = CreateAnimationClips();
            var controller = CreateAnimatorController(clips);
            var animationMap = CreateAnimationMap(clips);
            CreateConfigAsset<OutfitMapConfig>(RexOutfitMapPath);

            var root = new GameObject("AvatarRoot");
            root.transform.position = Vector3.zero;
            var modelRoot = CreateSlot("CharacterModel", root.transform, Vector3.zero);
            var outfitRoot = CreateSlot("OutfitRoot", root.transform, Vector3.zero);
            CreateSlot("ShoesRoot", root.transform, Vector3.zero);
            CreateSlot("AccessoryRoot", root.transform, Vector3.zero);
            CreateSlot("BodyHighlightRoot", root.transform, new Vector3(0f, 1.35f, 0f));
            var effectAnchor = CreateSlot("EffectAnchor", root.transform, new Vector3(0f, 1.55f, -0.1f));

            var accentRenderers = CreateRexBlockoutModel(
                modelRoot.transform,
                root.transform,
                skin,
                hair,
                outfit,
                leggings,
                shoes,
                sole,
                eye,
                accent,
                out var leftArm,
                out var rightArm,
                out var leftLeg,
                out var rightLeg
            );

            var animator = root.AddComponent<Animator>();
            animator.runtimeAnimatorController = controller;

            var animation = root.AddComponent<AvatarAnimationController>();
            animation.Bind(modelRoot.transform, leftArm.transform, rightArm.transform, leftLeg.transform, rightLeg.transform);
            animation.BindAnimator(animator, animationMap);

            var appearance = root.AddComponent<AvatarAppearanceController>();
            appearance.Bind(root.GetComponentsInChildren<Renderer>(true));
            appearance.BindAccentRenderers(accentRenderers);
            appearance.BindOutfits(AssetDatabase.LoadAssetAtPath<OutfitMapConfig>(RexOutfitMapPath), outfitRoot.transform);

            var growth = root.AddComponent<AvatarGrowthController>();
            var growthLight = effectAnchor.AddComponent<Light>();
            growthLight.type = LightType.Point;
            growthLight.range = 4f;
            growthLight.intensity = 2f;
            growthLight.color = new Color(0.13f, 0.83f, 0.65f);
            growth.Bind(growthLight);

            var capture = root.AddComponent<AvatarCaptureController>();
            var label = CreateLabel(root.transform);
            var avatar = root.AddComponent<AvatarController>();
            avatar.Bind(animation, appearance, growth, capture, label);

            PrefabUtility.SaveAsPrefabAsset(root, RexAvatarPrefabPath);
            Object.DestroyImmediate(root);

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Debug.Log($"Generated playable Rex placeholder prefab, clips, materials, and configs at {RexAvatarPrefabPath}");
        }

        private static void CreateDirectory(string assetPath)
        {
            var fullPath = Path.GetFullPath(assetPath);
            if (!Directory.Exists(fullPath))
            {
                Directory.CreateDirectory(fullPath);
            }
        }

        private static void CreateConfigAsset<T>(string assetPath) where T : ScriptableObject
        {
            if (AssetDatabase.LoadAssetAtPath<T>(assetPath) != null)
            {
                return;
            }

            var config = ScriptableObject.CreateInstance<T>();
            AssetDatabase.CreateAsset(config, assetPath);
        }

        private static void CreateAvatarRootPrefab(string assetPath)
        {
            if (AssetDatabase.LoadAssetAtPath<GameObject>(assetPath) != null)
            {
                return;
            }

            var root = new GameObject("AvatarRoot");
            CreateChild(root.transform, "CharacterModel", Vector3.zero);
            CreateChild(root.transform, "OutfitRoot", Vector3.zero);
            CreateChild(root.transform, "ShoesRoot", Vector3.zero);
            CreateChild(root.transform, "AccessoryRoot", Vector3.zero);
            CreateChild(root.transform, "BodyHighlightRoot", new Vector3(0f, 1.35f, 0f));
            CreateChild(root.transform, "EffectAnchor", new Vector3(0f, 1.55f, -0.1f));

            PrefabUtility.SaveAsPrefabAsset(root, assetPath);
            Object.DestroyImmediate(root);
        }

        private static void CreateChild(Transform parent, string name, Vector3 localPosition)
        {
            var child = new GameObject(name);
            child.transform.SetParent(parent);
            child.transform.localPosition = localPosition;
            child.transform.localRotation = Quaternion.identity;
            child.transform.localScale = Vector3.one;
        }

        private static Material CreateMaterialAsset(string materialName, Color color, float metallic, float emission)
        {
            var assetPath = $"{RexModelPath}/Materials/{materialName}.mat";
            var material = AssetDatabase.LoadAssetAtPath<Material>(assetPath);
            if (material == null)
            {
                var shader = Shader.Find("Standard");
                material = new Material(shader)
                {
                    name = materialName
                };
                AssetDatabase.CreateAsset(material, assetPath);
            }

            material.color = color;
            if (material.HasProperty("_Metallic"))
            {
                material.SetFloat("_Metallic", metallic);
            }
            if (material.HasProperty("_Glossiness"))
            {
                material.SetFloat("_Glossiness", 0.58f);
            }
            if (emission > 0f && material.HasProperty("_EmissionColor"))
            {
                material.EnableKeyword("_EMISSION");
                material.SetColor("_EmissionColor", color * emission);
            }
            return material;
        }

        private static Renderer[] CreateRexBlockoutModel(
            Transform modelRoot,
            Transform root,
            Material skin,
            Material hair,
            Material outfit,
            Material leggings,
            Material shoes,
            Material sole,
            Material eye,
            Material accent,
            out GameObject leftArm,
            out GameObject rightArm,
            out GameObject leftLeg,
            out GameObject rightLeg
        )
        {
            var accentRenderers = new System.Collections.Generic.List<Renderer>();

            CreateCapsule("Body", modelRoot, new Vector3(0f, 1.12f, 0f), new Vector3(0.42f, 0.58f, 0.28f), outfit);
            CreateCube("Hood", modelRoot, new Vector3(0f, 1.56f, 0.13f), new Vector3(0.62f, 0.28f, 0.2f), outfit);
            CreateCube("Shorts", modelRoot, new Vector3(0f, 0.69f, 0f), new Vector3(0.64f, 0.28f, 0.32f), outfit);
            CreateCube("Zipper", modelRoot, new Vector3(0f, 1.18f, -0.285f), new Vector3(0.035f, 0.72f, 0.025f), accentRenderers, accent);
            CreateCube("ChestMark", modelRoot, new Vector3(0.17f, 1.35f, -0.295f), new Vector3(0.15f, 0.07f, 0.025f), accentRenderers, accent);

            CreateSphere("Head", modelRoot, new Vector3(0f, 1.87f, -0.02f), new Vector3(0.34f, 0.39f, 0.32f), skin);
            CreateCube("HairTop", modelRoot, new Vector3(0f, 2.12f, -0.03f), new Vector3(0.48f, 0.16f, 0.42f), hair);
            CreateCube("HairFront_L", modelRoot, new Vector3(-0.12f, 2.03f, -0.25f), new Vector3(0.17f, 0.18f, 0.13f), hair);
            CreateCube("HairFront_R", modelRoot, new Vector3(0.14f, 2.02f, -0.25f), new Vector3(0.17f, 0.17f, 0.13f), hair);
            CreateSphere("Eye_L", modelRoot, new Vector3(-0.11f, 1.9f, -0.31f), new Vector3(0.045f, 0.05f, 0.018f), eye);
            CreateSphere("Eye_R", modelRoot, new Vector3(0.11f, 1.9f, -0.31f), new Vector3(0.045f, 0.05f, 0.018f), eye);

            leftArm = CreateSlot("LeftArm", root, new Vector3(-0.43f, 1.48f, 0f));
            rightArm = CreateSlot("RightArm", root, new Vector3(0.43f, 1.48f, 0f));
            CreateCapsule("LeftArmMesh", leftArm.transform, new Vector3(-0.04f, -0.32f, 0f), new Vector3(0.11f, 0.34f, 0.11f), skin);
            CreateCapsule("RightArmMesh", rightArm.transform, new Vector3(0.04f, -0.32f, 0f), new Vector3(0.11f, 0.34f, 0.11f), skin);
            CreateCube("WristBand_L", leftArm.transform, new Vector3(-0.04f, -0.68f, -0.01f), new Vector3(0.17f, 0.065f, 0.15f), accentRenderers, accent);
            CreateCube("WristBand_R", rightArm.transform, new Vector3(0.04f, -0.68f, -0.01f), new Vector3(0.17f, 0.065f, 0.15f), accentRenderers, accent);

            leftLeg = CreateSlot("LeftLeg", root, new Vector3(-0.2f, 0.58f, 0f));
            rightLeg = CreateSlot("RightLeg", root, new Vector3(0.2f, 0.58f, 0f));
            CreateCapsule("LeftLegging", leftLeg.transform, new Vector3(0f, -0.34f, 0f), new Vector3(0.13f, 0.42f, 0.13f), leggings);
            CreateCapsule("RightLegging", rightLeg.transform, new Vector3(0f, -0.34f, 0f), new Vector3(0.13f, 0.42f, 0.13f), leggings);
            CreateCube("LeftLegStripe", leftLeg.transform, new Vector3(-0.08f, -0.3f, -0.115f), new Vector3(0.035f, 0.52f, 0.025f), accentRenderers, accent);
            CreateCube("RightLegStripe", rightLeg.transform, new Vector3(0.08f, -0.3f, -0.115f), new Vector3(0.035f, 0.52f, 0.025f), accentRenderers, accent);
            CreateCube("LeftShoe", leftLeg.transform, new Vector3(0f, -0.83f, -0.05f), new Vector3(0.28f, 0.14f, 0.42f), shoes);
            CreateCube("RightShoe", rightLeg.transform, new Vector3(0f, -0.83f, -0.05f), new Vector3(0.28f, 0.14f, 0.42f), shoes);
            CreateCube("LeftSole", leftLeg.transform, new Vector3(0f, -0.91f, -0.05f), new Vector3(0.3f, 0.055f, 0.44f), sole);
            CreateCube("RightSole", rightLeg.transform, new Vector3(0f, -0.91f, -0.05f), new Vector3(0.3f, 0.055f, 0.44f), sole);

            return accentRenderers.ToArray();
        }

        private static GameObject CreateSlot(string name, Transform parent, Vector3 position)
        {
            var pivot = new GameObject(name);
            pivot.transform.SetParent(parent);
            pivot.transform.localPosition = position;
            pivot.transform.localRotation = Quaternion.identity;
            pivot.transform.localScale = Vector3.one;
            return pivot;
        }

        private static Renderer CreateCapsule(string name, Transform parent, Vector3 position, Vector3 scale, Material material)
        {
            return CreatePrimitive(PrimitiveType.Capsule, name, parent, position, Quaternion.identity, scale, material);
        }

        private static Renderer CreateSphere(string name, Transform parent, Vector3 position, Vector3 scale, Material material)
        {
            return CreatePrimitive(PrimitiveType.Sphere, name, parent, position, Quaternion.identity, scale, material);
        }

        private static Renderer CreateCube(string name, Transform parent, Vector3 position, Vector3 scale, Material material)
        {
            return CreatePrimitive(PrimitiveType.Cube, name, parent, position, Quaternion.identity, scale, material);
        }

        private static void CreateCube(
            string name,
            Transform parent,
            Vector3 position,
            Vector3 scale,
            System.Collections.Generic.List<Renderer> accentRenderers,
            Material material
        )
        {
            accentRenderers.Add(CreateCube(name, parent, position, scale, material));
        }

        private static Renderer CreatePrimitive(
            PrimitiveType type,
            string name,
            Transform parent,
            Vector3 position,
            Quaternion rotation,
            Vector3 scale,
            Material material
        )
        {
            var primitive = GameObject.CreatePrimitive(type);
            primitive.name = name;
            primitive.transform.SetParent(parent);
            primitive.transform.localPosition = position;
            primitive.transform.localRotation = rotation;
            primitive.transform.localScale = scale;
            var renderer = primitive.GetComponent<Renderer>();
            renderer.sharedMaterial = material;
            var collider = primitive.GetComponent<Collider>();
            if (collider != null)
            {
                Object.DestroyImmediate(collider);
            }
            return renderer;
        }

        private static TextMesh CreateLabel(Transform parent)
        {
            var labelObject = new GameObject("AvatarLabel");
            labelObject.transform.SetParent(parent);
            labelObject.transform.localPosition = new Vector3(0f, 2.35f, 0f);
            labelObject.transform.localRotation = Quaternion.identity;
            var label = labelObject.AddComponent<TextMesh>();
            label.text = "Lv.1 Rex";
            label.anchor = TextAnchor.MiddleCenter;
            label.alignment = TextAlignment.Center;
            label.fontSize = 48;
            label.characterSize = 0.035f;
            label.color = Color.white;
            return label;
        }

        private static System.Collections.Generic.Dictionary<string, AnimationClip> CreateAnimationClips()
        {
            var specs = new[]
            {
                new ClipSpec("idle_default", true, 3.2f, 0.05f, 0f, 0f, 4f, -4f, 2f, -2f),
                new ClipSpec("idle_confident", true, 3.4f, 0.035f, 0f, 0f, 18f, -18f, 4f, -4f),
                new ClipSpec("intro_hero", false, 2.0f, 0.08f, 0f, 0f, 28f, -28f, 3f, -3f),
                new ClipSpec("result_success", false, 1.8f, 0.08f, 0f, 0f, 82f, -82f, 4f, -4f),
                new ClipSpec("result_level_up", false, 2.6f, 0.12f, 0f, 0f, 105f, -105f, 8f, -8f),
                new ClipSpec("workout_squat", true, 2.2f, -0.24f, 0f, 0f, 30f, -30f, 18f, -18f),
                new ClipSpec("workout_jumping_jack", true, 1.4f, 0.12f, 0f, 0f, 110f, -110f, 24f, -24f),
                new ClipSpec("workout_plank", true, 3.2f, -0.58f, 68f, 0f, 22f, -22f, 5f, -5f),
                new ClipSpec("workout_stretch", true, 3.8f, 0.04f, 0f, 0f, 112f, -34f, 6f, -6f),
                new ClipSpec("pose_share_01", false, 1.2f, 0.02f, 0f, 0f, 46f, -20f, 4f, -10f)
            };

            var clips = new System.Collections.Generic.Dictionary<string, AnimationClip>();
            foreach (var spec in specs)
            {
                clips[spec.Key] = CreateClip(spec);
            }
            return clips;
        }

        private static AnimationClip CreateClip(ClipSpec spec)
        {
            var clipPath = $"{RexAnimationPath}/rex_{spec.Key}.anim";
            var clip = AssetDatabase.LoadAssetAtPath<AnimationClip>(clipPath);
            if (clip == null)
            {
                clip = new AnimationClip
                {
                    name = spec.Key,
                    frameRate = 30f
                };
                AssetDatabase.CreateAsset(clip, clipPath);
            }
            else
            {
                clip.ClearCurves();
            }

            clip.wrapMode = spec.Loop ? WrapMode.Loop : WrapMode.Once;
            var settings = AnimationUtility.GetAnimationClipSettings(clip);
            settings.loopTime = spec.Loop;
            AnimationUtility.SetAnimationClipSettings(clip, settings);

            SetFloatCurve(clip, "CharacterModel", "m_LocalPosition.y", 0f, spec.ModelYOffset, 0f, spec.Duration);
            SetFloatCurve(clip, "CharacterModel", "localEulerAnglesRaw.x", 0f, spec.ModelXRotation, 0f, spec.Duration);
            SetFloatCurve(clip, "LeftArm", "localEulerAnglesRaw.z", 14f, spec.LeftArmZ, 14f, spec.Duration);
            SetFloatCurve(clip, "RightArm", "localEulerAnglesRaw.z", -14f, spec.RightArmZ, -14f, spec.Duration);
            SetFloatCurve(clip, "LeftLeg", "localEulerAnglesRaw.z", 4f, spec.LeftLegZ, 4f, spec.Duration);
            SetFloatCurve(clip, "RightLeg", "localEulerAnglesRaw.z", -4f, spec.RightLegZ, -4f, spec.Duration);

            EditorUtility.SetDirty(clip);
            return clip;
        }

        private static void SetFloatCurve(
            AnimationClip clip,
            string relativePath,
            string propertyName,
            float start,
            float middle,
            float end,
            float duration
        )
        {
            var curve = new AnimationCurve(
                new Keyframe(0f, start),
                new Keyframe(duration * 0.5f, middle),
                new Keyframe(duration, end)
            );
            AnimationUtility.SetEditorCurve(
                clip,
                EditorCurveBinding.FloatCurve(relativePath, typeof(Transform), propertyName),
                curve
            );
        }

        private static RuntimeAnimatorController CreateAnimatorController(
            System.Collections.Generic.Dictionary<string, AnimationClip> clips
        )
        {
            var controller = AssetDatabase.LoadAssetAtPath<AnimatorController>(RexAnimatorControllerPath);
            if (controller == null)
            {
                controller = AnimatorController.CreateAnimatorControllerAtPath(RexAnimatorControllerPath);
            }

            var stateMachine = controller.layers[0].stateMachine;
            foreach (var childState in stateMachine.states)
            {
                stateMachine.RemoveState(childState.state);
            }

            AnimatorState firstState = null;
            foreach (var pair in clips)
            {
                var state = stateMachine.AddState(pair.Key);
                state.motion = pair.Value;
                if (firstState == null)
                {
                    firstState = state;
                }
            }

            if (firstState != null)
            {
                stateMachine.defaultState = firstState;
            }

            EditorUtility.SetDirty(controller);
            return controller;
        }

        private static AnimationMapConfig CreateAnimationMap(
            System.Collections.Generic.Dictionary<string, AnimationClip> clips
        )
        {
            CreateConfigAsset<AnimationMapConfig>(RexAnimationMapPath);
            var config = AssetDatabase.LoadAssetAtPath<AnimationMapConfig>(RexAnimationMapPath);
            var serialized = new SerializedObject(config);
            var entries = serialized.FindProperty("entries");
            entries.arraySize = clips.Count;

            var index = 0;
            foreach (var pair in clips)
            {
                var entry = entries.GetArrayElementAtIndex(index);
                entry.FindPropertyRelative("animationKey").stringValue = pair.Key;
                entry.FindPropertyRelative("stateName").stringValue = pair.Key;
                entry.FindPropertyRelative("clip").objectReferenceValue = pair.Value;
                entry.FindPropertyRelative("loop").boolValue = IsLoopingAnimation(pair.Key);
                entry.FindPropertyRelative("transitionSeconds").floatValue = 0.15f;
                index++;
            }

            serialized.ApplyModifiedPropertiesWithoutUndo();
            EditorUtility.SetDirty(config);
            return config;
        }

        private static bool IsLoopingAnimation(string key)
        {
            return key == "idle_default"
                || key == "idle_confident"
                || key == "workout_squat"
                || key == "workout_jumping_jack"
                || key == "workout_plank"
                || key == "workout_stretch";
        }

        private readonly struct ClipSpec
        {
            public ClipSpec(
                string key,
                bool loop,
                float duration,
                float modelYOffset,
                float modelXRotation,
                float modelZRotation,
                float leftArmZ,
                float rightArmZ,
                float leftLegZ,
                float rightLegZ
            )
            {
                Key = key;
                Loop = loop;
                Duration = duration;
                ModelYOffset = modelYOffset;
                ModelXRotation = modelXRotation;
                ModelZRotation = modelZRotation;
                LeftArmZ = leftArmZ;
                RightArmZ = rightArmZ;
                LeftLegZ = leftLegZ;
                RightLegZ = rightLegZ;
            }

            public string Key { get; }
            public bool Loop { get; }
            public float Duration { get; }
            public float ModelYOffset { get; }
            public float ModelXRotation { get; }
            public float ModelZRotation { get; }
            public float LeftArmZ { get; }
            public float RightArmZ { get; }
            public float LeftLegZ { get; }
            public float RightLegZ { get; }
        }
    }
}
