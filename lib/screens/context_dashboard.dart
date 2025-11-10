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
⚠️ Rate limit reached (${rateLimitStatus['requestsInWindow']}/${rateLimitStatus['maxRequestsPerMinute']} requests per minute).

Please wait a moment before requesting analysis again.

Cached responses available: ${rateLimitStatus['cachedResponses']}
''');
        return;
      }

      final analysis = await aiService.analyzeContext(contextDescription);
      setState(() => _aiAnalysis = analysis);
    } catch (e) {
      setState(() => _aiAnalysis = '''
❌ Error analyzing context: $e

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Context Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Analysis',
            onPressed: _isAnalyzing ? null : _analyzeContext,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _analyzeContext,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Current Context', theme),
              _buildInfoCard('Active App', sc.activeApp, theme),
              _buildInfoCard('Visible Items',
                  sc.visibleItems.isEmpty ? 'None' : sc.visibleItems.join(', '), theme),
              _buildActionsCard(sc.possibleActions, theme),

              const SizedBox(height: 24),
              _buildSectionHeader('AI Context Analysis', theme),
              _buildAnalysisCard(theme),

              const SizedBox(height: 24),
              _buildActionButtons(ctx),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSectionHeader(String title, ThemeData theme) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _buildInfoCard(String title, String value, ThemeData theme) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(
          value,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget _buildActionsCard(List<String> actions, ThemeData theme) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Possible Actions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (actions.isEmpty)
              Text('No available actions.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor)),
            if (actions.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions
                    .map(
                      (a) => OutlinedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: Text(a),
                        onPressed: () {},
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minHeight: 100),
        child: _isAnalyzing
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      'Analyzing context...',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            : SelectableText(
                _aiAnalysis ?? 'No analysis available yet.',
                style: theme.textTheme.bodyMedium,
              ),
      ),
    );
  }

  Widget _buildActionButtons(ContextManager ctx) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh Analysis'),
            onPressed: _isAnalyzing ? null : _analyzeContext,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.bolt_rounded),
            label: const Text('Execute Suggested Action'),
            onPressed: () =>
                ctx.addHistory('Executed suggested AI action'),
          ),
        ),
      ],
    );
  }
}
