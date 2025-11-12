import 'dart:ui';
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
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_text_styles.dart';
import '../../config/plombipro_spacing.dart';
import '../../widgets/glassmorphic/glass_card.dart';

/// Beautiful glassmorphic client detail page with summary, operations, and history
class ClientDetailPage extends StatefulWidget {
  final String clientId;

  const ClientDetailPage({
    super.key,
    required this.clientId,
  });

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fetchClientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientData() async {
    setState(() => _isLoading = true);

    try {
      final client = await SupabaseService.getClientById(widget.clientId);
      final quotes = await SupabaseService.fetchQuotesByClient(widget.clientId);
      final invoices =
          await SupabaseService.fetchInvoicesByClient(widget.clientId);

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
        _fadeController.forward();
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
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGlassEmailOptionsSheet(),
    );
  }

  Widget _buildGlassEmailOptionsSheet() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PlombiProColors.backgroundDark.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Email option
              _buildGlassListTile(
                icon: Icons.email,
                title: 'Envoyer un email',
                subtitle: 'Ouvrir votre client email',
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
              const SizedBox(height: 12),

              // Quote option
              _buildGlassListTile(
                icon: Icons.description,
                title: 'Envoyer un devis',
                subtitle: 'Créer et envoyer un nouveau devis',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/quotes/new', extra: widget.clientId);
                },
              ),
              const SizedBox(height: 12),

