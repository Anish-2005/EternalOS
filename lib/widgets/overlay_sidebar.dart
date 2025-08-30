import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../voice_service.dart';
import '../context_manager.dart';
import '../nlu.dart';
import '../action_executor.dart';

/// Mock in-app sidebar that simulates a system-wide overlay.
///
/// Real system overlay requires Android native code and the SYSTEM_ALERT_WINDOW
/// permission; this widget is a visual stand-in that appears above app UI
/// within the Flutter app and can be swapped with a native overlay later.
class OverlaySidebar extends StatefulWidget {
  const OverlaySidebar({super.key});

  @override
  State<OverlaySidebar> createState() => _OverlaySidebarState();
}

class _OverlaySidebarState extends State<OverlaySidebar> {
  double top = 120;
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final voice = Provider.of<VoiceService>(context);
    final ctx = Provider.of<ContextManager>(context);
    final media = MediaQuery.of(context);

    // Keep sidebar within safe vertical bounds
    top = top.clamp(24.0, media.size.height - 120.0);

    return Positioned(
      left: 0,
      top: top,
      child: GestureDetector(
        onVerticalDragUpdate: (d) => setState(() => top += d.delta.dy),
        onTap: () => setState(() => expanded = !expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: expanded ? 260 : 56,
          height: expanded ? 320 : 56,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.04),
            borderRadius: BorderRadius.horizontal(
                right: Radius.circular(expanded ? 12 : 28)),
            boxShadow: [
              BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 8)
            ],
          ),
          child: expanded
              ? _buildPanel(context, voice, ctx)
              : _buildCollapsed(voice),
        ),
      ),
    );
  }

  Widget _buildCollapsed(VoiceService voice) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(voice.isListening ? Icons.mic : Icons.keyboard_voice,
              color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildPanel(
      BuildContext context, VoiceService voice, ContextManager ctx) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('EternalOS', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                  onPressed: () => setState(() => expanded = false),
                  icon: const Icon(Icons.close))
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              if (!voice.isListening) {
                await voice.startListening(
                    onResult: (t) async {
                      final parsed = NLU.parse(t);
                      final resolved = ctx.resolveTarget(parsed['item'] ?? '');
                      final action = {
                        'intent': parsed['intent'],
                        'item': parsed['item'],
                        'resolvedItem': resolved,
                      };
                      await ActionExecutor(ctx).execute(action);
                    },
                    context: context);
              } else {
                await voice.stopListening();
              }
              setState(() {});
            },
            icon: Icon(voice.isListening ? Icons.mic_off : Icons.mic),
            label: Text(voice.isListening ? 'Stop' : 'Speak'),
          ),
          const SizedBox(height: 12),
          Text('Quick Actions', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ElevatedButton(
                onPressed: () => ctx.addHistory('Mock: Opened WhatsApp'),
                child: const Text('WhatsApp')),
            ElevatedButton(
                onPressed: () => ctx.addHistory('Mock: Play Music'),
                child: const Text('Play Music')),
            ElevatedButton(
                onPressed: () => ctx.addHistory('Mock: Search Notes'),
                child: const Text('Notes')),
          ]),
          const Spacer(),
          Text('Context: ${ctx.currentContext.activeApp}',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
