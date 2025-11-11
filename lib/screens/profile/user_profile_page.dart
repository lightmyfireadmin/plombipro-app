import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/profile.dart';
import '../../services/supabase_service.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  Profile? _profile;

  // Form fields
  late String _firstName;
  late String _lastName;
  late String _phone;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
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
          SnackBar(content: Text('Erreur de chargement du profil: ${e.toString()}')),
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
            SnackBar(content: Text('Profil enregistré avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
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
      appBar: AppBar(
        title: const Text('Mon Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveProfile,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('Impossible de charger le profil.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          initialValue: _profile!.email,
                          decoration: const InputDecoration(labelText: 'Email'),
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _firstName,
                          decoration: const InputDecoration(labelText: 'Prénom'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un prénom';
                            }
                            return null;
                          },
                          onSaved: (value) => _firstName = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _lastName,
                          decoration: const InputDecoration(labelText: 'Nom'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un nom';
                            }
                            return null;
                          },
                          onSaved: (value) => _lastName = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _phone,
                          decoration: const InputDecoration(labelText: 'Téléphone'),
                          keyboardType: TextInputType.phone,
                          onSaved: (value) => _phone = value!,
                        ),
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text('Abonnement', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Plan actuel'),
                          subtitle: Text(_profile!.subscriptionPlan ?? 'Free'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}