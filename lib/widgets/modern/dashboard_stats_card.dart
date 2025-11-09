import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_spacing.dart';
import '../../config/plombipro_text_styles.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/quote_repository.dart';
import '../../repositories/appointment_repository.dart';

/// Modern dashboard stats card using Riverpod for state management
/// Demonstrates the new repository pattern and error handling
class DashboardStatsCard extends ConsumerWidget {
  const DashboardStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch multiple providers concurrently
    final totalRevenueAsync = ref.watch(totalRevenueProvider);
    final outstandingAsync = ref.watch(outstandingAmountProvider);
    final conversionRateAsync = ref.watch(quoteConversionRateProvider);
    final todayAppointmentsAsync = ref.watch(todayAppointmentsProvider);

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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(PlombiProSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: PlombiProColors.primaryGradient,
                    borderRadius: PlombiProSpacing.borderRadiusMD,
                  ),
                  child: Icon(
                    Icons.dashboard,
                    color: PlombiProColors.white,
                    size: PlombiProSpacing.iconMD,
                  ),
                ),
                PlombiProSpacing.horizontalMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tableau de bord',
                        style: PlombiProTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Aperçu de votre activité',
                        style: PlombiProTextStyles.bodySmall.copyWith(
                          color: PlombiProColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            PlombiProSpacing.verticalLG,
            Divider(color: PlombiProColors.gray300),
            PlombiProSpacing.verticalLG,

            // Stats Grid
            Row(
              children: [
                // Revenue
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    label: 'Chiffre d\'affaires',
                    valueAsync: totalRevenueAsync,
                    icon: Icons.euro,
                    color: PlombiProColors.success,
                    formatter: (value) => '${value.toStringAsFixed(0)}€',
                  ),
                ),
                PlombiProSpacing.horizontalMD,
                // Outstanding
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    label: 'En attente',
                    valueAsync: outstandingAsync,
                    icon: Icons.pending,
                    color: PlombiProColors.warning,
                    formatter: (value) => '${value.toStringAsFixed(0)}€',
                  ),
                ),
              ],
            ),

            PlombiProSpacing.verticalMD,

            Row(
              children: [
                // Conversion Rate
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    label: 'Taux de conversion',
                    valueAsync: conversionRateAsync,
                    icon: Icons.trending_up,
                    color: PlombiProColors.info,
                    formatter: (value) => '${value.toStringAsFixed(1)}%',
                  ),
                ),
                PlombiProSpacing.horizontalMD,
                // Today's Appointments
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    label: 'RDV aujourd\'hui',
                    valueAsync: todayAppointmentsAsync.whenData(
                      (appointments) => appointments.length.toDouble(),
                    ),
                    icon: Icons.calendar_today,
                    color: PlombiProColors.primaryBlue,
                    formatter: (value) => value.toInt().toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required AsyncValue<double> valueAsync,
    required IconData icon,
    required Color color,
    required String Function(double) formatter,
  }) {
    return Container(
      padding: PlombiProSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: PlombiProSpacing.borderRadiusMD,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(PlombiProSpacing.xs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: PlombiProSpacing.borderRadiusSM,
            ),
            child: Icon(
              icon,
              color: color,
              size: PlombiProSpacing.iconSM,
            ),
          ),
          PlombiProSpacing.verticalSM,
          // Label
          Text(
            label,
            style: PlombiProTextStyles.bodySmall.copyWith(
              color: PlombiProColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          PlombiProSpacing.verticalXXS,
          // Value with loading/error states
          valueAsync.when(
            data: (value) => Text(
              formatter(value),
              style: PlombiProTextStyles.headlineSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            loading: () => SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            error: (error, stack) => Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: PlombiProSpacing.iconXS,
                  color: PlombiProColors.error,
                ),
                PlombiProSpacing.horizontalXXS,
                Text(
                  'Erreur',
                  style: PlombiProTextStyles.bodySmall.copyWith(
                    color: PlombiProColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Example of using the clients list with Riverpod
class ClientsListExample extends ConsumerWidget {
  const ClientsListExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the clients provider - automatically rebuilds when data changes
    final clientsAsync = ref.watch(clientsNotifierProvider);

    return clientsAsync.when(
      // Data loaded successfully
      data: (clients) => ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return ListTile(
            title: Text(client.name),
            subtitle: Text(client.email),
            trailing: IconButton(
              icon: Icon(
                client.isFavorite ? Icons.star : Icons.star_border,
                color: client.isFavorite
                    ? PlombiProColors.premium
                    : PlombiProColors.gray400,
              ),
              onPressed: () {
                // Toggle favorite - automatically updates UI
                if (client.id != null) {
                  ref
                      .read(clientsNotifierProvider.notifier)
                      .toggleFavorite(client.id!, client);
                }
              },
            ),
          );
        },
      ),
      // Loading state
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      // Error state with user-friendly message
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: PlombiProColors.error,
            ),
            PlombiProSpacing.verticalMD,
            Text(
              'Une erreur s\'est produite',
              style: PlombiProTextStyles.titleMedium,
            ),
            PlombiProSpacing.verticalSM,
            Text(
              error.toString(),
              style: PlombiProTextStyles.bodySmall.copyWith(
                color: PlombiProColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            PlombiProSpacing.verticalLG,
            ElevatedButton.icon(
              onPressed: () {
                // Refresh the data
                ref.invalidate(clientsNotifierProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
