import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF0F044C), Color(0xFF00E5FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Placeholder for Rive infinity animation
                SizedBox(
                  width: 160,
                  height: 160,
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _ctrl.value * 6.28,
                        child: Opacity(
                          opacity: 0.85 + 0.15 * (_ctrl.value - 0.5).abs(),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          Color.fromRGBO(178, 235, 242, 0.9),
                          Colors.deepPurple.shade700
                        ]),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(0, 188, 212, 0.25),
                              blurRadius: 20,
                              spreadRadius: 4)
                        ],
                      ),
                      child: Center(
                        child: Text('∞',
                            style: theme.textTheme.headlineLarge
                                ?.copyWith(color: Colors.white, fontSize: 56)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('EternalOS',
                    style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Text('The Intelligent Operating System Within',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed('/permissions'),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14)),
                  child: const Text('Begin Journey'),
                ),
                const SizedBox(height: 12),
                TextButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                            title: const Text('Learn More'),
                            content: const Text(
                                'EternalOS is a contextual voice assistant...'))),
                    child: const Text('Learn More',
                        style: TextStyle(color: Colors.white70))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
