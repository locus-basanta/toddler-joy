import 'package:flutter/services.dart';

class SoundService {
  static const MethodChannel _channel = MethodChannel('com.tinyplay.toddler_joy/sound');

  static Future<void> playSound(String key) async {
    try {
      await _channel.invokeMethod('playSound', {'key': key});
    } catch (_) {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    }
  }

  static Future<void> speak(String text) async {
    try {
      await _channel.invokeMethod('speak', {'text': text});
    } catch (_) {
      // Fallback
    }
  }

  static Future<void> vibrate() async {
    try {
      await _channel.invokeMethod('vibrate');
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }
}
