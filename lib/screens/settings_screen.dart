import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';
import '../widgets/fullscreen_overlay.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctx = Provider.of<ContextManager>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Microphone permissions and onboarding will be shown here.',
                      style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text('This is a placeholder for assistant settings.',
                      style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Enable Overlay Sidebar',
                          style: theme.textTheme.bodyMedium),
                      Switch(
                          value: ctx.overlayEnabled,
                          onChanged: (v) => ctx.setOverlayEnabled(v)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // open the full-screen Flutter overlay mock
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const FullscreenOverlay()));
                    },
                    child: const Text('Show Fullscreen Overlay (mock)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // reopen onboarding
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const OnboardingScreen()));
                    },
                    child: const Text('Re-run Onboarding'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
