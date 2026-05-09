# Unity iOS Library

This directory is generated from the Unity project and is intentionally not
checked in, except for this README.

Regenerate it from the repository root with Unity 6.3:

```sh
/Applications/Unity/Hub/Editor/6000.3.15f1/Unity.app/Contents/MacOS/Unity \
  -batchmode -quit \
  -projectPath "$PWD/unity" \
  -executeMethod FitGame.Editor.FitGameBuildExporter.ExportIosLibrary \
  -logFile "$PWD/unity/unity-demo2-export.log"
```

Then build the Flutter iOS simulator app with:

```sh
/Users/zhangzh/develop/flutter/bin/flutter build ios \
  --debug \
  --simulator \
  --dart-define=FITGAME_USE_NATIVE_UNITY=true
```
