import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/repositories/base_repository.dart';
import '../core/utils/result.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';

part 'product_repository.g.dart';

/// Repository for product data operations
class ProductRepository extends BaseRepository {
  /// Fetch all products with optional filters
  Future<Result<List<Product>>> getProducts({
    String? category,
    bool? isFavorite,
    String? source,
  }) async {
    return execute(
      () => SupabaseService.fetchProducts(
        category: category,
        isFavorite: isFavorite,
        source: source,
      ),
      errorMessage: 'Impossible de récupérer les produits',
    );
  }

  /// Get a specific product by ID
  Future<Result<Product>> getProductById(String productId) async {
    return execute(
      () async {
        final product = await SupabaseService.getProductById(productId);
        if (product == null) {
          throw Exception('Product not found');
        }
        return product;
      },
      errorMessage: 'Impossible de récupérer le produit',
    );
  }

  /// Create a new product
  Future<Result<String>> createProduct(Product product) async {
    return execute(
      () => SupabaseService.createProduct(product),
      errorMessage: 'Impossible de créer le produit',
    );
  }

  /// Update an existing product
  Future<Result<void>> updateProduct(String productId, Product product) async {
    return execute(
      () => SupabaseService.updateProduct(productId, product),
      errorMessage: 'Impossible de mettre à jour le produit',
    );
  }

  /// Delete a product
  Future<Result<void>> deleteProduct(String productId) async {
    return execute(
      () => SupabaseService.deleteProduct(productId),
      errorMessage: 'Impossible de supprimer le produit',
    );
  }

  /// Fetch supplier products with filters
  Future<Result<List<Product>>> getSupplierProducts({
    required String supplier,
    String? searchQuery,
    String? category,
    int limit = 50,
    int offset = 0,
  }) async {
    return execute(
      () => SupabaseService.fetchSupplierProducts(
        supplier: supplier,
        searchQuery: searchQuery,
        category: category,
        limit: limit,
        offset: offset,
      ),
      errorMessage: 'Impossible de récupérer les produits fournisseurs',
    );
  }

  /// Get supplier categories
  Future<Result<List<String>>> getSupplierCategories(String supplier) async {
    return execute(
      () => SupabaseService.getSupplierCategories(supplier),
      errorMessage: 'Impossible de récupérer les catégories',
    );
  }

  /// Get favorite products
  Future<Result<List<Product>>> getFavoriteProducts() async {
    return execute(
      () => SupabaseService.fetchProducts(isFavorite: true),
      errorMessage: 'Impossible de récupérer les produits favoris',
    );
  }

  /// Get products by category
  Future<Result<List<Product>>> getProductsByCategory(String category) async {
    return execute(
      () => SupabaseService.fetchProducts(category: category),
      errorMessage: 'Impossible de filtrer les produits par catégorie',
    );
  }

  /// Search products by name or reference
  Future<Result<List<Product>>> searchProducts(String query) async {
    return execute(
      () async {
        final products = await SupabaseService.fetchProducts();
        final lowerQuery = query.toLowerCase();
        return products.where((product) {
          final name = product.name.toLowerCase();
          final ref = product.ref.toLowerCase();
          return name.contains(lowerQuery) || ref.contains(lowerQuery);
        }).toList();
      },
      errorMessage: 'Impossible de rechercher les produits',
    );
  }

  /// Get most used products
  Future<Result<List<Product>>> getMostUsedProducts({int limit = 10}) async {
    return execute(
      () async {
        final products = await SupabaseService.fetchProducts();
        products.sort((a, b) => b.usageCount.compareTo(a.usageCount));
        return products.take(limit).toList();
      },
      errorMessage: 'Impossible de récupérer les produits les plus utilisés',
    );
  }

  /// Toggle favorite status for a product
  Future<Result<void>> toggleFavorite(String productId, Product product) async {
    final updatedProduct = Product(
      id: product.id,
      userId: product.userId,
      ref: product.ref,
      name: product.name,
      description: product.description,
      priceBuy: product.priceBuy,
      unitPrice: product.unitPrice,
      unit: product.unit,
      photoUrl: product.photoUrl,
      category: product.category,
      supplier: product.supplier,
      isFavorite: !product.isFavorite,
      usageCount: product.usageCount,
      source: product.source,
    );

    return execute(
      () => SupabaseService.updateProduct(productId, updatedProduct),
      errorMessage: 'Impossible de mettre à jour les favoris',
    );
  }

