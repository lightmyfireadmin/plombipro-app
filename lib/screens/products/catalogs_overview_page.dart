import 'package:flutter/material.dart';

class CatalogsOverviewPage extends StatelessWidget {
  const CatalogsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogues de Produits'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCatalogCard(context, 'Mon Catalogue', Icons.person, () {}),
          _buildCatalogCard(context, 'Point P', Icons.store, () {}),
          _buildCatalogCard(context, 'Cedeo', Icons.store, () {}),
          _buildCatalogCard(context, 'Favoris', Icons.favorite, () {}),
        ],
      ),
    );
  }

  Widget _buildCatalogCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0),
            const SizedBox(height: 16.0),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
