class Product {
  final String? id;
  final String? ref;
  final String name;
  final String? description;
  final double? priceBuy;
  final double unitPrice; // price_sell in schema
  final String? unit;
  final String? photoUrl;
  final String? category;
  final String? supplier;
  final bool isFavorite;
  final int usageCount;
  final String? source;

  String? get reference => ref;
  double get sellingPriceHt => unitPrice;

  Product({
    this.id,
    this.ref,
    required this.name,
    this.description,
    this.priceBuy,
    required this.unitPrice,
    this.unit = 'unité',
    this.photoUrl,
    this.category,
    this.supplier,
    this.isFavorite = false,
    this.usageCount = 0,
    this.source,
  });

  Map<String, dynamic> toJson() => {
        'ref': ref,
        'name': name,
        'description': description,
        'price_buy': priceBuy,
        'price_sell': unitPrice,
        'unit': unit,
        'photo_url': photoUrl,
        'category': category,
        'supplier': supplier,
        'is_favorite': isFavorite,
        'usage_count': usageCount,
        'source': source,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      ref: json['ref'],
      name: json['name'] ?? '',
      description: json['description'],
      priceBuy: (json['price_buy'] as num?)?.toDouble(),
      unitPrice: (json['price_sell'] as num?)?.toDouble() ?? 0,
      unit: json['unit'],
      photoUrl: json['photo_url'],
      category: json['category'],
      supplier: json['supplier'],
      isFavorite: json['is_favorite'] as bool? ?? false,
      usageCount: json['usage_count'] as int? ?? 0,
      source: json['source'],
    );
  }

  Product copyWith({
    String? id,
    String? ref,
    String? name,
    String? description,
    double? priceBuy,
    double? unitPrice,
    String? unit,
    String? photoUrl,
    String? category,
    String? supplier,
    bool? isFavorite,
    int? usageCount,
    String? source,
  }) {
    return Product(
      id: id ?? this.id,
      ref: ref ?? this.ref,
      name: name ?? this.name,
      description: description ?? this.description,
      priceBuy: priceBuy ?? this.priceBuy,
      unitPrice: unitPrice ?? this.unitPrice,
      unit: unit ?? this.unit,
      photoUrl: photoUrl ?? this.photoUrl,
      category: category ?? this.category,
      supplier: supplier ?? this.supplier,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
      source: source ?? this.source,
    );
  }
}