  /// Increment usage count for a product
  Future<Result<void>> incrementUsageCount(
    String productId,
    Product product,
  ) async {
    final updatedProduct = Product(
      id: product.id,
      userId: product.userId,
      ref: product.ref,
      name: product.name,
      description: product.description,
      priceBuy: product.priceBuy,
      unitPrice: product.unitPrice,
      unit: product.unit,
      photoUrl: product.photoUrl,
      category: product.category,
      supplier: product.supplier,
      isFavorite: product.isFavorite,
      usageCount: product.usageCount + 1,
      source: product.source,
    );

    return execute(
      () => SupabaseService.updateProduct(productId, updatedProduct),
      errorMessage: 'Impossible de mettre à jour le compteur d\'utilisation',
    );
  }

  /// Get low stock products (if inventory management is added)
  Future<Result<List<Product>>> getLowStockProducts() async {
    return execute(
      () async {
        // Placeholder - would need stock field in Product model
        final products = await SupabaseService.fetchProducts();
        return products;
      },
      errorMessage: 'Impossible de récupérer les produits en rupture',
    );
  }
}

/// Provider for ProductRepository
@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  return ProductRepository();
}

/// Provider for products list
@riverpod
class ProductsNotifier extends _$ProductsNotifier {
  @override
  Future<List<Product>> build({
    String? category,
    bool? isFavorite,
    String? source,
  }) async {
    final repository = ref.watch(productRepositoryProvider);
    final result = await repository.getProducts(
      category: category,
      isFavorite: isFavorite,
      source: source,
    );
    return result.getOrElse(() => []);
  }

  /// Refresh products list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getProducts(
      category: category,
      isFavorite: isFavorite,
      source: source,
    );
    state = result.fold(
      onSuccess: (products) => AsyncValue.data(products),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  /// Add a new product
  Future<Result<String>> addProduct(Product product) async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.createProduct(product);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Update a product
  Future<Result<void>> updateProduct(String productId, Product product) async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.updateProduct(productId, product);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Delete a product
  Future<Result<void>> deleteProduct(String productId) async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.deleteProduct(productId);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Toggle favorite status
  Future<Result<void>> toggleFavorite(String productId, Product product) async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.toggleFavorite(productId, product);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }
}

/// Provider for supplier products
@riverpod
class SupplierProductsNotifier extends _$SupplierProductsNotifier {
  @override
  Future<List<Product>> build({
    required String supplier,
    String? searchQuery,
    String? category,
    int limit = 50,
    int offset = 0,
  }) async {
    final repository = ref.watch(productRepositoryProvider);
    final result = await repository.getSupplierProducts(
      supplier: supplier,
      searchQuery: searchQuery,
      category: category,
      limit: limit,
      offset: offset,
    );
    return result.getOrElse(() => []);
  }

  /// Refresh supplier products
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getSupplierProducts(
      supplier: supplier,
      searchQuery: searchQuery,
      category: category,
      limit: limit,
      offset: offset,
    );
    state = result.fold(
      onSuccess: (products) => AsyncValue.data(products),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }
}

/// Provider for supplier categories
@riverpod
Future<List<String>> supplierCategories(
  SupplierCategoriesRef ref,
  String supplier,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getSupplierCategories(supplier);
  return result.getOrElse(() => []);
}

/// Provider for favorite products
@riverpod
Future<List<Product>> favoriteProducts(FavoriteProductsRef ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getFavoriteProducts();
  return result.getOrElse(() => []);
}

/// Provider for most used products
@riverpod
Future<List<Product>> mostUsedProducts(
  MostUsedProductsRef ref, {
  int limit = 10,
}) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getMostUsedProducts(limit: limit);
  return result.getOrElse(() => []);
}

/// Provider for a specific product
@riverpod
Future<Product?> product(ProductRef ref, String productId) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProductById(productId);
  return result.dataOrNull;
}

/// Provider for products by category
@riverpod
Future<List<Product>> productsByCategory(
  ProductsByCategoryRef ref,
  String category,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProductsByCategory(category);
  return result.getOrElse(() => []);
}
