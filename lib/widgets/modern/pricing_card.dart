import 'package:flutter/material.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_spacing.dart';
import '../../config/plombipro_text_styles.dart';
import 'gradient_button.dart';

/// Modern pricing card for subscription plans and pricing tiers
/// Supports featured/highlighted variants and detailed feature lists
class PricingCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final double price;
  final String period;
  final List<String> features;
  final List<String>? excludedFeatures;
  final VoidCallback? onSelect;
  final String buttonText;
  final bool isFeatured;
  final bool isPopular;
  final Color? accentColor;
  final String? badge;

  const PricingCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.price,
    this.period = '/mois',
    required this.features,
    this.excludedFeatures,
    this.onSelect,
    this.buttonText = 'Choisir',
    this.isFeatured = false,
    this.isPopular = false,
    this.accentColor,
    this.badge,
  });

  /// Free tier pricing card
  factory PricingCard.free({
    required List<String> features,
    VoidCallback? onSelect,
    String buttonText = 'Commencer',
  }) {
    return PricingCard(
      title: 'Gratuit',
      subtitle: 'Pour commencer',
      price: 0,
      features: features,
      onSelect: onSelect,
      buttonText: buttonText,
      accentColor: PlombiProColors.gray600,
    );
  }

  /// Pro tier pricing card
  factory PricingCard.pro({
    required double price,
    required List<String> features,
    List<String>? excludedFeatures,
    VoidCallback? onSelect,
    bool isFeatured = true,
    bool isPopular = true,
  }) {
    return PricingCard(
      title: 'Pro',
      subtitle: 'Pour les professionnels',
      price: price,
      features: features,
      excludedFeatures: excludedFeatures,
      onSelect: onSelect,
      buttonText: 'Commencer l\'essai gratuit',
      isFeatured: isFeatured,
      isPopular: isPopular,
      accentColor: PlombiProColors.primaryBlue,
      badge: isPopular ? 'POPULAIRE' : null,
    );
  }

  /// Premium tier pricing card
  factory PricingCard.premium({
    required double price,
    required List<String> features,
    VoidCallback? onSelect,
  }) {
    return PricingCard(
      title: 'Premium',
      subtitle: 'Pour les équipes',
      price: price,
      features: features,
      onSelect: onSelect,
      buttonText: 'Nous contacter',
      accentColor: PlombiProColors.premium,
      badge: 'MEILLEURE VALEUR',
    );
  }

  @override
  State<PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<PricingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? PlombiProColors.primaryBlue;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(widget.isFeatured && _isHovered ? 1.02 : 1.0),
        child: Card(
          elevation: widget.isFeatured
              ? PlombiProSpacing.elevationLG
              : _isHovered
                  ? PlombiProSpacing.elevationMD
                  : PlombiProSpacing.elevationSM,
          shape: RoundedRectangleBorder(
            borderRadius: PlombiProSpacing.borderRadiusXL,
            side: widget.isFeatured
                ? BorderSide(
                    color: accentColor,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          child: Container(
            decoration: widget.isFeatured
                ? BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withOpacity(0.02),
                        accentColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: PlombiProSpacing.borderRadiusXL,
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with badge
                if (widget.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: PlombiProSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          PlombiProColors.darken(accentColor, 0.1),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(PlombiProSpacing.radiusXL),
                        topRight: Radius.circular(PlombiProSpacing.radiusXL),
                      ),
                    ),
                    child: Text(
                      widget.badge!,
                      style: PlombiProTextStyles.labelSmall.copyWith(
                        color: PlombiProColors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Content
                Padding(
                  padding: PlombiProSpacing.cardPaddingLarge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and subtitle
                      Text(
                        widget.title,
                        style: PlombiProTextStyles.headlineMedium.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        PlombiProSpacing.verticalXXS,
                        Text(
                          widget.subtitle!,
                          style: PlombiProTextStyles.bodyMedium.copyWith(
                            color: PlombiProColors.textSecondaryLight,
                          ),
                        ),
                      ],

                      PlombiProSpacing.verticalLG,

                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.price.toStringAsFixed(0)}€',
                            style: PlombiProTextStyles.priceLarge.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          PlombiProSpacing.horizontalXXS,
                          Padding(
                            padding: const EdgeInsets.only(
                              top: PlombiProSpacing.sm,
                            ),
                            child: Text(
                              widget.period,
                              style: PlombiProTextStyles.bodyMedium.copyWith(
                                color: PlombiProColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),

                      PlombiProSpacing.verticalXL,

                      // CTA Button
                      GradientButton(
                        text: widget.buttonText,
                        onPressed: widget.onSelect,
                        isFullWidth: true,
                        gradient: widget.isFeatured
                            ? LinearGradient(
                                colors: [
                                  accentColor,
                                  PlombiProColors.darken(accentColor, 0.1),
                                ],
                              )
                            : null,
                      ),

                      PlombiProSpacing.verticalXL,

                      // Divider
                      Divider(
                        color: PlombiProColors.gray300,
                        height: 1,
                      ),

                      PlombiProSpacing.verticalLG,

                      // Features list
                      ...widget.features.map((feature) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: PlombiProSpacing.sm,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: PlombiProColors.success,
                                  size: PlombiProSpacing.iconSM,
                                ),
                                PlombiProSpacing.horizontalSM,
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: PlombiProTextStyles.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          )),

                      // Excluded features (grayed out)
                      if (widget.excludedFeatures != null)
                        ...widget.excludedFeatures!.map((feature) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: PlombiProSpacing.sm,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.cancel_outlined,
                                    color: PlombiProColors.gray400,
                                    size: PlombiProSpacing.iconSM,
                                  ),
                                  PlombiProSpacing.horizontalSM,
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: PlombiProTextStyles.bodyMedium
                                          .copyWith(
                                        color: PlombiProColors.textDisabledLight,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact pricing card for inline/horizontal layouts
class PricingCardCompact extends StatelessWidget {
  final String title;
  final double price;
  final String period;
  final String buttonText;
  final VoidCallback? onSelect;
  final Color? color;

  const PricingCardCompact({
    super.key,
    required this.title,
    required this.price,
    this.period = '/mois',
    this.buttonText = 'Choisir',
    this.onSelect,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? PlombiProColors.primaryBlue;

    return Card(
      elevation: PlombiProSpacing.elevationSM,
      shape: RoundedRectangleBorder(
        borderRadius: PlombiProSpacing.borderRadiusMD,
      ),
      child: Padding(
        padding: PlombiProSpacing.cardPadding,
        child: Row(
          children: [
            // Title and price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: PlombiProTextStyles.titleLarge.copyWith(
                      color: accentColor,
                    ),
                  ),
                  PlombiProSpacing.verticalXXS,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${price.toStringAsFixed(0)}€',
                        style: PlombiProTextStyles.priceMedium.copyWith(
                          color: accentColor,
                        ),
                      ),
                      Text(
                        period,
                        style: PlombiProTextStyles.bodySmall.copyWith(
                          color: PlombiProColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Button
            ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: PlombiProColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: PlombiProSpacing.lg,
                  vertical: PlombiProSpacing.sm,
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
