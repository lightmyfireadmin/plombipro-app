import 'package:flutter/material.dart';
import 'action_button.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        ActionButton(
          label: '+ Nouveau devis',
          icon: Icons.add,
          onPressed: () {},
        ),
        ActionButton(
          label: '+ Nouvelle facture',
          icon: Icons.add,
          onPressed: () {},
        ),
        ActionButton(
          label: '📸 Scanner',
          icon: Icons.camera_alt,
          onPressed: () {},
        ),
        ActionButton(
          label: '📞 Contacter',
          icon: Icons.phone,
          onPressed: () {},
        ),
      ],
    );
  }
}