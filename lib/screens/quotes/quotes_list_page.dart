import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Added
import 'package:path_provider/path_provider.dart'; // Added
import 'package:open_filex/open_filex.dart'; // Added
import 'dart:io'; // Added

import '../../models/quote.dart';
import '../../models/invoice.dart'; // Added
import '../../services/invoice_calculator.dart';
import '../../services/supabase_service.dart';
import '../../services/pdf_generator.dart'; // Added
import '../../services/error_handler.dart';
import '../../widgets/custom_app_bar.dart';
// For _InvoiceCard

class QuotesListPage extends StatefulWidget {
  const QuotesListPage({super.key});

  @override
  State<QuotesListPage> createState() => _QuotesListPageState();
}

class _QuotesListPageState extends State<QuotesListPage> {
  List<Quote> _quotes = [];
  List<Quote> _filteredQuotes = [];
  bool _isLoading = true;
  String _selectedStatus = 'Tous';
  final TextEditingController _searchController = TextEditingController();

  // Batch selection
  bool _isSelectionMode = false;
  final Set<String> _selectedQuoteIds = {};

  // Sort options
  String _sortBy = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc, client_asc

  final List<String> _statuses = ['Tous', 'Brouillon', 'Envoyé', 'Accepté', 'Rejeté', 'Facturé'];

