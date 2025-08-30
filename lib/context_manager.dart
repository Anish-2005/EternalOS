import 'package:flutter/material.dart';

class ActionRecord {
  final String title;
  final DateTime time;
  ActionRecord(this.title, [DateTime? t]) : time = t ?? DateTime.now();
}

class ScreenContext {
  String activeApp;
  List<String> visibleItems;
  List<String> possibleActions;
  ScreenContext(
      {this.activeApp = 'Home',
      List<String>? visibleItems,
      List<String>? possibleActions})
      : visibleItems = visibleItems ?? [],
        possibleActions = possibleActions ?? [];
}

class ContextManager extends ChangeNotifier {
  // Visible UI items for the in-app MVP.
  List<String> items = ['Red Shoes', 'Blue Shoes', 'Black Hat', 'Green Jacket'];

  // Simple cart representation
  final Map<String, int> cart = {};

  // Action history
  final List<ActionRecord> history = [];

  // Current screen context
  ScreenContext currentContext = ScreenContext(
      activeApp: 'EternalOS',
      visibleItems: ['Red Shoes', 'Blue Shoes'],
      possibleActions: ['Add to cart']);

  int get cartTotalCount => cart.values.fold(0, (a, b) => a + b);

  void addHistory(String title) {
    history.insert(0, ActionRecord(title));
    // keep last 200
    if (history.length > 200) history.removeRange(200, history.length);
    notifyListeners();
  }

  /// Try to resolve a fuzzy item name to a visible item.
  /// Returns the exact item string if found, otherwise null.
  String? resolveTarget(String query) {
    if (query.isEmpty) return null;
    final q = query.toLowerCase();
    // exact contains match
    for (final it in items) {
      if (it.toLowerCase() == q) return it;
    }
    for (final it in items) {
      if (it.toLowerCase().contains(q) || q.contains(it.toLowerCase()))
        return it;
    }
    // fallback: token match
    final tokens = q.split(RegExp('\\s+'));
    for (final it in items) {
      final lower = it.toLowerCase();
      var score = 0;
      for (final t in tokens) {
        if (lower.contains(t)) score++;
      }
      if (score >= 1) return it;
    }
    return null;
  }

  void addToCart(String item, {int qty = 1}) {
    cart[item] = (cart[item] ?? 0) + qty;
    addHistory('Added $item to cart');
    notifyListeners();
  }

  void removeFromCart(String item) {
    cart.remove(item);
    addHistory('Removed $item from cart');
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    addHistory('Cleared cart');
    notifyListeners();
  }

  void updateScreenContext(ScreenContext ctx) {
    currentContext = ctx;
    notifyListeners();
  }
}
