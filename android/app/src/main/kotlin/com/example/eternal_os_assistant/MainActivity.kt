package com.example.eternal_os_assistant

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "eternal_os/overlay"
    private val CONTEXT_CHANNEL = "eternal_os/context"
    private lateinit var methodChannel: MethodChannel
    private lateinit var contextChannel: MethodChannel

    companion object {
        var contextMethodChannel: MethodChannel? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    requestOverlayPermission(result)
                }
                "showOverlay" -> {
                    showOverlay()
                    result.success(null)
                }
                "hideOverlay" -> {
                    hideOverlay()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        contextChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTEXT_CHANNEL)
        contextMethodChannel = contextChannel
    }

    private fun requestOverlayPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName"))
                startActivity(intent)
                result.success(false) // Permission not granted yet
            } else {
                result.success(true)
            }
        } else {
            result.success(true) // No permission needed for older versions
        }
    }

    private fun showOverlay() {
        val intent = Intent(this, EternalOverlayService::class.java)
        startService(intent)
    }

    private fun hideOverlay() {
        val intent = Intent(this, EternalOverlayService::class.java)
        stopService(intent)
    }
}
