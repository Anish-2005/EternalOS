class NLU {
  /// Enhanced rule-based parser for AI-like OS interactions.
  /// Supports intents: ADD_TO_CART, SHOW_CART, CLEAR_CART, OPEN_APP, SEARCH, PLAY_MUSIC, SET_REMINDER, etc.
  static Map<String, String> parse(String transcript) {
    final t = transcript.trim().toLowerCase();
    if (t.isEmpty) return {'intent': 'NONE', 'item': ''};

    // Add to cart patterns
    final addRegex = RegExp(
        r'(?:add|put|get)\s+(?:the\s+)?(.+?)(?:\s+to\s+(?:cart|basket))?\s*\$');
    final addMatch = addRegex.firstMatch(t + ' ');
    if (addMatch != null) {
      final item = addMatch.group(1)?.trim() ?? '';
      return {'intent': 'ADD_TO_CART', 'item': item};
    }

    // Open app patterns
    final openRegex = RegExp(r'(?:open|launch|start)\s+(.+)');
    final openMatch = openRegex.firstMatch(t);
    if (openMatch != null) {
      final app = openMatch.group(1)?.trim() ?? '';
      return {'intent': 'OPEN_APP', 'item': app};
    }

    // Search patterns
    final searchRegex = RegExp(r'(?:search|find|look for)\s+(.+)');
    final searchMatch = searchRegex.firstMatch(t);
    if (searchMatch != null) {
      final query = searchMatch.group(1)?.trim() ?? '';
      return {'intent': 'SEARCH', 'item': query};
    }

    // Play music patterns
    if (t.contains('play') &&
        (t.contains('music') || t.contains('song') || t.contains('playlist'))) {
      final playRegex = RegExp(r'play\s+(.+)');
      final playMatch = playRegex.firstMatch(t);
      final song = playMatch?.group(1)?.trim() ?? 'music';
      return {'intent': 'PLAY_MUSIC', 'item': song};
    }

    // Set reminder patterns
    final reminderRegex =
        RegExp(r'(?:remind|set reminder|reminder)\s+(?:me\s+)?(?:to\s+)?(.+)');
    final reminderMatch = reminderRegex.firstMatch(t);
    if (reminderMatch != null) {
      final task = reminderMatch.group(1)?.trim() ?? '';
      return {'intent': 'SET_REMINDER', 'item': task};
    }

    // Cart-related intents
    if (t.contains('show cart') ||
        t.contains('open cart') ||
        t.contains('view cart')) return {'intent': 'SHOW_CART', 'item': ''};
    if (t.contains('clear cart') ||
        t.contains('empty cart') ||
        t.contains('remove all')) return {'intent': 'CLEAR_CART', 'item': ''};

    // AI suggestions
    if (t.contains('suggest') || t.contains('recommend'))
      return {'intent': 'GET_SUGGESTIONS', 'item': ''};

    // Fallback for unknown
    return {'intent': 'UNKNOWN', 'item': ''};
  }
}
