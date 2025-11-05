import 'package:flutter/material.dart';
import 'stat_card.dart';

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        StatCard(
          title: 'CA du mois',
          value: '12,450€',
          color: Colors.blue,
        ),
        StatCard(
          title: 'Factures impayées',
          value: '3 (2,100€)',
          color: Colors.orange,
        ),
        StatCard(
          title: 'Devis en attente',
          value: '2',
          color: Colors.purple,
        ),
        StatCard(
          title: 'RDV aujourd\'hui',
          value: '1',
          color: Colors.green,
        ),
      ],
    );
  }
}