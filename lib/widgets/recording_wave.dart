import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../voice_service.dart';

class RecordingWave extends StatefulWidget {
  final double width;
  final double height;
  const RecordingWave({super.key, this.width = 120, this.height = 48});

  @override
  State<RecordingWave> createState() => _RecordingWaveState();
}

class _RecordingWaveState extends State<RecordingWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voice = Provider.of<VoiceService>(context);
    if (!voice.isListening) return const SizedBox.shrink();

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(_ctrl.value),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t;
  _WavePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Color.fromRGBO(178, 235, 242, 0.9);
    final barWidth = size.width / 9;
    final centerY = size.height / 2;
    final rng = Random(1);
    for (int i = 0; i < 9; i++) {
      final phase = (t + i / 9) * 2 * pi;
      final h = (sin(phase) * 0.5 + 0.5) *
          size.height *
          (0.4 + (rng.nextDouble() * 0.6));
      final x = i * barWidth + barWidth * 0.15;
      final rect = Rect.fromLTWH(x, centerY - h / 2, barWidth * 0.7, h);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => oldDelegate.t != t;
}
