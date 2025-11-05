import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/supabase_service.dart';

class ScrapedCatalogPage extends StatefulWidget {
  final String source;

  const ScrapedCatalogPage({super.key, required this.source});

  @override
  State<ScrapedCatalogPage> createState() => _ScrapedCatalogPageState();
}

class _ScrapedCatalogPageState extends State<ScrapedCatalogPage> {
  bool _isLoading = true;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await SupabaseService.fetchProducts(source: widget.source);
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des produits: ${e.toString()}")),
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
        title: Text('Catalogue ${widget.source}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text(product.reference ?? 'N/A'),
                    trailing: Text('${product.sellingPriceHt} €'),
                    onTap: () {
                      // TODO: Show product details
                    },
                  ),
                );
              },
            ),
    );
  }
}
