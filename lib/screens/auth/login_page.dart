import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import '../../services/biometric_auth_service.dart';
import '../../services/error_handler.dart';
import '../../config/glassmorphism_theme.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_text_styles.dart';
import '../../config/plombipro_spacing.dart';
import '../../widgets/glassmorphic/glass_card.dart';

/// Modern glassmorphic login page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _enableBiometricLogin = false;
  String _biometricType = '';
  bool _rememberMe = false;
  bool _obscurePassword = true;

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

    _checkBiometricAvailability();
    _attemptBiometricLogin();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await BiometricAuthService.isBiometricAvailable();
    final biometricType = await BiometricAuthService.getBiometricDescription();
    final isEnabled = await BiometricAuthService.isBiometricEnabled();

    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
        _biometricType = biometricType;
        _enableBiometricLogin = isEnabled;
      });
    }
  }

  Future<void> _attemptBiometricLogin() async {
    // Only attempt if biometric is enabled and available
    final isEnabled = await BiometricAuthService.isBiometricEnabled();
    if (!isEnabled) return;

    final credentials = await BiometricAuthService.getBiometricCredentials();
    if (credentials != null && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        await SupabaseService.signIn(
          email: credentials['email']!,
          password: credentials['password']!,
        );
        if (mounted) {
          context.go('/home-enhanced');
        }
      } catch (e) {
        // Silently fail biometric auto-login
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Save credentials for biometric login if enabled
      if (_enableBiometricLogin && _isBiometricAvailable) {
        await BiometricAuthService.enableBiometricLogin(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (mounted) {
        context.showSuccess('Connexion réussie!');
        context.go('/home-enhanced');
      }
    } catch (e) {
      if (mounted) {
        context.handleError(e);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithBiometric() async {
    setState(() {
      _isLoading = true;
    });

    final credentials = await BiometricAuthService.getBiometricCredentials();
    if (credentials != null) {
      try {
        await SupabaseService.signIn(
          email: credentials['email']!,
          password: credentials['password']!,
        );
        if (mounted) {
          context.showSuccess('Connexion réussie!');
          context.go('/home-enhanced');
        }
      } catch (e) {
        if (mounted) {
          context.handleError(e);
        }
      }
    } else {
      if (mounted) {
        context.showWarning('Authentification biométrique échouée');
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
                        width: 100,
                        height: 100,
                        padding: const EdgeInsets.all(0),
                        borderRadius: BorderRadius.circular(25),
                        opacity: 0.2,
                        child: const Icon(
                          Icons.plumbing,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'PlombiPro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Connexion à votre compte',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Login form in glass container
                      GlassContainer(
                        padding: const EdgeInsets.all(32),
                        opacity: 0.15,
                        borderRadius: BorderRadius.circular(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email field
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
                                    return 'Email invalide';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Password field
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

                              const SizedBox(height: 20),

                              // Biometric checkbox
                              if (_isBiometricAvailable)
                                GlassContainer(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  opacity: 0.1,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _enableBiometricLogin,
                                        onChanged: (value) {
                                          setState(() {
                                            _enableBiometricLogin =
                                                value ?? false;
                                          });
                                        },
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
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
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Activer $_biometricType',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              'Connexion rapide et sécurisée',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (_isBiometricAvailable)
                                const SizedBox(height: 20),

                              // Remember me and forgot password
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Remember me
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _rememberMe = !_rememberMe;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                          fillColor:
                                              MaterialStateProperty.resolveWith(
                                            (states) {
                                              if (states.contains(
                                                  MaterialState.selected)) {
                                                return PlombiProColors
                                                    .primaryBlue;
                                              }
                                              return Colors.white
                                                  .withOpacity(0.3);
                                            },
                                          ),
                                        ),
                                        const Text(
                                          'Se souvenir',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Forgot password
                                  TextButton(
                                    onPressed: () {
                                      context.push('/forgot-password');
                                    },
                                    child: const Text(
                                      'Mot de passe oublié?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Sign in button
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
                                Column(
                                  children: [
                                    // Primary sign in button
                                    AnimatedGlassContainer(
                                      width: double.infinity,
                                      height: 56,
                                      borderRadius: BorderRadius.circular(16),
                                      opacity: 0.25,
                                      color: PlombiProColors.secondaryOrange,
                                      onTap: _signIn,
                                      child: const Center(
                                        child: Text(
                                          'Se connecter',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Biometric login button
                                    if (_isBiometricAvailable &&
                                        _enableBiometricLogin) ...[
                                      const SizedBox(height: 16),
                                      AnimatedGlassContainer(
                                        width: double.infinity,
                                        height: 56,
                                        borderRadius: BorderRadius.circular(16),
                                        opacity: 0.15,
                                        color: Colors.white,
                                        onTap: _signInWithBiometric,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.fingerprint,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Connexion avec $_biometricType',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Register link
                      TextButton(
                        onPressed: () {
                          context.go('/register');
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Pas encore de compte? ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const TextSpan(
                                text: 'Inscrivez-vous',
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
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(
                prefixIcon,
                color: Colors.white.withOpacity(0.7),
              ),
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        suffixIcon,
                        color: Colors.white.withOpacity(0.7),
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
        top: 100,
        right: 30,
        child: _FloatingBubble(size: 80, delay: 0),
      ),
      Positioned(
        top: 250,
        left: 20,
        child: _FloatingBubble(size: 60, delay: 1),
      ),
      Positioned(
        bottom: 150,
        right: 40,
        child: _FloatingBubble(size: 90, delay: 2),
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
