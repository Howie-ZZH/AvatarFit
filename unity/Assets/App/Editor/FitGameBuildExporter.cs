using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace FitGame.Editor
{
    public static class FitGameBuildExporter
    {
        private const string ScenePath = "Assets/App/Scenes/AvatarHomeScene.unity";

        [MenuItem("FitGame/Export Android Library")]
        public static void ExportAndroidLibrary()
        {
            EnsureScene();
            EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Android, BuildTarget.Android);
            EditorUserBuildSettings.androidBuildSystem = AndroidBuildSystem.Gradle;
            EditorUserBuildSettings.exportAsGoogleAndroidProject = true;

            var exportPath = Path.GetFullPath("../app/android/unityExport");
            var modulePath = Path.GetFullPath("../app/android/unityLibrary");
            CleanDirectory(exportPath);
            var report = BuildPipeline.BuildPlayer(
                new[] { ScenePath },
                exportPath,
                BuildTarget.Android,
                BuildOptions.None
            );
            if (report.summary.result == BuildResult.Succeeded)
            {
                var exportedModulePath = Path.Combine(exportPath, "unityLibrary");
                if (Directory.Exists(exportedModulePath))
                {
                    CleanDirectory(modulePath);
                    CopyDirectory(exportedModulePath, modulePath);
                }
                else
                {
                    Debug.LogWarning($"Unity export finished but unityLibrary module was not found at {exportedModulePath}");
                }
            }
            LogReport("Android", modulePath, report);
        }

        [MenuItem("FitGame/Export iOS Library")]
        public static void ExportIosLibrary()
        {
            ExportIosLibrary(iOSSdkVersion.SimulatorSDK, "iOS Simulator");
        }

        [MenuItem("FitGame/Export iOS Device Library")]
        public static void ExportIosDeviceLibrary()
        {
            ExportIosLibrary(iOSSdkVersion.DeviceSDK, "iOS Device");
        }

        private static void ExportIosLibrary(iOSSdkVersion sdkVersion, string platformLabel)
        {
            EnsureScene();
            EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.iOS, BuildTarget.iOS);
            PlayerSettings.iOS.sdkVersion = sdkVersion;
            if (sdkVersion == iOSSdkVersion.SimulatorSDK)
            {
                PlayerSettings.iOS.simulatorSdkArchitecture = AppleMobileArchitectureSimulator.ARM64;
            }

            var outputPath = Path.GetFullPath("../app/ios/UnityLibrary");
            CleanDirectory(outputPath);
            Debug.Log($"FitGame exporting {platformLabel} Unity library with SDK: {sdkVersion}");
            var report = BuildPipeline.BuildPlayer(
                new[] { ScenePath },
                outputPath,
                BuildTarget.iOS,
                BuildOptions.None
            );
            LogReport(platformLabel, outputPath, report);
        }

        private static void EnsureScene()
        {
            if (!File.Exists(ScenePath))
            {
                FitGameSceneBuilder.CreateScene();
            }
        }

        private static void CleanDirectory(string path)
        {
            if (Directory.Exists(path))
            {
                Directory.Delete(path, true);
            }
            Directory.CreateDirectory(path);
        }

        private static void CopyDirectory(string sourcePath, string targetPath)
        {
            foreach (var directory in Directory.GetDirectories(sourcePath, "*", SearchOption.AllDirectories))
            {
                Directory.CreateDirectory(directory.Replace(sourcePath, targetPath));
            }

            foreach (var file in Directory.GetFiles(sourcePath, "*", SearchOption.AllDirectories))
            {
                var targetFile = file.Replace(sourcePath, targetPath);
                Directory.CreateDirectory(Path.GetDirectoryName(targetFile));
                File.Copy(file, targetFile, true);
            }
        }

        private static void LogReport(string platform, string outputPath, BuildReport report)
        {
            if (report.summary.result == BuildResult.Succeeded)
            {
                Debug.Log($"FitGame {platform} Unity export succeeded: {outputPath}");
            }
            else
            {
                Debug.LogError($"FitGame {platform} Unity export failed: {report.summary.result}");
            }
        }
    }
}
