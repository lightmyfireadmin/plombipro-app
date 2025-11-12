import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/setting.dart';
import '../../services/supabase_service.dart';
import '../../config/plombipro_colors.dart';
import '../../widgets/glassmorphic/glass_card.dart';

/// Beautiful glassmorphic invoice settings page
class InvoiceSettingsPage extends StatefulWidget {
  const InvoiceSettingsPage({super.key});

  @override
  State<InvoiceSettingsPage> createState() => _InvoiceSettingsPageState();
}

class _InvoiceSettingsPageState extends State<InvoiceSettingsPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  Setting? _settings;

  // Form fields
  late String _invoicePrefix;
  late String _quotePrefix;
  late int _defaultPaymentTerms;
  late int _defaultQuoteValidity;
  late bool _enableFacturx;
  late bool _chorusProEnabled;
  late String _chorusProClientId;
  late String _chorusProClientSecret;

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

    _fetchSettings();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settings = await SupabaseService.getUserSettings();
      if (settings != null) {
        setState(() {
          _settings = settings;
          _invoicePrefix = _settings!.invoicePrefix ?? 'FACT-';
          _quotePrefix = _settings!.quotePrefix ?? 'DEV-';
          _defaultPaymentTerms = _settings!.defaultPaymentTermsDays ?? 30;
          _defaultQuoteValidity = _settings!.defaultQuoteValidityDays ?? 30;
          _enableFacturx = _settings!.enableFacturx ?? false;
          _chorusProEnabled = _settings!.chorusProEnabled ?? false;
          _chorusProClientId =
              _settings!.chorusProCredentials?['client_id'] ?? '';
          _chorusProClientSecret =
              _settings!.chorusProCredentials?['client_secret'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Erreur de chargement des paramètres: ${e.toString()}'),
            backgroundColor: PlombiProColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward();
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedSettings = _settings!.copyWith(
          invoicePrefix: _invoicePrefix,
          quotePrefix: _quotePrefix,
          defaultPaymentTermsDays: _defaultPaymentTerms,
          defaultQuoteValidityDays: _defaultQuoteValidity,
          enableFacturx: _enableFacturx,
          chorusProEnabled: _chorusProEnabled,
          chorusProCredentials: {
            'client_id': _chorusProClientId,
            'client_secret': _chorusProClientSecret,
          },
        );

        await SupabaseService.updateUserSettings(updatedSettings);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Paramètres enregistrés avec succès'),
              backgroundColor: PlombiProColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: PlombiProColors.error,
            ),
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
      body: Stack(
        children: [
          // Gradient background
          _buildGradientBackground(),

          // Content
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : _settings == null
                    ? _buildErrorState()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            _buildGlassAppBar(),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      _buildPrefixesCard(),
                                      const SizedBox(height: 16),
                                      _buildDefaultsCard(),
                                      const SizedBox(height: 16),
                                      _buildIntegrationsCard(),
                                    ],
                                  ),
                                ),
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

  Widget _buildErrorState() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        borderRadius: BorderRadius.circular(24),
        opacity: 0.15,
        child: const Text(
          'Impossible de charger les paramètres',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
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
          const Expanded(
            child: Text(
              'Paramètres de Facturation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AnimatedGlassContainer(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(12),
            opacity: 0.25,
            color: PlombiProColors.success,
            onTap: _isLoading ? null : _saveSettings,
            child: const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPrefixesCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PlombiProColors.tertiaryTeal.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tag, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Préfixes de numérotation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildGlassTextField(
            labelText: 'Préfixe de facture',
            hintText: 'FACT-',
            initialValue: _invoicePrefix,
            prefixIcon: Icons.receipt_long,
            onSaved: (value) => _invoicePrefix = value!,
          ),
          const SizedBox(height: 20),
          _buildGlassTextField(
            labelText: 'Préfixe de devis',
            hintText: 'DEV-',
            initialValue: _quotePrefix,
            prefixIcon: Icons.description,
            onSaved: (value) => _quotePrefix = value!,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultsCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PlombiProColors.secondaryOrange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.schedule, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Valeurs par défaut',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildGlassTextField(
            labelText: 'Termes de paiement (jours)',
            hintText: '30',
            initialValue: _defaultPaymentTerms.toString(),
            prefixIcon: Icons.event,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              if (int.tryParse(value) == null) return 'Nombre invalide';
              return null;
            },
            onSaved: (value) =>
                _defaultPaymentTerms = int.tryParse(value!) ?? 30,
          ),
          const SizedBox(height: 20),
          _buildGlassTextField(
            labelText: 'Validité de devis (jours)',
            hintText: '30',
            initialValue: _defaultQuoteValidity.toString(),
            prefixIcon: Icons.timer,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              if (int.tryParse(value) == null) return 'Nombre invalide';
              return null;
            },
            onSaved: (value) =>
                _defaultQuoteValidity = int.tryParse(value!) ?? 30,
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationsCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PlombiProColors.accent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.integration_instructions,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Intégrations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Factur-X toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.verified,
                    color: PlombiProColors.success, size: 24),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Activer Factur-X',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Switch(
                  value: _enableFacturx,
                  onChanged: (value) => setState(() => _enableFacturx = value),
                  activeColor: PlombiProColors.success,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Chorus Pro toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.business,
                    color: PlombiProColors.info, size: 24),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Activer Chorus Pro',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Switch(
                  value: _chorusProEnabled,
                  onChanged: (value) =>
                      setState(() => _chorusProEnabled = value),
                  activeColor: PlombiProColors.success,
                ),
              ],
            ),
          ),

          // Chorus Pro credentials
          if (_chorusProEnabled) ...[
            const SizedBox(height: 20),
            _buildGlassTextField(
              labelText: 'Chorus Pro Client ID',
              hintText: 'Votre Client ID',
              initialValue: _chorusProClientId,
              prefixIcon: Icons.vpn_key,
              onSaved: (value) => _chorusProClientId = value!,
            ),
            const SizedBox(height: 20),
            _buildGlassTextField(
              labelText: 'Chorus Pro Client Secret',
              hintText: 'Votre Client Secret',
              initialValue: _chorusProClientSecret,
              prefixIcon: Icons.lock,
              obscureText: true,
              onSaved: (value) => _chorusProClientSecret = value!,
            ),
          ],

          const SizedBox(height: 24),

          // Save button
          AnimatedGlassContainer(
            width: double.infinity,
            height: 56,
            borderRadius: BorderRadius.circular(16),
            opacity: 0.25,
            color: PlombiProColors.success,
            onTap: _isLoading ? null : _saveSettings,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Enregistrer les paramètres',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required String labelText,
    required String hintText,
    required String? initialValue,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
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
            obscureText: obscureText,
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
