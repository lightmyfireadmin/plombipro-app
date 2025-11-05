import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/supabase_service.dart';
import '../../models/profile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Profile? _profile;
  bool _isLoading = true;
  bool _isConnectingStripe = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });
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
          SnackBar(content: Text("Erreur de chargement du profil: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _connectStripeAccount() async {
    if (!mounted) return;
    setState(() { _isConnectingStripe = true; });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non authentifié.');
      }

      // Call the Edge Function to create a Stripe Connect account and get the onboarding URL
      final response = await Supabase.instance.client.functions.invoke(
        'create-stripe-connect-account',
        body: {
          'user_id': userId,
          'return_url': '${Uri.base.origin}/settings', // URL to return to after onboarding
          'refresh_url': '${Uri.base.origin}/settings', // URL to refresh if onboarding expires
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
        throw Exception(response.data['error'] ?? 'Échec de la création du compte Stripe Connect.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de connexion Stripe: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isConnectingStripe = false; });
        _fetchProfile(); // Refresh profile to show updated status
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSettingsSection(
                  context,
                  'Mon Profil',
                  Icons.person,
                  () => context.go('/profile'),
                ),
                _buildSettingsSection(
                  context,
                  'Mon Entreprise',
                  Icons.business,
                  () => context.go('/company-profile'),
                ),
                _buildSettingsSection(
                  context,
                  'Paramètres de Facturation',
                  Icons.receipt,
                  () => context.go('/invoice-settings'),
                ),
                // Stripe Connect Status
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stripe Connect Status', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        if (_profile?.stripeConnectId == null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Votre compte Stripe n\'est pas encore connecté.'),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _isConnectingStripe ? null : _connectStripeAccount,
                                icon: _isConnectingStripe ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.link),
                                label: Text(_isConnectingStripe ? 'Connexion en cours...' : 'Connecter mon compte Stripe'),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              const Text('Compte Stripe connecté'),
                              const Spacer(),
                              TextButton(onPressed: () { /* TODO: Manage Stripe Account */ }, child: const Text('Gérer')),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                // Other settings can go here
              ],
            ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}