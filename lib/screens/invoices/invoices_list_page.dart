import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Added
import '../../models/invoice.dart';
import '../../services/supabase_service.dart';
import '../../services/invoice_calculator.dart';

class InvoicesListPage extends StatefulWidget {
  const InvoicesListPage({super.key});

  @override
  State<InvoicesListPage> createState() => _InvoicesListPageState();
}

class _InvoicesListPageState extends State<InvoicesListPage> {
  List<Invoice> _invoices = [];
  List<Invoice> _filteredInvoices = [];
  bool _isLoading = true;
  String _selectedStatus = 'Tous';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statuses = ['Tous', 'Brouillon', 'Envoyé', 'Payé', 'Annulé'];

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

    // Filter by status
    if (_selectedStatus != 'Tous') {
      filtered = filtered.where((i) => i.paymentStatus.toLowerCase() == _selectedStatus.toLowerCase()).toList();
    }

    // Filter by search term
    final searchTerm = _searchController.text.toLowerCase();
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((i) {
        final clientName = i.client?.name.toLowerCase() ?? '';
        final invoiceNumber = i.number.toLowerCase();
        return clientName.contains(searchTerm) || invoiceNumber.contains(searchTerm);
      }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Factures'),
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
                    onRefresh: _fetchInvoices,
                    child: _filteredInvoices.isEmpty
                        ? const Center(child: Text('Aucune facture trouvée.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: _filteredInvoices.length,
                            itemBuilder: (context, index) {
                              final invoice = _filteredInvoices[index];
                              return InvoiceCard(invoice: invoice, onActionSelected: _fetchInvoices);
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/invoices/new');
          if (result == true && mounted) {
            _fetchInvoices();
          }
        },
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

  const InvoiceCard({super.key, required this.invoice, required this.onActionSelected});

  void _handleMenuSelection(String value, BuildContext context) async {
    switch (value) {
      case 'edit':
        final result = await context.push('/invoices/${invoice.id}', extra: invoice);
        if (result == true) onActionSelected();
        break;
      case 'record_payment':
        final result = await context.push('/payments/new', extra: invoice.id);
        if (result == true) onActionSelected();
        break;
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
                      Text('${invoice.number} - ${invoice.paymentStatus.toUpperCase()}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(invoice.client?.name ?? 'Client non trouvé', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuSelection(value, context),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(value: 'view', child: Text('Voir')),
                    const PopupMenuItem<String>(value: 'edit', child: Text('Éditer')),
                    const PopupMenuItem<String>(value: 'send', child: Text('Envoyer par email')),
                    const PopupMenuItem<String>(value: 'download', child: Text('Télécharger PDF')),
                    const PopupMenuItem<String>(value: 'record_payment', child: Text('Enregistrer un paiement')),
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
                Text(InvoiceCalculator.formatCurrency(invoice.totalTtc), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(InvoiceCalculator.formatDate(invoice.date), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
