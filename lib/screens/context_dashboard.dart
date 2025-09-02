import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';
import '../ai_service.dart';

class ContextDashboard extends StatefulWidget {
  const ContextDashboard({super.key});

  @override
  State<ContextDashboard> createState() => _ContextDashboardState();
}

class _ContextDashboardState extends State<ContextDashboard> {
  String? _aiAnalysis;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _analyzeContext();
  }

  Future<void> _analyzeContext() async {
    setState(() => _isAnalyzing = true);
    try {
      final ctx = Provider.of<ContextManager>(context, listen: false);
      final aiService = AIService();
      final contextDescription = '''
Active App: ${ctx.currentContext.activeApp}
Visible Items: ${ctx.currentContext.visibleItems.join(', ')}
Possible Actions: ${ctx.currentContext.possibleActions.join(', ')}
Time of Day: ${ctx.currentContext.timeOfDay}
AI Suggestions: ${ctx.currentContext.aiSuggestions.join(', ')}
''';

      // Check rate limit status before making request
      final rateLimitStatus = aiService.getRateLimitStatus();
      if (!rateLimitStatus['canMakeRequest']) {
        setState(() => _aiAnalysis = '''
Rate limit reached (${rateLimitStatus['requestsInWindow']}/${rateLimitStatus['maxRequestsPerMinute']} requests per minute).

Please wait a moment before requesting analysis again.

Cached responses available: ${rateLimitStatus['cachedResponses']}
''');
        return;
      }

      final analysis = await aiService.analyzeContext(contextDescription);
      setState(() => _aiAnalysis = analysis);
    } catch (e) {
      setState(() => _aiAnalysis = '''
Error analyzing context: $e

This might be due to:
• API quota exceeded
• Network connectivity issues
• Server maintenance

Please try again later or check your internet connection.
''');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctx = Provider.of<ContextManager>(context);
    final sc = ctx.currentContext;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Context', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                  title: const Text('Active App'),
                  subtitle: Text(sc.activeApp)),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                  title: const Text('Visible Items'),
                  subtitle: Text(sc.visibleItems.join(', '))),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: const Text('Possible Actions'),
                subtitle: Wrap(
                    spacing: 8,
                    children: sc.possibleActions
                        .map((a) =>
                            ElevatedButton(onPressed: () {}, child: Text(a)))
                        .toList()),
              ),
            ),
            const SizedBox(height: 12),
            Text('AI Context Analysis', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isAnalyzing
                    ? const CircularProgressIndicator()
                    : Text(_aiAnalysis ?? 'No analysis available'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                    onPressed: _analyzeContext,
                    child: const Text('Refresh Analysis')),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: () => ctx.addHistory('Executed suggested action'),
                    child: const Text('Execute Suggested Action'))
              ],
            )
          ],
        ),
      ),
    );
  }
}
