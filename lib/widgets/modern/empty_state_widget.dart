import 'package:flutter/material.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_spacing.dart';
import '../../config/plombipro_text_styles.dart';
import 'gradient_button.dart';

/// Beautiful empty state widget with illustrations and call-to-action
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final bool showIllustration;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.showIllustration = true,
  });

  // Pre-built empty states for common scenarios
  factory EmptyStateWidget.noClients({VoidCallback? onAddClient}) {
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: 'Aucun client',
      message:
          'Commencez par ajouter vos clients pour gérer vos devis et factures',
      actionLabel: 'Ajouter un client',
      onAction: onAddClient,
      iconColor: PlombiProColors.primaryBlue,
    );
  }

  factory EmptyStateWidget.noQuotes({VoidCallback? onCreateQuote}) {
    return EmptyStateWidget(
      icon: Icons.description_outlined,
      title: 'Aucun devis',
      message:
          'Créez votre premier devis pour commencer à gérer vos projets',
      actionLabel: 'Créer un devis',
      onAction: onCreateQuote,
      iconColor: PlombiProColors.info,
    );
  }

  factory EmptyStateWidget.noInvoices({VoidCallback? onCreateInvoice}) {
    return EmptyStateWidget(
      icon: Icons.receipt_outlined,
      title: 'Aucune facture',
      message:
          'Facturez vos interventions pour suivre vos paiements et votre chiffre d\'affaires',
      actionLabel: 'Créer une facture',
      onAction: onCreateInvoice,
      iconColor: PlombiProColors.success,
    );
  }

  factory EmptyStateWidget.noAppointments({VoidCallback? onCreateAppointment}) {
    return EmptyStateWidget(
      icon: Icons.event_outlined,
      title: 'Aucun rendez-vous',
      message:
          'Planifiez vos interventions pour mieux organiser votre semaine',
      actionLabel: 'Créer un rendez-vous',
      onAction: onCreateAppointment,
      iconColor: PlombiProColors.secondaryOrange,
    );
  }

  factory EmptyStateWidget.noProducts({VoidCallback? onAddProduct}) {
    return EmptyStateWidget(
      icon: Icons.inventory_2_outlined,
      title: 'Aucun produit',
      message:
          'Ajoutez vos produits favoris pour les utiliser rapidement dans vos devis',
      actionLabel: 'Ajouter un produit',
      onAction: onAddProduct,
      iconColor: PlombiProColors.tertiaryTeal,
    );
  }

  factory EmptyStateWidget.noSearchResults() {
    return const EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Aucun résultat',
      message: 'Essayez avec d\'autres mots-clés ou filtres',
      iconColor: PlombiProColors.gray400,
    );
  }

  factory EmptyStateWidget.noConnection({VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'Pas de connexion',
      message:
          'Vérifiez votre connexion internet et réessayez',
      actionLabel: 'Réessayer',
      onAction: onRetry,
      iconColor: PlombiProColors.error,
    );
  }

  factory EmptyStateWidget.error({
    required String message,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'Une erreur est survenue',
      message: message,
      actionLabel: onRetry != null ? 'Réessayer' : null,
      onAction: onRetry,
      iconColor: PlombiProColors.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: PlombiProSpacing.pagePaddingLarge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon with background circle
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(PlombiProSpacing.xl),
                    decoration: BoxDecoration(
                      color: (iconColor ?? PlombiProColors.gray400)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 80,
                      color: iconColor ?? PlombiProColors.gray400,
                    ),
                  ),
                );
              },
            ),

            PlombiProSpacing.verticalXL,

            // Title
            Text(
              title,
              style: PlombiProTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            PlombiProSpacing.verticalMD,

            // Message
            Text(
              message,
              style: PlombiProTextStyles.bodyLarge.copyWith(
                color: PlombiProColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            // Action button
            if (actionLabel != null && onAction != null) ...[
              PlombiProSpacing.verticalXL,
              GradientButton.primary(
                text: actionLabel!,
                onPressed: onAction,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading skeleton for lists
class LoadingSkeleton extends StatefulWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets? padding;

  const LoadingSkeleton({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
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
    return ListView.builder(
      padding: widget.padding ?? PlombiProSpacing.pagePadding,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Container(
                height: widget.itemHeight,
                margin: const EdgeInsets.only(bottom: PlombiProSpacing.md),
                decoration: BoxDecoration(
                  color: PlombiProColors.gray200,
                  borderRadius: PlombiProSpacing.borderRadiusMD,
                ),
                child: Row(
                  children: [
                    PlombiProSpacing.horizontalMD,
                    // Avatar skeleton
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: PlombiProColors.gray300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    PlombiProSpacing.horizontalMD,
                    // Text skeletons
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: PlombiProColors.gray300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          PlombiProSpacing.verticalSM,
                          Container(
                            height: 12,
                            width: 150,
                            decoration: BoxDecoration(
                              color: PlombiProColors.gray300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PlombiProSpacing.horizontalMD,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Loading skeleton for cards/grid
class CardLoadingSkeleton extends StatefulWidget {
  final int itemCount;
  final double itemHeight;
  final int crossAxisCount;

  const CardLoadingSkeleton({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 150,
    this.crossAxisCount = 2,
  });

  @override
  State<CardLoadingSkeleton> createState() => _CardLoadingSkeletonState();
}

class _CardLoadingSkeletonState extends State<CardLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
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
    return GridView.builder(
      padding: PlombiProSpacing.pagePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: PlombiProSpacing.md,
        mainAxisSpacing: PlombiProSpacing.md,
        childAspectRatio: 1.2,
      ),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: PlombiProColors.gray200,
                  borderRadius: PlombiProSpacing.borderRadiusLG,
                ),
                padding: PlombiProSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: PlombiProColors.gray300,
                        borderRadius: PlombiProSpacing.borderRadiusMD,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: PlombiProColors.gray300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    PlombiProSpacing.verticalSM,
                    Container(
                      height: 14,
                      width: 100,
                      decoration: BoxDecoration(
                        color: PlombiProColors.gray300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Shimmer loading effect for custom widgets
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor ?? PlombiProColors.gray200,
                widget.highlightColor ?? PlombiProColors.gray100,
                widget.baseColor ?? PlombiProColors.gray200,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
