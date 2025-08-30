import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';
import '../voice_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctx = Provider.of<ContextManager>(context);
    final voice = Provider.of<VoiceService>(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(children: [
                  Icon(Icons.blur_on, color: theme.iconTheme.color),
                  const SizedBox(width: 8),
                  Flexible(
                      child:
                          Text('EternalOS', style: theme.textTheme.titleLarge))
                ]),
              ),
              Row(children: [
                Text('Cart: ${ctx.cartTotalCount}',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen())),
                    icon: Icon(Icons.settings, color: theme.iconTheme.color))
              ])
            ],
          ),
          const SizedBox(height: 16),

          // Transcript area
          Card(
            color: Color.fromRGBO(13, 71, 161, 0.06),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(children: [
                Expanded(
                    child: Text(
                        voice.isListening
                            ? (voice.lastResult.isNotEmpty
                                ? voice.lastResult
                                : 'Listening...')
                            : 'Tap the mic or hold the orb to speak',
                        style: theme.textTheme.bodyLarge)),
                if (voice.isListening) const SizedBox(width: 12),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // Glowing orb mic
          SizedBox(
            height: 240,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (!voice.isListening) {
                    await voice.startListening(
                        onResult: (t) {}, context: context);
                  } else {
                    await voice.stopListening();
                  }
                },
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      Color.fromRGBO(13, 71, 161, 0.9),
                      Color.fromRGBO(124, 77, 255, 0.9)
                    ]),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(13, 71, 161, 0.22),
                          blurRadius: 28,
                          spreadRadius: 6)
                    ],
                  ),
                  child: Center(
                      child: Icon(
                          voice.isListening ? Icons.mic : Icons.mic_none,
                          size: 56,
                          color: theme.colorScheme.onPrimary)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Suggestions
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 8),
                ActionChip(
                    label: const Text('Open WhatsApp'),
                    backgroundColor: Color.fromRGBO(13, 71, 161, 0.12),
                    labelStyle: theme.textTheme.bodyMedium,
                    onPressed: () {}),
                const SizedBox(width: 8),
                ActionChip(
                    label: const Text('Play Music'),
                    backgroundColor: Color.fromRGBO(13, 71, 161, 0.12),
                    labelStyle: theme.textTheme.bodyMedium,
                    onPressed: () {}),
                const SizedBox(width: 8),
                ActionChip(
                    label: const Text('Search Notes'),
                    backgroundColor: Color.fromRGBO(13, 71, 161, 0.12),
                    labelStyle: theme.textTheme.bodyMedium,
                    onPressed: () {}),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recent actions
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Actions',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('✅ Opened Spotify — 2m ago',
                      style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
