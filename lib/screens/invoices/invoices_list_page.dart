import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';

import '../../models/invoice.dart';
import '../../services/invoice_calculator.dart';
import '../../services/supabase_service.dart';
import '../../services/pdf_generator.dart';

class InvoicesListPage extends StatefulWidget {
  const InvoicesListPage({super.key});

  @override
  State<InvoicesListPage> createState() => _InvoicesListPageState();
}

class _InvoicesListPageState extends State<InvoicesListPage> {
  List<Invoice> _invoices = [];
  List<Invoice> _filteredInvoices = [];
  bool _isLoading = true;
  String _selectedStatus = 'Toutes';
  final TextEditingController _searchController = TextEditingController();

  // Batch selection
  bool _isSelectionMode = false;
  final Set<String> _selectedInvoiceIds = {};

  // Sort options
  String _sortBy = 'date_desc';

  final List<String> _statuses = ['Toutes', 'Brouillon', 'Envoyée', 'Payée', 'Payée partiellement', 'En retard', 'Annulée'];

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    _searchController.addListener(_filterInvoices);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterInvoices);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInvoices() async {
    try {
      final invoices = await SupabaseService.fetchInvoices();
      if (mounted) {
        setState(() {
          _invoices = invoices;
          _filterInvoices();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des factures: ${e.toString()}")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterInvoices() {
    List<Invoice> filtered = List.from(_invoices);

    // Filter by payment status
    if (_selectedStatus != 'Toutes') {
      filtered = filtered.where((inv) {
        final status = inv.paymentStatus.toLowerCase();
        final selected = _selectedStatus.toLowerCase();

        if (selected == 'brouillon') return status == 'draft' || status == 'brouillon';
        if (selected == 'envoyée') return status == 'sent' || status == 'envoyée';
        if (selected == 'payée') return status == 'paid' || status == 'payée';
        if (selected == 'payée partiellement') return status == 'partial' || status.contains('partiel');
        if (selected == 'en retard') return status == 'overdue' || status.contains('retard');
        if (selected == 'annulée') return status == 'cancelled' || status.contains('annul');

        return false;
      }).toList();
    }

    // Filter by search term
    final searchTerm = _searchController.text.toLowerCase();
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((inv) {
        final clientName = inv.client?.name.toLowerCase() ?? '';
        final invoiceNumber = inv.number.toLowerCase();
        return clientName.contains(searchTerm) || invoiceNumber.contains(searchTerm);
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
      case 'due_date_asc':
        filtered.sort((a, b) => (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now()));
        break;
    }

    setState(() {
      _filteredInvoices = filtered;
    });
  }

  void _onStatusSelected(String status) {
    setState(() {
      _selectedStatus = status;
      _filterInvoices();
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedInvoiceIds.clear();
      }
    });
  }

  void _toggleInvoiceSelection(String invoiceId) {
    setState(() {
      if (_selectedInvoiceIds.contains(invoiceId)) {
        _selectedInvoiceIds.remove(invoiceId);
      } else {
        _selectedInvoiceIds.add(invoiceId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedInvoiceIds.length == _filteredInvoices.length) {
        _selectedInvoiceIds.clear();
      } else {
        _selectedInvoiceIds.clear();
        for (var invoice in _filteredInvoices) {
          if (invoice.id != null) _selectedInvoiceIds.add(invoice.id!);
        }
      }
    });
  }

  Future<void> _batchDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${_selectedInvoiceIds.length} factures ?'),
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
      for (var invoiceId in _selectedInvoiceIds) {
        await SupabaseService.deleteInvoice(invoiceId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedInvoiceIds.length} factures supprimées avec succès')),
        );
        _toggleSelectionMode();
        _fetchInvoices();
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
        SnackBar(content: Text('Export de ${_selectedInvoiceIds.length} factures en cours...')),
      );

      for (var invoiceId in _selectedInvoiceIds) {
        final invoice = _filteredInvoices.firstWhere((inv) => inv.id == invoiceId);
        final pdfBytes = await PdfGenerator.generateInvoicePdf(
          invoiceNumber: invoice.number,
          clientName: invoice.client?.name ?? 'Client inconnu',
          totalTtc: invoice.totalTtc,
        );

        final output = await getTemporaryDirectory();
        final file = File("${output.path}/${invoice.number}.pdf");
        await file.writeAsBytes(pdfBytes);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedInvoiceIds.length} PDF générés avec succès')),
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

  Future<void> _batchMarkAsPaid() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marquer comme payées'),
        content: Text('Voulez-vous marquer ${_selectedInvoiceIds.length} factures comme payées ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirmer')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      for (var invoiceId in _selectedInvoiceIds) {
        final invoice = _filteredInvoices.firstWhere((inv) => inv.id == invoiceId);
        await SupabaseService.updateInvoice(
          invoiceId,
          invoice.copyWith(paymentStatus: 'paid'),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedInvoiceIds.length} factures marquées comme payées')),
        );
        _toggleSelectionMode();
        _fetchInvoices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedInvoiceIds.length} sélectionnée(s)')
            : const Text('Mes Factures'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSelectionMode,
              )
            : null,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: _selectAll,
                  tooltip: 'Tout sélectionner',
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle),
                  onPressed: _selectedInvoiceIds.isEmpty ? null : _batchMarkAsPaid,
                  tooltip: 'Marquer comme payées',
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: _selectedInvoiceIds.isEmpty ? null : _batchExportPdf,
                  tooltip: 'Exporter en PDF',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _selectedInvoiceIds.isEmpty ? null : _batchDelete,
                  tooltip: 'Supprimer',
                ),
              ]
            : [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (value) {
                    setState(() {
                      _sortBy = value;
                      _filterInvoices();
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'date_desc', child: Text('Date (plus récent)')),
                    const PopupMenuItem(value: 'date_asc', child: Text('Date (plus ancien)')),
                    const PopupMenuItem(value: 'due_date_asc', child: Text('Échéance (croissant)')),
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
                    onRefresh: _fetchInvoices,
                    child: _filteredInvoices.isEmpty
                        ? const Center(child: Text('Aucune facture trouvée.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: _filteredInvoices.length,
                            itemBuilder: (context, index) {
                              final invoice = _filteredInvoices[index];
                              return InvoiceCard(
                                invoice: invoice,
                                onActionSelected: _fetchInvoices,
                                isSelectionMode: _isSelectionMode,
                                isSelected: _selectedInvoiceIds.contains(invoice.id),
                                onSelectionToggle: () => _toggleInvoiceSelection(invoice.id!),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/invoices/new'),
        tooltip: 'Nouvelle facture',
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
              labelText: 'Rechercher par client ou n° de facture',
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

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onActionSelected;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onActionSelected,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionToggle,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'payée':
        return Colors.green;
      case 'partial':
      case 'payée partiellement':
        return Colors.orange;
      case 'overdue':
      case 'en retard':
        return Colors.red;
      case 'cancelled':
      case 'annulée':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _handleMenuSelection(String value, BuildContext context) async {
    switch (value) {
      case 'edit':
        final result = await context.push('/invoices/${invoice.id}', extra: invoice);
        if (result == true) onActionSelected();
        break;
      case 'mark_paid':
        try {
          await SupabaseService.updateInvoice(invoice.id!, invoice.copyWith(paymentStatus: 'paid'));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Facture marquée comme payée')),
            );
            onActionSelected();
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur: ${e.toString()}')),
            );
          }
        }
        break;
      case 'download':
        try {
          final pdfBytes = await PdfGenerator.generateInvoicePdf(
            invoiceNumber: invoice.number,
            clientName: invoice.client?.name ?? 'Client inconnu',
            totalTtc: invoice.totalTtc,
          );

          final output = await getTemporaryDirectory();
          final file = File("${output.path}/${invoice.number}.pdf");
          await file.writeAsBytes(pdfBytes);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF généré: ${file.path}')),
            );
            OpenFilex.open(file.path);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur PDF: ${e.toString()}')),
            );
          }
        }
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text('Voulez-vous vraiment supprimer cette facture ?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
            ],
          ),
        );
        if (confirm == true) {
          try {
            await SupabaseService.deleteInvoice(invoice.id!);
            onActionSelected();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}")));
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(invoice.paymentStatus);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      color: isSelectionMode && isSelected ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: isSelectionMode ? onSelectionToggle : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isSelectionMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onSelectionToggle?.call(),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(invoice.number, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                invoice.paymentStatus.toUpperCase(),
                                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(invoice.client?.name ?? 'Client non trouvé', style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                  if (!isSelectionMode)
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuSelection(value, context),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(value: 'view', child: Text('Voir')),
                        const PopupMenuItem<String>(value: 'edit', child: Text('Éditer')),
                        if (invoice.paymentStatus.toLowerCase() != 'paid' && invoice.paymentStatus.toLowerCase() != 'payée')
                          const PopupMenuItem<String>(value: 'mark_paid', child: Text('Marquer comme payée')),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(InvoiceCalculator.formatCurrency(invoice.totalTtc),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      if (invoice.dueDate != null)
                        Text('Échéance: ${InvoiceCalculator.formatDate(invoice.dueDate!)}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Text(InvoiceCalculator.formatDate(invoice.date),
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
