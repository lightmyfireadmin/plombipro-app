import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product.dart';
import '../../services/supabase_service.dart';

class ProductFormPage extends StatefulWidget {
  final String? productId;

  const ProductFormPage({super.key, this.productId});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditing => widget.productId != null;
  Product? _product;

  late final TextEditingController _refController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceBuyController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _unitController;
  late final TextEditingController _photoUrlController;
  late final TextEditingController _categoryController;
  late final TextEditingController _supplierController;

  bool _isFavorite = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _refController = TextEditingController();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceBuyController = TextEditingController();
    _unitPriceController = TextEditingController();
    _unitController = TextEditingController();
    _photoUrlController = TextEditingController();
    _categoryController = TextEditingController();
    _supplierController = TextEditingController();

    if (_isEditing) {
      _fetchProduct();
    }
  }

  Future<void> _fetchProduct() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final product = await SupabaseService.getProductById(widget.productId!);
      if (product != null) {
        setState(() {
          _product = product;
          _refController.text = _product!.ref ?? '';
          _nameController.text = _product!.name;
          _descriptionController.text = _product!.description ?? '';
          _priceBuyController.text = _product!.priceBuy?.toStringAsFixed(2) ?? '';
          _unitPriceController.text = _product!.unitPrice.toStringAsFixed(2);
          _unitController.text = _product!.unit ?? '';
          _photoUrlController.text = _product!.photoUrl ?? '';
          _categoryController.text = _product!.category ?? '';
          _supplierController.text = _product!.supplier ?? '';
          _isFavorite = _product!.isFavorite;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement du produit: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _refController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceBuyController.dispose();
    _unitPriceController.dispose();
    _unitController.dispose();
    _photoUrlController.dispose();
    _categoryController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isSaving = true; });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final productData = Product(
        id: _product?.id,
        userId: userId,
        ref: _refController.text.isEmpty ? null : _refController.text,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        priceBuy: double.tryParse(_priceBuyController.text),
        unitPrice: double.tryParse(_unitPriceController.text) ?? 0.0,
        unit: _unitController.text.isEmpty ? null : _unitController.text,
        photoUrl: _photoUrlController.text.isEmpty ? null : _photoUrlController.text,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
        supplier: _supplierController.text.isEmpty ? null : _supplierController.text,
        isFavorite: _isFavorite,
        usageCount: _product?.usageCount ?? 0,
      );

      if (_isEditing) {
        await SupabaseService.updateProduct(productData.id!, productData);
      } else {
        await SupabaseService.createProduct(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit ${_isEditing ? 'mis à jour' : 'créé'} avec succès!')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'enregistrement: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Éditer le produit' : 'Nouveau Produit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProduct,
              tooltip: 'Enregistrer',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom du produit'),
              validator: (value) => (value == null || value.isEmpty) ? 'Le nom est requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _refController,
              decoration: const InputDecoration(labelText: 'Référence'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceBuyController,
                    decoration: const InputDecoration(labelText: 'Prix d\'achat', suffixText: '€'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$'))],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitPriceController,
                    decoration: const InputDecoration(labelText: 'Prix de vente', suffixText: '€'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$'))],
                    validator: (value) => (value == null || value.isEmpty) ? 'Le prix de vente est requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Unité'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Catégorie'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _supplierController,
              decoration: const InputDecoration(labelText: 'Fournisseur'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _photoUrlController,
              decoration: const InputDecoration(labelText: 'URL Photo'),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Favori'),
              value: _isFavorite,
              onChanged: (value) => setState(() => _isFavorite = value!),
            ),
          ],
        ),
      ),
    );
  }
}
