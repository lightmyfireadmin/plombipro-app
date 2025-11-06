import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/onboarding_service.dart';
import '../../services/supabase_service.dart';
import '../../services/error_service.dart';
import '../../models/profile.dart';

/// 4-step onboarding wizard for new users
///
/// Steps:
/// 1. Welcome & Introduction
/// 2. Company Profile Setup
/// 3. Bank Details Entry
/// 4. Quick Tour
class OnboardingWizardPage extends StatefulWidget {
  const OnboardingWizardPage({super.key});

  @override
  State<OnboardingWizardPage> createState() => _OnboardingWizardPageState();
}

class _OnboardingWizardPageState extends State<OnboardingWizardPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Form controllers for company profile
  final _companyFormKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _siretController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _vatNumberController = TextEditingController();

  // Form controllers for bank details
  final _bankFormKey = GlobalKey<FormState>();
  final _ibanController = TextEditingController();
  final _bicController = TextEditingController();
  final _bankNameController = TextEditingController();

  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await SupabaseService.fetchUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _profile = profile;
          // Pre-fill form fields if data exists
          _companyNameController.text = profile.companyName ?? '';
          _siretController.text = profile.siret ?? '';
          _addressController.text = profile.address ?? '';
          _postalCodeController.text = profile.postalCode ?? '';
          _cityController.text = profile.city ?? '';
          _phoneController.text = profile.phone ?? '';
          _emailController.text = profile.email ?? '';
          _vatNumberController.text = profile.vatNumber ?? '';
          _ibanController.text = profile.iban ?? '';
          _bicController.text = profile.bic ?? '';
        });
      }
    } catch (e) {
      ErrorService.handleError(context, e);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _companyNameController.dispose();
    _siretController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _vatNumberController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveCompanyProfile() async {
    if (!_companyFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Utilisateur non authentifié');

      await SupabaseService.updateUserProfile(
        userId: userId,
        companyName: _companyNameController.text.trim(),
        siret: _siretController.text.trim(),
        address: _addressController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        city: _cityController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        vatNumber: _vatNumberController.text.trim().isEmpty
            ? null
            : _vatNumberController.text.trim(),
      );

      if (mounted) {
        ErrorService.showSuccess(context, 'Profil entreprise sauvegardé');
        _nextPage();
      }
    } catch (e) {
      ErrorService.handleError(context, e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveBankDetails() async {
    if (!_bankFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Utilisateur non authentifié');

      await SupabaseService.updateUserProfile(
        userId: userId,
        iban: _ibanController.text.trim(),
        bic: _bicController.text.trim(),
      );

      if (mounted) {
        ErrorService.showSuccess(context, 'Coordonnées bancaires sauvegardées');
        _nextPage();
      }
    } catch (e) {
      ErrorService.handleError(context, e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _completeOnboarding() async {
    await OnboardingService.completeOnboarding();
    if (mounted) {
      ErrorService.showSuccess(
          context, 'Bienvenue dans PlombiPro! 🎉',
          duration: const Duration(seconds: 2));
      context.go('/home');
    }
  }

  Future<void> _skipOnboarding() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Passer l\'introduction?'),
        content: const Text(
          'Vous pourrez configurer ces informations plus tard dans les paramètres.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Passer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await OnboardingService.skipOnboarding();
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 4,
              backgroundColor: Colors.grey[200],
            ),
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: [
                  _buildWelcomePage(),
                  _buildCompanyProfilePage(),
                  _buildBankDetailsPage(),
                  _buildQuickTourPage(),
                ],
              ),
            ),
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.plumbing,
            size: 120,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 32),
          Text(
            'Bienvenue dans PlombiPro!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Votre assistant professionnel pour la gestion de votre entreprise de plomberie',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildFeatureItem(
            Icons.receipt_long,
            'Devis & Factures',
            'Créez et gérez vos documents professionnels',
          ),
          _buildFeatureItem(
            Icons.people,
            'Gestion clients',
            'Centralisez toutes vos informations clients',
          ),
          _buildFeatureItem(
            Icons.analytics,
            'Suivi financier',
            'Analysez votre activité en temps réel',
          ),
          _buildFeatureItem(
            Icons.payment,
            'Paiements',
            'Suivez vos encaissements facilement',
          ),
          const SizedBox(height: 32),
          Text(
            'Configurons ensemble votre espace de travail',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _companyFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Profil de votre entreprise',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ces informations apparaîtront sur vos devis et factures',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'entreprise *',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom de l\'entreprise est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _siretController,
              decoration: const InputDecoration(
                labelText: 'Numéro SIRET *',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
                hintText: '14 chiffres',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le SIRET est requis';
                }
                final siretDigits = value.replaceAll(RegExp(r'\s'), '');
                if (siretDigits.length != 14) {
                  return 'Le SIRET doit contenir 14 chiffres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vatNumberController,
              decoration: const InputDecoration(
                labelText: 'Numéro TVA (optionnel)',
                prefixIcon: Icon(Icons.euro),
                border: OutlineInputBorder(),
                hintText: 'FR12345678901',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse *',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'adresse est requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Code postal *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requis';
                      }
                      if (value.length != 5) {
                        return 'Code postal invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ville *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La ville est requise';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone *',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                hintText: '06 12 34 56 78',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le téléphone est requis';
                }
                final phoneDigits = value.replaceAll(RegExp(r'[\s\-\.]'), '');
                if (phoneDigits.length != 10) {
                  return 'Numéro invalide (10 chiffres)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email professionnel *',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'email est requis';
                }
                if (!value.contains('@')) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _bankFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Coordonnées bancaires',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pour recevoir les paiements de vos clients',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ces informations apparaîtront sur vos factures pour faciliter les virements',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _ibanController,
              decoration: const InputDecoration(
                labelText: 'IBAN *',
                prefixIcon: Icon(Icons.account_balance),
                border: OutlineInputBorder(),
                hintText: 'FR76 1234 5678 9012 3456 7890 123',
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'IBAN est requis';
                }
                final iban = value.replaceAll(RegExp(r'\s'), '');
                if (!iban.startsWith('FR')) {
                  return 'L\'IBAN doit commencer par FR';
                }
                if (iban.length != 27) {
                  return 'IBAN invalide (27 caractères requis)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bicController,
              decoration: const InputDecoration(
                labelText: 'BIC/SWIFT *',
                prefixIcon: Icon(Icons.code),
                border: OutlineInputBorder(),
                hintText: 'BNPAFRPPXXX',
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le BIC est requis';
                }
                if (value.length < 8 || value.length > 11) {
                  return 'BIC invalide (8-11 caractères)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bankNameController,
              decoration: const InputDecoration(
                labelText: 'Nom de la banque (optionnel)',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vos données bancaires sont sécurisées et ne sont utilisées que pour vos factures',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTourPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.celebration,
            size: 100,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 32),
          Text(
            'Tout est prêt!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Voici un aperçu des fonctionnalités principales',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildTourCard(
            Icons.description,
            'Devis',
            'Créez des devis professionnels en quelques clics',
            Colors.blue,
          ),
          _buildTourCard(
            Icons.receipt_long,
            'Factures',
            'Générez et envoyez vos factures facilement',
            Colors.green,
          ),
          _buildTourCard(
            Icons.people,
            'Clients',
            'Gérez votre fichier client et leur historique',
            Colors.orange,
          ),
          _buildTourCard(
            Icons.inventory,
            'Produits',
            'Cataloguez vos produits et services',
            Colors.purple,
          ),
          _buildTourCard(
            Icons.analytics,
            'Analytics',
            'Suivez votre chiffre d\'affaires et vos KPIs',
            Colors.red,
          ),
          const SizedBox(height: 32),
          Text(
            'Vous êtes prêt à commencer!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourCard(
      IconData icon, String title, String description, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Skip button (only on first page)
          if (_currentPage == 0)
            TextButton(
              onPressed: _skipOnboarding,
              child: const Text('Passer'),
            )
          else
            TextButton(
              onPressed: _previousPage,
              child: const Row(
                children: [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 4),
                  Text('Retour'),
                ],
              ),
            ),
          const Spacer(),
          // Page indicators
          Row(
            children: List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
          const Spacer(),
          // Next/Complete button
          if (_isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_currentPage == 3)
            ElevatedButton(
              onPressed: _completeOnboarding,
              child: const Row(
                children: [
                  Text('Commencer'),
                  SizedBox(width: 4),
                  Icon(Icons.check),
                ],
              ),
            )
          else if (_currentPage == 1)
            ElevatedButton(
              onPressed: _saveCompanyProfile,
              child: const Row(
                children: [
                  Text('Suivant'),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward),
                ],
              ),
            )
          else if (_currentPage == 2)
            ElevatedButton(
              onPressed: _saveBankDetails,
              child: const Row(
                children: [
                  Text('Suivant'),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: _nextPage,
              child: const Row(
                children: [
                  Text('Suivant'),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
