import 'puter_ai_service.dart';

class AIService {
  final PuterAIService _puterService;

  AIService(this._puterService);

  Future<void> initialize() async {
    await _puterService.initialize();
  }

  Future<String> analyzeContext(String contextDescription) async {
    final prompt = '''
Analyze the following user context and provide insights about their current activity and potential needs:

$contextDescription

Provide a brief analysis (2-3 sentences) of what the user might be doing and any relevant suggestions.
''';
    return await _generateResponse(prompt);
  }

  Future<String> generateSuggestions(
      String historyText, String timeOfDay) async {
    final prompt = '''
Based on the user's action history and current time of day ($timeOfDay), suggest 3 helpful actions or automations they might want:

History: $historyText

Provide 3 concise suggestions, one per line.
''';
    return await _generateResponse(prompt);
  }

  Future<String> generateAutomation(String trigger, String context) async {
    final prompt = '''
Suggest an automation based on:
Trigger: $trigger
Context: $context

Provide a simple automation rule in the format: "When [condition], then [action]"
''';
    return await _generateResponse(prompt);
  }

  Future<String> processVoiceQuery(String query, String currentContext) async {
    final prompt = '''
User query: "$query"
Current context: $currentContext

As an AI assistant in an operating system, provide a helpful response and suggest actions.
Keep the response concise but informative.
''';
    return await _generateResponse(prompt);
  }

  Future<String> _generateResponse(String prompt) async {
    try {
      return await _puterService.chat(prompt);
    } catch (e) {
      return 'AI service unavailable: $e';
    }
  }
}
