import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';
import '../voice_service.dart';

class FullscreenOverlay extends StatelessWidget {
  const FullscreenOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final ctx = Provider.of<ContextManager>(context);
    final voice = Provider.of<VoiceService>(context);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.6),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('EternalOS Overlay',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white))),
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white))
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (!voice.isListening) {
                    await voice.startListening(
                        onResult: (t) {}, context: context);
                  } else {
                    await voice.stopListening();
                  }
                },
                icon: Icon(voice.isListening ? Icons.mic_off : Icons.mic),
                label: Text(voice.isListening ? 'Stop' : 'Speak'),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Quick Actions',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white)),
            ),
            Wrap(spacing: 12, children: [
              ElevatedButton(
                  onPressed: () => ctx.addHistory('Overlay: WhatsApp'),
                  child: const Text('WhatsApp')),
              ElevatedButton(
                  onPressed: () => ctx.addHistory('Overlay: Music'),
                  child: const Text('Music')),
              ElevatedButton(
                  onPressed: () => ctx.addHistory('Overlay: Notes'),
                  child: const Text('Notes')),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
