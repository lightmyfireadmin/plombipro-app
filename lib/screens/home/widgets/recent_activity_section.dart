import 'package:flutter/material.dart';
import '../../../widgets/section_header.dart';
import 'recent_activity_card.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Activité récente'),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              RecentActivityCard(
                title: 'Devis #2024-001',
                subtitle: 'Client A',
                icon: Icons.description,
              ),
              RecentActivityCard(
                title: 'Facture #2024-001',
                subtitle: 'Client B',
                icon: Icons.receipt,
              ),
              RecentActivityCard(
                title: 'Nouveau Client',
                subtitle: 'Client C',
                icon: Icons.person_add,
              ),
              RecentActivityCard(
                title: 'Devis #2024-002',
                subtitle: 'Client D',
                icon: Icons.description,
              ),
            ],
          ),
        ),
      ],
    );
  }
}