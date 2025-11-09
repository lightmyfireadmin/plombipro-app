import 'package:flutter/material.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_spacing.dart';
import '../../config/plombipro_text_styles.dart';

/// Modern gradient button with elevation and hover effects
/// Used for primary CTAs and important actions
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.elevation = PlombiProSpacing.elevationSM,
    this.borderRadius,
    this.textStyle,
  });

  /// Primary gradient button (blue to teal)
  factory GradientButton.primary({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      gradient: PlombiProColors.primaryGradient,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// Secondary gradient button (orange to red)
  factory GradientButton.secondary({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      gradient: PlombiProColors.secondaryGradient,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// Success gradient button (emerald)
  factory GradientButton.success({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      gradient: PlombiProColors.successGradient,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// Premium gradient button (gold)
  factory GradientButton.premium({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      gradient: PlombiProColors.premiumGradient,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final gradient = widget.gradient ?? PlombiProColors.primaryGradient;
    final borderRadius =
        widget.borderRadius ?? PlombiProSpacing.borderRadiusMD;
    final padding = widget.padding ?? PlombiProSpacing.buttonPaddingLarge;

    Widget button = GestureDetector(
      onTapDown: isEnabled ? _onTapDown : null,
      onTapUp: isEnabled ? _onTapUp : null,
      onTapCancel: isEnabled ? _onTapCancel : null,
      child: MouseRegion(
        onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
        onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedScale(
          scale: _scaleAnimation.value,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? gradient
                  : LinearGradient(
                      colors: [
                        PlombiProColors.gray300,
                        PlombiProColors.gray400,
                      ],
                    ),
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: isEnabled && _isHovered
                      ? PlombiProColors.shadowMedium
                      : PlombiProColors.shadowLight,
                  blurRadius: isEnabled && _isHovered ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isEnabled ? widget.onPressed : null,
                borderRadius: borderRadius,
                child: Padding(
                  padding: padding,
                  child: widget.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              PlombiProColors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: widget.isFullWidth
                              ? MainAxisSize.max
                              : MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: PlombiProColors.white,
                                size: PlombiProSpacing.iconSM,
                              ),
                              PlombiProSpacing.horizontalSM,
                            ],
                            Text(
                              widget.text,
                              style: widget.textStyle ??
                                  PlombiProTextStyles.button.copyWith(
                                    color: PlombiProColors.white,
                                  ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
