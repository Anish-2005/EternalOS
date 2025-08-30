import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _ch = MethodChannel('eternal_os/overlay');

  /// Request native side to show overlay (if implemented later).
  static Future<void> showNativeOverlay() async {
    try {
      await _ch.invokeMethod('showOverlay');
    } catch (_) {}
  }

  static Future<void> hideNativeOverlay() async {
    try {
      await _ch.invokeMethod('hideOverlay');
    } catch (_) {}
  }

  static Future<bool> requestOverlayPermission() async {
    try {
      final res = await _ch.invokeMethod('requestPermission');
      return res == true;
    } catch (_) {
      return false;
    }
  }
}
