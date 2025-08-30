class NLU {
  /// Very small rule-based parser for MVP.
  /// Returns a map with keys: 'intent' and 'item' (raw slot text if found).
  static Map<String, String> parse(String transcript) {
    final t = transcript.trim().toLowerCase();
    if (t.isEmpty) return {'intent': 'NONE', 'item': ''};

    // Simple patterns for "add X" or "add X to cart"
    final addRegex = RegExp(r'add\s+(?:the\s+)?(.+?)(?:\s+to\s+cart)?\s*\$');
    final addMatch = addRegex.firstMatch(t + ' ');
    if (addMatch != null) {
      final item = addMatch.group(1)?.trim() ?? '';
      return {'intent': 'ADD_TO_CART', 'item': item};
    }

    // fallback contains "add" then try to pick word after add
    if (t.contains('add')) {
      final parts = t.split('add');
      if (parts.length > 1) {
        final item = parts[1].trim();
        return {'intent': 'ADD_TO_CART', 'item': item};
      }
    }

    // other simple intents
    if (t.contains('show cart') || t.contains('open cart'))
      return {'intent': 'SHOW_CART', 'item': ''};
    if (t.contains('clear cart') || t.contains('empty cart'))
      return {'intent': 'CLEAR_CART', 'item': ''};

    return {'intent': 'UNKNOWN', 'item': ''};
  }
}
