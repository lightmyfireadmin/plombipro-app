import 'package:flutter/material.dart';
import '../../models/purchase.dart';
import '../../services/supabase_service.dart';
import '../../widgets/section_header.dart';

class PurchasesListPage extends StatefulWidget {
  const PurchasesListPage({super.key});

  @override
  State<PurchasesListPage> createState() => _PurchasesListPageState();
}

class _PurchasesListPageState extends State<PurchasesListPage> {
  bool _isLoading = true;
  List<Purchase> _purchases = [];

  @override
  void initState() {
    super.initState();
    _fetchPurchases();
  }

  Future<void> _fetchPurchases() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final purchases = await SupabaseService.getPurchases();
      if (mounted) {
        setState(() {
          _purchases = purchases;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des achats: ${e.toString()}")),
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
        title: const Text('Mes Achats'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPurchases,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Tous les achats'),
                          _buildPurchasesList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPurchasesList() {
    if (_purchases.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text('Aucun achat trouvé.')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _purchases.length,
      itemBuilder: (context, index) {
        final purchase = _purchases[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: Text(purchase.supplierName ?? 'Fournisseur inconnu'),
            subtitle: Text(purchase.invoiceNumber ?? 'N/A'),
            trailing: Text('${purchase.totalTtc} €'),
          ),
        );
      },
    );
  }
}
