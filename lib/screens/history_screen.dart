import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctx = Provider.of<ContextManager>(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Action History', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height:
                  constraints.maxHeight - 72, // leave space for title+padding
              child: ListView.separated(
                itemCount: ctx.history.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final h = ctx.history[i];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading:
                          Icon(Icons.history, color: theme.iconTheme.color),
                      title: Text(h.title),
                      subtitle: Text('${h.time}'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
