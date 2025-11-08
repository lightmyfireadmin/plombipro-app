import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:csv/csv.dart';
import '../../services/supabase_service.dart';

class BackupExportPage extends StatefulWidget {
  const BackupExportPage({super.key});

  @override
  State<BackupExportPage> createState() => _BackupExportPageState();
}

class _BackupExportPageState extends State<BackupExportPage> {
  bool _isExporting = false;

  Future<void> _exportAllDataAsJson() async {
    setState(() => _isExporting = true);

    try {
      // Fetch all data
      final clients = await SupabaseService.fetchClients();
      final invoices = await SupabaseService.fetchInvoices();
      final quotes = await SupabaseService.fetchQuotes();
      final products = await SupabaseService.fetchProducts();

      // Create JSON structure
      final jsonData = {
        'export_date': DateTime.now().toIso8601String(),
        'clients': clients.map((c) => c.toJson()).toList(),
        'invoices': invoices.map((i) => i.toJson()).toList(),
        'quotes': quotes.map((q) => q.toJson()).toList(),
        'products': products.map((p) => p.toJson()).toList(),
      };

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'plombipro_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(jsonData));

      // Open file
      if (mounted) {
        final result = await OpenFilex.open(file.path);
        _showResultMessage(result, file.path, 'JSON');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Erreur lors de l\'export JSON: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportClientsAsCsv() async {
    setState(() => _isExporting = true);

    try {
      final clients = await SupabaseService.fetchClients();

      // Create CSV
      final List<List<dynamic>> rows = [
        ['ID', 'Nom', 'Email', 'Téléphone', 'Adresse', 'Code Postal', 'Ville', 'Notes'],
      ];

      for (var client in clients) {
        rows.add([
          client.id ?? '',
          client.name,
          client.email ?? '',
          client.phone ?? '',
          client.address ?? '',
          client.postalCode ?? '',
          client.city ?? '',
          client.notes ?? '',
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'clients_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csv);

      // Open file
      if (mounted) {
        final result = await OpenFilex.open(file.path);
        _showResultMessage(result, file.path, 'CSV (${clients.length} clients)');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Erreur lors de l\'export des clients: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportInvoicesAsCsv() async {
    setState(() => _isExporting = true);

    try {
      final invoices = await SupabaseService.fetchInvoices();

      // Create CSV
      final List<List<dynamic>> rows = [
        ['Numéro', 'Client', 'Date', 'Échéance', 'Total HT', 'TVA', 'Total TTC', 'Statut', 'Méthode Paiement'],
      ];

      for (var invoice in invoices) {
        rows.add([
          invoice.number,
          invoice.client?.name ?? 'N/A',
          invoice.date.toIso8601String().split('T')[0],
          invoice.dueDate?.toIso8601String().split('T')[0] ?? '',
          invoice.totalHt.toStringAsFixed(2),
          invoice.totalTva.toStringAsFixed(2),
          invoice.totalTtc.toStringAsFixed(2),
          invoice.paymentStatus,
          invoice.paymentMethod ?? '',
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'factures_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csv);

      // Open file
      if (mounted) {
        final result = await OpenFilex.open(file.path);
        _showResultMessage(result, file.path, 'CSV (${invoices.length} factures)');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Erreur lors de l\'export des factures: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportProductsAsCsv() async {
    setState(() => _isExporting = true);

    try {
      final products = await SupabaseService.fetchProducts();

      // Create CSV
      final List<List<dynamic>> rows = [
        ['Nom', 'Description', 'Référence', 'Prix Unitaire', 'Unité', 'Catégorie', 'Fournisseur'],
      ];

      for (var product in products) {
        rows.add([
          product.name,
          product.description ?? '',
          product.reference ?? '',
          product.unitPrice.toStringAsFixed(2),
          product.unit ?? '',
          product.category ?? '',
          product.supplier ?? '',
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'produits_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csv);

      // Open file
      if (mounted) {
        final result = await OpenFilex.open(file.path);
        _showResultMessage(result, file.path, 'CSV (${products.length} produits)');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Erreur lors de l\'export des produits: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showResultMessage(OpenResult result, String filePath, String format) {
    if (result.type == ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export $format réussi!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (result.type == ResultType.noAppToOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fichier sauvegardé:\n$filePath'),
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fichier sauvegardé:\n$filePath'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

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
            const Text(
              'Exportez vos données pour la sauvegarde ou l\'analyse',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportAllDataAsJson,
              icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
              label: const Text('Exporter toutes les données (JSON)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportClientsAsCsv,
              icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.table_chart),
              label: const Text('Exporter les clients (CSV)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportInvoicesAsCsv,
              icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.receipt_long),
              label: const Text('Exporter les factures (CSV)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportProductsAsCsv,
              icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.inventory),
              label: const Text('Exporter les produits (CSV)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Information', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Les fichiers sont sauvegardés dans le dossier Documents de l\'application.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
