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

  void _toggle(String key) {
    setState(() => _permissions[key] = !(_permissions[key] ?? false));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allEnabled = _permissions.values.every((v) => v);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup & Permissions'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPermissionCard(
                context,
                icon: Icons.mic_rounded,
                emoji: '🎙️',
                title: 'Microphone Access',
                subtitle: 'Enable voice capture for the assistant',
                enabled: _permissions['microphone']!,
                onTap: () => _toggle('microphone'),
              ),
              const SizedBox(height: 12),
              _buildPermissionCard(
                context,
                icon: Icons.visibility_rounded,
                emoji: '👁️',
                title: 'Screen Context (Accessibility)',
                subtitle:
                    'Allow EternalOS to understand on-screen UI for smart actions',
                enabled: _permissions['accessibility']!,
                onTap: () => _toggle('accessibility'),
              ),
              const SizedBox(height: 12),
              _buildPermissionCard(
                context,
                icon: Icons.blur_on_rounded,
                emoji: '🔮',
                title: 'Overlay Permission',
                subtitle:
                    'Enable floating assistant overlay for mini-mode access',
                enabled: _permissions['overlay']!,
                onTap: () => _toggle('overlay'),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(
                    allEnabled ? Icons.check_circle_outline : Icons.lock_open,
                    size: 22,
                  ),
                  label: Text(
                    allEnabled ? 'Continue to EternalOS' : 'Enable & Continue',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _permissions.values.any((v) => v)
                      ? () => Navigator.of(context).pushReplacementNamed('/')
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    backgroundColor: allEnabled
                        ? theme.colorScheme.primary
                        : theme.disabledColor.withOpacity(0.2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: allEnabled ? 1 : 0.6,
                child: Text(
                  allEnabled
                      ? 'All permissions granted — you’re good to go!'
                      : 'Grant required permissions to proceed.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard(
    BuildContext context, {
    required IconData icon,
    required String emoji,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: enabled
            ? theme.colorScheme.primaryContainer.withOpacity(0.2)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (enabled)
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.1),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Switch.adaptive(value: enabled, onChanged: (_) => onTap()),
        onTap: onTap,
      ),
    );
  }
}
