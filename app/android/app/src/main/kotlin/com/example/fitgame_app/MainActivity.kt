package com.example.fitgame_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UNITY_COMMANDS_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "postMessage" -> {
                    val message = call.arguments as? String
                    if (message.isNullOrBlank()) {
                        result.error("INVALID_MESSAGE", "Unity command message is empty.", null)
                        return@setMethodCallHandler
                    }
                    postUnityMessage(message)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UNITY_EVENTS_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                UNITY_VIEW_TYPE,
                UnityPlatformViewFactory(this)
            )
    }

    override fun onResume() {
        super.onResume()
        UnityRuntime.resume()
    }

    override fun onPause() {
        UnityRuntime.pause()
        super.onPause()
    }

    override fun onDestroy() {
        UnityRuntime.destroy()
        super.onDestroy()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        UnityRuntime.windowFocusChanged(hasFocus)
    }

    private fun postUnityMessage(message: String) {
        val delivered = UnityRuntime.postMessage(
            gameObject = UNITY_BRIDGE_OBJECT,
            method = UNITY_BRIDGE_METHOD,
            message = message
        )

        if (!delivered) {
            emitUnityEvent(
                JSONObject()
                    .put("type", "UNITY_UNAVAILABLE")
                    .put("requestId", readRequestId(message))
                    .put("success", false)
                    .put("error", "Unity runtime is not attached on Android.")
                    .toString()
            )
        }
    }

    private fun readRequestId(message: String): String {
        return runCatching {
            JSONObject(message).optString("requestId", "")
        }.getOrDefault("")
    }

    companion object {
        private const val UNITY_COMMANDS_CHANNEL = "fitgame/unity_commands"
        private const val UNITY_EVENTS_CHANNEL = "fitgame/unity_events"
        private const val UNITY_VIEW_TYPE = "fitgame/unity_view"
        private const val UNITY_BRIDGE_OBJECT = "UnityBridge"
        private const val UNITY_BRIDGE_METHOD = "PostMessage"

        @Volatile
        private var eventSink: EventChannel.EventSink? = null

        @JvmStatic
        fun emitUnityEvent(json: String) {
            eventSink?.success(json)
        }
    }
}
