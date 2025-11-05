import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/supabase_service.dart';

class SupplierComparatorPage extends StatefulWidget {
  const SupplierComparatorPage({super.key});

  @override
  State<SupplierComparatorPage> createState() => _SupplierComparatorPageState();
}

class _SupplierComparatorPageState extends State<SupplierComparatorPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = false;

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // This is a placeholder for a more advanced search across multiple sources
      final personalCatalog = await SupabaseService.fetchProducts();
      final pointPCatalog = await SupabaseService.fetchProducts(source: 'pointp');
      final cedeoCatalog = await SupabaseService.fetchProducts(source: 'cedeo');

      final allProducts = [...personalCatalog, ...pointPCatalog, ...cedeoCatalog];

      setState(() {
        _products = allProducts.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de recherche: ${e.toString()}")),
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
        title: const Text('Comparateur Fournisseurs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher un produit',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchProducts(_searchController.text),
                ),
              ),
              onSubmitted: _searchProducts,
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Card(
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text(product.source ?? 'N/A'),
                          trailing: Text('${product.sellingPriceHt} €'),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
