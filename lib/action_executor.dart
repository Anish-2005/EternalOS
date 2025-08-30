import 'context_manager.dart';

class ActionExecutor {
  final ContextManager context;
  ActionExecutor(this.context);

  /// Executes a simple action map produced by the NLU + resolver.
  /// Supported intents: ADD_TO_CART, SHOW_CART, CLEAR_CART
  /// Returns a human-readable result string.
  Future<String?> execute(Map<String, dynamic> action) async {
    final intent = action['intent'] as String? ?? 'NONE';
    final resolved = action['resolvedItem'] as String?;
    switch (intent) {
      case 'ADD_TO_CART':
        if (resolved == null) return 'Could not resolve target item.';
        context.addToCart(resolved);
        return 'Added $resolved to cart.';
      case 'SHOW_CART':
        final total = context.cartTotalCount;
        return 'Cart has $total items.';
      case 'CLEAR_CART':
        context.clearCart();
        return 'Cart cleared.';
      default:
        return null;
    }
  }
}
