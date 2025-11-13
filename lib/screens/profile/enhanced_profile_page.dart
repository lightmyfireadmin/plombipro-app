import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../models/profile.dart';
import '../../services/supabase_service.dart';
import '../../services/error_handler.dart';

/// Enhanced user profile page with avatar upload, company info, and logo management
class EnhancedProfilePage extends StatefulWidget {
  const EnhancedProfilePage({super.key});

  @override
  State<EnhancedProfilePage> createState() => _EnhancedProfilePageState();
}

class _EnhancedProfilePageState extends State<EnhancedProfilePage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  bool _isLoading = true;
  bool _isSaving = false;
  Profile? _profile;

  // Form controllers - Personal
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Form controllers - Company
  final _companyNameController = TextEditingController();
  final _siretController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();

  // Form controllers - Bank
  final _ibanController = TextEditingController();
  final _bicController = TextEditingController();

  File? _avatarImage;
  File? _logoImage;
  String? _avatarUrl;
  String? _logoUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _siretController.dispose();
    _vatNumberController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);

    try {
      final profile = await SupabaseService.fetchUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _profile = profile;
          _firstNameController.text = profile.firstName ?? '';
          _lastNameController.text = profile.lastName ?? '';
          _phoneController.text = profile.phone ?? '';
          _emailController.text = profile.email ?? '';
          _companyNameController.text = profile.companyName ?? '';
          _siretController.text = profile.siret ?? '';
          _vatNumberController.text = profile.vatNumber ?? '';
          _addressController.text = profile.address ?? '';
          _postalCodeController.text = profile.postalCode ?? '';
          _cityController.text = profile.city ?? '';
          _ibanController.text = profile.iban ?? '';
          _bicController.text = profile.bic ?? '';
          _avatarUrl = null; // Avatar URL not yet implemented in Profile model
          _logoUrl = profile.logoUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        context.handleError(e, customMessage: 'Erreur de chargement du profil');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _avatarImage = File(image.path);
      });
    }
  }

  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );

    if (image != null) {
      setState(() {
        _logoImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(File image, String bucket, String fileName) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final bytes = await image.readAsBytes();
      final filePath = '$userId/$fileName';

      await Supabase.instance.client.storage
          .from(bucket)
          .uploadBinary(filePath, bytes, fileOptions: FileOptions(upsert: true));

      final publicUrl = Supabase.instance.client.storage
          .from(bucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Upload avatar if changed
      String? newAvatarUrl = _avatarUrl;
      if (_avatarImage != null) {
        newAvatarUrl = await _uploadImage(
          _avatarImage!,
          'avatars',
          'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Upload logo if changed
      String? newLogoUrl = _logoUrl;
      if (_logoImage != null) {
        newLogoUrl = await _uploadImage(
          _logoImage!,
          'logos',
          'logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Update profile
      await SupabaseService.updateUserProfile(
        userId: userId,
        fullName: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        companyName: _companyNameController.text.trim(),
        siret: _siretController.text.trim(),
        vatNumber: _vatNumberController.text.trim().isEmpty ? null : _vatNumberController.text.trim(),
        address: _addressController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        city: _cityController.text.trim(),
        iban: _ibanController.text.trim(),
        bic: _bicController.text.trim(),
      );

      if (mounted) {
        context.showSuccess('Profil enregistré avec succès!');
        await _fetchProfile(); // Refresh
      }
    } catch (e) {
      if (mounted) {
        context.handleError(e, customMessage: 'Erreur lors de la sauvegarde');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
          onPressed: () => context.go('/home-enhanced'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Personnel'),
            Tab(icon: Icon(Icons.business), text: 'Entreprise'),
            Tab(icon: Icon(Icons.account_balance), text: 'Bancaire'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save),
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPersonalTab(),
                  _buildCompanyTab(),
                  _buildBankTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar Section
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  backgroundImage: _avatarImage != null
                      ? FileImage(_avatarImage!)
                      : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null) as ImageProvider?,
                  child: _avatarImage == null && _avatarUrl == null
                      ? Icon(Icons.person, size: 60, color: Theme.of(context).primaryColor)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      onPressed: _pickAvatar,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Personal Info
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'Prénom *',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le prénom est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Nom *',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email *',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty || !value.contains('@')) {
                return 'Email valide requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone *',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
              hintText: '06 12 34 56 78',
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le téléphone est requis';
              }
              final phoneDigits = value.replaceAll(RegExp(r'[\s\-\.]'), '');
              if (phoneDigits.length != 10) {
                return 'Numéro invalide (10 chiffres)';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Subscription info
          if (_profile != null) ...[
            const Divider(),
            const SizedBox(height: 16),
            Text('Abonnement', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.diamond, color: Theme.of(context).primaryColor),
                title: Text(_profile!.subscriptionPlan ?? 'Gratuit'),
                subtitle: const Text('Plan actuel'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Navigate to subscription management
                  },
                  child: const Text('Gérer'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo Section
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: _logoImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_logoImage!, fit: BoxFit.cover),
                        )
                      : _logoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(_logoUrl!, fit: BoxFit.cover),
                            )
                          : Icon(Icons.business, size: 60, color: Colors.grey[400]),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      onPressed: _pickLogo,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Logo de votre entreprise',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
          // Company Info
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'entreprise *',
              prefixIcon: Icon(Icons.business),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom de l\'entreprise est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _siretController,
            decoration: const InputDecoration(
              labelText: 'Numéro SIRET *',
              prefixIcon: Icon(Icons.badge),
              border: OutlineInputBorder(),
              hintText: '14 chiffres',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le SIRET est requis';
              }
              final siretDigits = value.replaceAll(RegExp(r'\s'), '');
              if (siretDigits.length != 14) {
                return 'Le SIRET doit contenir 14 chiffres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _vatNumberController,
            decoration: const InputDecoration(
              labelText: 'Numéro TVA (optionnel)',
              prefixIcon: Icon(Icons.euro),
              border: OutlineInputBorder(),
              hintText: 'FR12345678901',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Adresse *',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L\'adresse est requise';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Code postal *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Requis';
                    }
                    if (value.length != 5) {
                      return 'Code postal invalide';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'Ville *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La ville est requise';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ces informations apparaîtront sur vos factures pour faciliter les virements',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _ibanController,
            decoration: const InputDecoration(
              labelText: 'IBAN *',
              prefixIcon: Icon(Icons.account_balance),
              border: OutlineInputBorder(),
              hintText: 'FR76 1234 5678 9012 3456 7890 123',
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L\'IBAN est requis';
              }
              final iban = value.replaceAll(RegExp(r'\s'), '');
              if (!iban.startsWith('FR')) {
                return 'L\'IBAN doit commencer par FR';
              }
              if (iban.length != 27) {
                return 'IBAN invalide (27 caractères requis)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bicController,
            decoration: const InputDecoration(
              labelText: 'BIC/SWIFT *',
              prefixIcon: Icon(Icons.code),
              border: OutlineInputBorder(),
              hintText: 'BNPAFRPPXXX',
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le BIC est requis';
              }
              if (value.length < 8 || value.length > 11) {
                return 'BIC invalide (8-11 caractères)';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vos données bancaires sont sécurisées et ne sont utilisées que pour vos factures',
                    style: TextStyle(fontSize: 13, color: Colors.green.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
