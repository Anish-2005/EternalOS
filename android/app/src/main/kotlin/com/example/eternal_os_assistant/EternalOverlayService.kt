package com.example.eternal_os_assistant

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import io.flutter.plugin.common.MethodChannel

class EternalOverlayService : Service() {

    private val TAG = "EternalOverlayService"
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var methodChannel: MethodChannel? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Overlay Service created")
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        showOverlay()
        return START_STICKY
    }

    private fun showOverlay() {
        if (overlayView != null) return

        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        )

        layoutParams.gravity = Gravity.TOP or Gravity.END
        layoutParams.x = 0
        layoutParams.y = 100

        overlayView = LayoutInflater.from(this).inflate(R.layout.overlay_layout, null)

        val textView = overlayView?.findViewById<TextView>(R.id.overlay_text)
        textView?.text = "EternalOS Active"

        val closeButton = overlayView?.findViewById<Button>(R.id.close_button)
        closeButton?.setOnClickListener {
            hideOverlay()
        }

        try {
            windowManager?.addView(overlayView, layoutParams)
            Log.d(TAG, "Overlay shown")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to add overlay view", e)
        }
    }

    private fun hideOverlay() {
        if (overlayView != null) {
            try {
                windowManager?.removeView(overlayView)
                overlayView = null
                Log.d(TAG, "Overlay hidden")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to remove overlay view", e)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        hideOverlay()
        Log.d(TAG, "Overlay Service destroyed")
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}