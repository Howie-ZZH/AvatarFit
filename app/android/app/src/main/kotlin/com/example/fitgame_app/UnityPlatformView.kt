package com.example.fitgame_app

import android.app.Activity
import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class UnityPlatformViewFactory(
    private val activity: Activity
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return UnityPlatformView(context, activity)
    }
}

class UnityPlatformView(
    context: Context,
    activity: Activity
) : PlatformView {
    private val container = FrameLayout(context)

    init {
        val unityView = UnityRuntime.attach(activity)
        if (unityView == null) {
            container.addView(
                TextView(context).apply {
                    text = "Unity runtime is not attached. Export Unity as a Library to app/android/unityLibrary."
                    setTextColor(0xFFFFFFFF.toInt())
                    setBackgroundColor(0xFF080A0D.toInt())
                    setPadding(32, 32, 32, 32)
                },
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
            )
        } else {
            (unityView.parent as? ViewGroup)?.removeView(unityView)
            container.addView(
                unityView,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
            )
        }
    }

    override fun getView(): View = container

    override fun dispose() {
        container.removeAllViews()
    }
}
