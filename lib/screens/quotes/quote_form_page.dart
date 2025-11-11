import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../models/client.dart';
import '../../models/line_item.dart';
import '../../models/product.dart';
import '../../models/quote.dart';
import '../../services/invoice_calculator.dart';
import '../../services/supabase_service.dart';
import '../../services/template_service.dart';
import '../../services/pdf_generator.dart';
import '../../widgets/section_header.dart';

import '../templates/document_templates_page.dart';

class QuoteFormPage extends StatefulWidget {
  final String? quoteId;

  const QuoteFormPage({super.key, this.quoteId});

  @override
  State<QuoteFormPage> createState() => _QuoteFormPageState();
}

class _QuoteFormPageState extends State<QuoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditing => widget.quoteId != null;
  Quote? _quote;

  // Section 1: Client
  Client? _selectedClient;
  List<Client> _clients = [];
  final TextEditingController _clientController = TextEditingController();

  // Section 2: Dates
  DateTime _date = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));

  // Section 3: Templates
  List<TemplateInfo> _availableTemplates = [];
  TemplateInfo? _selectedTemplate;

  // Section 4: Line Items
  List<LineItem> _lineItems = [];
  List<Product> _products = [];

  // Section 5: Calculations
  double _totalHT = 0;
  double _totalTVA = 0;
  double _totalTTC = 0;
  double _tvaRate = 20.0; // Default to 20% (standard rate)

  // French VAT rates
  static const List<double> _availableVatRates = [20.0, 10.0, 5.5, 2.1];

  // Section 6: Options
  final TextEditingController _notesController = TextEditingController();
  bool _requiresSignature = false;
  bool _sendAfterCreation = false;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      if (_isEditing) {
        final quote = await SupabaseService.fetchQuoteById(widget.quoteId!);
        setState(() {
          _quote = quote;
        });
      }

      final clientsFuture = SupabaseService.fetchClients();
      final productsFuture = SupabaseService.fetchProducts();
      final templatesFuture = TemplateService.getTemplatesList();
      final results = await Future.wait([clientsFuture, productsFuture, templatesFuture]);

      setState(() {
        _clients = results[0] as List<Client>;
        _products = results[1] as List<Product>;
        _availableTemplates = results[2] as List<TemplateInfo>;
        if (_isEditing && _quote != null) {
          // Populate form with existing quote data
          final quote = _quote!;
          _selectedClient = _clients.firstWhere((c) => c.id == quote.clientId, orElse: () => Client(id: null, userId: Supabase.instance.client.auth.currentUser!.id, name: 'Client Inconnu', email: '', phone: '', address: null, city: null));
          if (_selectedClient != null) {
            _clientController.text = _selectedClient!.name;
          }
          _date = quote.date;
          _expiryDate = quote.expiryDate ?? DateTime.now().add(const Duration(days: 30));
          _lineItems = List<LineItem>.from(quote.items);
          _notesController.text = quote.notes ?? '';
          _calculateTotals();
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

  void _addLineItem() {
    setState(() {
      _lineItems.add(LineItem(description: '', quantity: 1, unitPrice: 0));
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _lineItems.removeAt(index);
      _calculateTotals();
    });
  }

  void _updateLineItem(int index, LineItem item) {
    setState(() {
      _lineItems[index] = item;
      _calculateTotals();
    });
  }

  Future<void> _applyTemplate(TemplateInfo templateInfo) async {
    try {
      // Load template by ID from database
      final template = await TemplateService.loadTemplate(templateInfo.id);
      if (template == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors du chargement du modèle')),
          );
        }
        return;
      }

      setState(() {
        _selectedTemplate = templateInfo;
        _lineItems = List<LineItem>.from(template.lineItems);
        if (template.termsConditions != null && template.termsConditions!.isNotEmpty) {
          _notesController.text = template.termsConditions!;
        }
        _calculateTotals();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Modèle "${templateInfo.name}" appliqué avec succès! (${template.lineItems.length} articles)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  void _showTemplateSelector() {
    final grouped = TemplateService.groupByCategory(_availableTemplates);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir un modèle'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...entry.value.map((template) {
                      return ListTile(
                        title: Text(template.name),
                        subtitle: Text(
                          '${template.itemsCount} articles • ${template.estimatedPriceRange}€',
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          _applyTemplate(template);
                        },
                      );
                    }),
                    const Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveQuote() async {
    if (!_formKey.currentState!.validate() || _selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs requis et sélectionner un client.')),
      );
      return;
    }

    setState(() { _isSaving = true; });

    try {
      final quote = Quote(
        id: _quote?.id,
        quoteNumber: _quote?.quoteNumber ?? 'DRAFT', // Auto-generated by database trigger
        clientId: _selectedClient!.id!,
        date: _date,
        expiryDate: _expiryDate,
        items: _lineItems,
        totalHt: _totalHT,
        totalTva: _totalTVA,
        totalTtc: _totalTTC,
        notes: _notesController.text,
        status: 'draft',
      );

      if (_isEditing) {
        await SupabaseService.updateQuote(quote.id!, quote);
      } else {
        final newQuoteId = await SupabaseService.createQuote(quote);
        // Associate line items with the new quote
        await SupabaseService.createLineItems(newQuoteId, _lineItems);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Devis enregistré avec succès!')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'enregistrement: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }

  Future<void> _convertToInvoice() async {
    if (_quote == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convertir en facture'),
        content: const Text('Voulez-vous convertir ce devis en facture ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Convertir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      // Navigate to invoice form with quote data pre-filled
      Navigator.of(context).pushNamed(
        '/invoice/new',
        arguments: {'quoteId': _quote!.id},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _previewPdf() async {
    if (_quote == null || _selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sauvegarder le devis avant de prévisualiser')),
      );
      return;
    }

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 16),
              Text('Génération du PDF en cours...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      // Load company profile data
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      String? companyName;
      String? companyAddress;

      if (userId != null) {
        try {
          final profileResponse = await supabase
              .from('profiles')
              .select('company_name, address, postal_code, city')
              .eq('id', userId)
              .maybeSingle();

          if (profileResponse != null) {
            companyName = profileResponse['company_name'] as String?;
            final address = profileResponse['address'] as String?;
            final postalCode = profileResponse['postal_code'] as String?;
            final city = profileResponse['city'] as String?;

            if (address != null && postalCode != null && city != null) {
              companyAddress = '$address\n$postalCode $city';
            }
          }
        } catch (e) {
          // Continue with default values if profile loading fails
          debugPrint('Error loading company profile: $e');
        }
      }

      // Prepare line items for PDF
      final lineItemsForPdf = _lineItems.map((item) => {
        'description': item.description,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
      }).toList();

      // Generate PDF
      final pdfBytes = await PdfGenerator.generateQuotePdf(
        quoteNumber: _quote!.quoteNumber,
        clientName: _selectedClient!.name,
        totalTtc: _totalTTC,
        companyName: companyName,
        companyAddress: companyAddress,
        lineItems: lineItemsForPdf,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        subtotalHt: _totalHT,
        totalVat: _totalTVA,
      );

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName = 'devis_${_quote!.quoteNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      // Open the PDF with system default viewer
      final result = await OpenFilex.open(file.path);

      if (mounted) {
        if (result.type == ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF ouvert avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (result.type == ResultType.noAppToOpen) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aucune application pour ouvrir le PDF.\nFichier sauvegardé: ${file.path}'),
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${result.message}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération du PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Éditer Devis' : 'Nouveau Devis'),
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
          else ...[
            if (_isEditing)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Plus d\'actions',
                onSelected: (value) {
                  switch (value) {
                    case 'convert':
                      _convertToInvoice();
                      break;
                    case 'preview':
                      _previewPdf();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'convert',
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long, size: 20),
                        SizedBox(width: 8),
                        Text('Convertir en facture'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'preview',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, size: 20),
                        SizedBox(width: 8),
                        Text('Aperçu PDF'),
                      ],
                    ),
                  ),
                ],
              ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveQuote,
              tooltip: 'Enregistrer',
            ),
          ],
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

                  // Section 2: Dates
                  const SectionHeader(title: 'Dates'),
                  _buildDatePickers(),
                  const SizedBox(height: 16),

                  // Section 3: Template
                  const SectionHeader(title: 'Modèle'),
                  _buildTemplateSelector(),
                  const SizedBox(height: 16),

                  // Section 4: Line Items
                  const SectionHeader(title: 'Lignes'),
                  _buildLineItemsEditor(),
                  const SizedBox(height: 16),

                  // Section 5: Calculations
                  const SectionHeader(title: 'Calculs'),
                  _buildTotalsCard(),
                  const SizedBox(height: 16),

                  // Section 6: Options
                  const SectionHeader(title: 'Options'),
                  _buildOptions(),
                  const SizedBox(height: 16),

                  // Section 7: Actions
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildClientSelector() {
    return Autocomplete<Client>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Client>.empty();
        }
        return _clients.where((Client client) {
          return client.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (Client option) => option.name,
      fieldViewBuilder: (BuildContext context, TextEditingController controller, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Rechercher un client',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.search),
          ),
          validator: (value) => _selectedClient == null ? 'Veuillez sélectionner un client valide' : null,
        );
      },
      onSelected: (Client selection) {
        setState(() {
          _selectedClient = selection;
          _clientController.text = selection.name;
        });
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Client> onSelected, Iterable<Client> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200.0,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final Client option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.name),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) setState(() => _date = date);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date du devis', border: OutlineInputBorder()),
              child: Text(InvoiceCalculator.formatDate(_date)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _expiryDate,
                firstDate: _date,
                lastDate: _date.add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _expiryDate = date);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Valide jusqu\'au', border: OutlineInputBorder()),
              child: Text(InvoiceCalculator.formatDate(_expiryDate)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateSelector() {
    return Card(
      child: InkWell(
        onTap: _showTemplateSelector,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedTemplate != null
                          ? _selectedTemplate!.name
                          : 'Aucun modèle sélectionné',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_selectedTemplate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '${_selectedTemplate!.itemsCount} articles • ${_selectedTemplate!.estimatedPriceRange}€',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (_selectedTemplate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedTemplate = null;
                          _lineItems.clear();
                          _notesController.clear();
                          _calculateTotals();
                        });
                      },
                      tooltip: 'Effacer le modèle',
                    ),
                  Icon(
                    Icons.description_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineItemsEditor() {
    return Column(
      children: [
        if (_lineItems.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _lineItems.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = _lineItems.removeAt(oldIndex);
                _lineItems.insert(newIndex, item);
              });
            },
            itemBuilder: (context, idx) {
              final item = _lineItems[idx];
              return _LineItemEditor(
                key: ValueKey('${item.description}_$idx'),
                item: item,
                onUpdate: (updated) => _updateLineItem(idx, updated),
                onRemove: () => _removeLineItem(idx),
                products: _products,
              );
            },
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Ajouter une ligne'),
          onPressed: _addLineItem,
        ),
      ],
    );
  }

  Widget _buildTotalsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTotalRow('Total HT', InvoiceCalculator.formatCurrency(_totalHT)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TVA', style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
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
                    const SizedBox(width: 16),
                    Text(InvoiceCalculator.formatCurrency(_totalTVA), style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ],
            ),
            const Divider(),
            _buildTotalRow('Total TTC', InvoiceCalculator.formatCurrency(_totalTTC), isBold: true),
            const Divider(),
            _buildTotalRow('Acompte (20%)', InvoiceCalculator.formatCurrency(InvoiceCalculator.calculateDeposit(total: _totalTTC, depositPercent: 20))),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount, {bool isBold = false}) {
    final style = isBold ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) : Theme.of(context).textTheme.titleMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(amount, style: style)],
      ),
    );
  }

  Widget _buildOptions() {
    return Column(
      children: [
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Nécessite une signature'),
          value: _requiresSignature,
          onChanged: (value) => setState(() => _requiresSignature = value!),
        ),
        CheckboxListTile(
          title: const Text('Envoyer après création'),
          value: _sendAfterCreation,
          onChanged: (value) => setState(() => _sendAfterCreation = value!),
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
              onPressed: _saveQuote,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ],
    );
  }
}

// A dedicated widget to manage the state of a single line item
class _LineItemEditor extends StatefulWidget {
  final LineItem item;
  final ValueChanged<LineItem> onUpdate;
  final VoidCallback onRemove;
  final List<Product> products;

  const _LineItemEditor({super.key, required this.item, required this.onUpdate, required this.onRemove, required this.products});

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
