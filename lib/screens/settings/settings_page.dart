import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/supabase_service.dart';
import '../../models/profile.dart';
import '../../config/plombipro_colors.dart';
import '../../widgets/glassmorphic/glass_card.dart';

/// Beautiful glassmorphic settings page
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  Profile? _profile;
  bool _isLoading = true;
  bool _isConnectingStripe = false;

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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final userProfile = await SupabaseService.fetchUserProfile();
      if (userProfile != null) {
        setState(() {
          _profile = userProfile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de chargement du profil: ${e.toString()}"),
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

  Future<void> _connectStripeAccount() async {
    if (!mounted) return;
    setState(() {
      _isConnectingStripe = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non authentifié.');
      }

      final response = await Supabase.instance.client.functions.invoke(
        'create-stripe-connect-account',
        body: {
          'user_id': userId,
          'return_url': '${Uri.base.origin}/settings',
          'refresh_url': '${Uri.base.origin}/settings',
        },
      );

      if (response.data['success'] == true && response.data['url'] != null) {
        final url = response.data['url'] as String;
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Impossible de lancer l\'URL: $url');
        }
      } else {
        throw Exception(response.data['error'] ??
            'Échec de la création du compte Stripe Connect.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de connexion Stripe: ${e.toString()}"),
            backgroundColor: PlombiProColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnectingStripe = false;
        });
        _fetchProfile();
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
            child: Column(
              children: [
                _buildGlassAppBar(),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildSettingsList(),
                        ),
                ),
              ],
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

          // Title with icon
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PlombiProColors.accent,
                        PlombiProColors.accent.withOpacity(0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PlombiProColors.accent.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Paramètres',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        // Account section
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Compte',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),

        _buildSettingsItem(
          context,
          'Mon Profil',
          Icons.person,
          PlombiProColors.primaryBlue,
          () => context.go('/profile'),
        ),

        const SizedBox(height: 12),

        _buildSettingsItem(
          context,
          'Mon Entreprise',
          Icons.business,
          PlombiProColors.secondaryOrange,
          () => context.go('/company-profile'),
        ),

        const SizedBox(height: 24),

        // Business section
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Configuration',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),

        _buildSettingsItem(
          context,
          'Paramètres de Facturation',
          Icons.receipt,
          PlombiProColors.tertiaryTeal,
          () => context.go('/invoice-settings'),
        ),

        const SizedBox(height: 24),

        // Stripe Connect section
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Paiements',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),

        _buildStripeConnectCard(),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AnimatedGlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      opacity: 0.15,
      onTap: onTap,
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Arrow icon
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildStripeConnectCard() {
    final isConnected = _profile?.stripeConnectId != null;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      opacity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isConnected ? PlombiProColors.success : PlombiProColors.warning,
                      isConnected
                          ? PlombiProColors.success.withOpacity(0.7)
                          : PlombiProColors.warning.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: (isConnected
                              ? PlombiProColors.success
                              : PlombiProColors.warning)
                          .withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Stripe Connect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (!isConnected) ...[
            // Not connected state
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: PlombiProColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Votre compte Stripe n\'est pas encore connecté',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Connectez votre compte pour accepter les paiements en ligne',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedGlassContainer(
              width: double.infinity,
              height: 48,
              borderRadius: BorderRadius.circular(12),
              opacity: 0.25,
              color: PlombiProColors.success,
              onTap: _isConnectingStripe ? null : _connectStripeAccount,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isConnectingStripe)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    const Icon(Icons.link, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _isConnectingStripe
                        ? 'Connexion en cours...'
                        : 'Connecter mon compte Stripe',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Connected state
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PlombiProColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PlombiProColors.success.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: PlombiProColors.success,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compte connecté',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vous pouvez accepter les paiements',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedGlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    opacity: 0.2,
                    onTap: () {
                      // TODO: Manage Stripe Account
                    },
                    child: const Text(
                      'Gérer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
