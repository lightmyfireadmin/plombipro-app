import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/line_item.dart';
import '../../services/supabase_service.dart';
import '../../services/invoice_calculator.dart';
import '../../widgets/section_header.dart';

class ScanReviewPage extends StatefulWidget {
  final String scanId;

  const ScanReviewPage({super.key, required this.scanId});

  @override
  State<ScanReviewPage> createState() => _ScanReviewPageState();
}

class _ScanReviewPageState extends State<ScanReviewPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  // Scan data
  Map<String, dynamic>? _scanData;
  String? _imageUrl;

  // Extracted data controllers
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _invoiceNumberController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  final TextEditingController _siretController = TextEditingController();
  final TextEditingController _vatNumberController = TextEditingController();
  final TextEditingController _subtotalHtController = TextEditingController();
  final TextEditingController _vatAmountController = TextEditingController();
  final TextEditingController _totalTtcController = TextEditingController();

  List<LineItem> _lineItems = [];
  Map<String, double>? _confidenceScores;

  @override
  void initState() {
    super.initState();
    _loadScanData();
  }

  @override
  void dispose() {
    _supplierNameController.dispose();
    _invoiceNumberController.dispose();
    _invoiceDateController.dispose();
    _siretController.dispose();
    _vatNumberController.dispose();
    _subtotalHtController.dispose();
    _vatAmountController.dispose();
    _totalTtcController.dispose();
    super.dispose();
  }

  Future<void> _loadScanData() async {
    try {
      final response = await Supabase.instance.client
          .from('scans')
          .select()
          .eq('id', widget.scanId)
          .single();

      setState(() {
        _scanData = response;
        _imageUrl = response['original_image_url'];
        final extractedData = response['extracted_data'] as Map<String, dynamic>?;

        if (extractedData != null) {
          _supplierNameController.text = extractedData['supplier_name'] ?? '';
          _invoiceNumberController.text = extractedData['invoice_number'] ?? '';
          _invoiceDateController.text = extractedData['invoice_date'] ?? '';
          _siretController.text = extractedData['supplier_siret'] ?? '';
          _vatNumberController.text = extractedData['supplier_vat_number'] ?? '';
          _subtotalHtController.text = (extractedData['subtotal_ht'] ?? 0).toString();
          _vatAmountController.text = (extractedData['vat_amount'] ?? 0).toString();
          _totalTtcController.text = (extractedData['total_ttc'] ?? 0).toString();

          // Parse line items
          if (extractedData['line_items'] != null) {
            final items = extractedData['line_items'] as List;
            _lineItems = items.map((item) {
              return LineItem(
                description: item['description'] ?? '',
                quantity: (item['quantity'] ?? 0).toDouble(),
                unitPrice: (item['unit_price'] ?? 0).toDouble(),
                vatRate: (item['vat_rate'] ?? 20.0).toDouble(),
              );
            }).toList();
          }

          // Confidence scores
          _confidenceScores = (extractedData['confidence_scores'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, (value as num).toDouble()));
        }

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: ${e.toString()}')),
        );
      }
    }
  }

  Color _getConfidenceColor(double? confidence) {
    if (confidence == null) return Colors.grey;
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildConfidenceBadge(String label, double? confidence) {
    return Chip(
      label: Text('$label: ${((confidence ?? 0) * 100).toStringAsFixed(0)}%'),
      backgroundColor: _getConfidenceColor(confidence).withOpacity(0.2),
      labelStyle: TextStyle(
        color: _getConfidenceColor(confidence),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> _createPurchase() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez corriger les erreurs')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Create purchase from scan data
      await Supabase.instance.client.from('purchases').insert({
        'user_id': userId,
        'supplier_name': _supplierNameController.text,
        'invoice_number': _invoiceNumberController.text,
        'invoice_date': _invoiceDateController.text,
        'subtotal_ht': double.tryParse(_subtotalHtController.text) ?? 0,
        'total_vat': double.tryParse(_vatAmountController.text) ?? 0,
        'total_ttc': double.tryParse(_totalTtcController.text) ?? 0,
        'payment_status': 'unpaid',
        'scan_id': widget.scanId,
        'invoice_image_url': _imageUrl,
        'line_items': _lineItems.map((item) => {
          'description': item.description,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'vat_rate': item.vatRate,
        }).toList(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Mark scan as reviewed and converted
      await Supabase.instance.client.from('scans').update({
        'reviewed': true,
        'converted_to_purchase': true,
      }).eq('id', widget.scanId);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Achat créé avec succès!')),
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
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _generateQuote() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez corriger les erreurs')),
      );
      return;
    }

    // Show margin input dialog
    final marginPercent = await showDialog<double>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: '30');
        return AlertDialog(
          title: const Text('Marge commerciale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Appliquer une marge sur les prix d\'achat:'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Marge (%)',
                  suffixText: '%',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(double.tryParse(controller.text) ?? 30);
              },
              child: const Text('Générer'),
            ),
          ],
        );
      },
    );

    if (marginPercent == null || !mounted) return;

    setState(() => _isSaving = true);

    try {
      // Apply margin to line items
      final quotedLineItems = _lineItems.map((item) {
        final costPrice = item.unitPrice;
        final sellingPrice = costPrice * (1 + marginPercent / 100);
        return item.copyWith(unitPrice: sellingPrice);
      }).toList();

      // Navigate to quote form with pre-filled data
      Navigator.of(context).pushNamed(
        '/quote/new',
        arguments: {
          'line_items': quotedLineItems,
          'source': 'scan',
          'scan_id': widget.scanId,
        },
      );

      // Mark scan as reviewed
      await Supabase.instance.client.from('scans').update({
        'reviewed': true,
      }).eq('id', widget.scanId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _addItemsToCatalog() async {
    // Show dialog to select which items to add
    final selectedItems = await showDialog<List<int>>(
      context: context,
      builder: (context) => _ItemSelectionDialog(lineItems: _lineItems),
    );

    if (selectedItems == null || selectedItems.isEmpty || !mounted) return;

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Add selected items to products catalog
      for (final index in selectedItems) {
        final item = _lineItems[index];
        await Supabase.instance.client.from('products').insert({
          'user_id': userId,
          'name': item.description,
          'purchase_price_ht': item.unitPrice,
          'selling_price_ht': item.unitPrice * 1.3, // Default 30% margin
          'margin_percentage': 30.0,
          'vat_rate': item.vatRate,
          'unit': 'unit',
          'is_active': true,
          'source': 'scan',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedItems.length} produit(s) ajouté(s) au catalogue!')),
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
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réviser le scan'),
        actions: [
          if (!_isLoading && !_isSaving)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'purchase':
                    _createPurchase();
                    break;
                  case 'quote':
                    _generateQuote();
                    break;
                  case 'catalog':
                    _addItemsToCatalog();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'purchase',
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, size: 20),
                      SizedBox(width: 8),
                      Text('Créer un achat'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'quote',
                  child: Row(
                    children: [
                      Icon(Icons.request_quote, size: 20),
                      SizedBox(width: 8),
                      Text('Générer un devis'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'catalog',
                  child: Row(
                    children: [
                      Icon(Icons.add_shopping_cart, size: 20),
                      SizedBox(width: 8),
                      Text('Ajouter au catalogue'),
                    ],
                  ),
                ),
              ],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Confidence scores overview
                    if (_confidenceScores != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Scores de confiance',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildConfidenceBadge('Global', _confidenceScores!['overall']),
                                  _buildConfidenceBadge('N° Facture', _confidenceScores!['invoice_number']),
                                  _buildConfidenceBadge('Date', _confidenceScores!['invoice_date']),
                                  _buildConfidenceBadge('Fournisseur', _confidenceScores!['supplier_info']),
                                  _buildConfidenceBadge('Total', _confidenceScores!['total_amount']),
                                  _buildConfidenceBadge('Lignes', _confidenceScores!['line_items']),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Vérifiez et corrigez les données ci-dessous si nécessaire.',
                                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Image preview
                    if (_imageUrl != null)
                      Card(
                        child: Column(
                          children: [
                            Image.network(_imageUrl!, height: 200, fit: BoxFit.contain),
                            TextButton.icon(
                              icon: const Icon(Icons.fullscreen),
                              label: const Text('Voir en grand'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: InteractiveViewer(
                                      child: Image.network(_imageUrl!),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Supplier information
                    const SectionHeader(title: 'Fournisseur'),
                    TextFormField(
                      controller: _supplierNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du fournisseur',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _siretController,
                            decoration: const InputDecoration(
                              labelText: 'SIRET',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _vatNumberController,
                            decoration: const InputDecoration(
                              labelText: 'N° TVA',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Invoice details
                    const SectionHeader(title: 'Facture'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _invoiceNumberController,
                            decoration: const InputDecoration(
                              labelText: 'N° Facture',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _invoiceDateController,
                            decoration: const InputDecoration(
                              labelText: 'Date (YYYY-MM-DD)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Line items
                    const SectionHeader(title: 'Articles'),
                    ..._lineItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(item.description),
                          subtitle: Text('Qté: ${item.quantity} × ${InvoiceCalculator.formatCurrency(item.unitPrice)}'),
                          trailing: Text(
                            InvoiceCalculator.formatCurrency(item.lineTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Totals
                    const SectionHeader(title: 'Totaux'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _subtotalHtController,
                            decoration: const InputDecoration(
                              labelText: 'Total HT',
                              suffixText: '€',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _vatAmountController,
                            decoration: const InputDecoration(
                              labelText: 'TVA',
                              suffixText: '€',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _totalTtcController,
                            decoration: const InputDecoration(
                              labelText: 'Total TTC',
                              suffixText: '€',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _createPurchase,
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Créer Achat'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _generateQuote,
                            icon: const Icon(Icons.request_quote),
                            label: const Text('Générer Devis'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
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

class _ItemSelectionDialog extends StatefulWidget {
  final List<LineItem> lineItems;

  const _ItemSelectionDialog({required this.lineItems});

  @override
  State<_ItemSelectionDialog> createState() => _ItemSelectionDialogState();
}

class _ItemSelectionDialogState extends State<_ItemSelectionDialog> {
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    // Select all by default
    _selectedIndices.addAll(List.generate(widget.lineItems.length, (i) => i));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sélectionner les articles'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.lineItems.length,
          itemBuilder: (context, index) {
            final item = widget.lineItems[index];
            return CheckboxListTile(
              title: Text(item.description),
              subtitle: Text('${InvoiceCalculator.formatCurrency(item.unitPrice)} × ${item.quantity}'),
              value: _selectedIndices.contains(index),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedIndices.add(index);
                  } else {
                    _selectedIndices.remove(index);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedIndices.toList()),
          child: Text('Ajouter (${_selectedIndices.length})'),
        ),
      ],
    );
  }
}
