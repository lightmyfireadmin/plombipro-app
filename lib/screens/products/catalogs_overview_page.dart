import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/plombipro_colors.dart';
import '../../widgets/glassmorphic/glass_card.dart';

/// Beautiful glassmorphic catalogs overview page
class CatalogsOverviewPage extends StatefulWidget {
  const CatalogsOverviewPage({super.key});

  @override
  State<CatalogsOverviewPage> createState() => _CatalogsOverviewPageState();
}

class _CatalogsOverviewPageState extends State<CatalogsOverviewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          _buildGradientBackground(),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildGlassAppBar(),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      padding: const EdgeInsets.all(16.0),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildCatalogCard(
                          context,
                          'Mon Catalogue',
                          Icons.person,
                          PlombiProColors.primaryBlue,
                          () {},
                        ),
                        _buildCatalogCard(
                          context,
                          'Point P',
                          Icons.store,
                          PlombiProColors.secondaryOrange,
                          () {},
                        ),
                        _buildCatalogCard(
                          context,
                          'Cedeo',
                          Icons.store,
                          PlombiProColors.tertiaryTeal,
                          () {},
                        ),
                        _buildCatalogCard(
                          context,
                          'Favoris',
                          Icons.favorite,
                          PlombiProColors.accent,
                          () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlombiProColors.primaryBlue,
            PlombiProColors.tertiaryTeal,
            PlombiProColors.primaryBlueDark,
          ],
        ),
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back button
          AnimatedGlassContainer(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(12),
            opacity: 0.2,
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          const SizedBox(width: 16),

          // Title
          const Expanded(
            child: Text(
              'Catalogues de Produits',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AnimatedGlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      opacity: 0.15,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with glow
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
