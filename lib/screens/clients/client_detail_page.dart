import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/client.dart';
import '../../models/quote.dart';
import '../../models/invoice.dart';
import '../../models/payment.dart';
import '../../services/supabase_service.dart';
import '../../services/error_handler.dart';
import '../../services/invoice_calculator.dart';
import '../../widgets/app_drawer.dart';

/// Beautiful client detail page with summary, operations, and history
/// Implements the design from Phase 3 requirements
class ClientDetailPage extends StatefulWidget {
  final String clientId;

  const ClientDetailPage({
    super.key,
    required this.clientId,
  });

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Client? _client;
  List<Quote> _quotes = [];
  List<Invoice> _invoices = [];
  List<Payment> _payments = [];

  // Statistics
  double _totalRevenue = 0;
  double _unpaidAmount = 0;
  int _activeQuotes = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchClientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientData() async {
    setState(() => _isLoading = true);

    try {
      final client = await SupabaseService.getClientById(widget.clientId);
      final quotes = await SupabaseService.fetchQuotesByClient(widget.clientId);
      final invoices = await SupabaseService.fetchInvoicesByClient(widget.clientId);

      // Calculate statistics
      double totalRev = 0;
      double unpaid = 0;
      int active = 0;

      for (final invoice in invoices) {
        totalRev += invoice.totalTtc;
        if (invoice.paymentStatus != 'paid') {
          unpaid += invoice.balanceDue;
        }
      }

      for (final quote in quotes) {
        if (quote.status == 'sent' || quote.status == 'pending') {
          active++;
        }
      }

      if (mounted) {
        setState(() {
          _client = client;
          _quotes = quotes;
          _invoices = invoices;
          _totalRevenue = totalRev;
          _unpaidAmount = unpaid;
          _activeQuotes = active;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.handleError(e, customMessage: 'Erreur de chargement du client');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _makePhoneCall() async {
    if (_client?.phone == null) {
      context.showWarning('Aucun numéro de téléphone disponible');
      return;
    }

    final phoneNumber = _client!.phone!.replaceAll(RegExp(r'[\s\-\.]'), '');
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          context.showError('Impossible de lancer l\'appel');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showError('Erreur lors du lancement de l\'appel');
      }
    }
  }

  Future<void> _sendEmail() async {
    if (_client?.email == null) {
      context.showWarning('Aucune adresse email disponible');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => _buildEmailOptionsSheet(),
    );
  }

  Widget _buildEmailOptionsSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Envoyer un email'),
            subtitle: const Text('Ouvrir votre client email'),
            onTap: () async {
              Navigator.pop(context);
              final Uri emailUri = Uri.parse('mailto:${_client!.email}');
              try {
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  if (mounted) {
                    context.showError('Impossible d\'ouvrir l\'email');
                  }
                }
              } catch (e) {
                if (mounted) {
                  context.showError('Erreur lors de l\'ouverture de l\'email');
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Envoyer un devis'),
            subtitle: const Text('Créer et envoyer un nouveau devis'),
            onTap: () {
              Navigator.pop(context);
              context.push('/quotes/new', extra: widget.clientId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Envoyer une facture'),
            subtitle: const Text('Créer et envoyer une nouvelle facture'),
            onTap: () {
              Navigator.pop(context);
              context.push('/invoices/new', extra: widget.clientId);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_client?.name ?? 'Client'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/clients/${widget.clientId}/edit');
            },
            tooltip: 'Modifier',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _client == null
              ? const Center(child: Text('Client non trouvé'))
              : RefreshIndicator(
                  onRefresh: _fetchClientData,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildClientHeader(),
                        _buildQuickActions(),
                        _buildStatistics(),
                        _buildTabSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildClientHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              _client!.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _client!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (_client!.companyName != null) ...[
            const SizedBox(height: 4),
            Text(
              _client!.companyName!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_client!.phone != null) ...[
                const Icon(Icons.phone, size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  _client!.phone!,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 20),
              ],
              if (_client!.email != null) ...[
                const Icon(Icons.email, size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _client!.email!,
                    style: const TextStyle(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _makePhoneCall,
              icon: const Icon(Icons.phone),
              label: const Text('Appeler'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _sendEmail,
              icon: const Icon(Icons.email),
              label: const Text('Email'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                context.push('/quotes/new', extra: widget.clientId);
              },
              icon: const Icon(Icons.add),
              label: const Text('Devis'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'CA Total',
              value: InvoiceCalculator.formatCurrency(_totalRevenue),
              icon: Icons.euro,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Impayés',
              value: InvoiceCalculator.formatCurrency(_unpaidAmount),
              icon: Icons.warning,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Devis actifs',
              value: _activeQuotes.toString(),
              icon: Icons.description,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Devis', icon: Icon(Icons.description)),
            Tab(text: 'Factures', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Infos', icon: Icon(Icons.info)),
          ],
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildQuotesTab(),
              _buildInvoicesTab(),
              _buildInfoTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuotesTab() {
    if (_quotes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Aucun devis pour ce client',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quotes.length,
      itemBuilder: (context, index) {
        final quote = _quotes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(quote.status),
              child: const Icon(Icons.description, color: Colors.white, size: 20),
            ),
            title: Text(quote.quoteNumber),
            subtitle: Text(
              '${InvoiceCalculator.formatDate(quote.date)} • ${_getStatusLabel(quote.status)}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  InvoiceCalculator.formatCurrency(quote.totalTtc),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            onTap: () {
              context.push('/quotes/${quote.id}');
            },
          ),
        );
      },
    );
  }

  Widget _buildInvoicesTab() {
    if (_invoices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Aucune facture pour ce client',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _invoices.length,
      itemBuilder: (context, index) {
        final invoice = _invoices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPaymentStatusColor(invoice.paymentStatus),
              child: const Icon(Icons.receipt_long, color: Colors.white, size: 20),
            ),
            title: Text(invoice.number),
            subtitle: Text(
              '${InvoiceCalculator.formatDate(invoice.date)} • ${_getPaymentStatusLabel(invoice.paymentStatus)}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  InvoiceCalculator.formatCurrency(invoice.totalTtc),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (invoice.paymentStatus != 'paid')
                  Text(
                    'Reste: ${InvoiceCalculator.formatCurrency(invoice.balanceDue)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            onTap: () {
              context.push('/invoices/${invoice.id}');
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_client!.address != null || _client!.city != null) ...[
            _buildInfoSection('Adresse', Icons.location_on, [
              if (_client!.address != null) _client!.address!,
              if (_client!.postalCode != null && _client!.city != null)
                '${_client!.postalCode} ${_client!.city}',
            ]),
            const Divider(height: 32),
          ],
          if (_client!.phone != null || _client!.email != null) ...[
            _buildInfoSection('Contact', Icons.contact_phone, [
              if (_client!.phone != null) 'Tél: ${_client!.phone}',
              if (_client!.email != null) 'Email: ${_client!.email}',
            ]),
            const Divider(height: 32),
          ],
          if (_client!.companyName != null || _client!.siret != null) ...[
            _buildInfoSection('Entreprise', Icons.business, [
              if (_client!.companyName != null) _client!.companyName!,
              if (_client!.siret != null) 'SIRET: ${_client!.siret}',
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                item,
                style: const TextStyle(fontSize: 16),
              ),
            )),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'sent':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Brouillon';
      case 'sent':
        return 'Envoyé';
      case 'accepted':
        return 'Accepté';
      case 'rejected':
        return 'Refusé';
      default:
        return status;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'unpaid':
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentStatusLabel(String status) {
    switch (status) {
      case 'paid':
        return 'Payée';
      case 'partial':
        return 'Partiellement payée';
      case 'unpaid':
        return 'Impayée';
      case 'overdue':
        return 'En retard';
      default:
        return status;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
