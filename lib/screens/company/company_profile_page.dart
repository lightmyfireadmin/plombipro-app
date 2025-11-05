import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/profile.dart';
import '../../services/supabase_service.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  Profile? _profile;

  // Form fields
  late String _companyName;
  late String _address;
  late String _siret;
  late String _vatNumber;
  late String _iban;

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
            _companyName = _profile!.companyName ?? '';
            _address = _profile!.address ?? '';
            _siret = _profile!.siret ?? '';
            _vatNumber = _profile!.vatNumber ?? '';
            _iban = _profile!.iban ?? '';
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
          companyName: _companyName,
          address: _address,
          siret: _siret,
          vatNumber: _vatNumber,
          iban: _iban,
        );

        await SupabaseService.updateProfile(updatedProfile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profil de l\'entreprise enregistré avec succès')),
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
        title: const Text('Mon Entreprise'),
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
              ? const Center(child: Text('Impossible de charger le profil de l\'entreprise.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          initialValue: _companyName,
                          decoration: const InputDecoration(labelText: 'Nom de l\'entreprise'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom de l\'entreprise';
                            }
                            return null;
                          },
                          onSaved: (value) => _companyName = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _address,
                          decoration: const InputDecoration(labelText: 'Adresse'),
                          onSaved: (value) => _address = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _siret,
                          decoration: const InputDecoration(labelText: 'SIRET'),
                          onSaved: (value) => _siret = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _vatNumber,
                          decoration: const InputDecoration(labelText: 'Numéro de TVA'),
                          onSaved: (value) => _vatNumber = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _iban,
                          decoration: const InputDecoration(labelText: 'IBAN'),
                          onSaved: (value) => _iban = value!,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}