              // Invoice option
              _buildGlassListTile(
                icon: Icons.receipt_long,
                title: 'Envoyer une facture',
                subtitle: 'Créer et envoyer une nouvelle facture',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/invoices/new', extra: widget.clientId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AnimatedGlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      opacity: 0.15,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PlombiProColors.primaryBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoadingState()
          : _client == null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Stack(
      children: [
        _buildGradientBackground(),
        Center(
          child: GlassContainer(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            opacity: 0.2,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Stack(
      children: [
        _buildGradientBackground(),
        const Center(
          child: Text(
            'Client non trouvé',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        _buildGradientBackground(),
        SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchClientData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildGlassAppBar(),
                    _buildClientHeader(),
                    _buildQuickActions(),
                    _buildStatistics(),
                    _buildTabSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlombiProColors.primaryBlue,
            PlombiProColors.tertiaryTeal,
            PlombiProColors.primaryBlueDark,
          ],
        ),
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back button
          AnimatedGlassContainer(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(12),
            opacity: 0.2,
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Spacer(),
          // Edit button
          AnimatedGlassContainer(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(12),
            opacity: 0.2,
            onTap: () {
              context.push('/clients/${widget.clientId}');
            },
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildClientHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(24),
        opacity: 0.15,
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    PlombiProColors.secondaryOrange,
                    PlombiProColors.secondaryOrangeLight,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: PlombiProColors.secondaryOrange.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _client!.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              _client!.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            // Company
            if (_client!.companyName != null) ...[
              const SizedBox(height: 4),
              Text(
                _client!.companyName!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 16),

            // Contact info
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 8,
              children: [
                if (_client!.phone != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone,
                          size: 16, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        _client!.phone!,
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                if (_client!.email != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.email,
                          size: 16, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _client!.email!,
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Call button
          Expanded(
            child: AnimatedGlassContainer(
              height: 56,
              borderRadius: BorderRadius.circular(16),
              opacity: 0.2,
              color: PlombiProColors.success,
              onTap: _makePhoneCall,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Appeler',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Email button
          Expanded(
            child: AnimatedGlassContainer(
              height: 56,
              borderRadius: BorderRadius.circular(16),
              opacity: 0.2,
              color: PlombiProColors.info,
              onTap: _sendEmail,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // New quote button
          Expanded(
            child: AnimatedGlassContainer(
              height: 56,
              borderRadius: BorderRadius.circular(16),
              opacity: 0.2,
              color: PlombiProColors.secondaryOrange,
              onTap: () {
                context.push('/quotes/new', extra: widget.clientId);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Devis',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _GlassStatCard(
              title: 'CA Total',
              value: InvoiceCalculator.formatCurrency(_totalRevenue),
              icon: Icons.euro,
              color: PlombiProColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _GlassStatCard(
              title: 'Impayés',
              value: InvoiceCalculator.formatCurrency(_unpaidAmount),
              icon: Icons.warning,
              color: PlombiProColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _GlassStatCard(
              title: 'Devis actifs',
              value: _activeQuotes.toString(),
              icon: Icons.description,
              color: PlombiProColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(0),
        borderRadius: BorderRadius.circular(24),
        opacity: 0.15,
        child: Column(
          children: [
            // Glass tab bar
            Container(
              padding: const EdgeInsets.all(8),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: PlombiProColors.secondaryOrange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description, size: 18),
                        SizedBox(width: 8),
                        Text('Devis', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 18),
                        SizedBox(width: 8),
                        Text('Factures', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info, size: 18),
                        SizedBox(width: 8),
                        Text('Infos', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab content
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
        ),
      ),
    );
  }

  Widget _buildQuotesTab() {
    if (_quotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description,
                  size: 64, color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'Aucun devis pour ce client',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 16),
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedGlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            opacity: 0.1,
            onTap: () {
              context.push('/quotes/${quote.id}');
            },
            child: Row(
              children: [
                // Status icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(quote.status).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quote.quoteNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${InvoiceCalculator.formatDate(quote.date)} • ${_getStatusLabel(quote.status)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  InvoiceCalculator.formatCurrency(quote.totalTtc),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoicesTab() {
    if (_invoices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long,
                  size: 64, color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'Aucune facture pour ce client',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 16),
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedGlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            opacity: 0.1,
            onTap: () {
              context.push('/invoices/${invoice.id}');
            },
            child: Row(
              children: [
                // Payment status icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(invoice.paymentStatus)
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${InvoiceCalculator.formatDate(invoice.date)} • ${_getPaymentStatusLabel(invoice.paymentStatus)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      InvoiceCalculator.formatCurrency(invoice.totalTtc),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (invoice.paymentStatus != 'paid')
                      Text(
                        'Reste: ${InvoiceCalculator.formatCurrency(invoice.balanceDue)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: PlombiProColors.error,
                        ),
                      ),
                  ],
                ),
              ],
            ),
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
            _buildGlassInfoSection('Adresse', Icons.location_on, [
              if (_client!.address != null) _client!.address!,
              if (_client!.postalCode != null && _client!.city != null)
                '${_client!.postalCode} ${_client!.city}',
            ]),
            const SizedBox(height: 16),
          ],
          if (_client!.phone != null || _client!.email != null) ...[
            _buildGlassInfoSection('Contact', Icons.contact_phone, [
              if (_client!.phone != null) 'Tél: ${_client!.phone}',
              if (_client!.email != null) 'Email: ${_client!.email}',
            ]),
            const SizedBox(height: 16),
          ],
          if (_client!.companyName != null || _client!.siret != null) ...[
            _buildGlassInfoSection('Entreprise', Icons.business, [
              if (_client!.companyName != null) _client!.companyName!,
              if (_client!.siret != null) 'SIRET: ${_client!.siret}',
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildGlassInfoSection(
      String title, IconData icon, List<String> items) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PlombiProColors.primaryBlue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return PlombiProColors.gray400;
      case 'sent':
        return PlombiProColors.info;
      case 'accepted':
        return PlombiProColors.success;
      case 'rejected':
        return PlombiProColors.error;
      default:
        return PlombiProColors.warning;
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
        return PlombiProColors.success;
      case 'partial':
        return PlombiProColors.warning;
      case 'unpaid':
      case 'overdue':
        return PlombiProColors.error;
      default:
        return PlombiProColors.gray400;
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

/// Glass statistics card widget
class _GlassStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _GlassStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      opacity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
