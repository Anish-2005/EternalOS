import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctx = Provider.of<ContextManager>(context);
    final theme = Theme.of(context);
    final history = ctx.history.reversed.toList(); // latest first

    return Scaffold(
      appBar: AppBar(
        title: const Text('Action History'),
        centerTitle: true,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: 'Clear History',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: ctx.clearHistory,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: history.isEmpty
              ? _buildEmptyState(theme)
              : _buildHistoryList(history, theme),
        ),
      ),
    );
  }

  // Empty state view when there's no history
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No actions yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your recent actions will appear here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // History list when entries are available
  Widget _buildHistoryList(List<HistoryEntry> history, ThemeData theme) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final h = history[i];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: const Icon(Icons.history_rounded, size: 22),
            ),
            title: Text(
              h.title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              h.time.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        );
      },
    );
  }
}
