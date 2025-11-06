import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outils'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Outils pour Plombiers',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Accédez à des outils professionnels conçus spécialement pour faciliter votre travail quotidien.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          _ToolCard(
            title: 'Calculateur Hydraulique',
            description: 'Calculez les débits, pertes de charge, et dimensionnement de tuyauterie en quelques secondes.',
            icon: Icons.calculate,
            color: Colors.blue,
            onTap: () {
              context.go('/hydraulic-calculator');
            },
          ),
          const SizedBox(height: 16),
          _ToolCard(
            title: 'Comparateur Fournisseurs',
            description: 'Comparez les prix et disponibilité des produits chez Point P, Cedeo, et autres fournisseurs.',
            icon: Icons.compare_arrows,
            color: Colors.orange,
            onTap: () {
              context.go('/supplier-comparator');
            },
          ),
          const SizedBox(height: 16),
          _ToolCard(
            title: 'Scanner OCR',
            description: 'Numérisez vos factures fournisseurs et importez automatiquement les données.',
            icon: Icons.qr_code_scanner,
            color: Colors.green,
            onTap: () {
              context.go('/scan-invoice');
            },
          ),
          const SizedBox(height: 16),
          _ToolCard(
            title: 'Catalogues',
            description: 'Parcourez les catalogues Point P et Cedeo directement dans l\'app.',
            icon: Icons.book,
            color: Colors.purple,
            onTap: () {
              context.go('/catalogs');
            },
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
