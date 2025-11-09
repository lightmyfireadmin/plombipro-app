import 'package:flutter/material.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_spacing.dart';
import '../../config/plombipro_text_styles.dart';
import '../../widgets/modern/gradient_button.dart';

/// Beautiful onboarding flow for new users
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Bienvenue sur PlombiPro',
      description:
          'L\'application complète pour gérer votre activité de plomberie en toute simplicité',
      icon: Icons.plumbing,
      gradient: PlombiProColors.primaryGradient,
    ),
    OnboardingData(
      title: 'Devis et Factures',
      description:
          'Créez des devis professionnels et facturez vos clients en quelques clics. Signature électronique incluse',
      icon: Icons.description,
      gradient: PlombiProColors.successGradient,
    ),
    OnboardingData(
      title: 'Gestion Clients',
      description:
          'Centralisez vos contacts, suivez vos projets et offrez un portail client sécurisé',
      icon: Icons.people,
      gradient: PlombiProColors.infoGradient,
    ),
    OnboardingData(
      title: 'Suivi Financier',
      description:
          'Réconciliation bancaire, facturation récurrente et paiements échelonnés pour une gestion optimale',
      icon: Icons.account_balance,
      gradient: PlombiProColors.warningGradient,
    ),
    OnboardingData(
      title: 'Outils Professionnels',
      description:
          'Calculateurs hydrauliques, catalogues fournisseurs et bien plus pour gagner du temps au quotidien',
      icon: Icons.build,
      gradient: LinearGradient(
        colors: [PlombiProColors.tertiaryTeal, PlombiProColors.primaryBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Mark onboarding as complete and navigate to main app
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: PlombiProSpacing.pagePadding,
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Passer',
                      style: PlombiProTextStyles.bodyLarge.copyWith(
                        color: PlombiProColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageWidget(data: _pages[index]);
                },
              ),
            ),

            // Page indicator
            PlombiProSpacing.verticalLG,
            _buildPageIndicator(),
            PlombiProSpacing.verticalXL,

            // Navigation buttons
            Padding(
              padding: PlombiProSpacing.pagePaddingLarge,
              child: Row(
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _previousPage,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Précédent'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: PlombiProSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: PlombiProSpacing.borderRadiusMD,
                          ),
                        ),
                      ),
                    ),

                  if (_currentPage > 0) PlombiProSpacing.horizontalMD,

                  // Next/Finish button
                  Expanded(
                    flex: _currentPage == 0 ? 1 : 2,
                    child: GradientButton.primary(
                      text: _currentPage == _pages.length - 1
                          ? 'Commencer'
                          : 'Suivant',
                      icon: _currentPage == _pages.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                      onPressed: _nextPage,
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ),

            PlombiProSpacing.verticalLG,
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: _currentPage == index
                ? PlombiProColors.primaryGradient
                : null,
            color: _currentPage == index
                ? null
                : PlombiProColors.gray300,
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPageWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: PlombiProSpacing.pagePaddingXLarge,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon with gradient background
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: data.gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PlombiProColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    data.icon,
                    size: 80,
                    color: PlombiProColors.white,
                  ),
                ),
              );
            },
          ),

          PlombiProSpacing.verticalXXL,

          // Title
          Text(
            data.title,
            style: PlombiProTextStyles.displaySmall.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),

          PlombiProSpacing.verticalLG,

          // Description
          Text(
            data.description,
            style: PlombiProTextStyles.bodyLarge.copyWith(
              color: PlombiProColors.textSecondaryLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
