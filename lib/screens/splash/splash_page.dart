import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/glassmorphism_theme.dart';
import '../../config/plombipro_colors.dart';

/// Modern glassmorphic splash screen with animations
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _logoScaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in animation for entire screen
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Pulse animation for loading indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Logo scale animation
    _logoScaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoScaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    _logoScaleController.forward();

    // Redirect after animations start
    _redirect();
  }

  Future<void> _redirect() async {
    // Wait a minimum time to show the splash screen
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) {
      return;
    }

    print('🔍 === SPLASH PAGE AUTH CHECK ===');
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;

    print('  Session exists: ${session != null}');
    print('  User exists: ${user != null}');
    print('  User ID: ${user?.id}');
    print('  Access Token exists: ${session?.accessToken != null}');
    if (session?.accessToken != null) {
      print('  Token preview: ${session!.accessToken!.substring(0, 20)}...');
    }

    if (session != null && user != null) {
      print('✅ User authenticated - navigating to home');
      context.go('/home-enhanced');
    } else {
      print('❌ No valid session - navigating to login');
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _logoScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PlombiProColors.primaryBlue.withOpacity(0.9),
                  PlombiProColors.tertiaryTeal.withOpacity(0.7),
                  PlombiProColors.backgroundDark,
                ],
              ),
            ),
          ),

          // Floating bubbles
          ..._buildFloatingBubbles(),

          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container with scale animation
                  ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: GlassContainer(
                      width: 140,
                      height: 140,
                      padding: const EdgeInsets.all(0),
                      borderRadius: BorderRadius.circular(35),
                      opacity: 0.2,
                      child: const Icon(
                        Icons.plumbing,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App name
                  const Text(
                    'PlombiPro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Gestion professionnelle pour plombiers',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Pulsing loading indicator in glass container
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pulseAnimation.value,
                        child: GlassContainer(
                          width: 60,
                          height: 60,
                          padding: const EdgeInsets.all(16),
                          borderRadius: BorderRadius.circular(15),
                          opacity: 0.15,
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Loading text
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pulseAnimation.value,
                        child: Text(
                          'Chargement...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Version number at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingBubbles() {
    return [
      Positioned(
        top: 100,
        right: 40,
        child: _FloatingBubble(size: 80, delay: 0),
      ),
      Positioned(
        top: 200,
        left: 30,
        child: _FloatingBubble(size: 60, delay: 1),
      ),
      Positioned(
        bottom: 150,
        right: 60,
        child: _FloatingBubble(size: 100, delay: 2),
      ),
      Positioned(
        bottom: 300,
        left: 50,
        child: _FloatingBubble(size: 70, delay: 1),
      ),
    ];
  }
}

/// Floating bubble decoration widget
class _FloatingBubble extends StatefulWidget {
  final double size;
  final int delay;

  const _FloatingBubble({required this.size, required this.delay});

  @override
  State<_FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<_FloatingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3 + widget.delay),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.size / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
