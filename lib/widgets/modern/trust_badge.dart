import 'package:flutter/material.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_spacing.dart';
import '../../config/plombipro_text_styles.dart';

/// Trust badge to display certifications, guarantees, and trust indicators
/// Used to build credibility and user confidence
class TrustBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final bool isVerified;
  final TrustBadgeStyle style;

  const TrustBadge({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.isVerified = false,
    this.style = TrustBadgeStyle.horizontal,
  });

  /// Certification badge (with verification checkmark)
  factory TrustBadge.certification({
    required String title,
    String? subtitle,
  }) {
    return TrustBadge(
      icon: Icons.verified,
      title: title,
      subtitle: subtitle,
      color: PlombiProColors.success,
      isVerified: true,
    );
  }

  /// Guarantee badge
  factory TrustBadge.guarantee({
    required String title,
    String? subtitle,
  }) {
    return TrustBadge(
      icon: Icons.shield_outlined,
      title: title,
      subtitle: subtitle,
      color: PlombiProColors.primaryBlue,
    );
  }

  /// Security badge
  factory TrustBadge.security({
    required String title,
    String? subtitle,
  }) {
    return TrustBadge(
      icon: Icons.security,
      title: title,
      subtitle: subtitle,
      color: PlombiProColors.tertiaryTeal,
    );
  }

  /// Quality badge
  factory TrustBadge.quality({
    required String title,
    String? subtitle,
  }) {
    return TrustBadge(
      icon: Icons.star,
      title: title,
      subtitle: subtitle,
      color: PlombiProColors.premium,
    );
  }

  /// Support badge
  factory TrustBadge.support({
    required String title,
    String? subtitle,
  }) {
    return TrustBadge(
      icon: Icons.support_agent,
      title: title,
      subtitle: subtitle,
      color: PlombiProColors.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? PlombiProColors.primaryBlue;

    switch (style) {
      case TrustBadgeStyle.horizontal:
        return _buildHorizontalBadge(badgeColor);
      case TrustBadgeStyle.vertical:
        return _buildVerticalBadge(badgeColor);
      case TrustBadgeStyle.compact:
        return _buildCompactBadge(badgeColor);
    }
  }

  Widget _buildHorizontalBadge(Color badgeColor) {
    return Container(
      padding: PlombiProSpacing.cardPadding,
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: PlombiProSpacing.borderRadiusMD,
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: badgeColor,
                size: PlombiProSpacing.iconLG,
              ),
              if (isVerified)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: PlombiProColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PlombiProColors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: PlombiProColors.white,
                      size: PlombiProSpacing.iconXS,
                    ),
                  ),
                ),
            ],
          ),
          PlombiProSpacing.horizontalSM,
          // Text
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: PlombiProTextStyles.titleSmall.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: PlombiProTextStyles.bodySmall.copyWith(
                      color: PlombiProColors.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBadge(Color badgeColor) {
    return Container(
      padding: PlombiProSpacing.cardPaddingLarge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor.withOpacity(0.05),
            badgeColor.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: PlombiProSpacing.borderRadiusLG,
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: PlombiProSpacing.iconXXXL,
                height: PlombiProSpacing.iconXXXL,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      badgeColor.withOpacity(0.2),
                      badgeColor.withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: PlombiProSpacing.borderRadiusFull,
                ),
                child: Icon(
                  icon,
                  color: badgeColor,
                  size: PlombiProSpacing.iconXL,
                ),
              ),
              if (isVerified)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: PlombiProColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PlombiProColors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PlombiProColors.shadowLight,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check,
                      color: PlombiProColors.white,
                      size: PlombiProSpacing.iconSM,
                    ),
                  ),
                ),
            ],
          ),
          PlombiProSpacing.verticalMD,
          // Text
          Text(
            title,
            style: PlombiProTextStyles.titleMedium.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            PlombiProSpacing.verticalXXS,
            Text(
              subtitle!,
              style: PlombiProTextStyles.bodySmall.copyWith(
                color: PlombiProColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactBadge(Color badgeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PlombiProSpacing.sm,
        vertical: PlombiProSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: PlombiProSpacing.borderRadiusFull,
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: badgeColor,
            size: PlombiProSpacing.iconXS,
          ),
          PlombiProSpacing.horizontalXXS,
          Text(
            title,
            style: PlombiProTextStyles.labelSmall.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isVerified) ...[
            PlombiProSpacing.horizontalXXS,
            Icon(
              Icons.verified,
              color: PlombiProColors.success,
              size: PlombiProSpacing.iconXS,
            ),
          ],
        ],
      ),
    );
  }
}

/// Trust badge style variants
enum TrustBadgeStyle {
  horizontal,
  vertical,
  compact,
}

/// Row of trust badges for displaying multiple certifications
class TrustBadgeRow extends StatelessWidget {
  final List<TrustBadge> badges;
  final MainAxisAlignment alignment;
  final double spacing;

  const TrustBadgeRow({
    super.key,
    required this.badges,
    this.alignment = MainAxisAlignment.center,
    this.spacing = PlombiProSpacing.md,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: badges,
    );
  }
}
