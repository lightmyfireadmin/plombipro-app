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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des devis: ${e.toString()}")),
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

    setState(() {
      _filteredQuotes = filtered;
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Devis'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}), // Search is handled by the text field below
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}), // Filter is handled by chips
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
                            padding: const EdgeInsets.all(8.0),
                            itemCount: _filteredQuotes.length,
                            itemBuilder: (context, index) {
                              final quote = _filteredQuotes[index];
                              return QuoteCard(quote: quote, onActionSelected: _fetchQuotes);
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/quotes/new'), // Use go_router
        tooltip: 'Nouveau devis',
        child: const Icon(Icons.add),
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

  const QuoteCard({super.key, required this.quote, required this.onActionSelected});

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
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${quote.quoteNumber} - ${quote.status.toUpperCase()}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(quote.client?.name ?? 'Client non trouvé', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuSelection(value, context),
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
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(InvoiceCalculator.formatCurrency(quote.totalTtc), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(InvoiceCalculator.formatDate(quote.date), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
