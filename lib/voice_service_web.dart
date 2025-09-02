import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Web version using speech_to_text for real voice recognition.
class VoiceService extends ChangeNotifier {
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _available = false;
  bool _isListening = false;
  String lastResult = '';
  String partialResult = '';
  bool _continuousMode = false;

  bool get isAvailable => _available;
  bool get isListening => _isListening;
  String get currentPartial => partialResult;

  Future<void> init() async {
    _available = await _stt.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'listening') {
          _isListening = true;
        } else if (status == 'notListening') {
          _isListening = false;
          if (_continuousMode) {
            Future.delayed(const Duration(seconds: 1), () => startListening(onResult: (_) {}));
          }
        }
        notifyListeners();
      },
      onError: (error) {
        print('Speech recognition error: $error');
        _isListening = false;
        notifyListeners();
      },
    );
    print('Speech recognition available: $_available');
    notifyListeners();
  }

  Future<void> startListening({
    required void Function(String) onResult,
    BuildContext? context,
    bool continuous = false,
  }) async {
    if (!_available) {
      await init();
      if (!_available) {
        // Fallback to dialog if speech recognition not available
        if (context != null) {
          _fallbackDialog(onResult, context);
        }
        return;
      }
    }
    _continuousMode = continuous;
    _isListening = true;
    _stt.listen(
      onResult: (result) {
        lastResult = result.recognizedWords;
        partialResult = result.recognizedWords;
        onResult(lastResult);
        if (result.finalResult) {
          partialResult = '';
        }
        notifyListeners();
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      onSoundLevelChange: (level) {
        // Could use this for visual feedback
      },
    );
    notifyListeners();
  }

  Future<void> stopListening() async {
    await _stt.stop();
    _isListening = false;
    _continuousMode = false;
    partialResult = '';
    notifyListeners();
  }

  void toggleContinuousMode() {
    _continuousMode = !_continuousMode;
    notifyListeners();
  }

  /// Fallback dialog for when speech recognition is not available
  Future<void> _fallbackDialog(void Function(String) onResult, BuildContext context) async {
    _isListening = true;
    notifyListeners();

    final controller = TextEditingController();
    final result = await showDialog<String>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Voice Input (Fallback)'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Type transcript...'),
              autofocus: true,
              onSubmitted: (_) => Navigator.of(ctx).pop(controller.text),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(controller.text),
                  child: const Text('Submit')),
            ],
          );
        });

    if (result != null && result.isNotEmpty) {
      lastResult = result;
      partialResult = result;
      onResult(result);
    }
    _isListening = false;
    partialResult = '';
    notifyListeners();
  }
}
