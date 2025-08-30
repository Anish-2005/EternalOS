import 'package:flutter/material.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final Map<String, bool> _permissions = {
    'microphone': false,
    'accessibility': false,
    'overlay': false,
  };

  void _toggle(String key) =>
      setState(() => _permissions[key] = !(_permissions[key] ?? false));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Setup & Permissions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCard(
                '🎙️ Microphone Access',
                'Enable voice capture for the assistant',
                _permissions['microphone']!,
                () => _toggle('microphone')),
            const SizedBox(height: 12),
            _buildCard(
                '👁️ Screen Context (Accessibility)',
                'Allow EternalOS to read on-screen UI to provide contextual actions',
                _permissions['accessibility']!,
                () => _toggle('accessibility')),
            const SizedBox(height: 12),
            _buildCard(
                '🔮 Overlay Permission',
                'Allow floating assistant overlay for mini-mode',
                _permissions['overlay']!,
                () => _toggle('overlay')),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _permissions.values.any((v) => v)
                    ? () => Navigator.of(context).pushReplacementNamed('/')
                    : null,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14)),
                child: Text('Enable & Continue',
                    style: theme.textTheme.titleMedium),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      String title, String subtitle, bool enabled, VoidCallback onTap) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Switch(value: enabled, onChanged: (_) => onTap()),
        onTap: onTap,
      ),
    );
  }
}
