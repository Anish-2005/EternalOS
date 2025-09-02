import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = 'AIzaSyDXMTeImv3SkZw1u3ElbmEdrA5XuF-eRhw';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  // Rate limiting
  static const int _maxRequestsPerMinute = 10; // Conservative limit
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  final List<DateTime> _requestTimestamps = [];

  // Caching
  final Map<String, String> _responseCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 2);

  Future<String> generateResponse(String prompt) async {
    // Check cache first
    if (_isCached(prompt)) {
      return _responseCache[prompt]!;
    }

    // Rate limiting check
    if (!_canMakeRequest()) {
      return 'Rate limit exceeded. Please wait before making another request.';
    }

    // Record request timestamp
    _recordRequest();

    int retryCount = 0;
    Duration delay = _initialRetryDelay;

    while (retryCount < _maxRetries) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final result = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'No response generated';

          // Cache the response
          _cacheResponse(prompt, result);
          return result;
        } else if (response.statusCode == 429) {
          // Rate limit exceeded
          if (retryCount < _maxRetries - 1) {
            retryCount++;
            await Future.delayed(delay);
            delay *= 2; // Exponential backoff
            continue;
          } else {
            return 'API quota exceeded. Please try again later or consider upgrading your plan.';
          }
        } else if (response.statusCode == 400) {
          return 'Invalid request. Please check your input.';
        } else if (response.statusCode == 403) {
          return 'API access forbidden. Please check your API key.';
        } else if (response.statusCode >= 500) {
          // Server error, retry
          if (retryCount < _maxRetries - 1) {
            retryCount++;
            await Future.delayed(delay);
            delay *= 2;
            continue;
          } else {
            return 'Server error. Please try again later.';
          }
        } else {
          return 'Error: ${response.statusCode} - ${response.body}';
        }
      } catch (e) {
        if (retryCount < _maxRetries - 1) {
          retryCount++;
          await Future.delayed(delay);
          delay *= 2;
          continue;
        } else {
          return 'Error communicating with AI: $e';
        }
      }
    }

    return 'Failed to generate response after $_maxRetries attempts.';
  }

  bool _canMakeRequest() {
    final now = DateTime.now();
    // Remove timestamps older than the rate limit window
    _requestTimestamps.removeWhere((timestamp) =>
        now.difference(timestamp) > _rateLimitWindow);

    return _requestTimestamps.length < _maxRequestsPerMinute;
  }

  void _recordRequest() {
    _requestTimestamps.add(DateTime.now());
  }

  bool _isCached(String prompt) {
    if (!_responseCache.containsKey(prompt)) return false;

    final cacheTime = _cacheTimestamps[prompt]!;
    return DateTime.now().difference(cacheTime) < _cacheDuration;
  }

  void _cacheResponse(String prompt, String response) {
    _responseCache[prompt] = response;
    _cacheTimestamps[prompt] = DateTime.now();

    // Clean up old cache entries
    _cleanupCache();
  }

  void _cleanupCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _cacheDuration) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _responseCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  Future<String> analyzeContext(String contextDescription) async {
    final prompt = '''
Analyze this context and provide insights:
$contextDescription

Provide:
1. Current activity analysis
2. Suggested actions
3. Potential improvements
4. Smart recommendations
''';
    return await generateResponse(prompt);
  }

  Future<String> processVoiceQuery(String query, String currentContext) async {
    final prompt = '''
User query: "$query"
Current context: $currentContext

As an AI assistant in an operating system, provide a helpful response and suggest actions.
Keep the response concise but informative.
''';
    return await generateResponse(prompt);
  }

  Future<String> generateSuggestions(String userHistory, String timeOfDay) async {
    final prompt = '''
Based on user history: $userHistory
Current time: $timeOfDay

Generate 3 personalized suggestions for the user.
''';
    return await generateResponse(prompt);
  }

  // Method to clear cache manually if needed
  void clearCache() {
    _responseCache.clear();
    _cacheTimestamps.clear();
  }

  // Method to get current rate limit status
  Map<String, dynamic> getRateLimitStatus() {
    final now = DateTime.now();
    _requestTimestamps.removeWhere((timestamp) =>
        now.difference(timestamp) > _rateLimitWindow);

    return {
      'requestsInWindow': _requestTimestamps.length,
      'maxRequestsPerMinute': _maxRequestsPerMinute,
      'canMakeRequest': _canMakeRequest(),
      'cachedResponses': _responseCache.length,
    };
  }
}
