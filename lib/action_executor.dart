import 'context_manager.dart';
import 'ai_service.dart';

class ActionExecutor {
  final ContextManager context;
  final AIService _aiService;

  ActionExecutor(this.context, this._aiService);

  /// Executes AI-driven actions for an OS-like experience.
  /// Supports intents: ADD_TO_CART, SHOW_CART, CLEAR_CART, OPEN_APP, SEARCH, PLAY_MUSIC, SET_REMINDER, GET_SUGGESTIONS
  Future<String?> execute(Map<String, dynamic> action) async {
    final intent = action['intent'] as String? ?? 'NONE';
    final item = action['item'] as String? ?? '';
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
      case 'OPEN_APP':
        context.addHistory('Opened $item');
        context.updateActiveApp(item);
        return 'Opening $item...';
      case 'SEARCH':
        context.addHistory('Searched for $item');
        return 'Searching for $item...';
      case 'PLAY_MUSIC':
        context.addHistory('Playing $item');
        return 'Playing $item...';
      case 'SET_REMINDER':
        context.addHistory('Set reminder: $item');
        return 'Reminder set for $item.';
      case 'GET_SUGGESTIONS':
        final suggestions = context.currentContext.aiSuggestions;
        return 'Suggestions: ${suggestions.join(', ')}';
      default:
        // Use AI to handle unknown queries with fallback
        try {
          final currentContext = '''
Active App: ${context.currentContext.activeApp}
Time: ${context.currentContext.timeOfDay}
Recent Actions: ${context.history.take(3).map((h) => h.title).join(', ')}
''';
          final aiResponse =
              await _aiService.processVoiceQuery(item, currentContext);
          context.addHistory('AI Response: $aiResponse');
          return aiResponse;
        } catch (e) {
          // Fallback response when AI is unavailable
          String fallbackResponse = '';

          if (e.toString().contains('429') || e.toString().contains('quota')) {
            fallbackResponse = '''
I understand you said: "$item"

I'm currently experiencing high demand and my AI processing is temporarily limited. Here are some things I can help you with:

• Open apps (say "open WhatsApp" or "open Spotify")
• Search for content (say "search for notes")
• Play music (say "play music")
• Set reminders (say "remind me to call mom")
• Manage your cart (say "add item to cart" or "show cart")

Please try again in a few minutes when the quota resets, or use one of the basic commands above.
''';
          } else {
            fallbackResponse = '''
I understand you said: "$item"

I'm having trouble processing that right now. You can try:
• Basic commands like "open WhatsApp" or "play music"
• Simple searches like "search for notes"
• Cart management: "add item to cart"

Please check your internet connection and try again.
''';
          }

          context.addHistory('Fallback Response: $fallbackResponse');
          return fallbackResponse;
        }
    }
  }
}
