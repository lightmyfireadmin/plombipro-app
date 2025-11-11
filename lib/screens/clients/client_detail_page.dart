import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../models/quote.dart';
import '../../models/invoice.dart';
import '../../services/supabase_service.dart';
import '../../services/invoice_calculator.dart';
import '../quotes/quotes_list_page.dart'; // For _QuoteCard
import '../invoices/invoices_list_page.dart'; // For _InvoiceCard

class ClientDetailPage extends StatefulWidget {
  final Client client;

  const ClientDetailPage({super.key, required this.client});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Quote> _clientQuotes = [];
  List<Invoice> _clientInvoices = [];
  bool _isLoadingQuotes = true;
  bool _isLoadingInvoices = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchClientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientData() async {
    await Future.wait([
      _fetchClientQuotes(),
      _fetchClientInvoices(),
    ]);
  }

  Future<void> _fetchClientQuotes() async {
    if (!mounted) return;
    setState(() { _isLoadingQuotes = true; });
    try {
      final quotes = await SupabaseService.fetchQuotesByClient(widget.client.id!);
      if (mounted) {
        setState(() {
          _clientQuotes = quotes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des devis: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoadingQuotes = false; });
      }
    }
  }

  Future<void> _fetchClientInvoices() async {
    if (!mounted) return;
    setState(() { _isLoadingInvoices = true; });
    try {
      final invoices = await SupabaseService.fetchInvoicesByClient(widget.client.id!);
      if (mounted) {
        setState(() {
          _clientInvoices = invoices;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des factures: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoadingInvoices = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
      ),
      body: Column(
        children: [
          _buildClientDetailsCard(),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Devis'),
              Tab(text: 'Factures'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuotesTab(),
                _buildInvoicesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDetailsCard() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.client.name, style: Theme.of(context).textTheme.headlineSmall),
            Text(widget.client.email!, style: Theme.of(context).textTheme.bodyMedium),
            Text(widget.client.phone!, style: Theme.of(context).textTheme.bodyMedium),
            if (widget.client.address != null) Text(widget.client.address!, style: Theme.of(context).textTheme.bodyMedium),
            if (widget.client.city != null) Text(widget.client.city!, style: Theme.of(context).textTheme.bodyMedium),
            // Add more client details as needed
          ],
        ),
      ),
    );
  }

  Widget _buildQuotesTab() {
    if (_isLoadingQuotes) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_clientQuotes.isEmpty) {
      return const Center(child: Text('Aucun devis pour ce client.'));
    }
    return ListView.builder(
      itemCount: _clientQuotes.length,
      itemBuilder: (context, index) {
        final quote = _clientQuotes[index];
        // Reuse _QuoteCard from quotes_list_page.dart
        return QuoteCard(quote: quote, onActionSelected: _fetchClientQuotes);
      },
    );
  }

  Widget _buildInvoicesTab() {
    if (_isLoadingInvoices) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_clientInvoices.isEmpty) {
      return const Center(child: Text('Aucune facture pour ce client.'));
    }
    return ListView.builder(
      itemCount: _clientInvoices.length,
      itemBuilder: (context, index) {
        final invoice = _clientInvoices[index];
        // Reuse _InvoiceCard from invoices_list_page.dart
        return InvoiceCard(invoice: invoice, onActionSelected: _fetchClientInvoices);
      },
    );
  }
}
