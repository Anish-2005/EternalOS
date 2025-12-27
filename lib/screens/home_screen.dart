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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.cyanAccent, Colors.blueAccent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.blur_on, color: Colors.black),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ETERNAL OS', style: theme.textTheme.headlineLarge),
                    Text('AI-Powered Overlay System',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.cyanAccent,
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Status Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Active App',
                    ctx.currentContext.activeApp,
                    Icons.apps,
                    Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    'Cart Items',
                    '${ctx.cartTotalCount}',
                    Icons.shopping_cart,
                    Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions Grid
            Text('QUICK ACTIONS', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  'Voice Command',
                  'Speak to control',
                  Icons.mic,
                  () => _startVoiceCommand(ctx, voice),
                ),
                _buildActionCard(
                  'AI Analysis',
                  'Context insights',
                  Icons.psychology,
                  () => _showAIAnalysis(context, ctx),
                ),
                _buildActionCard(
                  'Automation',
                  'Create rules',
                  Icons.auto_mode,
                  () => _showAutomationDialog(context),
                ),
                _buildActionCard(
                  'System Overlay',
                  'Toggle overlay',
                  Icons.layers,
                  () => _toggleOverlay(ctx),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Activity
            Text('RECENT ACTIVITY', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            ...ctx.history.take(3).map((record) => _buildActivityItem(record)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.cyanAccent, Colors.blueAccent],
                  ),
                ),
                child: Icon(icon, color: Colors.black, size: 24),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(ActionRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.cyanAccent,
          ),
        ),
        title: Text(record.title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '${record.time.hour}:${record.time.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  void _startVoiceCommand(ContextManager ctx, VoiceService voice) async {
    // Implement voice command
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice command activated')),
    );
  }

  void _showAIAnalysis(BuildContext context, ContextManager ctx) async {
    // Show AI analysis dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('AI Context Analysis', style: TextStyle(color: Colors.white)),
        content: const Text('Analyzing current context...', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAutomationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Create Automation', style: TextStyle(color: Colors.white)),
        content: const Text('Automation creation coming soon...', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _toggleOverlay(ContextManager ctx) {
    // Toggle overlay
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Overlay toggled')),
    );
  }
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
