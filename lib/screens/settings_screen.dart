import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../context_manager.dart';
import '../native_bridge.dart';
import '../widgets/fullscreen_overlay.dart';
import 'onboarding_screen.dart';

/// Advanced Settings screen for EternalOS with professional UI
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Local UI-only toggles
  bool _useCloudAI = false;
  bool _autoRunTrusted = false;
  bool _sendAnonymizedTelemetry = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showInfoDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotImplementedSnackBar([String? msg]) {
    final text = msg ?? 'This feature is not implemented yet.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A2A2A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _confirmAndClearHistory(ContextManager ctx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Clear Automation History',
          style: TextStyle(
            color: Colors.redAccent,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will remove stored suggestions and automation logs from the device. This action cannot be undone.',
          style: TextStyle(color: Colors.white, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final clear = ctx.clearAutomationHistory;
      if (clear is Function) {
        await clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Automation history cleared.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        _showNotImplementedSnackBar(
            'clearAutomationHistory not implemented in ContextManager.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to clear history: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.cyanAccent, Colors.blueAccent],
                ),
              ),
              child: const Icon(Icons.settings, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'SYSTEM SETTINGS',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Help & Onboarding',
            icon: const Icon(Icons.help_outline, color: Colors.cyanAccent),
            onPressed: () {
              _showInfoDialog(
                'About Settings',
                'Manage overlay, permissions, privacy and automations. Use the Onboarding flow to re-check required permissions and onboarding steps.',
              );
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<ContextManager>(
            builder: (context, ctx, _) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSectionHeader('ASSISTANT & OVERLAY'),
                  const SizedBox(height: 16),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      'Enable Overlay Sidebar',
                      'System-wide floating assistant',
                      ctx.overlayEnabled,
                      (v) {
                        try {
                          ctx.setOverlayEnabled(v);
                        } catch (e) {
                          _showNotImplementedSnackBar(
                              'setOverlayEnabled not implemented in ContextManager.');
                        }
                      },
                      Icons.layers,
                      Colors.greenAccent,
                    ),
                    _buildSwitchTile(
                      'Voice Activation',
                      'Always listening for wake words',
                      ctx.voiceEnabled,
                      (v) {
                        try {
                          ctx.setVoiceEnabled(v);
                        } catch (e) {
                          _showNotImplementedSnackBar(
                              'setVoiceEnabled not implemented in ContextManager.');
                        }
                      },
                      Icons.mic,
                      Colors.blueAccent,
                    ),
                    _buildSwitchTile(
                      'Context Awareness',
                      'Monitor app usage and activities',
                      ctx.contextAwarenessEnabled,
                      (v) {
                        try {
                          ctx.setContextAwarenessEnabled(v);
                        } catch (e) {
                          _showNotImplementedSnackBar(
                              'setContextAwarenessEnabled not implemented in ContextManager.');
                        }
                      },
                      Icons.psychology,
                      Colors.purpleAccent,
                    ),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader('AI & PRIVACY'),
                  const SizedBox(height: 16),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      'Cloud AI Processing',
                      'Use remote servers for advanced AI',
                      _useCloudAI,
                      (v) => setState(() => _useCloudAI = v),
                      Icons.cloud,
                      Colors.orangeAccent,
                    ),
                    _buildSwitchTile(
                      'Auto-run Trusted Actions',
                      'Execute suggestions without confirmation',
                      _autoRunTrusted,
                      (v) => setState(() => _autoRunTrusted = v),
                      Icons.auto_mode,
                      Colors.redAccent,
                    ),
                    _buildSwitchTile(
                      'Anonymous Telemetry',
                      'Help improve EternalOS',
                      _sendAnonymizedTelemetry,
                      (v) => setState(() => _sendAnonymizedTelemetry = v),
                      Icons.analytics,
                      Colors.tealAccent,
                    ),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader('SYSTEM'),
                  const SizedBox(height: 16),
                  _buildSettingsCard([
                    _buildActionTile(
                      'Re-run Onboarding',
                      'Check permissions and setup',
                      Icons.refresh,
                      Colors.cyanAccent,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const OnboardingScreen()),
                      ),
                    ),
                    _buildActionTile(
                      'Clear History',
                      'Remove automation logs',
                      Icons.delete_forever,
                      Colors.redAccent,
                      () => _confirmAndClearHistory(ctx),
                    ),
                    _buildActionTile(
                      'System Information',
                      'View device and app details',
                      Icons.info,
                      Colors.white70,
                      () => _showInfoDialog(
                        'System Information',
                        'EternalOS v1.0.0\n'
                            'Built with Flutter\n'
                            'AI Powered by Puter\n'
                            'Platform: ${Theme.of(context).platform}',
                      ),
                    ),
                  ]),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'ETERNAL OS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 12,
                        fontFamily: 'Orbitron',
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyanAccent, Colors.blueAccent],
            ),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
    Color accentColor,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              accentColor.withOpacity(0.2),
              accentColor.withOpacity(0.1)
            ],
          ),
        ),
        child: Icon(icon, color: accentColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: accentColor,
        activeTrackColor: accentColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              accentColor.withOpacity(0.2),
              accentColor.withOpacity(0.1)
            ],
          ),
        ),
        child: Icon(icon, color: accentColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.white.withOpacity(0.5),
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
