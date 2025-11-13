import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../notifications/notifications_page.dart';

import '../../models/activity.dart';
import '../../models/appointment.dart';
import '../../models/client.dart';
import '../../models/invoice.dart';
import '../../models/job_site.dart';
import '../../models/payment.dart';
import '../../models/profile.dart';
import '../../models/quote.dart';
import '../../services/invoice_calculator.dart';
import '../../services/supabase_service.dart';
import '../../services/supabase_service_enhanced.dart';
import '../../services/auth_service.dart';
import '../../services/error_handler.dart';
import '../../widgets/section_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/app_bottom_nav.dart';
import '../clients/client_form_page.dart';
import '../quotes/quote_form_page.dart';
import '../quotes/quotes_list_page.dart';
import './widgets/revenue_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  Profile? _profile;
  List<Quote> _quotes = [];
  List<Invoice> _invoices = [];
  List<JobSite> _jobSites = [];
  List<Payment> _payments = [];
  List<Activity> _activityFeed = [];
  List<Appointment> _upcomingAppointments = [];
  List<Client> _clients = [];

  // Stats
  double _monthlyRevenue = 0;
  int _pendingQuotesCount = 0;
  double _unpaidInvoicesAmount = 0;
  int _activeJobSitesCount = 0;
  int _totalClientsCount = 0;
  int _totalQuotesCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Debug: Print auth state before fetching data
      print('🔍 === DASHBOARD DATA FETCH ===');
      await SupabaseServiceEnhanced.printAuthState();

      final profile = await SupabaseService.fetchUserProfile();
      final clients = await SupabaseServiceEnhanced.fetchClients();
      final quotes = await SupabaseServiceEnhanced.fetchQuotes();
      final invoices = await SupabaseServiceEnhanced.fetchInvoices();
      final jobSites = await SupabaseService.getJobSites();
      final payments = await SupabaseService.getPayments();
      final appointments = await SupabaseService.fetchUpcomingAppointments();

      print('📊 Dashboard Data Fetched:');
      print('  - Clients: ${clients.length}');
      print('  - Quotes: ${quotes.length}');
      print('  - Invoices: ${invoices.length}');
      print('  - Job Sites: ${jobSites.length}');

      if (mounted) {
        setState(() {
          _profile = profile;
          _clients = clients;
          _quotes = quotes;
          _invoices = invoices;
          _jobSites = jobSites;
          _payments = payments;
          _upcomingAppointments = appointments;
          _calculateStats();
          _prepareActivityFeed();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.handleError(
          e,
          customMessage: "Erreur de chargement du tableau de bord",
          onRetry: _fetchDashboardData,
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _prepareActivityFeed() {
    List<Activity> feed = [];
    for (var quote in _quotes) {
      feed.add(Activity(item: quote, date: quote.date, type: ActivityType.quote));
    }
    for (var invoice in _invoices) {
      feed.add(Activity(item: invoice, date: invoice.date, type: ActivityType.invoice));
    }
    for (var payment in _payments) {
      feed.add(Activity(item: payment, date: payment.paymentDate, type: ActivityType.payment));
    }

    feed.sort((a, b) => b.date.compareTo(a.date));
    _activityFeed = feed.take(5).toList();
  }

  void _calculateStats() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    double monthlyRev = 0;
    int pendingCount = 0;
    double unpaidAmount = 0;
    int activeJobSites = 0;

    // Calculate total clients and quotes
    int totalClients = _clients.length;
    int totalQuotes = _quotes.length;

    print('📈 Calculating Stats:');
    print('  - Total Clients: $totalClients');
    print('  - Total Quotes: $totalQuotes');

    for (final quote in _quotes) {
      print('    Quote: ${quote.quoteNumber}, Status: ${quote.status}, Date: ${quote.date}');

      // Monthly revenue from accepted quotes this month
      if (quote.status == 'accepted' && quote.date.month == currentMonth && quote.date.year == currentYear) {
        monthlyRev += quote.totalTtc;
        print('      ✓ Added to monthly revenue: ${quote.totalTtc}');
      }
      // Pending quotes - count 'sent', 'pending', or 'draft' status
      if (quote.status == 'sent' || quote.status == 'pending' || quote.status == 'draft') {
        pendingCount++;
        print('      ✓ Counted as pending');
      }
    }

    print('  - Monthly Revenue: $monthlyRev');
    print('  - Pending Quotes: $pendingCount');

    for (final invoice in _invoices) {
      if (invoice.paymentStatus != 'paid') {
        unpaidAmount += invoice.balanceDue;
      }
    }

    for (final jobSite in _jobSites) {
      if (jobSite.status == 'in_progress') {
        activeJobSites++;
      }
    }

    setState(() {
      _monthlyRevenue = monthlyRev;
      _pendingQuotesCount = pendingCount;
      _unpaidInvoicesAmount = unpaidAmount;
      _activeJobSitesCount = activeJobSites;
      _totalClientsCount = totalClients;
      _totalQuotesCount = totalQuotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithDrawer(
        title: 'PlombiPro',
        actions: [
          _buildNotificationBellWithBadge(context),
          IconButton(
            onPressed: () {
              context.go('/settings');
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Paramètres',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Header
                    Text(
                      'Bonjour, Utilisateur!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      InvoiceCalculator.formatDate(DateTime.now()),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Statistiques Rapides'),
                    _buildQuickStatsGrid(),
                    const Divider(height: 32),
                    const SectionHeader(title: 'Revenus des 12 derniers mois'),
                    RevenueChart(quotes: _quotes),
                    const Divider(height: 32),
                    const SectionHeader(title: 'Activité Récente'),
                    _buildRecentActivityList(),
                    const Divider(height: 32),
                    const SectionHeader(title: 'Rendez-vous à venir'),
                    _buildUpcomingAppointments(),
                    const Divider(height: 32),
                    const SectionHeader(title: 'Actions Rapides'),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }


  Widget _buildHeader() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        centerTitle: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _profile != null && _profile!.firstName != null
                  ? 'Bonjour, ${_profile!.firstName}!'
                  : 'Bonjour!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              InvoiceCalculator.formatDate(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _StatCard(title: 'Total Clients', value: _totalClientsCount.toString(), icon: Icons.people, color: Colors.blue),
        _StatCard(title: 'Total Devis', value: _totalQuotesCount.toString(), icon: Icons.request_quote, color: Colors.purple),
        _StatCard(title: 'CA du mois', value: InvoiceCalculator.formatCurrency(_monthlyRevenue), icon: Icons.euro, color: Colors.green),
        _StatCard(title: 'Factures impayées', value: InvoiceCalculator.formatCurrency(_unpaidInvoicesAmount), icon: Icons.receipt_long, color: Colors.red),
        _StatCard(title: 'Devis en attente', value: _pendingQuotesCount.toString(), icon: Icons.hourglass_empty, color: Colors.orange),
        _StatCard(title: "Chantiers actifs", value: _activeJobSitesCount.toString(), icon: Icons.construction, color: Colors.teal),
      ],
    );
  }

  Widget _buildRecentActivityList() {
    if (_activityFeed.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text('Aucune activité récente.')),
      );
    }
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _activityFeed.length,
        itemBuilder: (context, index) {
          final activity = _activityFeed[index];
          return _ActivityCard(activity: activity);
        },
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    if (_upcomingAppointments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text('Aucun rendez-vous à venir.')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _upcomingAppointments[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(appointment.title),
            subtitle: Text(InvoiceCalculator.formatDate(appointment.appointmentDate)),
            trailing: Text(appointment.appointmentTime),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _ActionButton(title: '+ Nouveau Devis', icon: Icons.add, onTap: () {
           context.go('/quotes/new');
        }),
        _ActionButton(title: '+ Nv. Facture', icon: Icons.receipt_long, onTap: () {
          context.go('/invoices/new');
        }),
        _ActionButton(title: '+ Nouveau Client', icon: Icons.person_add, onTap: () {
          context.go('/clients/new');
        }),
        _ActionButton(title: 'Scanner', icon: Icons.qr_code_scanner, onTap: () {
          context.go('/scan-invoice');
        }),
        _ActionButton(title: 'Contacter', icon: Icons.call, onTap: () {
          // Open phone dialer - this would typically use url_launcher
          // For now, navigate to client list to select who to contact
          context.go('/clients');
        }),
      ],
    );
  }

  Widget _buildNotificationBellWithBadge(BuildContext context) {
    // Count unread notifications (for now, we'll use a placeholder)
    // TODO: Get real unread count from SupabaseService
    final unreadCount = 0; // Placeholder - will be replaced with actual count

    return Stack(
      children: [
        IconButton(
          onPressed: () async {
            // Add ripple effect by using InkWell behavior (automatic with IconButton)
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
            // Refresh dashboard when returning from notifications
            _fetchDashboardData();
          },
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications & Rappels',
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// Internal helper widgets for the dashboard

class _StatCard extends StatelessWidget {
  final String title; 
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(title), Icon(icon, color: color, size: 20)],
            ),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget{
  final Activity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    Widget title, subtitle, trailing;
    IconData icon;

    switch (activity.type) {
      case ActivityType.quote:
        final quote = activity.item as Quote;
        icon = Icons.request_quote;
        title = Text(quote.quoteNumber, style: Theme.of(context).textTheme.labelLarge);
        subtitle = Text(quote.client?.name ?? 'Client inconnu', overflow: TextOverflow.ellipsis);
        trailing = Text(InvoiceCalculator.formatCurrency(quote.totalTtc), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold));
        break;
      case ActivityType.invoice:
        final invoice = activity.item as Invoice;
        icon = Icons.receipt_long;
        title = Text(invoice.number, style: Theme.of(context).textTheme.labelLarge);
        subtitle = Text(invoice.client?.name ?? 'Client inconnu', overflow: TextOverflow.ellipsis);
        trailing = Text(InvoiceCalculator.formatCurrency(invoice.totalTtc), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold));
        break;
      case ActivityType.payment:
        final payment = activity.item as Payment;
        icon = Icons.payment;
        title = Text('Paiement reçu', style: Theme.of(context).textTheme.labelLarge);
        subtitle = Text('Facture #${payment.invoiceId}', overflow: TextOverflow.ellipsis);
        trailing = Text(InvoiceCalculator.formatCurrency(payment.amount), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold));
        break;
    }

    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 8),
                  title,
                ],
              ),
              subtitle,
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(InvoiceCalculator.formatDate(activity.date), style: Theme.of(context).textTheme.bodySmall),
                  trailing,
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
