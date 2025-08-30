import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService extends ChangeNotifier {
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _available = false;
  bool _isListening = false;
  String lastResult = '';

  bool get isAvailable => _available;
  bool get isListening => _isListening;

  Future<void> init() async {
    _available = await _stt.initialize(onStatus: (s) {}, onError: (e) {});
    notifyListeners();
  }

  Future<void> startListening(
      {required void Function(String) onResult, BuildContext? context}) async {
    if (!_available) {
      await init();
      if (!_available) return;
    }
    _isListening = true;
    // Newer versions of speech_to_text use SpeechListenOptions with named parameters.
    _stt.listen(onResult: (val) {
      lastResult = val.recognizedWords;
      onResult(lastResult);
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> stopListening() async {
    await _stt.stop();
    _isListening = false;
    notifyListeners();
  }
}
