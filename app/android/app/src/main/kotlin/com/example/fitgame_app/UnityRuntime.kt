package com.example.fitgame_app

import android.app.Activity
import android.content.Context
import android.view.View

object UnityRuntime {
    private const val UNITY_PLAYER_CLASS = "com.unity3d.player.UnityPlayer"

    private var unityPlayer: Any? = null
    private var unityView: View? = null
    private val pendingMessages = mutableListOf<UnityMessage>()

    fun attach(activity: Activity): View? {
        if (unityView != null) {
            return unityView
        }

        val player = createUnityPlayer(activity) ?: return null
        unityPlayer = player
        unityView = when (player) {
            is View -> player
            else -> runCatching {
                player.javaClass.getMethod("getView").invoke(player) as? View
            }.getOrNull()
        }
        flushPendingMessages()
        return unityView
    }

    fun postMessage(gameObject: String, method: String, message: String): Boolean {
        if (unityPlayer == null) {
            if (!isUnityAvailable()) {
                return false
            }
            pendingMessages.add(UnityMessage(gameObject, method, message))
            return true
        }

        return sendMessage(gameObject, method, message)
    }

    private fun sendMessage(gameObject: String, method: String, message: String): Boolean {
        return runCatching {
            val unityPlayerClass = Class.forName(UNITY_PLAYER_CLASS)
            val unitySendMessage = unityPlayerClass.getMethod(
                "UnitySendMessage",
                String::class.java,
                String::class.java,
                String::class.java
            )
            unitySendMessage.invoke(null, gameObject, method, message)
        }.isSuccess
    }

    private fun flushPendingMessages() {
        if (pendingMessages.isEmpty()) {
            return
        }
        val messages = pendingMessages.toList()
        pendingMessages.clear()
        messages.forEach { pending ->
            sendMessage(pending.gameObject, pending.method, pending.message)
        }
    }

    private fun isUnityAvailable(): Boolean {
        return runCatching {
            Class.forName(UNITY_PLAYER_CLASS)
        }.isSuccess
    }

    fun resume() {
        callPlayerMethod("resume")
    }

    fun pause() {
        callPlayerMethod("pause")
    }

    fun destroy() {
        callPlayerMethod("destroy")
        unityView = null
        unityPlayer = null
        pendingMessages.clear()
    }

    fun windowFocusChanged(hasFocus: Boolean) {
        callPlayerMethod("windowFocusChanged", Boolean::class.javaPrimitiveType, hasFocus)
    }

    private fun createUnityPlayer(activity: Activity): Any? {
        val unityPlayerClass = runCatching {
            Class.forName(UNITY_PLAYER_CLASS)
        }.getOrNull() ?: return null

        return runCatching {
            unityPlayerClass.getConstructor(Context::class.java).newInstance(activity)
        }.recoverCatching {
            unityPlayerClass.getConstructor(Activity::class.java).newInstance(activity)
        }.getOrNull()
    }

    private fun callPlayerMethod(name: String) {
        val player = unityPlayer ?: return
        runCatching {
            player.javaClass.getMethod(name).invoke(player)
        }
    }

    private fun callPlayerMethod(name: String, parameterType: Class<*>?, value: Any) {
        val player = unityPlayer ?: return
        runCatching {
            player.javaClass.getMethod(name, parameterType).invoke(player, value)
        }
    }

    private data class UnityMessage(
        val gameObject: String,
        val method: String,
        val message: String
    )
}
