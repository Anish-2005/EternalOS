import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_service.dart';
import 'native_bridge.dart';
import 'puter_ai_service.dart';

class ActionRecord {
  final String title;
  final DateTime time;
  ActionRecord(this.title, [DateTime? t]) : time = t ?? DateTime.now();
}

class ScreenContext {
  String activeApp;
  List<String> visibleItems;
  List<String> possibleActions;
  String timeOfDay;
  List<String> aiSuggestions;

  ScreenContext({
    this.activeApp = 'Home',
    List<String>? visibleItems,
    List<String>? possibleActions,
    this.timeOfDay = 'morning',
    List<String>? aiSuggestions,
  })  : visibleItems = visibleItems ?? [],
        possibleActions = possibleActions ?? [],
        aiSuggestions = aiSuggestions ?? [];
}

class ContextManager extends ChangeNotifier {
  final AIService _aiService;
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
    possibleActions: ['Add to cart'],
    timeOfDay: 'morning',
    aiSuggestions: ['Try adding an item to cart', 'Check your history'],
  );

  // Whether the overlay sidebar should be shown (persisted)
  bool overlayEnabled = true;
  bool onboardingSeen = false;

  ContextManager(PuterAIService puterService)
      : _aiService = AIService(puterService) {
    _updateDynamicContext();
    _setupNativeContextListener();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    await _aiService.initialize();
  }

  void _setupNativeContextListener() {
    NativeBridge.setContextUpdateHandler((data) {
      if (data is Map) {
        final packageName = data['packageName'] as String?;
        final className = data['className'] as String?;
        final text = data['text'] as String?;
        if (packageName != null) {
          currentContext.activeApp = _getAppNameFromPackage(packageName);
          currentContext.visibleItems = _extractVisibleItems(text);
          _updateDynamicContext();
        }
      }
    });
  }

  String _getAppNameFromPackage(String packageName) {
    // Simple mapping; in real app, use package manager or database
    final map = {
      'com.android.chrome': 'Chrome',
      'com.google.android.youtube': 'YouTube',
      'com.instagram.android': 'Instagram',
      // Add more mappings
    };
    return map[packageName] ?? packageName.split('.').last;
  }

  List<String> _extractVisibleItems(String? text) {
    if (text == null || text.isEmpty) return [];
    // Simple extraction; in real app, use NLP
    return text
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3)
        .take(5)
        .toList();
  }

  void _updateDynamicContext() {
    final now = DateTime.now();
    final hour = now.hour;
    String timeOfDay;
    if (hour < 12) {
      timeOfDay = 'morning';
    } else if (hour < 18) {
      timeOfDay = 'afternoon';
    } else {
      timeOfDay = 'evening';
    }

    currentContext.timeOfDay = timeOfDay;
    currentContext.aiSuggestions = _generateAISuggestions();
    notifyListeners();
  }

  List<String> _generateAISuggestions() {
    // This will be replaced with AI-generated suggestions
    List<String> suggestions = [];
    final recentActions = history.take(5).map((h) => h.title).toList();

    if (cart.isEmpty) {
      suggestions.add('Add items to your cart');
    }
    if (recentActions.any((a) => a.contains('music'))) {
      suggestions.add('Continue listening to music');
    }
    if (currentContext.timeOfDay == 'morning') {
      suggestions.add('Start your day with some tasks');
    } else if (currentContext.timeOfDay == 'evening') {
      suggestions.add('Review your completed tasks');
    }
    if (suggestions.isEmpty) {
      suggestions.add('Explore available apps');
    }
    return suggestions.take(3).toList();
  }

  Future<String> getAIContextAnalysis() async {
    final contextDescription = '''
Active App: ${currentContext.activeApp}
Visible Items: ${currentContext.visibleItems.join(', ')}
Possible Actions: ${currentContext.possibleActions.join(', ')}
Time of Day: ${currentContext.timeOfDay}
Recent History: ${history.take(5).map((h) => h.title).join(', ')}
Cart Items: ${cart.length}
''';
    return await _aiService.analyzeContext(contextDescription);
  }

  Future<String> getAISuggestions() async {
    final historyText = history.take(10).map((h) => h.title).join(', ');
    return await _aiService.generateSuggestions(
        historyText, currentContext.timeOfDay);
  }

  Future<void> setOverlayEnabled(bool v) async {
    overlayEnabled = v;
    notifyListeners();
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool('overlayEnabled', v);
    } catch (_) {}
  }

  Future<void> setOnboardingSeen(bool v) async {
    onboardingSeen = v;
    notifyListeners();
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool('onboardingSeen', v);
    } catch (_) {}
  }

  Future<void> loadPreferences() async {
    try {
      final sp = await SharedPreferences.getInstance();
      overlayEnabled = sp.getBool('overlayEnabled') ?? overlayEnabled;
      onboardingSeen = sp.getBool('onboardingSeen') ?? onboardingSeen;
      notifyListeners();
    } catch (_) {}
  }

  int get cartTotalCount => cart.values.fold(0, (a, b) => a + b);

  void addHistory(String title) {
    history.insert(0, ActionRecord(title));
    // keep last 200
    if (history.length > 200) history.removeRange(200, history.length);
    _updateDynamicContext();
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
    _updateDynamicContext();
    notifyListeners();
  }

  void updateActiveApp(String app) {
    currentContext.activeApp = app;
    _updateDynamicContext();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    history.clear();
    _updateDynamicContext();
    notifyListeners();
  }

  Future<void> clearAutomationHistory() async {
    // For now, clear the same history; can be differentiated later if needed
    await clearHistory();
  }

  AIService get aiService => _aiService;
}
