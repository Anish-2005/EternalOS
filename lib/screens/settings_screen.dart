import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
