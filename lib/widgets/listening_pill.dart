import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../voice_service.dart';

class ListeningPill extends StatefulWidget {
  final Future<void> Function() onStart;
  final Future<void> Function() onStop;
  const ListeningPill({super.key, required this.onStart, required this.onStop});

  @override
  State<ListeningPill> createState() => _ListeningPillState();
}

class _ListeningPillState extends State<ListeningPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulse.stop();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    _pulse.repeat(reverse: true);
    await widget.onStart();
  }

  Future<void> _stop() async {
    _pulse.stop();
    await widget.onStop();
  }

  @override
  Widget build(BuildContext context) {
    final voice = Provider.of<VoiceService>(context);
    if (!voice.isListening) _pulse.stop();
    return GestureDetector(
      onLongPressStart: (_) => _start(),
      onLongPressEnd: (_) => _stop(),
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 1.08)
            .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
        child: FloatingActionButton.extended(
          onPressed: () async {
            if (!voice.isListening) {
              await _start();
            } else {
              await _stop();
            }
          },
          label: Text(voice.isListening ? 'Stop' : 'Listen'),
          icon: Icon(voice.isListening ? Icons.mic_off : Icons.mic),
        ),
      ),
    );
  }
}
