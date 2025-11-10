import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/glassmorphism_theme.dart';
import '../../config/plombipro_colors.dart';
import '../../widgets/glassmorphic/glass_card.dart';
import '../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Step-by-step registration with progressive commitment
/// Following best practices: Show value at each step, reduce friction
class RegisterStepByStepScreen extends StatefulWidget {
  const RegisterStepByStepScreen({super.key});

  @override
  State<RegisterStepByStepScreen> createState() =>
      _RegisterStepByStepScreenState();
}

class _RegisterStepByStepScreenState extends State<RegisterStepByStepScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _siretController = TextEditingController();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String? _selectedCompanyType;
  final List<String> _companyTypes = [
    'Auto-entrepreneur',
    'SARL',
    'EURL',
    'SAS',
    'SASU',
    'SA',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _siretController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _fadeController.reset();
        _fadeController.forward();
      } else {
        _completeRegistration();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Email step
        if (_emailController.text.isEmpty ||
            !_emailController.text.contains('@')) {
          _showError('Veuillez entrer une adresse email valide');
          return false;
        }
        return true;

      case 1: // Password step
        if (_passwordController.text.length < 6) {
          _showError('Le mot de passe doit contenir au moins 6 caractères');
          return false;
        }
        if (_passwordController.text != _confirmPasswordController.text) {
          _showError('Les mots de passe ne correspondent pas');
          return false;
        }
        return true;

      case 2: // Personal info
        if (_firstNameController.text.isEmpty ||
            _lastNameController.text.isEmpty) {
          _showError('Veuillez remplir tous les champs obligatoires');
          return false;
        }
        return true;

      case 3: // Company info
        if (_companyNameController.text.isEmpty) {
          _showError('Veuillez entrer le nom de votre entreprise');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  Future<void> _completeRegistration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Register user with Supabase
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
      );

      if (response.user != null) {
        // Create profile
        await Supabase.instance.client.from('profiles').insert({
          'id': response.user!.id,
          'company_name': _companyNameController.text.trim(),
          'company_type': _selectedCompanyType,
          'siret': _siretController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
        });

        if (mounted) {
          // Show success and navigate
          _showSuccess('Compte créé avec succès!');
          await Future.delayed(const Duration(seconds: 2));
          context.go('/home');
        }
      }
    } catch (e) {
      _showError('Erreur lors de la création du compte: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PlombiProColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: PlombiProColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PlombiProColors.primaryBlue,
                  PlombiProColors.tertiaryTeal,
                  PlombiProColors.backgroundDark,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header with progress
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (_currentStep > 0)
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: _previousStep,
                            ),
                          const Spacer(),
                          Text(
                            'Étape ${_currentStep + 1} sur 4',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildProgressBar(),
                    ],
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildEmailStep(),
                      _buildPasswordStep(),
                      _buildPersonalInfoStep(),
                      _buildCompanyInfoStep(),
                    ],
                  ),
                ),

                // Bottom button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildBottomButton(),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(4, (index) {
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep;

        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmailStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✉️ Votre email',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Commençons par votre adresse email professionnelle',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),
            GlassTextField(
              controller: _emailController,
              hintText: 'votre.email@entreprise.fr',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              opacity: 0.1,
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vos données sont sécurisées et chiffrées',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
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

  Widget _buildPasswordStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔐 Sécurité',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Créez un mot de passe sécurisé',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),
            GlassTextField(
              controller: _passwordController,
              hintText: 'Mot de passe (min. 6 caractères)',
              prefixIcon: Icons.lock_outlined,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            GlassTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirmez le mot de passe',
              prefixIcon: Icons.lock_outlined,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _buildPasswordStrength(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👤 Qui êtes-vous?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Parlez-nous un peu de vous',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),
            GlassTextField(
              controller: _firstNameController,
              hintText: 'Prénom *',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            GlassTextField(
              controller: _lastNameController,
              hintText: 'Nom *',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            GlassTextField(
              controller: _phoneController,
              hintText: 'Téléphone',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfoStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏢 Votre entreprise',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Dernière étape avant de commencer!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),
            GlassTextField(
              controller: _companyNameController,
              hintText: 'Nom de l\'entreprise *',
              prefixIcon: Icons.business_outlined,
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              opacity: 0.1,
              blur: 10,
              child: DropdownButtonFormField<String>(
                value: _selectedCompanyType,
                decoration: InputDecoration(
                  hintText: 'Type d\'entreprise',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.business_center_outlined,
                      color: Colors.white70),
                ),
                dropdownColor: PlombiProColors.primaryBlue,
                style: const TextStyle(color: Colors.white),
                items: _companyTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCompanyType = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            GlassTextField(
              controller: _siretController,
              hintText: 'SIRET (optionnel)',
              prefixIcon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              opacity: 0.1,
              child: Row(
                children: [
                  const Icon(Icons.celebration_outlined,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vous êtes prêt à démarrer votre essai gratuit!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
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

  Widget _buildPasswordStrength() {
    final strength = _calculatePasswordStrength(_passwordController.text);
    final strengthColor = strength > 0.66
        ? PlombiProColors.success
        : strength > 0.33
            ? PlombiProColors.warning
            : PlombiProColors.error;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Force du mot de passe',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                strength > 0.66
                    ? 'Fort'
                    : strength > 0.33
                        ? 'Moyen'
                        : 'Faible',
                style: TextStyle(
                  fontSize: 14,
                  color: strengthColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(strengthColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;

    // Length
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 10) strength += 0.25;

    // Has uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;

    // Has lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;

    // Has number
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.1;

    // Has special char
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

    return strength.clamp(0.0, 1.0);
  }

  Widget _buildBottomButton() {
    final isLastStep = _currentStep == 3;

    return AnimatedGlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      color: Colors.white,
      opacity: 0.95,
      borderRadius: BorderRadius.circular(16),
      onTap: _isLoading ? null : _nextStep,
      enabled: !_isLoading,
      child: Center(
        child: Text(
          isLastStep ? 'Créer mon compte' : 'Continuer',
          style: TextStyle(
            color: PlombiProColors.primaryBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
