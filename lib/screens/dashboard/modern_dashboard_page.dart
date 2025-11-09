import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_spacing.dart';
import '../../config/plombipro_text_styles.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/quote_repository.dart';
import '../../repositories/appointment_repository.dart';
import '../../repositories/client_repository.dart';

/// Modern, beautiful dashboard with real-time business metrics
class ModernDashboardPage extends ConsumerWidget {
  const ModernDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern app bar with gradient
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: PlombiProColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: PlombiProSpacing.pagePaddingLarge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Tableau de bord',
                          style: PlombiProTextStyles.displaySmall.copyWith(
                            color: PlombiProColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        PlombiProSpacing.verticalXS,
                        Text(
                          'Vue d\'ensemble de votre activité',
                          style: PlombiProTextStyles.bodyMedium.copyWith(
                            color: PlombiProColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Dashboard content
          SliverPadding(
            padding: PlombiProSpacing.pagePadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick stats cards
                const _QuickStatsSection(),
                PlombiProSpacing.verticalLG,

                // Revenue chart
                const _RevenueChartCard(),
                PlombiProSpacing.verticalLG,

                // Today's appointments
                const _TodayAppointmentsCard(),
                PlombiProSpacing.verticalLG,

                // Recent activity
                const _RecentActivityCard(),
                PlombiProSpacing.verticalLG,

                // Quick actions
                const _QuickActionsCard(),
                PlombiProSpacing.verticalXL,
              ]),
            ),
          ),
        ],
      ),

      // Floating action button with gradient
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQuickCreateMenu(context);
        },
        backgroundColor: PlombiProColors.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('Créer'),
      ),
    );
  }

  void _showQuickCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _QuickCreateMenu(),
    );
  }
}

