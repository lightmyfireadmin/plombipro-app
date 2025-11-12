import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/client.dart';
import '../../models/line_item.dart';
import '../../models/product.dart';
import '../../models/invoice.dart';
import '../../services/invoice_calculator.dart';
import '../../services/supabase_service.dart';
import '../../services/stripe_service.dart';
import '../../services/facturx_service.dart';
import '../../services/chorus_pro_service.dart';
import '../../config/env_config.dart';
import '../../widgets/section_header.dart';

import '../templates/document_templates_page.dart';

class InvoiceFormPage extends StatefulWidget {
  final String? invoiceId;

  const InvoiceFormPage({super.key, this.invoiceId});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditing => widget.invoiceId != null;
  Invoice? _invoice;

  // Form state
  Client? _selectedClient;
  List<Client> _clients = [];
  final TextEditingController _invoiceNumberController = TextEditingController();
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  List<LineItem> _lineItems = [];
  List<Product> _products = [];
  double _totalHT = 0;
  double _totalTVA = 0;
  double _totalTTC = 0;
  double _tvaRate = 20.0; // Default to 20% (standard rate)
  final TextEditingController _notesController = TextEditingController();

  // French VAT rates
  static const List<double> _availableVatRates = [20.0, 10.0, 5.5, 2.1];

  // Invoice specific fields
  String _invoiceType = 'standard'; // standard, deposit, progress, credit_note
  String _paymentStatus = 'Brouillon';
  String _paymentMethod = 'Virement bancaire';
  bool _generateFacturX = false;
  String? _xmlUrl;
  bool _submitToChorusPro = false;

  // Legal mentions and terms
  final TextEditingController _termsConditionsController = TextEditingController();
  final TextEditingController _legalMentionsController = TextEditingController();
  String? _companyIban;
  String? _companyBic;
  String? _companySiret;
  String? _companyVatNumber;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _notesController.dispose();
    _termsConditionsController.dispose();
    _legalMentionsController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      if (_isEditing) {
        final invoice = await SupabaseService.getInvoiceById(widget.invoiceId!);
        setState(() {
          _invoice = invoice;
        });
      }

      final clientsFuture = SupabaseService.fetchClients();
      final productsFuture = SupabaseService.fetchProducts();
      final results = await Future.wait([clientsFuture, productsFuture]);

      // Load company profile for legal mentions and bank details
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      Map<String, dynamic>? companyProfile;
      Map<String, dynamic>? userSettings;

      if (userId != null) {
        try {
          companyProfile = await supabase
              .from('profiles')
              .select('company_name, siret, vat_number, iban, bic, address, postal_code, city')
              .eq('id', userId)
              .maybeSingle();

          userSettings = await supabase
              .from('settings')
              .select('default_invoice_footer, default_payment_terms_days')
              .eq('user_id', userId)
              .maybeSingle();
        } catch (e) {
          debugPrint('Error loading company profile: $e');
        }
      }

