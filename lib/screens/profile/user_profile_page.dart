import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/profile.dart';
import '../../services/supabase_service.dart';
import '../../config/plombipro_colors.dart';
import '../../widgets/glassmorphic/glass_card.dart';

/// Beautiful glassmorphic user profile page
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  Profile? _profile;

  // Form fields
  late String _firstName;
  late String _lastName;
  late String _phone;

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

    _fetchProfile();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profileData = await SupabaseService.fetchUserProfile();
        if (profileData != null) {
          setState(() {
            _profile = profileData;
            _firstName = _profile!.firstName ?? '';
            _lastName = _profile!.lastName ?? '';
            _phone = _profile!.phone ?? '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement du profil: ${e.toString()}'),
            backgroundColor: PlombiProColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward();
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedProfile = _profile!.copyWith(
          firstName: _firstName,
          lastName: _lastName,
          phone: _phone,
        );

        await SupabaseService.updateProfile(updatedProfile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Profil enregistré avec succès'),
              backgroundColor: PlombiProColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: PlombiProColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
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
            child: _isLoading
                ? _buildLoadingState()
                : _profile == null
                    ? _buildErrorState()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            _buildGlassAppBar(),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    _buildProfileHeader(),
                                    const SizedBox(height: 24),
                                    _buildProfileForm(),
                                    const SizedBox(height: 24),
                                    _buildSubscriptionCard(),
                                  ],
                                ),
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

  Widget _buildLoadingState() {
    return Center(
      child: GlassContainer(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        opacity: 0.2,
        child: const CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          borderRadius: BorderRadius.circular(24),
          opacity: 0.15,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: PlombiProColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Impossible de charger le profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
              'Mon Profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Save button
          AnimatedGlassContainer(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(12),
            opacity: 0.25,
            color: PlombiProColors.success,
            onTap: _isLoading ? null : _saveProfile,
            child: const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final initials = '${_firstName.isNotEmpty ? _firstName[0] : ''}${_lastName.isNotEmpty ? _lastName[0] : ''}'.toUpperCase();

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.15,
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  PlombiProColors.primaryBlue,
                  PlombiProColors.tertiaryTeal,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: PlombiProColors.primaryBlue.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials.isNotEmpty ? initials : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            '${_firstName.isNotEmpty ? _firstName : 'Prénom'} ${_lastName.isNotEmpty ? _lastName : 'Nom'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Email
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email,
                  color: PlombiProColors.tertiaryTeal,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _profile!.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.15,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PlombiProColors.primaryBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Informations personnelles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // First Name
            _buildGlassTextField(
              labelText: 'Prénom *',
              hintText: 'Votre prénom',
              initialValue: _firstName,
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un prénom';
                }
                return null;
              },
              onSaved: (value) => _firstName = value!,
            ),

            const SizedBox(height: 20),

            // Last Name
            _buildGlassTextField(
              labelText: 'Nom *',
              hintText: 'Votre nom',
              initialValue: _lastName,
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
              onSaved: (value) => _lastName = value!,
            ),

            const SizedBox(height: 20),

            // Phone
            _buildGlassTextField(
              labelText: 'Téléphone',
              hintText: '+33 6 12 34 56 78',
              initialValue: _phone,
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              onSaved: (value) => _phone = value ?? '',
            ),

            const SizedBox(height: 32),

            // Save button (large)
            AnimatedGlassContainer(
              width: double.infinity,
              height: 56,
              borderRadius: BorderRadius.circular(16),
              opacity: 0.25,
              color: PlombiProColors.success,
              onTap: _isLoading ? null : _saveProfile,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Enregistrer les modifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Required fields note
            Center(
              child: Text(
                '* Champs requis',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required String labelText,
    required String hintText,
    required String? initialValue,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            initialValue: initialValue,
            keyboardType: keyboardType,
            validator: validator,
            onSaved: onSaved,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(
                prefixIcon,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard() {
    final planName = _profile!.subscriptionPlan ?? 'Free';
    final isPremium = planName.toLowerCase() != 'free';

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isPremium ? PlombiProColors.accent : PlombiProColors.warning,
                      isPremium
                          ? PlombiProColors.accent.withOpacity(0.7)
                          : PlombiProColors.warning.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isPremium ? PlombiProColors.accent : PlombiProColors.warning)
                          .withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  isPremium ? Icons.star : Icons.workspace_premium,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Abonnement',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Plan info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isPremium ? Icons.check_circle : Icons.info_outline,
                  color: isPremium ? PlombiProColors.success : PlombiProColors.info,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plan actuel',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        planName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          PlombiProColors.accent,
                          PlombiProColors.accent.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Upgrade',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
