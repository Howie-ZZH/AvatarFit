using FitGame.Avatar;
using FitGame.Bridge;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace FitGame.Editor
{
    public static class FitGameSceneBuilder
    {
        private const string ScenePath = "Assets/App/Scenes/AvatarHomeScene.unity";
        private const string HeroAvatarTexturePath = "Assets/App/Textures/avatar_hero_fitgame.png";
        private const string RexAvatarPrefabPath = "Assets/App/Prefabs/Avatar/AvatarRoot.prefab";

        [MenuItem("FitGame/Create Avatar Demo Scene")]
        public static void CreateScene()
        {
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            scene.name = "AvatarHomeScene";

            RenderSettings.ambientLight = new Color(0.08f, 0.1f, 0.12f);
            CreateCamera();
            var growthLight = CreateLights();
            CreateFloor();

            var avatarRoot = CreateAvatarRoot(growthLight);
            var avatar = avatarRoot.GetComponent<AvatarController>();

            var bridgeObject = new GameObject("UnityBridge");
            var router = bridgeObject.AddComponent<AvatarCommandRouter>();
            router.Bind(avatar);
            var bridge = bridgeObject.AddComponent<UnityBridge>();
            bridge.Bind(router);

            EditorSceneManager.SaveScene(scene, ScenePath);
            EditorBuildSettings.scenes = new[]
            {
                new EditorBuildSettingsScene(ScenePath, true)
            };
            Selection.activeGameObject = avatarRoot;
            Debug.Log($"FitGame demo scene created at {ScenePath}");
        }

        private static void CreateCamera()
        {
            var cameraObject = new GameObject("Main Camera");
            cameraObject.tag = "MainCamera";
            var camera = cameraObject.AddComponent<Camera>();
            camera.clearFlags = CameraClearFlags.SolidColor;
            camera.backgroundColor = new Color(0.03f, 0.04f, 0.05f);
            camera.fieldOfView = 27f;
            cameraObject.transform.position = new Vector3(0f, 1.45f, -7.6f);
            cameraObject.transform.LookAt(new Vector3(0f, 1.42f, 0f));
        }

        private static Light CreateLights()
        {
            var key = new GameObject("Directional Light").AddComponent<Light>();
            key.type = LightType.Directional;
            key.intensity = 1.25f;
            key.transform.rotation = Quaternion.Euler(45f, -30f, 0f);

            var rimObject = new GameObject("Rim Light");
            rimObject.transform.position = new Vector3(0f, 2.3f, -2f);
            var rim = rimObject.AddComponent<Light>();
            rim.type = LightType.Point;
            rim.range = 6f;
            rim.intensity = 3f;
            rim.color = new Color(0.13f, 0.83f, 0.65f);
            return rim;
        }

        private static GameObject CreateAvatarRoot(Light growthLight)
        {
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(RexAvatarPrefabPath);
            if (prefab != null)
            {
                var instance = (GameObject)PrefabUtility.InstantiatePrefab(prefab);
                instance.name = "AvatarRoot";
                instance.transform.position = Vector3.zero;

                var prefabGrowthController = instance.GetComponent<AvatarGrowthController>();
                if (prefabGrowthController != null)
                {
                    prefabGrowthController.Bind(growthLight);
                }

                return instance;
            }

            var avatarRoot = new GameObject("AvatarRoot");
            avatarRoot.transform.position = Vector3.zero;

            var characterModel = CreateSlot("CharacterModel", avatarRoot.transform, Vector3.zero);
            var outfitRoot = CreateSlot("OutfitRoot", avatarRoot.transform, Vector3.zero);
            CreateSlot("ShoesRoot", avatarRoot.transform, Vector3.zero);
            CreateSlot("AccessoryRoot", avatarRoot.transform, Vector3.zero);
            CreateSlot("BodyHighlightRoot", avatarRoot.transform, new Vector3(0f, 1.35f, 0f));
            CreateSlot("EffectAnchor", avatarRoot.transform, new Vector3(0f, 1.55f, -0.1f));

            var leftArm = CreateLimbPivot("LeftArm", avatarRoot.transform, new Vector3(-0.62f, 1.5f, 0f));
            var rightArm = CreateLimbPivot("RightArm", avatarRoot.transform, new Vector3(0.62f, 1.5f, 0f));
            var leftLeg = CreateLimbPivot("LeftLeg", avatarRoot.transform, new Vector3(-0.22f, 0.75f, 0f));
            var rightLeg = CreateLimbPivot("RightLeg", avatarRoot.transform, new Vector3(0.22f, 0.75f, 0f));
            var accentRenderers = CreateProceduralRex(
                characterModel.transform,
                leftArm.transform,
                rightArm.transform,
                leftLeg.transform,
                rightLeg.transform
            );

            var label = CreateLabel(avatarRoot.transform);

            var animation = avatarRoot.AddComponent<AvatarAnimationController>();
            animation.Bind(avatarRoot.transform, leftArm.transform, rightArm.transform, leftLeg.transform, rightLeg.transform);

            var appearance = avatarRoot.AddComponent<AvatarAppearanceController>();
            appearance.Bind(avatarRoot.GetComponentsInChildren<Renderer>(true));
            appearance.BindAccentRenderers(accentRenderers);
            appearance.BindOutfits(null, outfitRoot.transform);

            var growthController = avatarRoot.AddComponent<AvatarGrowthController>();
            growthController.Bind(growthLight);

            var capture = avatarRoot.AddComponent<AvatarCaptureController>();
            var avatar = avatarRoot.AddComponent<AvatarController>();
            avatar.Bind(animation, appearance, growthController, capture, label);
            return avatarRoot;
        }

        private static Renderer[] CreateProceduralRex(
            Transform modelRoot,
            Transform leftArm,
            Transform rightArm,
            Transform leftLeg,
            Transform rightLeg
        )
        {
            var skin = CreateMaterial("Rex Skin", new Color(0.93f, 0.66f, 0.48f), 0f, 0f);
            var hair = CreateMaterial("Rex Hair Black", new Color(0.03f, 0.035f, 0.04f), 0f, 0f);
            var outfit = CreateMaterial("Rex Outfit Black", new Color(0.055f, 0.07f, 0.08f), 0f, 0.08f);
            var leggings = CreateMaterial("Rex Leggings Black", new Color(0.025f, 0.03f, 0.035f), 0f, 0f);
            var shoes = CreateMaterial("Rex Shoes Black", new Color(0.08f, 0.085f, 0.09f), 0f, 0f);
            var sole = CreateMaterial("Rex Sole Light", new Color(0.82f, 0.86f, 0.86f), 0f, 0f);
            var eye = CreateMaterial("Rex Eye", new Color(0.08f, 0.12f, 0.14f), 0f, 0f);
            var accent = CreateMaterial("Rex Accent Teal", new Color(0.13f, 0.83f, 0.65f), 0f, 0.55f);
            var accents = new System.Collections.Generic.List<Renderer>();

            CreateCapsule("Body", modelRoot, new Vector3(0f, 1.12f, 0f), new Vector3(0.42f, 0.58f, 0.28f), outfit);
            CreateCube("Hood", modelRoot, new Vector3(0f, 1.56f, 0.13f), new Vector3(0.62f, 0.28f, 0.2f), outfit);
            CreateCube("Shorts", modelRoot, new Vector3(0f, 0.69f, 0f), new Vector3(0.64f, 0.28f, 0.32f), outfit);
            AddAccentCube(accents, "Zipper", modelRoot, new Vector3(0f, 1.18f, -0.285f), new Vector3(0.035f, 0.72f, 0.025f), accent);
            AddAccentCube(accents, "ChestMark", modelRoot, new Vector3(0.17f, 1.35f, -0.295f), new Vector3(0.15f, 0.07f, 0.025f), accent);

            CreateSphere("Head", modelRoot, new Vector3(0f, 1.87f, -0.02f), new Vector3(0.34f, 0.39f, 0.32f), skin);
            CreateCube("HairTop", modelRoot, new Vector3(0f, 2.12f, -0.03f), new Vector3(0.48f, 0.16f, 0.42f), hair);
            CreateCube("HairFront_L", modelRoot, new Vector3(-0.12f, 2.03f, -0.25f), new Vector3(0.17f, 0.18f, 0.13f), hair);
            CreateCube("HairFront_R", modelRoot, new Vector3(0.14f, 2.02f, -0.25f), new Vector3(0.17f, 0.17f, 0.13f), hair);
            CreateSphere("Eye_L", modelRoot, new Vector3(-0.11f, 1.9f, -0.31f), new Vector3(0.045f, 0.05f, 0.018f), eye);
            CreateSphere("Eye_R", modelRoot, new Vector3(0.11f, 1.9f, -0.31f), new Vector3(0.045f, 0.05f, 0.018f), eye);

            CreateCapsule("LeftArmMesh", leftArm, new Vector3(-0.04f, -0.32f, 0f), new Vector3(0.11f, 0.34f, 0.11f), skin);
            CreateCapsule("RightArmMesh", rightArm, new Vector3(0.04f, -0.32f, 0f), new Vector3(0.11f, 0.34f, 0.11f), skin);
            AddAccentCube(accents, "WristBand_L", leftArm, new Vector3(-0.04f, -0.68f, -0.01f), new Vector3(0.17f, 0.065f, 0.15f), accent);
            AddAccentCube(accents, "WristBand_R", rightArm, new Vector3(0.04f, -0.68f, -0.01f), new Vector3(0.17f, 0.065f, 0.15f), accent);

            CreateCapsule("LeftLegging", leftLeg, new Vector3(0f, -0.34f, 0f), new Vector3(0.13f, 0.42f, 0.13f), leggings);
            CreateCapsule("RightLegging", rightLeg, new Vector3(0f, -0.34f, 0f), new Vector3(0.13f, 0.42f, 0.13f), leggings);
            AddAccentCube(accents, "LeftLegStripe", leftLeg, new Vector3(-0.08f, -0.3f, -0.115f), new Vector3(0.035f, 0.52f, 0.025f), accent);
            AddAccentCube(accents, "RightLegStripe", rightLeg, new Vector3(0.08f, -0.3f, -0.115f), new Vector3(0.035f, 0.52f, 0.025f), accent);
            CreateCube("LeftShoe", leftLeg, new Vector3(0f, -0.83f, -0.05f), new Vector3(0.28f, 0.14f, 0.42f), shoes);
            CreateCube("RightShoe", rightLeg, new Vector3(0f, -0.83f, -0.05f), new Vector3(0.28f, 0.14f, 0.42f), shoes);
            CreateCube("LeftSole", leftLeg, new Vector3(0f, -0.91f, -0.05f), new Vector3(0.3f, 0.055f, 0.44f), sole);
            CreateCube("RightSole", rightLeg, new Vector3(0f, -0.91f, -0.05f), new Vector3(0.3f, 0.055f, 0.44f), sole);

            return accents.ToArray();
        }

        private static void AddAccentCube(
            System.Collections.Generic.List<Renderer> accents,
            string name,
            Transform parent,
            Vector3 position,
            Vector3 scale,
            Material material
        )
        {
            accents.Add(CreateCube(name, parent, position, scale, material).GetComponent<Renderer>());
        }

        private static void CreateFloor()
        {
            var floor = GameObject.CreatePrimitive(PrimitiveType.Cube);
            floor.name = "TrainingFloor";
            floor.transform.position = new Vector3(0f, -0.42f, 0f);
            floor.transform.localScale = new Vector3(5.5f, 0.04f, 5.5f);
            floor.GetComponent<Renderer>().material.color = new Color(0.36f, 0.44f, 0.52f);
        }

        private static void CreateHeroAvatarBillboard(Transform parent)
        {
            var texture = AssetDatabase.LoadAssetAtPath<Texture2D>(HeroAvatarTexturePath);
            if (texture == null)
            {
                Debug.LogWarning($"Missing hero avatar texture at {HeroAvatarTexturePath}. Falling back to primitive placeholder.");
                var fallbackMaterial = CreateMaterial("Fallback Energy Teal", new Color(0.13f, 0.83f, 0.65f), 0.18f, 0.25f);
                CreateCapsule("FallbackAvatar", parent, new Vector3(0f, 1.2f, 0f), new Vector3(0.48f, 1.7f, 0.32f), fallbackMaterial);
                return;
            }

            var shader = Shader.Find("Unlit/Transparent");
            if (shader == null)
            {
                shader = Shader.Find("Sprites/Default");
            }

            var material = new Material(shader)
            {
                name = "Hero Avatar Billboard",
                mainTexture = texture,
                color = Color.white
            };
            material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;

            var avatar = GameObject.CreatePrimitive(PrimitiveType.Quad);
            avatar.name = "HeroAvatarBillboard";
            avatar.transform.SetParent(parent);
            avatar.transform.localPosition = new Vector3(0f, 1.34f, -0.02f);
            avatar.transform.localRotation = Quaternion.identity;

            var width = 2.05f;
            var height = width * texture.height / texture.width;
            avatar.transform.localScale = new Vector3(width, height, 1f);
            avatar.GetComponent<Renderer>().sharedMaterial = material;

            var collider = avatar.GetComponent<Collider>();
            if (collider != null)
            {
                Object.DestroyImmediate(collider);
            }
        }

        private static Material CreateMaterial(string name, Color color, float metallic, float emission)
        {
            var material = new Material(Shader.Find("Standard"))
            {
                name = name,
                color = color
            };
            material.SetFloat("_Metallic", metallic);
            material.SetFloat("_Glossiness", 0.68f);
            if (emission > 0f)
            {
                material.EnableKeyword("_EMISSION");
                material.SetColor("_EmissionColor", color * emission);
            }
            return material;
        }

        private static GameObject CreateLimbPivot(string name, Transform parent, Vector3 position)
        {
            return CreateSlot(name, parent, position);
        }

        private static GameObject CreateSlot(string name, Transform parent, Vector3 position)
        {
            var pivot = new GameObject(name);
            pivot.transform.SetParent(parent);
            pivot.transform.localPosition = position;
            pivot.transform.localRotation = Quaternion.identity;
            return pivot;
        }

        private static GameObject CreateCapsule(string name, Transform parent, Vector3 position, Vector3 scale, Material material)
        {
            var primitive = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            primitive.name = name;
            primitive.transform.SetParent(parent);
            primitive.transform.localPosition = position;
            primitive.transform.localScale = scale;
            primitive.GetComponent<Renderer>().material = material;
            return primitive;
        }

        private static GameObject CreateSphere(string name, Transform parent, Vector3 position, Vector3 scale, Material material)
        {
            var primitive = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            primitive.name = name;
            primitive.transform.SetParent(parent);
            primitive.transform.localPosition = position;
            primitive.transform.localScale = scale;
            primitive.GetComponent<Renderer>().material = material;
            return primitive;
        }

        private static GameObject CreateCube(string name, Transform parent, Vector3 position, Vector3 scale, Material material)
        {
            var primitive = GameObject.CreatePrimitive(PrimitiveType.Cube);
            primitive.name = name;
            primitive.transform.SetParent(parent);
            primitive.transform.localPosition = position;
            primitive.transform.localScale = scale;
            primitive.GetComponent<Renderer>().material = material;
            return primitive;
        }

        private static TextMesh CreateLabel(Transform parent)
        {
            var labelObject = new GameObject("AvatarLabel");
            labelObject.transform.SetParent(parent);
            labelObject.transform.localPosition = new Vector3(0f, 3.28f, 0f);
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
    }
}
