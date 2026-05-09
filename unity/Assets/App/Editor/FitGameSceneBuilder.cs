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

        [MenuItem("FitGame/Create Avatar Demo Scene")]
        public static void CreateScene()
        {
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            scene.name = "AvatarHomeScene";

            RenderSettings.ambientLight = new Color(0.08f, 0.1f, 0.12f);
            CreateCamera();
            var growthLight = CreateLights();
            CreateFloor();

            var avatarRoot = new GameObject("AvatarRoot");
            avatarRoot.transform.position = Vector3.zero;

            var body = CreateCapsule("Body", avatarRoot.transform, new Vector3(0f, 1.05f, 0f), new Vector3(0.72f, 1.35f, 0.42f));
            var head = CreateSphere("Head", avatarRoot.transform, new Vector3(0f, 2.0f, 0f), new Vector3(0.48f, 0.48f, 0.48f));
            var leftArm = CreateCapsule("LeftArm", avatarRoot.transform, new Vector3(-0.58f, 1.2f, 0f), new Vector3(0.22f, 0.92f, 0.22f));
            var rightArm = CreateCapsule("RightArm", avatarRoot.transform, new Vector3(0.58f, 1.2f, 0f), new Vector3(0.22f, 0.92f, 0.22f));
            var leftLeg = CreateCapsule("LeftLeg", avatarRoot.transform, new Vector3(-0.22f, 0.18f, 0f), new Vector3(0.24f, 0.9f, 0.24f));
            var rightLeg = CreateCapsule("RightLeg", avatarRoot.transform, new Vector3(0.22f, 0.18f, 0f), new Vector3(0.24f, 0.9f, 0.24f));
            var label = CreateLabel(avatarRoot.transform);

            var animation = avatarRoot.AddComponent<AvatarAnimationController>();
            animation.Bind(avatarRoot.transform, leftArm.transform, rightArm.transform, leftLeg.transform, rightLeg.transform);

            var appearance = avatarRoot.AddComponent<AvatarAppearanceController>();
            appearance.Bind(new[]
            {
                body.GetComponent<Renderer>(),
                head.GetComponent<Renderer>(),
                leftArm.GetComponent<Renderer>(),
                rightArm.GetComponent<Renderer>(),
                leftLeg.GetComponent<Renderer>(),
                rightLeg.GetComponent<Renderer>()
            });

            var growth = avatarRoot.AddComponent<AvatarGrowthController>();
            growth.Bind(growthLight);

            var capture = avatarRoot.AddComponent<AvatarCaptureController>();
            var avatar = avatarRoot.AddComponent<AvatarController>();
            avatar.Bind(animation, appearance, growth, capture, label);

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
            camera.fieldOfView = 34f;
            cameraObject.transform.position = new Vector3(0f, 1.35f, -9.5f);
            cameraObject.transform.LookAt(new Vector3(0f, 1.15f, 0f));
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

        private static void CreateFloor()
        {
            var floor = GameObject.CreatePrimitive(PrimitiveType.Cube);
            floor.name = "TrainingFloor";
            floor.transform.position = new Vector3(0f, -0.42f, 0f);
            floor.transform.localScale = new Vector3(5.5f, 0.04f, 5.5f);
            floor.GetComponent<Renderer>().material.color = new Color(0.035f, 0.045f, 0.06f);
        }

        private static GameObject CreateCapsule(string name, Transform parent, Vector3 position, Vector3 scale)
        {
            var primitive = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            primitive.name = name;
            primitive.transform.SetParent(parent);
            primitive.transform.localPosition = position;
            primitive.transform.localScale = scale;
            primitive.GetComponent<Renderer>().material.color = new Color(0.13f, 0.83f, 0.65f);
            return primitive;
        }

        private static GameObject CreateSphere(string name, Transform parent, Vector3 position, Vector3 scale)
        {
            var primitive = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            primitive.name = name;
            primitive.transform.SetParent(parent);
            primitive.transform.localPosition = position;
            primitive.transform.localScale = scale;
            primitive.GetComponent<Renderer>().material.color = new Color(0.13f, 0.83f, 0.65f);
            return primitive;
        }

        private static TextMesh CreateLabel(Transform parent)
        {
            var labelObject = new GameObject("AvatarLabel");
            labelObject.transform.SetParent(parent);
            labelObject.transform.localPosition = new Vector3(0f, 2.55f, 0f);
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