      setState(() {
        _clients = results[0] as List<Client>;
        _products = results[1] as List<Product>;

        // Load company info for legal mentions
        if (companyProfile != null) {
          _companyIban = companyProfile['iban'] as String?;
          _companyBic = companyProfile['bic'] as String?;
          _companySiret = companyProfile['siret'] as String?;
          _companyVatNumber = companyProfile['vat_number'] as String?;

          // Auto-generate legal mentions
          final companyName = companyProfile['company_name'] as String? ?? 'Votre Entreprise';
          final address = companyProfile['address'] as String? ?? '';
          final postalCode = companyProfile['postal_code'] as String? ?? '';
          final city = companyProfile['city'] as String? ?? '';

          _legalMentionsController.text = _generateLegalMentions(
            companyName: companyName,
            address: address,
            postalCode: postalCode,
            city: city,
            siret: _companySiret,
            vatNumber: _companyVatNumber,
          );
        }

        // Load default terms & conditions from settings
        if (userSettings != null && userSettings['default_invoice_footer'] != null) {
          _termsConditionsController.text = userSettings['default_invoice_footer'] as String;
        } else {
          _termsConditionsController.text = _getDefaultTermsConditions();
        }

        if (_isEditing && _invoice != null) {
          // Populate form with existing invoice data
          final invoice = _invoice!;
          _invoiceNumberController.text = invoice.number;
          _selectedClient = _clients.firstWhere((c) => c.id == invoice.clientId, orElse: () => Client(id: null, userId: Supabase.instance.client.auth.currentUser!.id, name: 'Client Inconnu', email: '', phone: '', address: null, city: null));
          _invoiceDate = invoice.date;
          _dueDate = invoice.dueDate ?? _invoiceDate.add(const Duration(days: 30));
          _lineItems = List<LineItem>.from(invoice.items);
          _totalHT = invoice.totalHt;
          _totalTVA = invoice.totalTva;
          _totalTTC = invoice.totalTtc;
          _paymentStatus = invoice.paymentStatus;
          _notesController.text = invoice.notes ?? '';
          _paymentMethod = invoice.paymentMethod ?? 'Virement bancaire';
          _generateFacturX = invoice.isElectronic ?? false;
          _xmlUrl = invoice.xmlUrl;

          // Override with existing invoice legal mentions if present
          // (for now, we use auto-generated ones)
        } else {
          // For new invoices, leave as DRAFT - will be auto-generated by database trigger
          _invoiceNumberController.text = 'DRAFT';
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des données: ${e.toString()}")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _generateLegalMentions({
    required String companyName,
    required String address,
    required String postalCode,
    required String city,
    String? siret,
    String? vatNumber,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('$companyName');
    if (address.isNotEmpty) {
      buffer.writeln('$address');
      buffer.writeln('$postalCode $city');
    }
    if (siret != null && siret.isNotEmpty) {
      buffer.writeln('SIRET: $siret');
    }
    if (vatNumber != null && vatNumber.isNotEmpty) {
      buffer.writeln('TVA intracommunautaire: $vatNumber');
    }
    buffer.writeln('\nDispense d\'immatriculation au RCS ou au RM (Article L123-1-1 du Code de Commerce)');
    buffer.writeln('Assurance professionnelle: Garantie décennale');
    return buffer.toString();
  }

  String _getDefaultTermsConditions() {
    return '''Conditions de paiement: Règlement à 30 jours
En cas de retard de paiement, des pénalités de retard au taux de 10% seront appliquées.
Indemnité forfaitaire pour frais de recouvrement: 40€

Aucun escompte ne sera accordé en cas de paiement anticipé.
Tout acompte versé restera acquis en cas d'annulation.

TVA non applicable, art. 293 B du CGI (si applicable)
Garantie décennale et responsabilité civile professionnelle''';
  }

  void _calculateTotals() {
    double subtotal = 0;
    for (var item in _lineItems) {
      subtotal += item.lineTotal;
    }
    setState(() {
      _totalHT = subtotal;
      _totalTVA = InvoiceCalculator.calculateVAT(subtotal: _totalHT, tvaRate: _tvaRate);
      _totalTTC = _totalHT + _totalTVA;
    });
  }

  Future<void> _saveInvoice() async {
    // Validation checks
    if (!_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Validation échouée'),
          content: const Text('Veuillez remplir tous les champs requis.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (_selectedClient == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Client manquant'),
          content: const Text('Veuillez sélectionner un client pour cette facture.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (_selectedClient!.id == null || _selectedClient!.id!.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur Client'),
          content: const Text('Le client sélectionné n\'a pas d\'ID valide. Veuillez sélectionner un autre client.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (_lineItems.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Articles manquants'),
          content: const Text('Veuillez ajouter au moins un article à la facture.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() { _isSaving = true; });

    try {
      print('💾 Saving Invoice:');
      print('  - Client: ${_selectedClient!.name} (ID: ${_selectedClient!.id})');
      print('  - Number: ${_invoiceNumberController.text}');
      print('  - Date: $_invoiceDate');
      print('  - Due Date: $_dueDate');
      print('  - Line Items: ${_lineItems.length}');
      print('  - Total HT: $_totalHT');
      print('  - Total TVA: $_totalTVA');
      print('  - Total TTC: $_totalTTC');
      print('  - Payment Status: $_paymentStatus');
      print('  - Generate Factur-X: $_generateFacturX');

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non authentifié. Veuillez vous reconnecter.');
      }

      final invoice = Invoice(
        id: _invoice?.id,
        userId: userId,
        number: _invoiceNumberController.text.trim(),
        clientId: _selectedClient!.id!,
        date: _invoiceDate,
        dueDate: _dueDate,
        totalHt: _totalHT,
        totalTva: _totalTVA,
        totalTtc: _totalTTC,
        paymentStatus: _paymentStatus,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        paymentMethod: _paymentMethod,
        isElectronic: _generateFacturX,
        xmlUrl: _xmlUrl,
        client: _selectedClient,
        items: _lineItems,
      );

      print('  - Invoice object created');

      String invoiceId;
      if (_isEditing) {
        print('  - Updating existing invoice: ${invoice.id}');
        await SupabaseService.updateInvoice(invoice.id!, invoice);
        invoiceId = invoice.id!;
        print('  ✅ Invoice updated successfully');
      } else {
        print('  - Creating new invoice...');
        invoiceId = await SupabaseService.createInvoice(invoice);
        print('  ✅ Invoice created with ID: $invoiceId');

        print('  - Creating ${_lineItems.length} line items...');
        await SupabaseService.createInvoiceLineItems(invoiceId, _lineItems);
        print('  ✅ Line items created successfully');
      }

      // Generate Factur-X if requested
      if (_generateFacturX) {
        try {
          // First validate that all required fields are present
          final validation = await FacturXService.validateForFacturX(invoiceId);

          if (!validation.isValid) {
            // Show validation errors
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Impossible de générer Factur-X:\n${validation.errors.join("\n")}',
                  ),
                  duration: const Duration(seconds: 5),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            // Show warnings if any
            if (validation.hasWarnings && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Avertissements Factur-X:\n${validation.warnings.join("\n")}',
                  ),
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.orange,
                ),
              );
            }

            // Proceed with generation
            final result = await FacturXService.generateFacturX(invoiceId);

            if (result != null && mounted) {
              setState(() {
                _xmlUrl = result['xml_url'];
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Factur-X généré avec succès!\nNiveau: ${result['level']}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );

              // Submit to Chorus Pro if requested
              if (_submitToChorusPro) {
                try {
                  final chorusProUrl = EnvConfig.chorusProSubmitterUrl;
                  if (chorusProUrl.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('URL Chorus Pro non configurée dans les paramètres'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } else {
                    final chorusProService = ChorusProService(
                      cloudFunctionUrl: chorusProUrl,
                      testMode: EnvConfig.environment != 'production',
                    );

                    final chorusResult = await chorusProService.submitInvoice(invoiceId);

                    if (mounted) {
                      if (chorusResult['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Facture soumise à Chorus Pro!\nID Chorus: ${chorusResult['chorus_invoice_id']}\nStatut: ${ChorusProService.getStatusText(chorusResult['status'])}',
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Erreur Chorus Pro: ${chorusResult['error']}',
                            ),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de la soumission à Chorus Pro: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              }
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de la génération Factur-X: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Facture enregistrée avec succès!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }

    } catch (e, stackTrace) {
      print('❌ Error saving invoice: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur'),
            content: Text(
              'Impossible d\'enregistrer la facture.\n\n'
              'Détails: ${e.toString()}\n\n'
              'Veuillez vérifier que tous les champs sont correctement remplis.',
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
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Éditer Facture' : 'Nouvelle Facture'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveInvoice,
              tooltip: 'Enregistrer',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Section 1: Client
                  const SectionHeader(title: 'Client'),
                  _buildClientSelector(),
                  const SizedBox(height: 16),

                  // Section 1.5: Invoice Type
                  const SectionHeader(title: 'Type de Facture'),
                  _buildInvoiceTypeSelector(),
                  const SizedBox(height: 16),

                  // Section 2: Dates (Issue Date only for Invoice)
                  const SectionHeader(title: 'Date'),
                  _buildDatePicker(context, 'Date de Facture', _invoiceDate, (date) {
                    setState(() {
                      _invoiceDate = date;
                    });
                  }),
                  const SizedBox(height: 16),
                  _buildDatePicker(context, 'Date d\'échéance', _dueDate, (date) {
                    setState(() {
                      _dueDate = date;
                    });
                  }),
                  const SizedBox(height: 16),

                  // Section 3: Line Items
                  const SectionHeader(title: 'Lignes'),
                  _buildLineItemsEditor(),
                  const SizedBox(height: 16),

                  // Section 4: Calculations
                  const SectionHeader(title: 'Calculs'),
                  _buildTotalsCard(),
                  const SizedBox(height: 16),

                  // Invoice specific sections
                  const SectionHeader(title: 'Paiement'),
                  _buildPaymentSection(),
                  const SizedBox(height: 16),

                  const SectionHeader(title: 'Coordonnées Bancaires'),
                  _buildBankDetailsSection(),
                  const SizedBox(height: 16),

                  const SectionHeader(title: 'Conditions de Paiement'),
                  _buildTermsConditionsSection(),
                  const SizedBox(height: 16),

                  const SectionHeader(title: 'Mentions Légales'),
                  _buildLegalMentionsSection(),
                  const SizedBox(height: 16),

                  const SectionHeader(title: 'Options'),
                  _buildOptionsSection(),

                  const SizedBox(height: 32),
                  _buildActionButtons(),

                  // Payment Action Button
                  if (_invoice != null && _invoice!.paymentStatus != 'paid')
                    _buildPaymentActionButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildClientSelector() {
    return DropdownButtonFormField<Client>(
      initialValue: _selectedClient,
      decoration: const InputDecoration(labelText: 'Client'),
      items: _clients.map((Client client) {
        return DropdownMenuItem<Client>(
          value: client,
          child: Text(client.name),
        );
      }).toList(),
      onChanged: (Client? newValue) {
        setState(() {
          _selectedClient = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner un client';
        }
        return null;
      },
    );
  }

  Widget _buildInvoiceTypeSelector() {
    return DropdownButtonFormField<String>(
      value: _invoiceType,
      decoration: const InputDecoration(
        labelText: 'Type de Facture',
        border: OutlineInputBorder(),
        helperText: 'Sélectionnez le type de facture approprié',
      ),
      items: const [
        DropdownMenuItem(value: 'standard', child: Text('Facture standard')),
        DropdownMenuItem(value: 'deposit', child: Text('Facture d\'acompte')),
        DropdownMenuItem(value: 'progress', child: Text('Facture de situation')),
        DropdownMenuItem(value: 'credit_note', child: Text('Avoir (crédit)')),
      ],
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _invoiceType = newValue;
          });
        }
      },
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime selectedDate, Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        baseStyle: Theme.of(context).textTheme.bodyLarge,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(InvoiceCalculator.formatDate(selectedDate)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Articles'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _lineItems.length,
          itemBuilder: (context, index) {
            final item = _lineItems[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: item.description,
                      decoration: InputDecoration(labelText: 'Description de l\'article ${index + 1}'),
                      onChanged: (value) {
                        setState(() {
                          _lineItems[index] = item.copyWith(description: value);
                          _calculateTotals();
                        });
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: item.quantity.toString(),
                            decoration: const InputDecoration(labelText: 'Quantité'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _lineItems[index] = item.copyWith(quantity: double.tryParse(value) ?? 0.0);
                                _calculateTotals();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: item.unitPrice.toStringAsFixed(2),
                            decoration: const InputDecoration(labelText: 'Prix unitaire'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _lineItems[index] = item.copyWith(unitPrice: double.tryParse(value) ?? 0.0);
                                _calculateTotals();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: item.taxRate.toStringAsFixed(2),
                            decoration: const InputDecoration(labelText: 'TVA %'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _lineItems[index] = item.copyWith(taxRate: double.tryParse(value) ?? 0.0);
                                _calculateTotals();
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _lineItems.removeAt(index);
                              _calculateTotals();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _lineItems.add(LineItem(description: '', quantity: 1.0, unitPrice: 0.0, taxRate: 20.0));
                _calculateTotals();
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un article'),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total HT:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(InvoiceCalculator.formatCurrency(_totalHT)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('TVA', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    DropdownButton<double>(
                      value: _tvaRate,
                      items: _availableVatRates.map((rate) {
                        return DropdownMenuItem<double>(
                          value: rate,
                          child: Text('${rate.toStringAsFixed(rate == rate.roundToDouble() ? 0 : 1)}%'),
                        );
                      }).toList(),
                      onChanged: (double? newRate) {
                        if (newRate != null) {
                          setState(() {
                            _tvaRate = newRate;
                            _calculateTotals();
                          });
                        }
                      },
                    ),
                  ],
                ),
                Text(InvoiceCalculator.formatCurrency(_totalTVA)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total TTC:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(InvoiceCalculator.formatCurrency(_totalTTC), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _paymentMethod,
          decoration: const InputDecoration(
            labelText: 'Méthode de Paiement',
            border: OutlineInputBorder(),
            helperText: 'Sélectionnez la méthode de paiement acceptée',
          ),
          items: <String>[
            'Virement bancaire',
            'Chèque',
            'Espèces',
            'Carte bancaire',
            'Prélèvement SEPA',
            'Stripe',
            'Autre'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _paymentMethod = newValue;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes internes (non imprimées)',
            border: OutlineInputBorder(),
            helperText: 'Notes privées, ne seront pas affichées sur la facture',
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildBankDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informations bancaires pour le virement',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_companyIban != null && _companyIban!.isNotEmpty) ...[
              Row(
                children: [
                  const SizedBox(width: 80, child: Text('IBAN:', style: TextStyle(fontWeight: FontWeight.w500))),
                  Expanded(child: Text(_companyIban!)),
                ],
              ),
              const SizedBox(height: 8),
            ] else
              const Text('IBAN non renseigné dans votre profil', style: TextStyle(color: Colors.orange)),

            if (_companyBic != null && _companyBic!.isNotEmpty) ...[
              Row(
                children: [
                  const SizedBox(width: 80, child: Text('BIC:', style: TextStyle(fontWeight: FontWeight.w500))),
                  Expanded(child: Text(_companyBic!)),
                ],
              ),
            ] else
              const Text('BIC non renseigné dans votre profil', style: TextStyle(color: Colors.orange)),

            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to company profile settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Modifiez vos coordonnées bancaires dans Paramètres > Profil Entreprise')),
                );
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Modifier les coordonnées bancaires'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsConditionsSection() {
    return TextFormField(
      controller: _termsConditionsController,
      decoration: const InputDecoration(
        labelText: 'Conditions de paiement et clauses',
        border: OutlineInputBorder(),
        helperText: 'Ces conditions seront affichées sur la facture',
        helperMaxLines: 2,
      ),
      maxLines: 5,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Les conditions de paiement sont obligatoires';
        }
        return null;
      },
    );
  }

  Widget _buildLegalMentionsSection() {
    return TextFormField(
      controller: _legalMentionsController,
      decoration: const InputDecoration(
        labelText: 'Mentions légales',
        border: OutlineInputBorder(),
        helperText: 'Mentions légales obligatoires (SIRET, TVA, etc.)',
        helperMaxLines: 2,
      ),
      maxLines: 7,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Les mentions légales sont obligatoires';
        }
        return null;
      },
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Générer Factur-X'),
          subtitle: const Text('Génère un PDF conforme Factur-X (obligatoire pour B2B en 2026)'),
          value: _generateFacturX,
          onChanged: (bool value) {
            setState(() {
              _generateFacturX = value;
            });
          },
        ),
        if (_xmlUrl != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Factur-X XML URL: $_xmlUrl', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        SwitchListTile(
          title: const Text('Soumettre à Chorus Pro'),
          subtitle: const Text('Soumet automatiquement la facture au portail gouvernemental Chorus Pro'),
          value: _submitToChorusPro,
          onChanged: (bool value) {
            setState(() {
              _submitToChorusPro = value;
              // If Chorus Pro is enabled, Factur-X must also be enabled
              if (value && !_generateFacturX) {
                _generateFacturX = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Factur-X a été activé automatiquement (requis pour Chorus Pro)'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DocumentTemplatesPage()));
          },
          child: const Text('Charger un modèle'),
        ),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _saveInvoice,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentActionButton() {
    if (_paymentMethod == 'Stripe') {
      return ElevatedButton.icon(
        onPressed: _isSaving ? null : () async {
          setState(() { _isSaving = true; });
          try {
            final result = await StripePaymentService.processPayment(
              amount: _totalTTC,
              invoiceId: _invoice!.id!,
              clientEmail: _selectedClient!.email ?? '',
            );
            if (result.success) {
              // Update invoice status to paid
              await SupabaseService.updateInvoice(_invoice!.id!, _invoice!.copyWith(paymentStatus: 'paid'));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
                Navigator.of(context).pop(true);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur de paiement: ${e.toString()}")));
            }
          } finally {
            if (mounted) setState(() { _isSaving = false; });
          }
        },
        icon: const Icon(Icons.payment),
        label: const Text('Payer par Carte'),
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: _isSaving ? null : () async {
          setState(() { _isSaving = true; });
          try {
            await SupabaseService.updateInvoice(_invoice!.id!, _invoice!.copyWith(paymentStatus: 'paid'));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Facture marquée comme payée.')));
              Navigator.of(context).pop(true);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}")));
            }
          } finally {
            if (mounted) setState(() { _isSaving = false; });
          }
        },
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Marquer comme payée'),
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      );
    }
  }
}

// A dedicated widget to manage the state of a single line item
class _LineItemEditor extends StatefulWidget {
  final LineItem item;
  final ValueChanged<LineItem> onUpdate;
  final VoidCallback onRemove;
  final List<Product> products;

  const _LineItemEditor({required this.item, required this.onUpdate, required this.onRemove, required this.products});

  @override
  State<_LineItemEditor> createState() => _LineItemEditorState();
}

class _LineItemEditorState extends State<_LineItemEditor> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.item.description);
    _quantityController = TextEditingController(text: widget.item.quantity.toString());
    _priceController = TextEditingController(text: widget.item.unitPrice.toString());
    _discountController = TextEditingController(text: widget.item.discountPercent.toString());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _updateParent() {
    widget.onUpdate(widget.item.copyWith(
      description: _descriptionController.text,
      quantity: double.tryParse(_quantityController.text) ?? 0,
      unitPrice: double.tryParse(_priceController.text) ?? 0,
      discountPercent: int.tryParse(_discountController.text) ?? 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Autocomplete<Product>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<Product>.empty();
                return widget.products.where((p) => p.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              displayStringForOption: (Product option) => option.name,
              onSelected: (Product selection) {
                _descriptionController.text = selection.name;
                _priceController.text = selection.unitPrice.toString();
                _updateParent();
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Produit/Service'),
                  onChanged: (value) {
                    _descriptionController.text = value;
                    _updateParent();
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _quantityController, decoration: const InputDecoration(labelText: 'Qté'), keyboardType: TextInputType.number, onChanged: (_) => _updateParent())),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Prix U.', suffixText: '€'), keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (_) => _updateParent())),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _discountController, decoration: const InputDecoration(labelText: 'Remise', suffixText: '%'), keyboardType: TextInputType.number, onChanged: (_) => _updateParent())),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: widget.onRemove, tooltip: 'Supprimer la ligne'),
                Text('Total: ${InvoiceCalculator.formatCurrency(widget.item.lineTotal)}', style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}