import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context_manager.dart';

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
      final aiService = ctx.aiService;

      final contextDescription = '''
Active App: ${ctx.currentContext.activeApp}
Visible Items: ${ctx.currentContext.visibleItems.join(', ')}
Possible Actions: ${ctx.currentContext.possibleActions.join(', ')}
Time of Day: ${ctx.currentContext.timeOfDay}
AI Suggestions: ${ctx.currentContext.aiSuggestions.join(', ')}
''';

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
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.cyanAccent, Colors.blueAccent],
                ),
              ),
              child:
                  const Icon(Icons.psychology, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'CONTEXT DASHBOARD',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: _isAnalyzing ? Colors.grey : Colors.cyanAccent,
            ),
            tooltip: 'Refresh Analysis',
            onPressed: _isAnalyzing ? null : _analyzeContext,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _analyzeContext,
          color: Colors.cyanAccent,
          backgroundColor: Colors.black.withOpacity(0.5),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('SYSTEM CONTEXT', theme),
                _buildContextGrid(sc, theme),
                const SizedBox(height: 32),
                _buildSectionHeader('AI ANALYSIS', theme),
                _buildAIAnalysisCard(theme),
                const SizedBox(height: 32),
                _buildActionButtons(ctx),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyanAccent, Colors.blueAccent],
              ),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextGrid(ScreenContext sc, ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildContextMetricCard(
            'Active App', sc.activeApp, Icons.apps, Colors.greenAccent),
        _buildContextMetricCard(
            'Time Context', sc.timeOfDay, Icons.schedule, Colors.orangeAccent),
        _buildContextMetricCard('Visible Items', '${sc.visibleItems.length}',
            Icons.visibility, Colors.purpleAccent),
        _buildContextMetricCard('Actions Available',
            '${sc.possibleActions.length}', Icons.bolt, Colors.redAccent),
      ],
    );
  }

  Widget _buildContextMetricCard(
      String title, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.2),
                  accentColor.withOpacity(0.1)
                ],
              ),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.cyanAccent, Colors.blueAccent],
                  ),
                ),
                child:
                    const Icon(Icons.psychology, color: Colors.black, size: 14),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI INSIGHTS',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (_isAnalyzing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            constraints: const BoxConstraints(minHeight: 120),
            child: _isAnalyzing
                ? Center(
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Colors.cyanAccent, Colors.blueAccent],
                            ),
                          ),
                          child: const Icon(Icons.psychology,
                              color: Colors.black, size: 20),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ANALYZING CONTEXT...',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  )
                : SelectableText(
                    _aiAnalysis ?? 'No analysis available yet.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ContextManager ctx) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.cyanAccent, Colors.blueAccent],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, color: Colors.black),
              label: const Text(
                'REFRESH ANALYSIS',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              onPressed: _isAnalyzing ? null : _analyzeContext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.bolt_rounded, color: Colors.cyanAccent),
              label: const Text(
                'EXECUTE ACTION',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              onPressed: () => ctx.addHistory('Executed suggested AI action'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
