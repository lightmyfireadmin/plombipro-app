import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import '../../config/glassmorphism_theme.dart';
import '../../config/plombipro_colors.dart';
import '../../widgets/glassmorphic/glass_card.dart';

/// Modern glassmorphic registration page
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _siretController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;
    String text = '';
    Color color = Colors.grey;

    if (password.isEmpty) {
      strength = 0.0;
      text = '';
      color = Colors.grey;
    } else if (password.length < 6) {
      strength = 0.25;
      text = 'Très faible';
      color = PlombiProColors.error;
    } else {
      // Start with length-based strength
      strength = 0.4;
      text = 'Faible';
      color = PlombiProColors.warning;

      // Add strength for uppercase letters
      if (password.contains(RegExp(r'[A-Z]'))) {
        strength += 0.2;
      }

      // Add strength for numbers
      if (password.contains(RegExp(r'[0-9]'))) {
        strength += 0.2;
      }

      // Add strength for special characters
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        strength += 0.2;
      }

      // Determine text and color based on strength
      if (strength >= 0.8) {
        text = 'Fort';
        color = PlombiProColors.success;
      } else if (strength >= 0.6) {
        text = 'Moyen';
        color = PlombiProColors.tertiaryTeal;
      } else if (strength >= 0.4) {
        text = 'Faible';
        color = PlombiProColors.warning;
      }
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = text;
      _passwordStrengthColor = color;
    });
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vous devez accepter les conditions d\'utilisation'),
          backgroundColor: PlombiProColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await SupabaseService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        companyName: _companyNameController.text.trim(),
        siret: _siretController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        // Navigate to email verification page
        context.go(
            '/email-verification?email=${Uri.encodeComponent(_emailController.text.trim())}');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: PlombiProColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue: ${e.toString()}'),
            backgroundColor: PlombiProColors.error,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _companyNameController.dispose();
    _siretController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PlombiProColors.primaryBlue.withOpacity(0.9),
                  PlombiProColors.tertiaryTeal.withOpacity(0.7),
                  PlombiProColors.backgroundDark,
                ],
              ),
            ),
          ),

          // Floating bubbles
          ..._buildFloatingBubbles(),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      GlassContainer(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(0),
                        borderRadius: BorderRadius.circular(20),
                        opacity: 0.2,
                        child: const Icon(
                          Icons.plumbing,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Title
                      const Text(
                        'PlombiPro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Créer votre compte professionnel',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Registration form in glass container
                      GlassContainer(
                        padding: const EdgeInsets.all(28),
                        opacity: 0.15,
                        borderRadius: BorderRadius.circular(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Full Name
                              _buildGlassTextField(
                                controller: _fullNameController,
                                labelText: 'Nom complet',
                                hintText: 'Jean Dupont',
                                prefixIcon: Icons.person_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre nom complet';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Email
                              _buildGlassTextField(
                                controller: _emailController,
                                labelText: 'Email',
                                hintText: 'votre@email.com',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Veuillez entrer un email valide';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Phone
                              _buildGlassTextField(
                                controller: _phoneController,
                                labelText: 'Téléphone',
                                hintText: '06 12 34 56 78',
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre numéro de téléphone';
                                  }
                                  final phoneDigits =
                                      value.replaceAll(RegExp(r'[\s\-\.]'), '');
                                  if (phoneDigits.length != 10) {
                                    return 'Le numéro doit contenir 10 chiffres';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Company Name
                              _buildGlassTextField(
                                controller: _companyNameController,
                                labelText: 'Nom de l\'entreprise',
                                hintText: 'Plomberie Dupont',
                                prefixIcon: Icons.business_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer le nom de votre entreprise';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // SIRET
                              _buildGlassTextField(
                                controller: _siretController,
                                labelText: 'Numéro SIRET',
                                hintText: '12345678901234',
                                prefixIcon: Icons.badge_outlined,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre numéro SIRET';
                                  }
                                  final siretDigits =
                                      value.replaceAll(RegExp(r'\s'), '');
                                  if (siretDigits.length != 14) {
                                    return 'Le SIRET doit contenir 14 chiffres';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Password with strength indicator
                              _buildGlassTextField(
                                controller: _passwordController,
                                labelText: 'Mot de passe',
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outlined,
                                obscureText: _obscurePassword,
                                suffixIcon: _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                onSuffixTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre mot de passe';
                                  }
                                  if (value.length < 6) {
                                    return 'Le mot de passe doit contenir au moins 6 caractères';
                                  }
                                  return null;
                                },
                              ),

                              // Password strength indicator
                              if (_passwordController.text.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                GlassContainer(
                                  padding: const EdgeInsets.all(12),
                                  opacity: 0.1,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: _passwordStrength,
                                                backgroundColor:
                                                    Colors.white.withOpacity(0.2),
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(
                                                        _passwordStrengthColor),
                                                minHeight: 6,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _passwordStrengthText,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _passwordStrengthColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Confirm Password
                              _buildGlassTextField(
                                controller: _confirmPasswordController,
                                labelText: 'Confirmer le mot de passe',
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline_outlined,
                                obscureText: _obscureConfirmPassword,
                                suffixIcon: _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                onSuffixTap: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez confirmer votre mot de passe';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Les mots de passe ne correspondent pas';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Terms and conditions
                              GlassContainer(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                opacity: 0.1,
                                borderRadius: BorderRadius.circular(12),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _acceptedTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _acceptedTerms = value ?? false;
                                        });
                                      },
                                      fillColor: MaterialStateProperty.resolveWith(
                                        (states) {
                                          if (states
                                              .contains(MaterialState.selected)) {
                                            return PlombiProColors.primaryBlue;
                                          }
                                          return Colors.white.withOpacity(0.3);
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _acceptedTerms = !_acceptedTerms;
                                          });
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            children: [
                                              const TextSpan(text: 'J\'accepte les '),
                                              TextSpan(
                                                text: 'conditions d\'utilisation',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const TextSpan(text: ' et la '),
                                              TextSpan(
                                                text:
                                                    'politique de confidentialité',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Sign up button
                              if (_isLoading)
                                Center(
                                  child: GlassContainer(
                                    width: 60,
                                    height: 60,
                                    padding: const EdgeInsets.all(16),
                                    borderRadius: BorderRadius.circular(15),
                                    opacity: 0.15,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                AnimatedGlassContainer(
                                  width: double.infinity,
                                  height: 56,
                                  borderRadius: BorderRadius.circular(16),
                                  opacity: 0.25,
                                  color: PlombiProColors.secondaryOrange,
                                  onTap: _signUp,
                                  child: const Center(
                                    child: Text(
                                      'S\'inscrire',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login link
                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Déjà un compte? ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const TextSpan(
                                text: 'Connectez-vous',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
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
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
              prefixIcon: Icon(
                prefixIcon,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        suffixIcon,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      onPressed: onSuffixTap,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFloatingBubbles() {
    return [
      Positioned(
        top: 80,
        right: 20,
        child: _FloatingBubble(size: 70, delay: 0),
      ),
      Positioned(
        top: 200,
        left: 15,
        child: _FloatingBubble(size: 50, delay: 1),
      ),
      Positioned(
        bottom: 120,
        right: 30,
        child: _FloatingBubble(size: 80, delay: 2),
      ),
    ];
  }
}

/// Floating bubble decoration widget
class _FloatingBubble extends StatefulWidget {
  final double size;
  final int delay;

  const _FloatingBubble({required this.size, required this.delay});

  @override
  State<_FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<_FloatingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3 + widget.delay),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 30).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.size / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
