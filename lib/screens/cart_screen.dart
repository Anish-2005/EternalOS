import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctx = Provider.of<ContextManager>(context);
    final entries = ctx.cart.entries.toList();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Cart', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child:
                      Text('Cart is empty', style: theme.textTheme.bodyMedium),
                ),
              ),
            if (entries.isNotEmpty)
              SizedBox(
                height: constraints.maxHeight - 120,
                child: ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: Text(e.key),
                        subtitle: Text('Quantity: ${e.value}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => ctx.removeFromCart(e.key),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: entries.isEmpty ? null : () => ctx.clearCart(),
              child: const Text('Clear Cart'),
            )
          ],
        );
      }),
    );
  }
}
