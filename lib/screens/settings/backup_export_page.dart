import 'package:flutter/material.dart';

class BackupExportPage extends StatelessWidget {
  const BackupExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sauvegarde et Export'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () { /* TODO: Export all data as JSON */ },
              child: const Text('Exporter toutes les données (JSON)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () { /* TODO: Export clients as CSV */ },
              child: const Text('Exporter les clients (CSV)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () { /* TODO: Export invoices as CSV */ },
              child: const Text('Exporter les factures (CSV)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () { /* TODO: Export products as CSV */ },
              child: const Text('Exporter les produits (CSV)'),
            ),
          ],
        ),
      ),
    );
  }
}
