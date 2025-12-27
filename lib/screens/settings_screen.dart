import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';
import '../native_bridge.dart';
import '../widgets/fullscreen_overlay.dart';
import 'onboarding_screen.dart';

/// Improved Settings screen for EternalOS
///
/// - Uses a ListView so content scrolls on small devices.
/// - Provides clearer labels, icons, and helpful dialogs for permissions/privacy.
/// - Uses `Consumer` to avoid rebuilding the whole tree when only a small part changes.
/// - Adds confirmation dialogs for destructive actions and helpful SnackBars for placeholders.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local UI-only toggles (persist them in your ContextManager or storage as needed)
  bool _useCloudAI = false;
  bool _autoRunTrusted = false;
  bool _sendAnonymizedTelemetry = false;

  void _showInfoDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotImplementedSnackBar([String? msg]) {
    final text = msg ?? 'This feature is not implemented yet.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _confirmAndClearHistory(ContextManager ctx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('Clear automation history'),
        content: const Text(
            'This will remove stored suggestions and automation logs from the device. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            style: ElevatedButton.styleFrom(elevation: 0),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // If your ContextManager exposes a clearHistory / clearAutomationHistory method,
      // call it here. The try/catch protects against missing methods during development.
      // Replace with the actual API call to clear history.
      // Example: await ctx.clearAutomationHistory();
      final clear = ctx.clearAutomationHistory;
      if (clear is Function) {
        await clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Automation history cleared.')),
        );
      } else {
        // Fallback if method doesn't exist
        _showNotImplementedSnackBar(
            'clearAutomationHistory not implemented in ContextManager.');
      }
    } catch (e) {
      // If ContextManager does not provide the method or it fails, show feedback.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear history: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = EdgeInsets.symmetric(
      horizontal: 16,
      vertical: MediaQuery.of(context).size.height * 0.02,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Onboarding & help',
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showInfoDialog(
                'About Settings',
                'Manage overlay, permissions, privacy and automations. Use the Onboarding flow to re-check required permissions and onboarding steps.',
              );
            },
          )
        ],
      ),
      body: Consumer<ContextManager>(
        builder: (context, ctx, _) {
          return ListView(
            padding: padding,
            children: [
              Text('Assistant & Overlay',
                  style: theme.textTheme.titleLarge,
                  semanticsLabel: 'Assistant and overlay settings'),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Overlay toggle
                    SwitchListTile.adaptive(
                      value: ctx.overlayEnabled,
                      onChanged: (v) {
                        try {
                          ctx.setOverlayEnabled(v);
                        } catch (e) {
                          // Fallback if method not found
                          _showNotImplementedSnackBar(
                              'setOverlayEnabled not implemented in ContextManager.');
                        }
                      },
                      title: const Text('Enable overlay sidebar'),
                      subtitle: const Text(
                          'Show the floating overlay control across apps.'),
                      secondary: const Icon(Icons.view_sidebar),
                    ),

                    // Request overlay permission
                    ListTile(
                      leading: const Icon(Icons.settings_applications),
                      title: const Text('Request overlay permission'),
                      subtitle: const Text(
                          'Grant permission to draw over other apps.'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final granted =
                              await NativeBridge.requestOverlayPermission();
                          if (granted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Overlay permission granted')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please grant overlay permission in settings')),
                            );
                          }
                        },
                        child: const Text('Request'),
                      ),
                    ),

                    // Show/Hide overlay
                    ListTile(
                      leading: const Icon(Icons.visibility),
                      title: const Text('Show system overlay'),
                      subtitle: const Text('Display the system-wide overlay.'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          if (ctx.overlayEnabled) {
                            await NativeBridge.showNativeOverlay();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Overlay shown')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Enable overlay first')),
                            );
                          }
                        },
                        child: const Text('Show'),
                      ),
                    ),

                    // Auto-run trusted automations
                    SwitchListTile.adaptive(
                      value: _autoRunTrusted,
                      onChanged: (v) => setState(() => _autoRunTrusted = v),
                      title: const Text('Auto-run trusted automations'),
                      subtitle: const Text(
                          'Allow automations you explicitly marked as "trusted" to run without confirmation. Use with caution.'),
                      secondary: const Icon(Icons.play_arrow_rounded),
                    ),

                    // Fullscreen overlay mock
                    ListTile(
                      leading: const Icon(Icons.fullscreen),
                      title: const Text('Show fullscreen overlay (mock)'),
                      subtitle:
                          const Text('Preview the fullscreen overlay UI.'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const FullscreenOverlay()),
                          );
                        },
                        child: const Text('Preview'),
                      ),
                    ),

                    const Divider(height: 1),

                    // Re-run onboarding
                    ListTile(
                      leading: const Icon(Icons.replay),
                      title: const Text('Re-run onboarding'),
                      subtitle: const Text(
                          'Re-open the onboarding flow to re-check permissions and walkthroughs.'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const OnboardingScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Permissions section
              Text('Permissions & Privacy', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Permissions guidance'),
                      subtitle: const Text(
                          'Instructions to enable overlay and accessibility permissions.'),
                      onTap: () {
                        _showInfoDialog(
                          'Enable required permissions',
                          '1) Allow "Display over other apps" in system settings.\n'
                              '2) Enable the EternalOS Accessibility Service.\n\n'
                              'Both are required for context recognition and overlays. We do not enable these automatically; follow the steps shown by the onboarding flow.',
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.cloud_outlined),
                      title: const Text('Use cloud AI (optional)'),
                      subtitle: const Text(
                          'Send anonymized context to a cloud provider to get richer suggestions. Opt-in only.'),
                      trailing: Switch.adaptive(
                        value: _useCloudAI,
                        onChanged: (v) {
                          setState(() => _useCloudAI = v);
                          if (v) {
                            _showInfoDialog(
                              'Cloud AI enabled',
                              'When enabled, minimized and anonymized context may be sent to a configured AI provider. Make sure you have configured your provider and consented to data usage in Privacy settings.',
                            );
                          }
                        },
                      ),
                    ),
                    SwitchListTile.adaptive(
                      value: _sendAnonymizedTelemetry,
                      onChanged: (v) {
                        setState(() => _sendAnonymizedTelemetry = v);
                      },
                      title: const Text('Send anonymized telemetry'),
                      subtitle: const Text(
                          'Help improve EternalOS while preserving privacy.'),
                      secondary: const Icon(Icons.bar_chart),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Clear automation history'),
                      subtitle:
                          const Text('Remove stored suggestions and logs.'),
                      onTap: () => _confirmAndClearHistory(ctx),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Developer / advanced
              Text('Advanced & Developer', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.developer_mode),
                      title: const Text('Open debug overlay'),
                      subtitle: const Text(
                          'Show debug info useful while developing.'),
                      onTap: () {
                        _showNotImplementedSnackBar(
                            'Debug overlay not implemented.');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('Export automations'),
                      subtitle: const Text(
                          'Export your automations as JSON for sharing.'),
                      onTap: () {
                        _showNotImplementedSnackBar(
                            'Export feature not implemented.');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.import_export),
                      title: const Text('Import automations'),
                      subtitle:
                          const Text('Import automations from a JSON file.'),
                      onTap: () {
                        _showNotImplementedSnackBar(
                            'Import feature not implemented.');
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Footer
              Center(
                child: Text(
                  'EternalOS — privacy-first contextual automation',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}
