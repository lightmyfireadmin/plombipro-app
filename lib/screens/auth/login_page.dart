import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import '../../services/biometric_auth_service.dart';
import '../../services/error_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _enableBiometricLogin = false;
  String _biometricType = '';

  @override
  void initState() {
    super.initState();
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
          context.go('/home');
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
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Save credentials for biometric login if enabled
      if (_enableBiometricLogin && _isBiometricAvailable) {
        await BiometricAuthService.enableBiometricLogin(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      if (mounted) {
        context.showSuccess('Connexion réussie!');
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        context.handleError(e);
      }
    }

    setState(() {
      _isLoading = false;
    });
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
          context.go('/home');
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

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Biometric login checkbox
                if (_isBiometricAvailable)
                  CheckboxListTile(
                    title: Text('Activer $_biometricType'),
                    subtitle: const Text('Connexion rapide et sécurisée'),
                    value: _enableBiometricLogin,
                    onChanged: (value) {
                      setState(() {
                        _enableBiometricLogin = value ?? false;
                      });
                    },
                  ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _signIn,
                            child: const Text('Se connecter'),
                          ),
                          // Biometric login button
                          if (_isBiometricAvailable && _enableBiometricLogin)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: OutlinedButton.icon(
                                onPressed: _signInWithBiometric,
                                icon: const Icon(Icons.fingerprint),
                                label: Text('Connexion avec $_biometricType'),
                              ),
                            ),
                        ],
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  child: const Text('Pas encore de compte? Inscrivez-vous'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}