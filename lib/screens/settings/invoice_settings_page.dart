import 'package:flutter/material.dart';
import '../../models/setting.dart';
import '../../services/supabase_service.dart';

class InvoiceSettingsPage extends StatefulWidget {
  const InvoiceSettingsPage({super.key});

  @override
  State<InvoiceSettingsPage> createState() => _InvoiceSettingsPageState();
}

class _InvoiceSettingsPageState extends State<InvoiceSettingsPage> {
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

  @override
  void initState() {
    super.initState();
    _fetchSettings();
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
          _chorusProClientId = _settings!.chorusProCredentials?['client_id'] ?? '';
          _chorusProClientSecret = _settings!.chorusProCredentials?['client_secret'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement des paramètres: ${e.toString()}')),
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
            SnackBar(content: Text('Paramètres enregistrés avec succès')),
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
        title: const Text('Paramètres de Facturation'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveSettings,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _settings == null
              ? const Center(child: Text('Impossible de charger les paramètres.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          initialValue: _invoicePrefix,
                          decoration: const InputDecoration(labelText: 'Préfixe de facture'),
                          onSaved: (value) => _invoicePrefix = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _quotePrefix,
                          decoration: const InputDecoration(labelText: 'Préfixe de devis'),
                          onSaved: (value) => _quotePrefix = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _defaultPaymentTerms.toString(),
                          decoration: const InputDecoration(labelText: 'Termes de paiement par défaut (jours)'),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _defaultPaymentTerms = int.parse(value!),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _defaultQuoteValidity.toString(),
                          decoration: const InputDecoration(labelText: 'Validité de devis par défaut (jours)'),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _defaultQuoteValidity = int.parse(value!),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Activer Factur-X'),
                          value: _enableFacturx,
                          onChanged: (value) => setState(() => _enableFacturx = value),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Activer Chorus Pro'),
                          value: _chorusProEnabled,
                          onChanged: (value) => setState(() => _chorusProEnabled = value),
                        ),
                        if (_chorusProEnabled)
                          Column(
                            children: [
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: _chorusProClientId,
                                decoration: const InputDecoration(labelText: 'Chorus Pro Client ID'),
                                onSaved: (value) => _chorusProClientId = value!,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: _chorusProClientSecret,
                                decoration: const InputDecoration(labelText: 'Chorus Pro Client Secret'),
                                obscureText: true,
                                onSaved: (value) => _chorusProClientSecret = value!,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}