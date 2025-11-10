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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        centerTitle: true,
        actions: [
          if (entries.isNotEmpty)
            IconButton(
              tooltip: 'Clear Cart',
              icon: const Icon(Icons.delete_forever_rounded),
              onPressed: ctx.clearCart,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: entries.isEmpty
              ? _buildEmptyState(theme)
              : _buildCartList(entries, ctx, theme),
        ),
      ),
    );
  }

  /// Empty state widget with icon and subtle text
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty!',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some items to get started.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// List of cart items
  Widget _buildCartList(
      List<MapEntry<String, int>> entries, ContextManager ctx, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items in Cart (${entries.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final e = entries[i];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        theme.colorScheme.primaryContainer.withOpacity(0.3),
                    child: Text(
                      e.value.toString(),
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    e.key,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Quantity: ${e.value}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: theme.colorScheme.error,
                    onPressed: () => ctx.removeFromCart(e.key),
                    tooltip: 'Remove item',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text('Clear Cart'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
            ),
            onPressed: ctx.clearCart,
          ),
        ),
      ],
    );
  }
}
