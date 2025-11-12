class Product {
  final String? id;
  final String userId;
  final String? ref;
  final String name;
  final String? description;
  final double? priceBuy;
  final double unitPrice; // price_sell in schema
  final String? unit;
  final List<String>? imageUrls; // Changed from photoUrl to support multiple images
  final String? category;
  final String? supplier;
  final bool isFavorite;
  final int usageCount;
  final String? source;

  String? get reference => ref;
  double get sellingPriceHt => unitPrice;

  // Backward compatibility getter - returns first image or null
  String? get photoUrl => imageUrls?.isNotEmpty == true ? imageUrls!.first : null;

  Product({
    this.id,
    required this.userId,
    this.ref,
    required this.name,
    this.description,
    this.priceBuy,
    required this.unitPrice,
    this.unit = 'unité',
    this.imageUrls,
    this.category,
    this.supplier,
    this.isFavorite = false,
    this.usageCount = 0,
    this.source,
  });

  Map<String, dynamic> toJson() => {
      'user_id': userId,
        'ref': ref,
        'name': name,
        'description': description,
        'price_buy': priceBuy,
        'price_sell': unitPrice,
        'unit': unit,
        'image_urls': imageUrls,
        'category': category,
        'supplier': supplier,
        'is_favorite': isFavorite,
        'usage_count': usageCount,
        'source': source,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle both image_urls (array) and photo_url (single string) for backward compatibility
    List<String>? images;
    if (json['image_urls'] != null) {
      images = (json['image_urls'] as List).cast<String>();
    } else if (json['photo_url'] != null) {
      images = [json['photo_url'] as String];
    }

    return Product(
      id: json['id'],
      userId: json['user_id'] ?? '',
      ref: json['ref'],
      name: json['name'] ?? '',
      description: json['description'],
      priceBuy: (json['price_buy'] as num?)?.toDouble(),
      unitPrice: (json['price_sell'] as num?)?.toDouble() ?? 0,
      unit: json['unit'],
      imageUrls: images,
      category: json['category'],
      supplier: json['supplier'],
      isFavorite: json['is_favorite'] as bool? ?? false,
      usageCount: json['usage_count'] as int? ?? 0,
      source: json['source'],
    );
  }

  /// Factory constructor for supplier_products table data
  factory Product.fromSupplierProductJson(Map<String, dynamic> json) {
    // Handle single image URL from supplier
    List<String>? images;
    if (json['image_url'] != null) {
      images = [json['image_url'] as String];
    }

    return Product(
      id: json['id'],
      userId: json['user_id'] ?? '',
      ref: json['reference'],
      name: json['name'] ?? '',
      description: json['description'],
      priceBuy: (json['price'] as num?)?.toDouble(),
      unitPrice: (json['price'] as num?)?.toDouble() ?? 0,
      unit: json['price_unit'] ?? 'unité',
      imageUrls: images,
      category: json['category'],
      supplier: json['supplier'],
      isFavorite: false,
      usageCount: 0,
      source: json['supplier'],
    );
  }

  Product copyWith({
    String? id,
    String? userId,
    String? ref,
    String? name,
    String? description,
    double? priceBuy,
    double? unitPrice,
    String? unit,
    List<String>? imageUrls,
    String? category,
    String? supplier,
    bool? isFavorite,
    int? usageCount,
    String? source,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ref: ref ?? this.ref,
      name: name ?? this.name,
      description: description ?? this.description,
      priceBuy: priceBuy ?? this.priceBuy,
      unitPrice: unitPrice ?? this.unitPrice,
      unit: unit ?? this.unit,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      supplier: supplier ?? this.supplier,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
      source: source ?? this.source,
    );
  }
}
