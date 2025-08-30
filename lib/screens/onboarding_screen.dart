import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctx = Provider.of<ContextManager>(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Overlay Onboarding')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About the Overlay', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('The overlay allows EternalOS to provide quick access to the assistant across apps.\n\nIt will appear above other apps and provide controls to speak, see context, and quick actions.', style: theme.textTheme.bodyMedium),
            const Spacer(),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: () async { await ctx.setOverlayEnabled(true); await ctx.setOnboardingSeen(true); Navigator.of(context).pop(); }, child: const Text('Enable Overlay'))),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () async { await ctx.setOnboardingSeen(true); Navigator.of(context).pop(); }, child: const Text('Skip'))
          ],
        ),
      ),
    );
  }
}
