package com.mindwars.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import android.os.Bundle

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.mindwars.app/platform"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android ${Build.VERSION.RELEASE}")
                }
                "getPlatformInfo" -> {
                    val info = mapOf(
                        "platform" to "android",
                        "version" to Build.VERSION.RELEASE,
                        "sdkInt" to Build.VERSION.SDK_INT,
                        "manufacturer" to Build.MANUFACTURER,
                        "model" to Build.MODEL,
                        "isTablet" to isTablet()
                    )
                    result.success(info)
                }
                "supportsFeature" -> {
                    val feature = call.argument<String>("feature")
                    result.success(supportsFeature(feature))
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display (Material Design 3)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
        }
    }
    
    private fun isTablet(): Boolean {
        val screenLayout = resources.configuration.screenLayout
        val screenSize = screenLayout and android.content.res.Configuration.SCREENLAYOUT_SIZE_MASK
        return screenSize >= android.content.res.Configuration.SCREENLAYOUT_SIZE_LARGE
    }
    
    private fun supportsFeature(feature: String?): Boolean {
        return when (feature) {
            "camera" -> packageManager.hasSystemFeature(android.content.pm.PackageManager.FEATURE_CAMERA)
            "bluetooth" -> packageManager.hasSystemFeature(android.content.pm.PackageManager.FEATURE_BLUETOOTH)
            "nfc" -> packageManager.hasSystemFeature(android.content.pm.PackageManager.FEATURE_NFC)
            else -> false
        }
    }
}
