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

  late String _email;

  late String _phone;

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

          _email = _client!.email;

          _phone = _client!.phone;

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

        final newClient = Client(

          id: _client?.id,

          userId: Supabase.instance.client.auth.currentUser!.id,

          clientType: _clientType,

          salutation: _salutation,

          firstName: _firstName,

          name: _name,

          email: _email,

          phone: _phone,

          mobilePhone: _mobilePhone,

          address: _address,

          postalCode: _postalCode,

          city: _city,

          country: _country,

          billingAddress: _billingAddress,

          siret: _siret,

          vatNumber: _vatNumber,

          defaultPaymentTerms: _defaultPaymentTerms,

          defaultDiscount: _defaultDiscount,

          tags: _tags,

          isFavorite: _isFavorite,

          notes: _notes,

        );



        if (_client == null) {

          await SupabaseService.createClient(newClient);

        } else {

          await SupabaseService.updateClient(_client!.id!, newClient);

        }



        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(

            SnackBar(content: Text('Client enregistré avec succès')),

          );

          Navigator.of(context).pop();

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

                      decoration: const InputDecoration(labelText: 'Email'),

                      keyboardType: TextInputType.emailAddress,

                      validator: (value) {

                        if (value == null || value.isEmpty || !value.contains('@')) {

                          return 'Veuillez entrer une adresse email valide';

                        }

                        return null;

                      },

                      onSaved: (value) => _email = value!,

                    ),

                    const SizedBox(height: 16),

                    TextFormField(

                      initialValue: _phone,

                      decoration: const InputDecoration(labelText: 'Téléphone'),

                      keyboardType: TextInputType.phone,

                      validator: (value) {

                        if (value == null || value.isEmpty) {

                          return 'Veuillez entrer un numéro de téléphone';

                        }

                        return null;

                      },

                      onSaved: (value) => _phone = value!,

                    ),

                    const SizedBox(height: 16),

                    TextFormField(

                      initialValue: _address,

                      decoration: const InputDecoration(labelText: 'Adresse'),

                      onSaved: (value) => _address = value!,

                    ),

                  ],

                ),

              ),

            ),

    );

  }

}
