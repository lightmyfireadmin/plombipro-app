import 'package:flutter/material.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_spacing.dart';
import '../../config/plombipro_text_styles.dart';

/// Modern feature card with icon, title, description
/// Used to showcase app features and capabilities
class FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showBadge;
  final String? badgeText;
  final bool hasGlassMorphism;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.showBadge = false,
    this.badgeText,
    this.hasGlassMorphism = false,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? PlombiProColors.primaryBlue;
    final backgroundColor =
        widget.backgroundColor ?? PlombiProColors.surfaceLight;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0),
        child: Card(
          elevation: _isHovered
              ? PlombiProSpacing.elevationLG
              : PlombiProSpacing.elevationSM,
          color: widget.hasGlassMorphism
              ? PlombiProColors.glassMorphismOverlay
              : backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: PlombiProSpacing.borderRadiusLG,
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: PlombiProSpacing.borderRadiusLG,
            child: Padding(
              padding: PlombiProSpacing.cardPaddingLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon with badge
                  Stack(
                    children: [
                      // Icon container
                      Container(
                        width: PlombiProSpacing.iconXXXL,
                        height: PlombiProSpacing.iconXXXL,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              iconColor.withOpacity(0.1),
                              iconColor.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: PlombiProSpacing.borderRadiusMD,
                        ),
                        child: Icon(
                          widget.icon,
                          size: PlombiProSpacing.iconXL,
                          color: iconColor,
                        ),
                      ),
                      // Badge
                      if (widget.showBadge && widget.badgeText != null)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PlombiProSpacing.xxs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: PlombiProColors.secondaryGradient,
                              borderRadius:
                                  BorderRadius.circular(PlombiProSpacing.radiusSM),
                              boxShadow: [
                                BoxShadow(
                                  color: PlombiProColors.shadowLight,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.badgeText!,
                              style: PlombiProTextStyles.labelSmall.copyWith(
                                color: PlombiProColors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  PlombiProSpacing.verticalMD,
                  // Title
                  Text(
                    widget.title,
                    style: PlombiProTextStyles.titleLarge.copyWith(
                      color: PlombiProColors.textPrimaryLight,
                    ),
                  ),
                  PlombiProSpacing.verticalSM,
                  // Description
                  Text(
                    widget.description,
                    style: PlombiProTextStyles.bodyMedium.copyWith(
                      color: PlombiProColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                  // Arrow indicator if tappable
                  if (widget.onTap != null) ...[
                    PlombiProSpacing.verticalMD,
                    Row(
                      children: [
                        Text(
                          'En savoir plus',
                          style: PlombiProTextStyles.labelMedium.copyWith(
                            color: iconColor,
                          ),
                        ),
                        PlombiProSpacing.horizontalXXS,
                        Icon(
                          Icons.arrow_forward,
                          size: PlombiProSpacing.iconXS,
                          color: iconColor,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal variant of FeatureCard for list items
class FeatureCardHorizontal extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;
  final VoidCallback? onTap;

  const FeatureCardHorizontal({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? PlombiProColors.primaryBlue;

    return Card(
      elevation: PlombiProSpacing.elevationXS,
      shape: RoundedRectangleBorder(
        borderRadius: PlombiProSpacing.borderRadiusMD,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: PlombiProSpacing.borderRadiusMD,
        child: Padding(
          padding: PlombiProSpacing.cardPadding,
          child: Row(
            children: [
              // Icon
              Container(
                width: PlombiProSpacing.iconXXL,
                height: PlombiProSpacing.iconXXL,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: PlombiProSpacing.borderRadiusSM,
                ),
                child: Icon(
                  icon,
                  size: PlombiProSpacing.iconMD,
                  color: color,
                ),
              ),
              PlombiProSpacing.horizontalMD,
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: PlombiProTextStyles.titleMedium,
                    ),
                    PlombiProSpacing.verticalXXS,
                    Text(
                      description,
                      style: PlombiProTextStyles.bodySmall.copyWith(
                        color: PlombiProColors.textSecondaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                PlombiProSpacing.horizontalSM,
                Icon(
                  Icons.chevron_right,
                  color: PlombiProColors.gray400,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