  @override
  void initState() {
    super.initState();
    _fetchQuotes();
    _searchController.addListener(_filterQuotes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterQuotes);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuotes() async {
    try {
      final quotes = await SupabaseService.fetchQuotes();
      if (mounted) {
        setState(() {
          _quotes = quotes;
          _filterQuotes();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.handleError(
          e,
          customMessage: "Erreur de chargement des devis",
          onRetry: _fetchQuotes,
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterQuotes() {
    List<Quote> filtered = List.from(_quotes);

    // Filter by status
    if (_selectedStatus != 'Tous') {
      filtered = filtered.where((q) => q.status.toLowerCase() == _selectedStatus.toLowerCase()).toList();
    }

    // Filter by search term
    final searchTerm = _searchController.text.toLowerCase();
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((q) {
        final clientName = q.client?.name.toLowerCase() ?? '';
        final quoteNumber = q.quoteNumber.toLowerCase();
        return clientName.contains(searchTerm) || quoteNumber.contains(searchTerm);
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'date_desc':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'date_asc':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_desc':
        filtered.sort((a, b) => b.totalTtc.compareTo(a.totalTtc));
        break;
      case 'amount_asc':
        filtered.sort((a, b) => a.totalTtc.compareTo(b.totalTtc));
        break;
      case 'client_asc':
        filtered.sort((a, b) => (a.client?.name ?? '').compareTo(b.client?.name ?? ''));
        break;
    }

    setState(() {
      _filteredQuotes = filtered;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedQuoteIds.clear();
      }
    });
  }

  void _toggleQuoteSelection(String quoteId) {
    setState(() {
      if (_selectedQuoteIds.contains(quoteId)) {
        _selectedQuoteIds.remove(quoteId);
      } else {
        _selectedQuoteIds.add(quoteId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedQuoteIds.length == _filteredQuotes.length) {
        _selectedQuoteIds.clear();
      } else {
        _selectedQuoteIds.clear();
        for (var quote in _filteredQuotes) {
          if (quote.id != null) _selectedQuoteIds.add(quote.id!);
        }
      }
    });
  }

  Future<void> _batchDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${_selectedQuoteIds.length} devis ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      for (var quoteId in _selectedQuoteIds) {
        await SupabaseService.deleteQuote(quoteId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedQuoteIds.length} devis supprimés avec succès')),
        );
        _toggleSelectionMode();
        _fetchQuotes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _batchExportPdf() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export de ${_selectedQuoteIds.length} devis en cours...')),
      );

      for (var quoteId in _selectedQuoteIds) {
        final quote = _filteredQuotes.firstWhere((q) => q.id == quoteId);
        final pdfBytes = await PdfGenerator.generateQuotePdf(
          quoteNumber: quote.quoteNumber,
          clientName: quote.client?.name ?? 'Client inconnu',
          totalTtc: quote.totalTtc,
        );

        final output = await getTemporaryDirectory();
        final file = File("${output.path}/${quote.quoteNumber}.pdf");
        await file.writeAsBytes(pdfBytes);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedQuoteIds.length} PDF générés avec succès')),
        );
        _toggleSelectionMode();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  void _onStatusSelected(String status) {
    setState(() {
      _selectedStatus = status;
      _filterQuotes();
    });
  }

  // Removed _navigateAndRefresh as go_router handles navigation directly

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedQuoteIds.length} sélectionné(s)')
            : const Text('Mes Devis'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSelectionMode,
              )
            : null,
        actions: _isSelectionMode && !isSmallScreen
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: _selectAll,
                  tooltip: 'Tout sélectionner',
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: _selectedQuoteIds.isEmpty ? null : _batchExportPdf,
                  tooltip: 'Exporter en PDF',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _selectedQuoteIds.isEmpty ? null : _batchDelete,
                  tooltip: 'Supprimer',
                ),
              ]
            : _isSelectionMode && isSmallScreen
            ? [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: _showBatchActionsSheet,
                  tooltip: 'Actions',
                ),
              ]
            : [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (value) {
                    setState(() {
                      _sortBy = value;
                      _filterQuotes();
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'date_desc', child: Text('Date (plus récent)')),
                    const PopupMenuItem(value: 'date_asc', child: Text('Date (plus ancien)')),
                    const PopupMenuItem(value: 'amount_desc', child: Text('Montant (décroissant)')),
                    const PopupMenuItem(value: 'amount_asc', child: Text('Montant (croissant)')),
                    const PopupMenuItem(value: 'client_asc', child: Text('Client (A-Z)')),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.checklist),
                  onPressed: _toggleSelectionMode,
                  tooltip: 'Mode sélection',
                ),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterBar(),
                const Divider(height: 1),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchQuotes,
                    child: _filteredQuotes.isEmpty
                        ? const Center(child: Text('Aucun devis trouvé.'))
                        : ListView.builder(
                            padding: EdgeInsets.all(isSmallScreen ? 4.0 : 8.0),
                            itemCount: _filteredQuotes.length,
                            itemBuilder: (context, index) {
                              final quote = _filteredQuotes[index];
                              return QuoteCard(
                                quote: quote,
                                onActionSelected: _fetchQuotes,
                                isSelectionMode: _isSelectionMode,
                                isSelected: _selectedQuoteIds.contains(quote.id),
                                onSelectionToggle: () => _toggleQuoteSelection(quote.id!),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _isSelectionMode ? null : FloatingActionButton(
        onPressed: () => context.push('/quotes/new'),
        tooltip: 'Nouveau devis',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBatchActionsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.select_all),
              title: const Text('Tout sélectionner'),
              onTap: () {
                Navigator.pop(context);
                _selectAll();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Exporter en PDF'),
              enabled: _selectedQuoteIds.isNotEmpty,
              onTap: _selectedQuoteIds.isEmpty ? null : () {
                Navigator.pop(context);
                _batchExportPdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              enabled: _selectedQuoteIds.isNotEmpty,
              onTap: _selectedQuoteIds.isEmpty ? null : () {
                Navigator.pop(context);
                _batchDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Rechercher par client ou n° de devis',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView( 
              scrollDirection: Axis.horizontal,
              children: _statuses.map((status) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: _selectedStatus == status,
                    onSelected: (isSelected) {
                      if (isSelected) _onStatusSelected(status);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// The QuoteCard widget as described in the layout guide
class QuoteCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback onActionSelected;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.onActionSelected,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionToggle,
  });

  void _handleMenuSelection(String value, BuildContext context) async {
    switch (value) {
      case 'edit':
        final result = await context.push('/quotes/${quote.id}', extra: quote);
        if (result == true) onActionSelected();
        break;
      case 'create_invoice':
        try {
          // Generate a simple invoice number (e.g., FAC-YYYY-001)
          final now = DateTime.now();
          final invoiceNumber = InvoiceCalculator.generateInvoiceNumber(1);

          final newInvoice = Invoice(
            number: invoiceNumber,
            clientId: quote.clientId,
            date: now,
            dueDate: now.add(const Duration(days: 30)), // Default due date 30 days
            totalHt: quote.totalHt,
            totalTva: quote.totalTva,
            totalTtc: quote.totalTtc,
            notes: quote.notes,
            client: quote.client,
            items: quote.items, // Copy line items from quote
          );

          final newInvoiceId = await SupabaseService.createInvoice(newInvoice);
          await SupabaseService.createInvoiceLineItems(newInvoiceId, newInvoice.items);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Facture créée avec succès!')),
            );
            context.go('/invoices'); // Navigate to InvoicesListPage
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erreur lors de la création de la facture: ${e.toString()}")),
            );
          }
        }
        break;
      case 'download':
        try {
          final pdfBytes = await PdfGenerator.generateQuotePdf(
            quoteNumber: quote.quoteNumber,
            clientName: quote.client?.name ?? 'Client inconnu',
            totalTtc: quote.totalTtc,
          );

          final output = await getTemporaryDirectory();
          final file = File("${output.path}/${quote.quoteNumber}.pdf");
          await file.writeAsBytes(pdfBytes);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF généré et enregistré dans ${file.path}')),
            );
            OpenFilex.open(file.path);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erreur lors de la génération du PDF: ${e.toString()}")),
            );
          }
        }
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text('Voulez-vous vraiment supprimer ce devis ?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
            ],
          ),
        );
        if (confirm == true) {
          try {
            await SupabaseService.deleteQuote(quote.id!);
            onActionSelected();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}")));
          }
        }
        break;
      // Add other cases for 'view', 'send'
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      color: isSelectionMode && isSelected ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: isSelectionMode ? onSelectionToggle : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isSelectionMode)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (_) => onSelectionToggle?.call(),
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: isSelectionMode ? 8.0 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${quote.quoteNumber} - ${quote.status.toUpperCase()}',
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(quote.client?.name ?? 'Client non trouvé',
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isSelectionMode)
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuSelection(value, context),
                      padding: const EdgeInsets.all(8.0),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(value: 'view', child: Text('Voir')),
                        const PopupMenuItem<String>(value: 'edit', child: Text('Éditer')),
                        const PopupMenuItem<String>(value: 'create_invoice', child: Text('Créer une facture')),
                        const PopupMenuItem<String>(value: 'send', child: Text('Envoyer par email')),
                        const PopupMenuItem<String>(value: 'download', child: Text('Télécharger PDF')),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(value: 'delete', child: Text('Supprimer', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(InvoiceCalculator.formatCurrency(quote.totalTtc),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(InvoiceCalculator.formatDate(quote.date),
                    style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
