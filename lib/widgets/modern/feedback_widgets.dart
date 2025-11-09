import 'package:flutter/material.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_spacing.dart';
import '../../config/plombipro_text_styles.dart';

/// Modern snackbar with beautiful design and animations
class ModernSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final config = _getConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(PlombiProSpacing.xs),
              decoration: BoxDecoration(
                color: PlombiProColors.white.withOpacity(0.2),
                borderRadius: PlombiProSpacing.borderRadiusSM,
              ),
              child: Icon(
                config.icon,
                color: PlombiProColors.white,
                size: 20,
              ),
            ),
            PlombiProSpacing.horizontalMD,
            Expanded(
              child: Text(
                message,
                style: PlombiProTextStyles.bodyMedium.copyWith(
                  color: PlombiProColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: PlombiProSpacing.borderRadiusMD,
        ),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: PlombiProColors.white,
                onPressed: onAction ?? () {},
              )
            : null,
        margin: PlombiProSpacing.pagePadding,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.info);
  }

  static _SnackBarConfig _getConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          icon: Icons.check_circle,
          color: PlombiProColors.success,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          icon: Icons.error,
          color: PlombiProColors.error,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          icon: Icons.warning,
          color: PlombiProColors.warning,
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          icon: Icons.info,
          color: PlombiProColors.info,
        );
    }
  }
}

class _SnackBarConfig {
  final IconData icon;
  final Color color;

  _SnackBarConfig({required this.icon, required this.color});
}

enum SnackBarType { success, error, warning, info }

/// Animated success dialog
class SuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onConfirm;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonLabel,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        buttonLabel: buttonLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: PlombiProSpacing.borderRadiusXL,
        ),
        child: Padding(
          padding: PlombiProSpacing.cardPaddingXLarge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated success icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: PlombiProColors.successGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: PlombiProColors.white,
                    size: 48,
                  ),
                ),
              ),

              PlombiProSpacing.verticalXL,

              // Title
              Text(
                widget.title,
                style: PlombiProTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              PlombiProSpacing.verticalMD,

              // Message
              Text(
                widget.message,
                style: PlombiProTextStyles.bodyLarge.copyWith(
                  color: PlombiProColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              PlombiProSpacing.verticalXL,

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onConfirm?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PlombiProColors.success,
                    foregroundColor: PlombiProColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: PlombiProSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: PlombiProSpacing.borderRadiusMD,
                    ),
                  ),
                  child: Text(
                    widget.buttonLabel ?? 'OK',
                    style: PlombiProTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
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
}

/// Animated error dialog
class ErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onRetry,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonLabel,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        buttonLabel: buttonLabel,
        onRetry: onRetry,
      ),
    );
  }

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: PlombiProSpacing.borderRadiusXL,
        ),
        child: Padding(
          padding: PlombiProSpacing.cardPaddingXLarge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: PlombiProColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: PlombiProColors.error,
                  size: 48,
                ),
              ),

              PlombiProSpacing.verticalXL,

              // Title
              Text(
                widget.title,
                style: PlombiProTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              PlombiProSpacing.verticalMD,

              // Message
              Text(
                widget.message,
                style: PlombiProTextStyles.bodyLarge.copyWith(
                  color: PlombiProColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              PlombiProSpacing.verticalXL,

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: PlombiProSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: PlombiProSpacing.borderRadiusMD,
                        ),
                      ),
                      child: const Text('Fermer'),
                    ),
                  ),
                  if (widget.onRetry != null) ...[
                    PlombiProSpacing.horizontalMD,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onRetry?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PlombiProColors.error,
                          foregroundColor: PlombiProColors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: PlombiProSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: PlombiProSpacing.borderRadiusMD,
                          ),
                        ),
                        child: Text(
                          widget.buttonLabel ?? 'Réessayer',
                          style: PlombiProTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading overlay with message
class LoadingOverlay {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, {String? message}) {
    hide(); // Hide any existing overlay

    _currentOverlay = OverlayEntry(
      builder: (context) => _LoadingOverlayWidget(message: message),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _LoadingOverlayWidget extends StatelessWidget {
  final String? message;

  const _LoadingOverlayWidget({this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: PlombiProSpacing.cardPaddingLarge,
          decoration: BoxDecoration(
            color: PlombiProColors.white,
            borderRadius: PlombiProSpacing.borderRadiusLG,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                PlombiProSpacing.verticalMD,
                Text(
                  message!,
                  style: PlombiProTextStyles.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirmation dialog with modern design
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirmer',
    this.cancelLabel = 'Annuler',
    this.isDestructive = false,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: PlombiProSpacing.borderRadiusXL,
      ),
      child: Padding(
        padding: PlombiProSpacing.cardPaddingXLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(PlombiProSpacing.sm),
                  decoration: BoxDecoration(
                    color: (isDestructive
                            ? PlombiProColors.error
                            : PlombiProColors.info)
                        .withOpacity(0.1),
                    borderRadius: PlombiProSpacing.borderRadiusMD,
                  ),
                  child: Icon(
                    isDestructive ? Icons.warning : Icons.help_outline,
                    color: isDestructive
                        ? PlombiProColors.error
                        : PlombiProColors.info,
                  ),
                ),
                PlombiProSpacing.horizontalMD,
                Expanded(
                  child: Text(
                    title,
                    style: PlombiProTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            PlombiProSpacing.verticalLG,

            Text(
              message,
              style: PlombiProTextStyles.bodyLarge.copyWith(
                color: PlombiProColors.textSecondaryLight,
              ),
            ),

            PlombiProSpacing.verticalXL,

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: PlombiProSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: PlombiProSpacing.borderRadiusMD,
                      ),
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
                PlombiProSpacing.horizontalMD,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDestructive
                          ? PlombiProColors.error
                          : PlombiProColors.primaryBlue,
                      foregroundColor: PlombiProColors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: PlombiProSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: PlombiProSpacing.borderRadiusMD,
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: PlombiProTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
