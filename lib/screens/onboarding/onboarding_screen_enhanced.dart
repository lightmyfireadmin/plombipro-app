import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/glassmorphism_theme.dart';
import '../../config/plombipro_colors.dart';
import '../../services/onboarding_service_enhanced.dart';
import 'dart:ui';

/// Modern glassmorphic onboarding screen with animations
class OnboardingScreenEnhanced extends StatefulWidget {
  const OnboardingScreenEnhanced({super.key});

  @override
  State<OnboardingScreenEnhanced> createState() =>
      _OnboardingScreenEnhancedState();
}

class _OnboardingScreenEnhancedState extends State<OnboardingScreenEnhanced>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _completeOnboarding() async {
    final service = await OnboardingServiceEnhanced.create();
    await service.completeOnboarding();
    if (mounted) {
      context.go('/auth/register-step-by-step');
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _nextPage() {
    if (_currentPage < OnboardingSteps.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  OnboardingSteps.steps[_currentPage].color,
                  OnboardingSteps.steps[_currentPage].color.withOpacity(0.6),
                  PlombiProColors.backgroundDark,
                ],
              ),
            ),
          ),

          // Floating animated shapes
          ..._buildFloatingShapes(),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 80),
                      _buildPageIndicator(),
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: const Text(
                          'Passer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: OnboardingSteps.steps.length,
                    itemBuilder: (context, index) {
                      return _buildPage(OnboardingSteps.steps[index]);
                    },
                  ),
                ),

                // Bottom navigation
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildBottomNavigation(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingStep step) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              GlassContainer(
                width: 120,
                height: 120,
                blur: 20,
                opacity: 0.2,
                borderRadius: BorderRadius.circular(30),
                child: Icon(
                  step.icon,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),

              // Title
              Text(
                step.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                step.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Features list
              if (step.features != null)
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  blur: 20,
                  opacity: 0.15,
                  child: Column(
                    children: step.features!
                        .map((feature) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        OnboardingSteps.steps.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final isLastPage = _currentPage == OnboardingSteps.steps.length - 1;

    return Row(
      children: [
        // Back button
        if (_currentPage > 0)
          Expanded(
            child: AnimatedGlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.white,
              opacity: 0.2,
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: const Center(
                child: Text(
                  'Retour',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (_currentPage > 0) const SizedBox(width: 16),

        // Next/Start button
        Expanded(
          flex: 2,
          child: AnimatedGlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            opacity: 0.95,
            borderRadius: BorderRadius.circular(16),
            onTap: _nextPage,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastPage ? 'Commencer' : 'Suivant',
                    style: TextStyle(
                      color: OnboardingSteps.steps[_currentPage].color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastPage ? Icons.rocket_launch : Icons.arrow_forward,
                    color: OnboardingSteps.steps[_currentPage].color,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFloatingShapes() {
    return [
      Positioned(
        top: 100,
        right: 30,
        child: _FloatingShape(
          size: 80,
          color: Colors.white.withOpacity(0.1),
          duration: const Duration(seconds: 3),
        ),
      ),
      Positioned(
        top: 200,
        left: 50,
        child: _FloatingShape(
          size: 60,
          color: Colors.white.withOpacity(0.08),
          duration: const Duration(seconds: 4),
        ),
      ),
      Positioned(
        bottom: 150,
        right: 60,
        child: _FloatingShape(
          size: 100,
          color: Colors.white.withOpacity(0.06),
          duration: const Duration(seconds: 5),
        ),
      ),
    ];
  }
}

class _FloatingShape extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const _FloatingShape({
    required this.size,
    required this.color,
    required this.duration,
  });

  @override
  State<_FloatingShape> createState() => _FloatingShapeState();
}

class _FloatingShapeState extends State<_FloatingShape>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 20).animate(
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
            borderRadius: BorderRadius.circular(widget.size / 4),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(widget.size / 4),
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