/// Quick stats cards with animated values
class _QuickStatsSection extends ConsumerWidget {
  const _QuickStatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = ref.watch(totalRevenueProvider);
    final outstandingAsync = ref.watch(outstandingAmountProvider);
    final clientsAsync = ref.watch(clientsNotifierProvider);
    final conversionAsync = ref.watch(quoteConversionRateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aperçu rapide',
          style: PlombiProTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        PlombiProSpacing.verticalMD,
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: PlombiProSpacing.md,
          mainAxisSpacing: PlombiProSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _MetricCard(
              title: 'Chiffre d\'affaires',
              valueAsync: revenueAsync,
              icon: Icons.euro,
              gradient: PlombiProColors.successGradient,
              formatter: (value) => '${value.toStringAsFixed(0)}€',
            ),
            _MetricCard(
              title: 'En attente',
              valueAsync: outstandingAsync,
              icon: Icons.pending_actions,
              gradient: PlombiProColors.warningGradient,
              formatter: (value) => '${value.toStringAsFixed(0)}€',
            ),
            _MetricCard(
              title: 'Clients',
              valueAsync: clientsAsync.whenData((c) => c.length.toDouble()),
              icon: Icons.people,
              gradient: PlombiProColors.primaryGradient,
              formatter: (value) => value.toInt().toString(),
            ),
            _MetricCard(
              title: 'Conversion',
              valueAsync: conversionAsync,
              icon: Icons.trending_up,
              gradient: PlombiProColors.infoGradient,
              formatter: (value) => '${value.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final AsyncValue<double> valueAsync;
  final IconData icon;
  final Gradient gradient;
  final String Function(double) formatter;

  const _MetricCard({
    required this.title,
    required this.valueAsync,
    required this.icon,
    required this.gradient,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: PlombiProSpacing.elevationSM,
      shape: RoundedRectangleBorder(
        borderRadius: PlombiProSpacing.borderRadiusLG,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PlombiProColors.white,
              PlombiProColors.gray50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: PlombiProSpacing.borderRadiusLG,
        ),
        padding: PlombiProSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(PlombiProSpacing.xs),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: PlombiProSpacing.borderRadiusSM,
                  ),
                  child: Icon(
                    icon,
                    color: PlombiProColors.white,
                    size: PlombiProSpacing.iconSM,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                valueAsync.when(
                  data: (value) => TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0, end: value),
                    builder: (context, animatedValue, child) {
                      return Text(
                        formatter(animatedValue),
                        style: PlombiProTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                  loading: () => const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Text('--'),
                ),
                PlombiProSpacing.verticalXXS,
                Text(
                  title,
                  style: PlombiProTextStyles.bodySmall.copyWith(
                    color: PlombiProColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Revenue chart card with beautiful visualization
class _RevenueChartCard extends ConsumerWidget {
  const _RevenueChartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: PlombiProSpacing.elevationMD,
      shape: RoundedRectangleBorder(
        borderRadius: PlombiProSpacing.borderRadiusLG,
      ),
      child: Padding(
        padding: PlombiProSpacing.cardPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Évolution du CA',
                      style: PlombiProTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    PlombiProSpacing.verticalXXS,
                    Text(
                      '7 derniers jours',
                      style: PlombiProTextStyles.bodySmall.copyWith(
                        color: PlombiProColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            PlombiProSpacing.verticalLG,
            SizedBox(
              height: 200,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: PlombiProColors.gray200,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  fontSize: 12,
                  color: PlombiProColors.textSecondaryLight,
                );
                final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(days[value.toInt()], style: style);
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}k',
                  style: const TextStyle(
                    fontSize: 12,
                    color: PlombiProColors.textSecondaryLight,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 1),
              FlSpot(2, 4),
              FlSpot(3, 3),
              FlSpot(4, 5),
              FlSpot(5, 3),
              FlSpot(6, 4),
            ],
            isCurved: true,
            gradient: PlombiProColors.primaryGradient,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  PlombiProColors.primaryBlue.withOpacity(0.3),
                  PlombiProColors.primaryBlue.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Today's appointments card
class _TodayAppointmentsCard extends ConsumerWidget {
  const _TodayAppointmentsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(todayAppointmentsProvider);

    return Card(
      elevation: PlombiProSpacing.elevationMD,
      shape: RoundedRectangleBorder(
        borderRadius: PlombiProSpacing.borderRadiusLG,
      ),
      child: Padding(
        padding: PlombiProSpacing.cardPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(PlombiProSpacing.sm),
                      decoration: BoxDecoration(
                        color: PlombiProColors.primaryBlue.withOpacity(0.1),
                        borderRadius: PlombiProSpacing.borderRadiusMD,
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: PlombiProColors.primaryBlue,
                        size: PlombiProSpacing.iconSM,
                      ),
                    ),
                    PlombiProSpacing.horizontalMD,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aujourd\'hui',
                          style: PlombiProTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        appointmentsAsync.when(
                          data: (appointments) => Text(
                            '${appointments.length} rendez-vous',
                            style: PlombiProTextStyles.bodySmall.copyWith(
                              color: PlombiProColors.textSecondaryLight,
                            ),
                          ),
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            PlombiProSpacing.verticalMD,
            appointmentsAsync.when(
              data: (appointments) {
                if (appointments.isEmpty) {
                  return _buildEmptyState();
                }
                return Column(
                  children: appointments.take(3).map((apt) {
                    return _AppointmentItem(appointment: apt);
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, __) => const Text('Erreur de chargement'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: PlombiProSpacing.cardPaddingLarge,
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: PlombiProColors.gray300,
          ),
          PlombiProSpacing.verticalMD,
          Text(
            'Aucun rendez-vous aujourd\'hui',
            style: PlombiProTextStyles.bodyLarge.copyWith(
              color: PlombiProColors.textSecondaryLight,
            ),
          ),
          PlombiProSpacing.verticalSM,
          Text(
            'Profitez de cette journée pour planifier vos prochaines interventions',
            style: PlombiProTextStyles.bodySmall.copyWith(
              color: PlombiProColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AppointmentItem extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const _AppointmentItem({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: PlombiProSpacing.sm),
      padding: PlombiProSpacing.cardPadding,
      decoration: BoxDecoration(
        color: PlombiProColors.gray50,
        borderRadius: PlombiProSpacing.borderRadiusMD,
        border: Border.all(color: PlombiProColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(appointment['status']),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          PlombiProSpacing.horizontalMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['title'] ?? 'Sans titre',
                  style: PlombiProTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                PlombiProSpacing.verticalXXS,
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: PlombiProColors.textSecondaryLight,
                    ),
                    PlombiProSpacing.horizontalXS,
                    Text(
                      _formatTime(appointment['start_time']),
                      style: PlombiProTextStyles.bodySmall.copyWith(
                        color: PlombiProColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: PlombiProColors.gray400,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'confirmed':
        return PlombiProColors.success;
      case 'in_progress':
        return PlombiProColors.info;
      case 'completed':
        return PlombiProColors.primaryBlue;
      default:
        return PlombiProColors.warning;
    }
  }

  String _formatTime(String? time) {
    if (time == null) return '--:--';
    try {
      final dt = DateTime.parse(time);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }
}

/// Recent activity card
class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: PlombiProSpacing.elevationMD,
      shape: RoundedRectangleBorder(
        borderRadius: PlombiProSpacing.borderRadiusLG,
      ),
      child: Padding(
        padding: PlombiProSpacing.cardPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activité récente',
              style: PlombiProTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            PlombiProSpacing.verticalMD,
            _ActivityItem(
              icon: Icons.description,
              color: PlombiProColors.success,
              title: 'Devis accepté',
              subtitle: 'Rénovation salle de bain - M. Dupont',
              time: 'Il y a 2h',
            ),
            _ActivityItem(
              icon: Icons.receipt,
              color: PlombiProColors.info,
              title: 'Facture payée',
              subtitle: 'Dépannage urgence - Mme Martin',
              time: 'Il y a 4h',
            ),
            _ActivityItem(
              icon: Icons.person_add,
              color: PlombiProColors.primaryBlue,
              title: 'Nouveau client',
              subtitle: 'M. Bernard',
              time: 'Hier',
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PlombiProSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(PlombiProSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: PlombiProSpacing.borderRadiusMD,
            ),
            child: Icon(icon, color: color, size: PlombiProSpacing.iconSM),
          ),
          PlombiProSpacing.horizontalMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PlombiProTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: PlombiProTextStyles.bodySmall.copyWith(
                    color: PlombiProColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: PlombiProTextStyles.bodySmall.copyWith(
              color: PlombiProColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick actions card
class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: PlombiProSpacing.elevationMD,
      shape: RoundedRectangleBorder(
        borderRadius: PlombiProSpacing.borderRadiusLG,
      ),
      child: Padding(
        padding: PlombiProSpacing.cardPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: PlombiProTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            PlombiProSpacing.verticalMD,
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: PlombiProSpacing.sm,
              mainAxisSpacing: PlombiProSpacing.sm,
              children: [
                _QuickActionButton(
                  icon: Icons.description,
                  label: 'Devis',
                  color: PlombiProColors.primaryBlue,
                  onTap: () {},
                ),
                _QuickActionButton(
                  icon: Icons.receipt,
                  label: 'Facture',
                  color: PlombiProColors.success,
                  onTap: () {},
                ),
                _QuickActionButton(
                  icon: Icons.event,
                  label: 'RDV',
                  color: PlombiProColors.info,
                  onTap: () {},
                ),
                _QuickActionButton(
                  icon: Icons.person_add,
                  label: 'Client',
                  color: PlombiProColors.secondaryOrange,
                  onTap: () {},
                ),
                _QuickActionButton(
                  icon: Icons.build,
                  label: 'Outils',
                  color: PlombiProColors.tertiaryTeal,
                  onTap: () {},
                ),
                _QuickActionButton(
                  icon: Icons.settings,
                  label: 'Paramètres',
                  color: PlombiProColors.gray600,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: PlombiProSpacing.borderRadiusMD,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: PlombiProSpacing.borderRadiusMD,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            PlombiProSpacing.verticalXS,
            Text(
              label,
              style: PlombiProTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick create menu
class _QuickCreateMenu extends StatelessWidget {
  const _QuickCreateMenu();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PlombiProSpacing.pagePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: PlombiProSpacing.md),
            decoration: BoxDecoration(
              color: PlombiProColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Créer un document',
            style: PlombiProTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          PlombiProSpacing.verticalLG,
          _QuickCreateItem(
            icon: Icons.description,
            title: 'Nouveau devis',
            subtitle: 'Créer un devis pour un client',
            color: PlombiProColors.primaryBlue,
            onTap: () {},
          ),
          _QuickCreateItem(
            icon: Icons.receipt,
            title: 'Nouvelle facture',
            subtitle: 'Facturer une intervention',
            color: PlombiProColors.success,
            onTap: () {},
          ),
          _QuickCreateItem(
            icon: Icons.event,
            title: 'Nouveau rendez-vous',
            subtitle: 'Planifier une intervention',
            color: PlombiProColors.info,
            onTap: () {},
          ),
          _QuickCreateItem(
            icon: Icons.person_add,
            title: 'Nouveau client',
            subtitle: 'Ajouter un client',
            color: PlombiProColors.secondaryOrange,
            onTap: () {},
          ),
          PlombiProSpacing.verticalMD,
        ],
      ),
    );
  }
}

class _QuickCreateItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickCreateItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: PlombiProSpacing.sm),
        padding: PlombiProSpacing.cardPadding,
        decoration: BoxDecoration(
          color: PlombiProColors.gray50,
          borderRadius: PlombiProSpacing.borderRadiusMD,
          border: Border.all(color: PlombiProColors.gray200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(PlombiProSpacing.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: PlombiProSpacing.borderRadiusMD,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            PlombiProSpacing.horizontalMD,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PlombiProTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: PlombiProTextStyles.bodySmall.copyWith(
                      color: PlombiProColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: PlombiProColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
