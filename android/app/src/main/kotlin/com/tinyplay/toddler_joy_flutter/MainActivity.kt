package com.tinyplay.toddler_joy_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tinyplay.toddler_joy/sound"
    private var soundManager: SoundManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        soundManager = SoundManager(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playSound" -> {
                    val key = call.argument<String>("key")
                    if (key != null) {
                        soundManager?.playSound(key)
                        result.success(true)
                    } else {
                        result.error("INVALID_KEY", "Key is null", null)
                    }
                }
                "speak" -> {
                    val text = call.argument<String>("text")
                    if (text != null) {
                        soundManager?.speak(text)
                        result.success(true)
                    } else {
                        result.error("INVALID_TEXT", "Text is null", null)
                    }
                }
                "vibrate" -> {
                    soundManager?.vibrateShort()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        soundManager?.release()
    }
}
