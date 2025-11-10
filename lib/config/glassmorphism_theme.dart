import 'dart:ui';
import 'package:flutter/material.dart';
import 'plombipro_colors.dart';

/// Glassmorphism theme configuration for PlombiPro
/// Implements modern glass-effect design with blur and transparency
class GlassmorphismTheme {
  // Blur intensities
  static const double blurLight = 10.0;
  static const double blurMedium = 15.0;
  static const double blurHeavy = 20.0;
  static const double blurExtraHeavy = 30.0;

  // Opacity levels
  static const double opacitySubtle = 0.1;
  static const double opacityLight = 0.15;
  static const double opacityMedium = 0.25;
  static const double opacityHeavy = 0.35;

  // Border configurations
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 1.5;
  static const double borderWidthThick = 2.0;

  // Border opacity
  static const double borderOpacity = 0.2;
  static const double borderOpacityStrong = 0.3;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Primary glass card configuration
  static BoxDecoration primaryGlass({
    BorderRadius? borderRadius,
    Color? color,
    double? opacity,
  }) {
    return BoxDecoration(
      color: (color ?? PlombiProColors.primaryBlue)
          .withOpacity(opacity ?? opacityLight),
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: borderWidthThin,
      ),
      boxShadow: [
        BoxShadow(
          color: PlombiProColors.primaryBlue.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Accent glass card configuration
  static BoxDecoration accentGlass({
    BorderRadius? borderRadius,
    double? opacity,
  }) {
    return BoxDecoration(
      color: PlombiProColors.secondaryOrange.withOpacity(opacity ?? opacityLight),
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: borderWidthThin,
      ),
      boxShadow: [
        BoxShadow(
          color: PlombiProColors.secondaryOrange.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Dark glass card for overlays
  static BoxDecoration darkGlass({
    BorderRadius? borderRadius,
    double? opacity,
  }) {
    return BoxDecoration(
      color: Colors.black.withOpacity(opacity ?? opacityMedium),
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: borderWidthThin,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Light glass card for light backgrounds
  static BoxDecoration lightGlass({
    BorderRadius? borderRadius,
    double? opacity,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity ?? opacityMedium),
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacityStrong),
        width: borderWidthMedium,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  /// Success glass card
  static BoxDecoration successGlass({
    BorderRadius? borderRadius,
    double? opacity,
  }) {
    return BoxDecoration(
      color: PlombiProColors.success.withOpacity(opacity ?? opacityLight),
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: borderWidthThin,
      ),
      boxShadow: [
        BoxShadow(
          color: PlombiProColors.success.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Error glass card
  static BoxDecoration errorGlass({
    BorderRadius? borderRadius,
    double? opacity,
  }) {
    return BoxDecoration(
      color: PlombiProColors.error.withOpacity(opacity ?? opacityLight),
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: borderWidthThin,
      ),
      boxShadow: [
        BoxShadow(
          color: PlombiProColors.error.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Gradient glass backgrounds
  static LinearGradient primaryGradient({double opacity = 0.15}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        PlombiProColors.primaryBlue.withOpacity(opacity),
        PlombiProColors.tertiaryTeal.withOpacity(opacity * 0.7),
      ],
    );
  }

  static LinearGradient accentGradient({double opacity = 0.15}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        PlombiProColors.secondaryOrange.withOpacity(opacity),
        PlombiProColors.secondaryOrange.withOpacity(opacity * 0.5),
      ],
    );
  }

  /// Animated shimmer effect for loading states
  static LinearGradient shimmerGradient({
    required Animation<double> animation,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [
        animation.value - 0.3,
        animation.value,
        animation.value + 0.3,
      ],
      colors: [
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0.1),
      ],
    );
  }
}

/// Glass container widget with backdrop filter
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final double opacity;
  final double blur;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.opacity = GlassmorphismTheme.opacityLight,
    this.blur = GlassmorphismTheme.blurMedium,
    this.border,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color?.withOpacity(opacity) ??
                  Colors.white.withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(20),
              border: border ??
                  Border.all(
                    color: Colors.white
                        .withOpacity(GlassmorphismTheme.borderOpacity),
                    width: GlassmorphismTheme.borderWidthThin,
                  ),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
              gradient: gradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Animated glass container with hover/tap effects
class AnimatedGlassContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final double opacity;
  final double blur;
  final VoidCallback? onTap;
  final bool enabled;

  const AnimatedGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.opacity = GlassmorphismTheme.opacityLight,
    this.blur = GlassmorphismTheme.blurMedium,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<AnimatedGlassContainer> createState() =>
      _AnimatedGlassContainerState();
}

class _AnimatedGlassContainerState extends State<AnimatedGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: GlassmorphismTheme.animationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(
      begin: widget.opacity,
      end: widget.opacity * 1.5,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      _controller.reverse();
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              margin: widget.margin,
              borderRadius: widget.borderRadius,
              color: widget.color,
              opacity: _opacityAnimation.value,
              blur: widget.blur,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
