import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _particleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _particleAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _scaleController.forward();
    });

    // Auto navigate after 4 seconds
    _navigationTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/permissions');
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
              Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ..._buildBackgroundParticles(),

            // Main content
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated logo
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.cyanAccent,
                                      Colors.blueAccent,
                                      Colors.purpleAccent,
                                      Colors.cyanAccent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withOpacity(0.4),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: Colors.blueAccent.withOpacity(0.3),
                                      blurRadius: 60,
                                      spreadRadius: 15,
                                    ),
                                    BoxShadow(
                                      color:
                                          Colors.purpleAccent.withOpacity(0.2),
                                      blurRadius: 80,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Inner rotating ring
                                    AnimatedBuilder(
                                      animation: _rotationAnimation,
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle: -_rotationAnimation.value * 2,
                                          child: Container(
                                            width: 140,
                                            height: 140,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Center icon
                                    const Icon(
                                      Icons.blur_on,
                                      color: Colors.black,
                                      size: 60,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Title with glow effect
                      AnimatedBuilder(
                        animation: _particleAnimation,
                        builder: (context, child) {
                          return Text(
                            'ETERNAL OS',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Orbitron',
                              color: Colors.white,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: Colors.cyanAccent.withOpacity(
                                      0.5 + _particleAnimation.value * 0.5),
                                  blurRadius:
                                      20 + _particleAnimation.value * 10,
                                  offset: const Offset(0, 0),
                                ),
                                Shadow(
                                  color: Colors.blueAccent.withOpacity(
                                      0.3 + _particleAnimation.value * 0.3),
                                  blurRadius:
                                      30 + _particleAnimation.value * 15,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'THE INTELLIGENT OPERATING SYSTEM WITHIN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Orbitron',
                          color: Colors.cyanAccent.withOpacity(0.8),
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Loading indicator
                      AnimatedBuilder(
                        animation: _particleAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 120,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.cyanAccent.withOpacity(
                                      0.6 + _particleAnimation.value * 0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Skip button
                          TextButton(
                            onPressed: () {
                              _navigationTimer?.cancel();
                              Navigator.of(context)
                                  .pushReplacementNamed('/permissions');
                            },
                            child: Text(
                              'SKIP',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          const SizedBox(width: 40),

                          // Learn more button
                          TextButton(
                            onPressed: () => _showLearnMoreDialog(context),
                            child: Text(
                              'LEARN MORE',
                              style: TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundParticles() {
    return List.generate(30, (index) {
      final random = math.Random(index);
      final size = 2 + random.nextDouble() * 4;
      final colors = [
        Colors.cyanAccent,
        Colors.blueAccent,
        Colors.purpleAccent,
        Colors.white,
        Colors.orangeAccent,
      ];

      return Positioned(
        left: random.nextDouble() * MediaQuery.of(context).size.width,
        top: random.nextDouble() * MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            final offset =
                math.sin(_particleController.value * 2 * math.pi + index) * 30;
            return Transform.translate(
              offset: Offset(offset, -offset),
              child: Opacity(
                opacity: 0.1 + _particleAnimation.value * 0.4,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color:
                        colors[random.nextInt(colors.length)].withOpacity(0.6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[random.nextInt(colors.length)]
                            .withOpacity(0.3),
                        blurRadius: size * 2,
                        spreadRadius: size * 0.5,
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

  void _showLearnMoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'About EternalOS',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'EternalOS is a revolutionary contextual voice assistant that lives within your device. '
          'It understands your activities, anticipates your needs, and provides intelligent '
          'assistance through natural voice commands and smart automation.\n\n'
          'Experience the future of human-computer interaction.',
          style: TextStyle(
            color: Colors.white,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'GOT IT',
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
        ],
      ),
    );
  }
}
