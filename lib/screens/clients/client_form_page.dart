import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../models/client.dart';
import '../../services/supabase_service.dart';
import '../../config/plombipro_colors.dart';
import '../../widgets/glassmorphic/glass_card.dart';

/// Beautiful glassmorphic client form page
class ClientFormPage extends StatefulWidget {
  final String? clientId;

  const ClientFormPage({super.key, this.clientId});

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  Client? _client;

  // Form fields
  String _clientType = 'individual';
  String? _salutation;
  String? _firstName;
  late String _name;
  String _email = '';
  String _phone = '';
  String? _mobilePhone;
  String? _address;
  String? _postalCode;
  String? _city;
  String? _country;
  String? _billingAddress;
  String? _siret;
  String? _vatNumber;
  int? _defaultPaymentTerms;
  double? _defaultDiscount;
  List<String> _tags = [];
  bool _isFavorite = false;
  String? _notes;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    if (widget.clientId != null) {
      _fetchClient();
    } else {
      _name = '';
      _email = '';
      _phone = '';
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchClient() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final client = await SupabaseService.getClientById(widget.clientId!);
      if (client != null) {
        setState(() {
          _client = client;
          _clientType = _client!.clientType;
          _salutation = _client!.salutation;
          _firstName = _client!.firstName;
          _name = _client!.name;
          _email = _client!.email ?? '';
          _phone = _client!.phone ?? '';
          _mobilePhone = _client!.mobilePhone;
          _address = _client!.address;
          _postalCode = _client!.postalCode;
          _city = _client!.city;
          _country = _client!.country;
          _billingAddress = _client!.billingAddress;
          _siret = _client!.siret;
          _vatNumber = _client!.vatNumber;
          _defaultPaymentTerms = _client!.defaultPaymentTerms;
          _defaultDiscount = _client!.defaultDiscount;
          _tags = _client!.tags ?? [];
          _isFavorite = _client!.isFavorite;
          _notes = _client!.notes;
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement du client: ${e.toString()}'),
            backgroundColor: PlombiProColors.error,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated. Please log in again.');
        }

        // Sanitize email and phone (empty string becomes null)
        final sanitizedEmail = _email.trim().isEmpty ? null : _email.trim();
        final sanitizedPhone = _phone.trim().isEmpty ? null : _phone.trim();

        final newClient = Client(
          id: _client?.id,
          userId: currentUser.id,
          clientType: _clientType,
          salutation: _salutation,
          firstName: _firstName,
          name: _name.trim(),
          email: sanitizedEmail,
          phone: sanitizedPhone,
          mobilePhone: _mobilePhone?.trim(),
          address: _address?.trim(),
          postalCode: _postalCode?.trim(),
          city: _city?.trim(),
          country: _country ?? 'France',
          billingAddress: _billingAddress?.trim(),
          siret: _siret?.trim(),
          vatNumber: _vatNumber?.trim(),
          defaultPaymentTerms: _defaultPaymentTerms,
          defaultDiscount: _defaultDiscount,
          tags: _tags,
          isFavorite: _isFavorite,
          notes: _notes?.trim(),
        );

        if (_client == null) {
          await SupabaseService.createClient(newClient);
        } else {
          await SupabaseService.updateClient(_client!.id!, newClient);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Client enregistré avec succès'),
              backgroundColor: PlombiProColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
          context.pop(true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => _buildErrorDialog(e.toString()),
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

  Widget _buildErrorDialog(String error) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: PlombiProColors.backgroundDark.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Erreur',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Impossible d\'enregistrer le client.\n\n'
            'Détails: $error\n\n'
            'Veuillez vérifier que tous les champs requis sont remplis correctement.',
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(color: PlombiProColors.primaryBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          _buildGradientBackground(),

          // Content
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildGlassAppBar(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildForm(),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlombiProColors.primaryBlue,
            PlombiProColors.tertiaryTeal,
            PlombiProColors.primaryBlueDark,
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: GlassContainer(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        opacity: 0.2,
        child: const CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back button
          AnimatedGlassContainer(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(12),
            opacity: 0.2,
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              _client == null ? 'Nouveau Client' : 'Modifier le Client',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Save button
          AnimatedGlassContainer(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(12),
            opacity: 0.25,
            color: PlombiProColors.secondaryOrange,
            onTap: _isLoading ? null : _saveClient,
            child: const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.15,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PlombiProColors.primaryBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Informations du client',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Name field (required)
            _buildGlassTextField(
              labelText: 'Nom du client *',
              hintText: 'Nom complet',
              initialValue: _name,
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),

            const SizedBox(height: 20),

            // Email field (optional)
            _buildGlassTextField(
              labelText: 'Email',
              hintText: 'exemple@email.com',
              initialValue: _email,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('@')) {
                  return 'Adresse email invalide';
                }
                return null;
              },
              onSaved: (value) => _email = value ?? '',
            ),

            const SizedBox(height: 20),

            // Phone field (optional)
            _buildGlassTextField(
              labelText: 'Téléphone',
              hintText: '06 12 34 56 78',
              initialValue: _phone,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onSaved: (value) => _phone = value ?? '',
            ),

            const SizedBox(height: 24),

            // Address section header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlombiProColors.tertiaryTeal.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Adresse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Address field
            _buildGlassTextField(
              labelText: 'Adresse complète',
              hintText: '123 Rue Example',
              initialValue: _address,
              prefixIcon: Icons.home_outlined,
              onSaved: (value) => _address = value,
            ),

            const SizedBox(height: 20),

            // Postal code and city in a row
            Row(
              children: [
                // Postal code
                Expanded(
                  flex: 1,
                  child: _buildGlassTextField(
                    labelText: 'Code Postal',
                    hintText: '75001',
                    initialValue: _postalCode,
                    prefixIcon: Icons.markunread_mailbox_outlined,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _postalCode = value,
                  ),
                ),
                const SizedBox(width: 16),
                // City
                Expanded(
                  flex: 2,
                  child: _buildGlassTextField(
                    labelText: 'Ville',
                    hintText: 'Paris',
                    initialValue: _city,
                    prefixIcon: Icons.location_city_outlined,
                    onSaved: (value) => _city = value,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save button (large, prominent)
            AnimatedGlassContainer(
              width: double.infinity,
              height: 56,
              borderRadius: BorderRadius.circular(16),
              opacity: 0.25,
              color: PlombiProColors.secondaryOrange,
              onTap: _isLoading ? null : _saveClient,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    _client == null ? 'Créer le client' : 'Enregistrer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Required field note
            Center(
              child: Text(
                '* Champs requis',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required String labelText,
    required String hintText,
    required String? initialValue,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
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
            initialValue: initialValue,
            keyboardType: keyboardType,
            validator: validator,
            onSaved: onSaved,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(
                prefixIcon,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
