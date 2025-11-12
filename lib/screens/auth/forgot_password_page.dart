import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../services/error_handler.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _sendPasswordResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Supabase.instance.client.auth.resetPasswordForEmail(
          _emailController.text.trim(),
          redirectTo: '${const String.fromEnvironment('APP_URL', defaultValue: 'plombipro://app')}/reset-password',
        );

        if (mounted) {
          setState(() {
            _emailSent = true;
          });
          context.showSuccess('Email de réinitialisation envoyé!');
        }
      } catch (e) {
        if (mounted) {
          context.handleError(e, customMessage: 'Erreur lors de l\'envoi de l\'email');
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
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: _emailSent ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.lock_reset,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Réinitialisation du mot de passe',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Adresse email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Veuillez entrer une adresse email valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _sendPasswordResetEmail,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Envoyer le lien de réinitialisation',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              context.go('/login');
            },
            child: const Text('Retour à la connexion'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.mark_email_read,
          size: 100,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        Text(
          'Email envoyé!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Nous avons envoyé un email de réinitialisation à:',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text.trim(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(height: 12),
              Text(
                'Cliquez sur le lien dans l\'email pour réinitialiser votre mot de passe.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Si vous ne recevez pas l\'email dans quelques minutes, vérifiez vos spams.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
              _emailController.clear();
            });
          },
          child: const Text('Envoyer à une autre adresse'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            context.go('/login');
          },
          child: const Text('Retour à la connexion'),
        ),
      ],
    );
  }
}