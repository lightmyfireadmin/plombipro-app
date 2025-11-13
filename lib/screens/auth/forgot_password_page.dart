import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../services/error_handler.dart';
import '../../config/glassmorphism_theme.dart';
import '../../config/plombipro_colors.dart';
import '../../widgets/glassmorphic/glass_card.dart';

/// Modern glassmorphic forgot password page
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

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
  }

  Future<void> _sendPasswordResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Supabase.instance.client.auth.resetPasswordForEmail(
          _emailController.text.trim(),
          redirectTo:
              '${const String.fromEnvironment('APP_URL', defaultValue: 'plombipro://app')}/reset-password',
        );

        if (mounted) {
          setState(() {
            _emailSent = true;
          });
          context.showSuccess('Email de réinitialisation envoyé!');
        }
      } catch (e) {
        if (mounted) {
          context.handleError(e,
              customMessage: 'Erreur lors de l\'envoi de l\'email');
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
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
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
                  child: _emailSent ? _buildSuccessView() : _buildFormView(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        GlassContainer(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(0),
          borderRadius: BorderRadius.circular(25),
          opacity: 0.2,
          child: const Icon(
            Icons.lock_reset,
            color: Colors.white,
            size: 56,
          ),
        ),

        const SizedBox(height: 24),

        // Title
        const Text(
          'Mot de passe oublié?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Entrez votre adresse email et nous vous\nenverrons un lien de réinitialisation',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Form in glass container
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adresse email',
                      style: TextStyle(
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
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'votre@email.com',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Veuillez entrer une adresse email valide';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Submit button
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
                    onTap: _sendPasswordResetEmail,
                    child: const Center(
                      child: Text(
                        'Envoyer le lien',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Back to login
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    child: const Text(
                      'Retour à la connexion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success icon
        GlassContainer(
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(0),
          borderRadius: BorderRadius.circular(30),
          opacity: 0.2,
          color: PlombiProColors.success,
          child: const Icon(
            Icons.mark_email_read,
            color: Colors.white,
            size: 64,
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          'Email envoyé!',
          style: TextStyle(
            color: PlombiProColors.success,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Nous avons envoyé un email de\nréinitialisation à:',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          _emailController.text.trim(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Info card
        GlassContainer(
          padding: const EdgeInsets.all(24),
          opacity: 0.15,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: PlombiProColors.info,
                size: 32,
              ),
              const SizedBox(height: 16),
              Text(
                'Cliquez sur le lien dans l\'email pour réinitialiser votre mot de passe.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Si vous ne recevez pas l\'email dans quelques minutes, vérifiez vos spams.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Resend button
        AnimatedGlassContainer(
          width: double.infinity,
          height: 56,
          borderRadius: BorderRadius.circular(16),
          opacity: 0.15,
          color: Colors.white,
          onTap: () {
            setState(() {
              _emailSent = false;
              _emailController.clear();
            });
          },
          child: const Center(
            child: Text(
              'Envoyer à une autre adresse',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Back to login button
        AnimatedGlassContainer(
          width: double.infinity,
          height: 56,
          borderRadius: BorderRadius.circular(16),
          opacity: 0.25,
          color: PlombiProColors.primaryBlue,
          onTap: () {
            context.go('/login');
          },
          child: const Center(
            child: Text(
              'Retour à la connexion',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
