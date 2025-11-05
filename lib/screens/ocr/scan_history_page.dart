import 'package:flutter/material.dart';
import '../../models/scan.dart';
import '../../services/supabase_service.dart';
import '../../widgets/section_header.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  bool _isLoading = true;
  List<Scan> _scans = [];

  @override
  void initState() {
    super.initState();
    _fetchScans();
  }

  Future<void> _fetchScans() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final scans = await SupabaseService.getScanHistory();
      if (mounted) {
        setState(() {
          _scans = scans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement de l'historique des scans: ${e.toString()}")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Scans'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchScans,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Tous les scans'),
                          _buildScansList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildScansList() {
    if (_scans.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text('Aucun scan trouvé.')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _scans.length,
      itemBuilder: (context, index) {
        final scan = _scans[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.document_scanner),
            title: Text(scan.scanDate.toString()),
            subtitle: Text(scan.extractionStatus ?? 'N/A'),
            trailing: Image.network(scan.originalImageUrl ?? '', width: 50, height: 50, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
