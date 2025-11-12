import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Added
import '../../models/product.dart';
import '../../services/invoice_calculator.dart';
import '../../services/supabase_service.dart';
import '../../widgets/app_drawer.dart';

class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key});

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await SupabaseService.fetchProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _filterProducts();
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

  void _filterProducts() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        final productName = product.name.toLowerCase();
        final productCategory = product.category?.toLowerCase() ?? '';
        return productName.contains(searchTerm) || productCategory.contains(searchTerm);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Produits'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchProducts,
                    child: _filteredProducts.isEmpty
                        ? const Center(child: Text('Aucun produit trouvé.'))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
                              return GridView.builder(
                                padding: const EdgeInsets.all(8.0),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: 0.8, // Adjust as needed
                                ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _filteredProducts[index];
                                  return _ProductCard(product: product);
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/products/new');
          if (result == true && mounted) {
            _fetchProducts();
          }
        },
        tooltip: 'Nouveau produit',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Rechercher un produit...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) {
      return 4; // Desktop
    } else if (width > 600) {
      return 3; // Tablet
    } else {
      return 2; // Mobile
    }
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for product image
            Container(
              height: 100,
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            Text(product.name, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
            Text(product.category ?? 'Général', style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(InvoiceCalculator.formatCurrency(product.unitPrice), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border, color: product.isFavorite ? Colors.red : null),
                  onPressed: () { /* TODO: Toggle favorite status */ },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
