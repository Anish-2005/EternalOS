import 'package:flutter/material.dart';
import 'dart:math' as math;

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with TickerProviderStateMixin {
  final Map<String, bool> _permissions = {
    'microphone': false,
    'accessibility': false,
    'overlay': false,
  };

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _toggle(String key) {
    setState(() => _permissions[key] = !(_permissions[key] ?? false));
  }

  @override
  Widget build(BuildContext context) {
    final allEnabled = _permissions.values.every((v) => v);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
              Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background particles
              ..._buildFloatingParticles(),

              // Main content
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),

                          // Header section
                          AnimatedBuilder(
                            animation: _floatAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _floatAnimation.value),
                                child: child,
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.cyanAccent,
                                        Colors.blueAccent,
                                        Colors.purpleAccent
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.cyanAccent.withOpacity(0.4),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                      BoxShadow(
                                        color:
                                            Colors.blueAccent.withOpacity(0.3),
                                        blurRadius: 50,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.security,
                                    color: Colors.black,
                                    size: 50,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'PERMISSIONS',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Orbitron',
                                    color: Colors.white,
                                    letterSpacing: 3,
                                    shadows: [
                                      Shadow(
                                        color: Colors.cyanAccent,
                                        blurRadius: 10,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Grant access to unlock EternalOS capabilities',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    fontFamily: 'Orbitron',
                                    letterSpacing: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 60),

                          // Permissions section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.cyanAccent.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'REQUIRED ACCESS',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Orbitron',
                                    color: Colors.cyanAccent,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildPermissionCard(
                                  icon: Icons.mic_rounded,
                                  emoji: '🎙️',
                                  title: 'Microphone Access',
                                  subtitle:
                                      'Enable voice capture for the assistant',
                                  enabled: _permissions['microphone']!,
                                  onTap: () => _toggle('microphone'),
                                ),
                                const SizedBox(height: 20),
                                _buildPermissionCard(
                                  icon: Icons.visibility_rounded,
                                  emoji: '👁️',
                                  title: 'Screen Context (Accessibility)',
                                  subtitle:
                                      'Allow EternalOS to understand on-screen UI for smart actions',
                                  enabled: _permissions['accessibility']!,
                                  onTap: () => _toggle('accessibility'),
                                ),
                                const SizedBox(height: 20),
                                _buildPermissionCard(
                                  icon: Icons.blur_on_rounded,
                                  emoji: '🔮',
                                  title: 'Overlay Permission',
                                  subtitle:
                                      'Enable floating assistant overlay for mini-mode access',
                                  enabled: _permissions['overlay']!,
                                  onTap: () => _toggle('overlay'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 60),

                          // Action button
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: allEnabled
                                    ? [Colors.cyanAccent, Colors.blueAccent]
                                    : [
                                        Colors.grey.withOpacity(0.3),
                                        Colors.grey.withOpacity(0.1)
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: allEnabled
                                  ? [
                                      BoxShadow(
                                        color:
                                            Colors.cyanAccent.withOpacity(0.4),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ElevatedButton.icon(
                              icon: Icon(
                                allEnabled
                                    ? Icons.check_circle_outline
                                    : Icons.lock_open,
                                color:
                                    allEnabled ? Colors.black : Colors.white54,
                                size: 22,
                              ),
                              label: Text(
                                allEnabled
                                    ? 'Continue to EternalOS'
                                    : 'Enable & Continue',
                                style: TextStyle(
                                  color: allEnabled
                                      ? Colors.black
                                      : Colors.white54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Orbitron',
                                  letterSpacing: 1,
                                ),
                              ),
                              onPressed: _permissions.values.any((v) => v)
                                  ? () => Navigator.of(context)
                                      .pushReplacementNamed('/')
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Status text
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: allEnabled ? 1 : 0.6,
                            child: Text(
                              allEnabled
                                  ? 'All permissions granted — you\'re good to go!'
                                  : 'Grant required permissions to proceed.',
                              style: TextStyle(
                                color: allEnabled
                                    ? Colors.cyanAccent
                                    : Colors.white54,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(15, (index) {
      final random = math.Random(index);
      return Positioned(
        left: random.nextDouble() * MediaQuery.of(context).size.width,
        top: random.nextDouble() * MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                math.sin(_floatController.value * 2 * math.pi + index) * 15,
                math.cos(_floatController.value * 2 * math.pi + index) * 15,
              ),
              child: Opacity(
                opacity: 0.1 + random.nextDouble() * 0.2,
                child: Container(
                  width: 2 + random.nextDouble() * 3,
                  height: 2 + random.nextDouble() * 3,
                  decoration: BoxDecoration(
                    color: [
                      Colors.cyanAccent,
                      Colors.blueAccent,
                      Colors.purpleAccent,
                      Colors.white,
                    ][random.nextInt(4)],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String emoji,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: enabled
            ? Colors.cyanAccent.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? Colors.cyanAccent.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: enabled
                  ? [
                      Colors.cyanAccent.withOpacity(0.3),
                      Colors.blueAccent.withOpacity(0.3)
                    ]
                  : [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05)
                    ],
            ),
            border: Border.all(
              color:
                  enabled ? Colors.cyanAccent : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: enabled ? Colors.cyanAccent : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: enabled ? Colors.white70 : Colors.white54,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        trailing: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: enabled ? Colors.cyanAccent : Colors.white.withOpacity(0.1),
            border: Border.all(
              color:
                  enabled ? Colors.cyanAccent : Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                left: enabled ? 22 : 2,
                top: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        enabled ? Colors.black : Colors.white.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    enabled ? Icons.check : Icons.close,
                    color: enabled ? Colors.cyanAccent : Colors.grey,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
