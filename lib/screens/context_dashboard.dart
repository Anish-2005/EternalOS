import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';

class ContextDashboard extends StatelessWidget {
  const ContextDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctx = Provider.of<ContextManager>(context);
    final sc = ctx.currentContext;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Context', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                  title: const Text('Active App'),
                  subtitle: Text(sc.activeApp)),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                  title: const Text('Visible Items'),
                  subtitle: Text(sc.visibleItems.join(', '))),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: const Text('Possible Actions'),
                subtitle: Wrap(
                    spacing: 8,
                    children: sc.possibleActions
                        .map((a) =>
                            ElevatedButton(onPressed: () {}, child: Text(a)))
                        .toList()),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: () => ctx.addHistory('Executed suggested action'),
                child: const Text('Execute Suggested Action'))
          ],
        ),
      ),
    );
  }
}
