import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';
import '../voice_service.dart';
import '../action_executor.dart';
import '../nlu.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _aiResponse;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final ctx = Provider.of<ContextManager>(context);
    final voice = Provider.of<VoiceService>(context);
    final theme = Theme.of(context);
    final actionExecutor = ActionExecutor(ctx, ctx.aiService);

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      voice.isListening
                          ? (voice.currentPartial.isNotEmpty
                              ? voice.currentPartial
                              : 'Listening...')
                          : 'Tap the mic or hold the orb to speak',
                      style: theme.textTheme.bodyLarge),
                  if (voice.isListening && voice.currentPartial.isNotEmpty)
                    Text('Partial: ${voice.currentPartial}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // AI Response area
          if (_aiResponse != null || _isProcessing)
            Card(
              color: Color.fromRGBO(76, 175, 80, 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Response',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _isProcessing
                        ? const CircularProgressIndicator()
                        : Text(_aiResponse!, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // AI Suggestions
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Suggestions',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...ctx.currentContext.aiSuggestions.map((s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('• $s', style: theme.textTheme.bodyMedium),
                      )),
                ],
              ),
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
                        onResult: (transcript) async {
                          if (transcript.isNotEmpty) {
                            setState(() => _isProcessing = true);
                            try {
                              final nluResult = NLU.parse(transcript);
                              final response =
                                  await actionExecutor.execute(nluResult);
                              setState(() =>
                                  _aiResponse = response ?? 'No response');
                            } catch (e) {
                              String errorMessage = 'Error: $e';

                              // Provide more helpful error messages
                              if (e.toString().contains('429') ||
                                  e.toString().contains('quota')) {
                                errorMessage = '''
API quota exceeded. This means you've reached the free tier limit for AI requests.

To fix this:
1. Wait a few minutes for the quota to reset
2. Consider upgrading to a paid plan at: https://cloud.google.com/docs/quotas/help/request_increase
3. Or reduce the frequency of AI requests

The app will continue to work with cached responses and basic voice commands.
''';
                              } else if (e.toString().contains('network') ||
                                  e.toString().contains('connection')) {
                                errorMessage = '''
Network error. Please check your internet connection and try again.

The app will work offline with basic voice commands.
''';
                              }

                              setState(() => _aiResponse = errorMessage);
                            } finally {
                              setState(() => _isProcessing = false);
                            }
                          }
                        },
                        context: context);
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
