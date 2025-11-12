import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/client.dart';
import '../../services/supabase_service.dart';

class ClientFormPage extends StatefulWidget {
  final String? clientId;

  const ClientFormPage({super.key, this.clientId});

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {

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



  @override

  void initState() {

    super.initState();

    if (widget.clientId != null) {
      _fetchClient();
    } else {

      _name = '';

      _email = '';

      _phone = '';

    }

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
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement du client: ${e.toString()}')),
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



  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        print('💾 Saving Client:');
        print('  - Name: $_name');
        print('  - Email: $_email');
        print('  - Phone: $_phone');
        print('  - Type: $_clientType');

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

        print('  - Creating client object: ${newClient.toJson()}');

        String clientId;
        if (_client == null) {
          print('  - Calling createClient...');
          clientId = await SupabaseService.createClient(newClient);
          print('  ✅ Client created with ID: $clientId');
        } else {
          print('  - Calling updateClient for ID: ${_client!.id}');
          await SupabaseService.updateClient(_client!.id!, newClient);
          print('  ✅ Client updated successfully');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Client enregistré avec succès'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e, stackTrace) {
        print('❌ Error saving client: $e');
        print('Stack trace: $stackTrace');

        if (mounted) {
          // Show error at top with more detail
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Erreur'),
              content: Text(
                'Impossible d\'enregistrer le client.\n\n'
                'Détails: ${e.toString()}\n\n'
                'Veuillez vérifier que tous les champs requis sont remplis correctement.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
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
    } else {
      print('❌ Form validation failed');
    }
  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(_client == null ? 'Nouveau Client' : 'Modifier le Client'),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),

        actions: [

          IconButton(

            onPressed: _isLoading ? null : _saveClient,

            icon: const Icon(Icons.save),

          ),

        ],

      ),

      body: _isLoading

          ? const Center(child: CircularProgressIndicator())

          : SingleChildScrollView(

              padding: const EdgeInsets.all(16.0),

              child: Form(

                key: _formKey,

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [

                    TextFormField(

                      initialValue: _name,

                      decoration: const InputDecoration(labelText: 'Nom du client'),

                      validator: (value) {

                        if (value == null || value.isEmpty) {

                          return 'Veuillez entrer un nom';

                        }

                        return null;

                      },

                      onSaved: (value) => _name = value!,

                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'exemple@email.com',
                        helperText: 'Optionnel',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        // Email is optional, but if provided, must be valid
                        if (value != null && value.isNotEmpty && !value.contains('@')) {
                          return 'Adresse email invalide';
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value ?? '',
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _phone,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        hintText: '06 12 34 56 78',
                        helperText: 'Optionnel',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        // Phone is optional
                        return null;
                      },
                      onSaved: (value) => _phone = value ?? '',
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _address,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        hintText: '123 Rue Example',
                        helperText: 'Optionnel',
                      ),
                      onSaved: (value) => _address = value,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _postalCode,
                      decoration: const InputDecoration(
                        labelText: 'Code Postal',
                        hintText: '75001',
                        helperText: 'Optionnel',
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _postalCode = value,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _city,
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        hintText: 'Paris',
                        helperText: 'Optionnel',
                      ),
                      onSaved: (value) => _city = value,
                    ),

                  ],

                ),

              ),

            ),

    );

  }

}
