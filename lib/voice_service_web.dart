import 'package:flutter/material.dart';

/// Web fallback: no direct microphone support here; use a manual prompt to simulate transcripts.
class VoiceService extends ChangeNotifier {
  bool _isListening = false;
  String lastResult = '';

  bool get isListening => _isListening;

  /// On web, we show a simple typed-input dialog when [context] is provided.
  Future<void> startListening(
      {required void Function(String) onResult, BuildContext? context}) async {
    _isListening = true;
    notifyListeners();

    if (context != null) {
      final controller = TextEditingController();
      final result = await showDialog<String>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Simulate voice input'),
              content: TextField(
                controller: controller,
                decoration:
                    const InputDecoration(hintText: 'Type transcript...'),
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
        onResult(result);
      }
    }
  }

  Future<void> stopListening() async {
    _isListening = false;
    notifyListeners();
  }
}
