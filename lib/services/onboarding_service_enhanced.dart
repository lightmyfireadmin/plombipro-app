import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Enhanced onboarding service with progressive disclosure
/// Best practices: 3-7 steps max, interactive, show value quickly
class OnboardingServiceEnhanced {
  static const String _keyOnboardingCompleted = 'onboarding_completed_v2';
  static const String _keyOnboardingStep = 'onboarding_current_step';
  static const String _keyProfileSetup = 'profile_setup_completed';
  static const String _keyFirstQuoteCreated = 'first_quote_created';
  static const String _keyFirstInvoiceCreated = 'first_invoice_created';

  final SharedPreferences _prefs;

  OnboardingServiceEnhanced(this._prefs);

  static Future<OnboardingServiceEnhanced> create() async {
    final prefs = await SharedPreferences.getInstance();
    return OnboardingServiceEnhanced(prefs);
  }

  /// Check if user has completed onboarding
  bool get isOnboardingCompleted {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// Get current onboarding step
  int get currentStep {
    return _prefs.getInt(_keyOnboardingStep) ?? 0;
  }

  /// Check if profile setup is complete
  bool get isProfileSetupComplete {
    return _prefs.getBool(_keyProfileSetup) ?? false;
  }

  /// Check if first quote was created
  bool get isFirstQuoteCreated {
    return _prefs.getBool(_keyFirstQuoteCreated) ?? false;
  }

  /// Check if first invoice was created
  bool get isFirstInvoiceCreated {
    return _prefs.getBool(_keyFirstInvoiceCreated) ?? false;
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    await _prefs.setBool(_keyOnboardingCompleted, true);
  }

  /// Set current onboarding step
  Future<void> setCurrentStep(int step) async {
    await _prefs.setInt(_keyOnboardingStep, step);
  }

  /// Mark profile setup as complete
  Future<void> completeProfileSetup() async {
    await _prefs.setBool(_keyProfileSetup, true);
  }

  /// Mark first quote as created
  Future<void> markFirstQuoteCreated() async {
    await _prefs.setBool(_keyFirstQuoteCreated, true);
  }

  /// Mark first invoice as created
  Future<void> markFirstInvoiceCreated() async {
    await _prefs.setBool(_keyFirstInvoiceCreated, true);
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    await _prefs.setBool(_keyOnboardingCompleted, false);
    await _prefs.setInt(_keyOnboardingStep, 0);
    await _prefs.setBool(_keyProfileSetup, false);
    await _prefs.setBool(_keyFirstQuoteCreated, false);
    await _prefs.setBool(_keyFirstInvoiceCreated, false);
  }

  /// Get onboarding progress percentage
  double getProgress() {
    int completed = 0;
    const int total = 5;

    if (isProfileSetupComplete) completed++;
    if (isFirstQuoteCreated) completed++;
    if (isFirstInvoiceCreated) completed++;
    if (currentStep >= 3) completed++;
    if (isOnboardingCompleted) completed++;

    return completed / total;
  }

  /// Get next suggested action for user
  OnboardingAction getNextAction() {
    if (!isProfileSetupComplete) {
      return OnboardingAction.setupProfile;
    }
    if (!isFirstQuoteCreated) {
      return OnboardingAction.createFirstQuote;
    }
    if (!isFirstInvoiceCreated) {
      return OnboardingAction.createFirstInvoice;
    }
    return OnboardingAction.explore;
  }
}

/// Onboarding actions enum
enum OnboardingAction {
  setupProfile,
  createFirstQuote,
  createFirstInvoice,
  addClient,
  addProduct,
  explore,
}

/// Onboarding step model
class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? imagePath;
  final List<String>? features;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.imagePath,
    this.features,
  });
}

/// Default onboarding steps
class OnboardingSteps {
  static const List<OnboardingStep> steps = [
    OnboardingStep(
      title: 'Bienvenue sur PlombiPro',
      description:
          'La solution tout-en-un pour gérer vos devis, factures et chantiers',
      icon: Icons.handshake_outlined,
      color: Color(0xFF0066CC),
      features: [
        'Devis et factures professionnels',
        'Suivi de chantiers en temps réel',
        'Bibliothèque de produits complète',
        'Conforme à la loi 2026',
      ],
    ),
    OnboardingStep(
      title: 'Créez vos devis en 2 minutes',
      description:
          'Des modèles prêts à l\'emploi pour tous vos travaux de plomberie',
      icon: Icons.description_outlined,
      color: Color(0xFFFF6B35),
      features: [
        '30+ modèles de devis inclus',
        'Calcul automatique des marges',
        'Envoi par email en un clic',
        'Signature électronique',
      ],
    ),
    OnboardingStep(
      title: 'Suivez vos chantiers',
      description:
          'Gérez vos projets avec photos, notes et suivi du temps',
      icon: Icons.construction_outlined,
      color: Color(0xFF00BFA5),
      features: [
        'Photos et documentation',
        'Suivi du temps de travail',
        'Listes de tâches',
        'Facturation par étapes',
      ],
    ),
    OnboardingStep(
      title: 'Gérez vos clients facilement',
      description:
          'Centralisez toutes les informations de vos clients',
      icon: Icons.people_outline,
      color: Color(0xFF9C27B0),
      features: [
        'Historique complet',
        'Rappels de paiement automatiques',
        'Import depuis Excel/CSV',
        'Statistiques par client',
      ],
    ),
    OnboardingStep(
      title: 'Prêt à démarrer?',
      description:
          'Commencez par configurer votre profil d\'entreprise',
      icon: Icons.rocket_launch_outlined,
      color: Color(0xFF0066CC),
      features: [
        'Configuration en 5 minutes',
        'Support gratuit 6j/7',
        'Essai gratuit 14 jours',
        'Aucune carte bancaire requise',
      ],
    ),
  ];
}

/// Feature highlight model for contextual onboarding
class FeatureHighlight {
  final String id;
  final String title;
  final String description;
  final GlobalKey targetKey;
  final IconData icon;
  final Color color;

  const FeatureHighlight({
    required this.id,
    required this.title,
    required this.description,
    required this.targetKey,
    required this.icon,
    required this.color,
  });
}

/// Dashboard tooltips for first-time users
class DashboardTooltips {
  static List<FeatureHighlight> get highlights => [
        FeatureHighlight(
          id: 'create_quote',
          title: 'Créer un devis',
          description:
              'Commencez par créer votre premier devis en quelques clics',
          targetKey: GlobalKey(),
          icon: Icons.add_circle_outline,
          color: const Color(0xFFFF6B35),
        ),
        FeatureHighlight(
          id: 'clients',
          title: 'Vos clients',
          description: 'Gérez tous vos clients au même endroit',
          targetKey: GlobalKey(),
          icon: Icons.people_outline,
          color: const Color(0xFF0066CC),
        ),
        FeatureHighlight(
          id: 'job_sites',
          title: 'Vos chantiers',
          description: 'Suivez l\'avancement de vos projets',
          targetKey: GlobalKey(),
          icon: Icons.construction,
          color: const Color(0xFF00BFA5),
        ),
        FeatureHighlight(
          id: 'stats',
          title: 'Statistiques',
          description: 'Suivez votre chiffre d\'affaires en temps réel',
          targetKey: GlobalKey(),
          icon: Icons.analytics_outlined,
          color: const Color(0xFF9C27B0),
        ),
      ];
}
