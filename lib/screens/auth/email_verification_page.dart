import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/error_handler.dart';

/// Email verification page shown after registration
/// Guides users to check their email and verify their account
class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isResending = false;
  bool _emailSent = false;

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
    });

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );

      if (mounted) {
        setState(() {
          _emailSent = true;
        });
        context.showSuccess('Email de vérification renvoyé avec succès!');
      }
    } catch (e) {
      if (mounted) {
        context.handleError(e, customMessage: 'Erreur lors de l\'envoi de l\'email');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification de l\'email'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Success Icon
              Icon(
                Icons.mark_email_read,
                size: 120,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Vérifiez votre email',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                'Nous avons envoyé un email de vérification à:',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Étapes suivantes:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep(
                      '1',
                      'Ouvrez votre boîte de réception',
                      Icons.inbox,
                    ),
                    _buildInstructionStep(
                      '2',
                      'Cliquez sur le lien de vérification',
                      Icons.link,
                    ),
                    _buildInstructionStep(
                      '3',
                      'Connectez-vous avec vos identifiants',
                      Icons.login,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Helpful tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Vous ne trouvez pas l\'email?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Vérifiez vos spams ou courrier indésirable\n'
                      '• Assurez-vous d\'avoir saisi le bon email\n'
                      '• L\'email peut prendre quelques minutes',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Resend email button
              if (_emailSent)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Email renvoyé! Vérifiez votre boîte de réception.',
                          style: TextStyle(color: Colors.green.shade900),
                        ),
                      ),
                    ],
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _isResending ? null : _resendVerificationEmail,
                  icon: _isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isResending ? 'Envoi en cours...' : 'Renvoyer l\'email'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              const SizedBox(height: 16),
              // Back to login button
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text('Retour à la connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
