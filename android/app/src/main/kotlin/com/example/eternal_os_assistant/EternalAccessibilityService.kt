package com.example.eternal_os_assistant

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import io.flutter.plugin.common.MethodChannel

class EternalAccessibilityService : AccessibilityService() {

    private val TAG = "EternalAccessibilityService"
    private var methodChannel: MethodChannel? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Accessibility Service created")
        // Initialize method channel if needed
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Accessibility Service connected")

        val info = AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                          AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
                          AccessibilityEvent.TYPE_VIEW_CLICKED or
                          AccessibilityEvent.TYPE_VIEW_FOCUSED or
                          AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
        info.flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                     AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        info.notificationTimeout = 100
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            val eventType = it.eventType
            val packageName = it.packageName?.toString() ?: "unknown"
            val className = it.className?.toString() ?: "unknown"
            val text = it.text?.joinToString(" ") ?: ""

            Log.d(TAG, "Accessibility Event: type=$eventType, pkg=$packageName, class=$className, text=$text")

            // Send context update to Flutter
            val contextData = mapOf(
                "eventType" to eventType,
                "packageName" to packageName,
                "className" to className,
                "text" to text
            )

            try {
                MainActivity.contextMethodChannel?.invokeMethod("onContextUpdate", contextData)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to send context update", e)
            }
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "Accessibility Service interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Accessibility Service destroyed")
    }
}