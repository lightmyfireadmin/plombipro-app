import 'package:flutter/material.dart';

class ImportClientsPage extends StatefulWidget {
  const ImportClientsPage({super.key});

  @override
  State<ImportClientsPage> createState() => _ImportClientsPageState();
}

class _ImportClientsPageState extends State<ImportClientsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importer des Clients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () { /* TODO: Upload CSV/Excel file */ },
              child: const Text('Télécharger un fichier (CSV/Excel)'),
            ),
            const SizedBox(height: 32),
            // Placeholder for field mapping UI
            const Text('Interface de mappage des champs'),
          ],
        ),
      ),
    );
  }
}
