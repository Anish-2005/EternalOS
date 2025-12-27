import 'dart:ui' as ui;
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
  bool _isAnimating = false;

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
        onTap: () => _toggleExpanded(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: expanded ? 280 : 64,
          height: expanded ? 400 : 64,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.horizontal(
                right: Radius.circular(expanded ? 20 : 32)),
            border: Border.all(
              color: Colors.cyanAccent.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.1),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.horizontal(
                right: Radius.circular(expanded ? 20 : 32)),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                ),
                child: expanded
                    ? _buildExpandedPanel(context, voice, ctx)
                    : _buildCollapsedOrb(voice),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isAnimating = true;
      expanded = !expanded;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isAnimating = false);
    });
  }

  Widget _buildCollapsedOrb(VoiceService voice) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: voice.isListening ? 48 : 32,
            height: voice.isListening ? 48 : 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: voice.isListening
                    ? Colors.cyanAccent.withOpacity(0.8)
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: voice.isListening
                  ? [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ]
                  : null,
            ),
          ),
          // Inner icon
          Icon(
            voice.isListening ? Icons.mic : Icons.blur_on,
            color: voice.isListening ? Colors.cyanAccent : Colors.white,
            size: 20,
          ),
          // Pulse animation when listening
          if (voice.isListening)
            AnimatedOpacity(
              opacity: _isAnimating ? 0.8 : 0.3,
              duration: const Duration(milliseconds: 1000),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedPanel(
      BuildContext context, VoiceService voice, ContextManager ctx) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.cyanAccent, Colors.blueAccent],
                  ),
                ),
                child: const Icon(Icons.blur_on, color: Colors.black, size: 14),
              ),
              const SizedBox(width: 8),
              const Text(
                'ETERNAL',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _toggleExpanded,
                icon: const Icon(Icons.close, size: 16, color: Colors.white70),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Voice Control
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.cyanAccent.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      voice.isListening ? Icons.mic : Icons.mic_none,
                      color: voice.isListening
                          ? Colors.cyanAccent
                          : Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      voice.isListening ? 'LISTENING...' : 'VOICE COMMAND',
                      style: TextStyle(
                        color: voice.isListening
                            ? Colors.cyanAccent
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!voice.isListening) {
                        await voice.startListening(
                          onResult: (t) async {
                            final parsed = NLU.parse(t);
                            final resolved =
                                ctx.resolveTarget(parsed['item'] ?? '');
                            final action = {
                              'intent': parsed['intent'],
                              'item': parsed['item'],
                              'resolvedItem': resolved,
                            };
                            await ActionExecutor(ctx, ctx.aiService)
                                .execute(action);
                          },
                          context: context,
                        );
                      } else {
                        await voice.stopListening();
                      }
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: voice.isListening
                          ? Colors.redAccent.withOpacity(0.2)
                          : Colors.cyanAccent.withOpacity(0.1),
                      foregroundColor: voice.isListening
                          ? Colors.redAccent
                          : Colors.cyanAccent,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      voice.isListening ? 'STOP' : 'START',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // AI Suggestions
          Text(
            'AI SUGGESTIONS',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSuggestionItem('Open recent app', Icons.history),
                _buildSuggestionItem('Search contacts', Icons.contacts),
                _buildSuggestionItem('Play music', Icons.music_note),
                _buildSuggestionItem('Take note', Icons.note_add),
              ],
            ),
          ),

          // Context Info
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white54, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Context: ${ctx.currentContext.activeApp}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String text, IconData icon) {
    return InkWell(
      onTap: () {
        // Execute suggestion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Executed: $text')),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 12),
          ],
        ),
      ),
    );
  }
}
