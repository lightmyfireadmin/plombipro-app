import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/glassmorphism_theme.dart';
import '../../config/plombipro_colors.dart';
import '../../widgets/glassmorphic/glass_card.dart';
import '../../services/onboarding_service_enhanced.dart';
import '../../services/supabase_service.dart';
import 'dart:ui';

/// Modern glassmorphic dashboard with animations
class HomeScreenEnhanced extends StatefulWidget {
  const HomeScreenEnhanced({super.key});

  @override
  State<HomeScreenEnhanced> createState() => _HomeScreenEnhancedState();
}

class _HomeScreenEnhancedState extends State<HomeScreenEnhanced>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _showOnboarding = false;
  OnboardingServiceEnhanced? _onboardingService;

  // Dashboard stats
  int _totalClients = 0;
  int _pendingQuotes = 0;
  int _unpaidInvoices = 0;
  int _activeJobSites = 0;
  double _monthlyRevenue = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    _initializeOnboarding();
    _loadDashboardData();
  }

  Future<void> _initializeOnboarding() async {
    final service = await OnboardingServiceEnhanced.create();
    setState(() {
      _onboardingService = service;
      _showOnboarding = !service.isOnboardingCompleted ||
                       !service.isProfileSetupComplete;
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      // Fetch real data from Supabase
      final quotes = await SupabaseService.fetchQuotes();
      final invoices = await SupabaseService.fetchInvoices();
      final clients = await SupabaseService.fetchClients();
      final jobSites = await SupabaseService.getJobSites();

      if (mounted) {
        setState(() {
          _totalClients = clients.length;
          _pendingQuotes = quotes.where((q) => q.status == 'sent').length;
          _unpaidInvoices = invoices.where((i) => i.paymentStatus != 'paid').length;
          _activeJobSites = jobSites.where((j) => j.status == 'in_progress').length;

          // Calculate monthly revenue from accepted quotes this month
          final now = DateTime.now();
          _monthlyRevenue = quotes
              .where((q) =>
                  q.status == 'accepted' &&
                  q.date.month == now.month &&
                  q.date.year == now.year)
              .fold(0.0, (sum, q) => sum + q.totalTtc);
        });
      }
    } catch (e) {
      // Handle error gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement des données: ${e.toString()}'),
            backgroundColor: PlombiProColors.error,
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: _loadDashboardData,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PlombiProColors.primaryBlue.withOpacity(0.9),
                  PlombiProColors.tertiaryTeal.withOpacity(0.7),
                  PlombiProColors.backgroundDark,
                ],
              ),
            ),
          ),

          // Floating bubbles
          ..._buildFloatingBubbles(),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  _buildAppBar(),

                  // Welcome Card
                  SliverToBoxAdapter(
                    child: _buildWelcomeCard(),
                  ),

                  // Quick Actions
                  SliverToBoxAdapter(
                    child: _buildQuickActions(),
                  ),

                  // Stats Grid
                  SliverToBoxAdapter(
                    child: _buildStatsGrid(),
                  ),

                  // Recent Activity
                  SliverToBoxAdapter(
                    child: _buildRecentActivity(),
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ),

          // Floating Action Button
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildFAB(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo and title
            Row(
              children: [
                GlassContainer(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(0),
                  borderRadius: BorderRadius.circular(15),
                  opacity: 0.2,
                  child: const Icon(
                    Icons.plumbing,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PlombiPro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tableau de bord',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Actions
            Row(
              children: [
                AnimatedGlassContainer(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(0),
                  borderRadius: BorderRadius.circular(15),
                  opacity: 0.2,
                  onTap: () {
                    // Show notifications
                  },
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: PlombiProColors.secondaryOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedGlassContainer(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(0),
                  borderRadius: BorderRadius.circular(15),
                  opacity: 0.2,
                  onTap: () {
                    context.push('/profile');
                  },
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        gradient: GlassmorphismTheme.primaryGradient(opacity: 0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.wb_sunny_outlined,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bonjour Jean! 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Prêt pour une nouvelle journée productive?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showOnboarding) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PlombiProColors.secondaryOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PlombiProColors.secondaryOrange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.rocket_launch_outlined,
                      color: PlombiProColors.secondaryOrange,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Commencez votre aventure',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Créez votre premier devis en 2 minutes',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: PlombiProColors.secondaryOrange,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Nouveau\nDevis',
                  Icons.description_outlined,
                  PlombiProColors.secondaryOrange,
                  () => context.push('/quotes/new'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Nouvelle\nFacture',
                  Icons.receipt_long_outlined,
                  PlombiProColors.tertiaryTeal,
                  () => context.push('/invoices/new'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Nouveau\nClient',
                  Icons.person_add_outlined,
                  PlombiProColors.primaryBlue,
                  () => context.push('/clients/new'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AnimatedGlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      color: color,
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vue d\'ensemble',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              GlassStatCard(
                title: 'Clients',
                value: '$_totalClients',
                icon: Icons.people_outline,
                color: PlombiProColors.primaryBlue,
                onTap: () => context.push('/clients'),
              ),
              GlassStatCard(
                title: 'Devis en attente',
                value: '$_pendingQuotes',
                icon: Icons.description_outlined,
                color: PlombiProColors.secondaryOrange,
                onTap: () => context.push('/quotes'),
              ),
              GlassStatCard(
                title: 'Factures impayées',
                value: '$_unpaidInvoices',
                icon: Icons.receipt_long_outlined,
                color: PlombiProColors.error,
                subtitle: 'À relancer',
                onTap: () => context.push('/invoices'),
              ),
              GlassStatCard(
                title: 'Chantiers actifs',
                value: '$_activeJobSites',
                icon: Icons.construction_outlined,
                color: PlombiProColors.tertiaryTeal,
                onTap: () => context.push('/job-sites'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassCard(
            color: PlombiProColors.success,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.euro_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_monthlyRevenue.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chiffre d\'affaires ce mois',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activité récente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Voir tout',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Devis accepté',
            'Sophie Martin a accepté le devis DEV-2025-001',
            Icons.check_circle_outline,
            PlombiProColors.success,
            'Il y a 2 heures',
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Nouveau paiement',
            'Paiement reçu pour FAC-2025-001 (171,00 €)',
            Icons.payment_outlined,
            PlombiProColors.primaryBlue,
            'Hier à 14:30',
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Rappel',
            'Facture FAC-2025-002 à relancer (624,00 €)',
            Icons.notifications_active_outlined,
            PlombiProColors.warning,
            'Il y a 1 jour',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String time,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return AnimatedGlassContainer(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(0),
      color: PlombiProColors.secondaryOrange,
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        _showQuickMenu();
      },
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  void _showQuickMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassBottomSheet(
        title: 'Créer',
        height: 400,
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildMenuOption('Devis', Icons.description_outlined,
                PlombiProColors.secondaryOrange, () => context.push('/quotes/new')),
            _buildMenuOption('Facture', Icons.receipt_long_outlined,
                PlombiProColors.primaryBlue, () => context.push('/invoices/new')),
            _buildMenuOption('Client', Icons.person_add_outlined,
                PlombiProColors.tertiaryTeal, () => context.push('/clients/new')),
            _buildMenuOption('Chantier', Icons.construction_outlined,
                PlombiProColors.success, () => context.push('/job-sites/new')),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GlassCard(
      color: color,
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingBubbles() {
    return [
      Positioned(
        top: 150,
        right: 20,
        child: _FloatingBubble(size: 60, delay: 0),
      ),
      Positioned(
        top: 300,
        left: 30,
        child: _FloatingBubble(size: 80, delay: 1),
      ),
      Positioned(
        bottom: 200,
        right: 50,
        child: _FloatingBubble(size: 100, delay: 2),
      ),
    ];
  }
}

class _FloatingBubble extends StatefulWidget {
  final double size;
  final int delay;

  const _FloatingBubble({required this.size, required this.delay});

  @override
  State<_FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<_FloatingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3 + widget.delay),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.size / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
