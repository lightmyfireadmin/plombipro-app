/// Product Category Model (Phase 12)
class ProductCategory {
  final String? id;
  final String name;
  final String? description;
  final String? icon; // Icon name or emoji
  final String? color; // Hex color code
  final int? sortOrder;
  final DateTime? createdAt;

  ProductCategory({
    this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.sortOrder,
    this.createdAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      sortOrder: json['sort_order'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
    };
  }

  ProductCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Product Tag Model (Phase 12)
class ProductTag {
  final String? id;
  final String name;
  final String? color;
  final DateTime? createdAt;

  ProductTag({
    this.id,
    required this.name,
    this.color,
    this.createdAt,
  });

  factory ProductTag.fromJson(Map<String, dynamic> json) {
    return ProductTag(
      id: json['id'] as String?,
      name: json['name'] as String,
      color: json['color'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (color != null) 'color': color,
    };
  }
}

/// Default categories for PlombiPro
class DefaultCategories {
  static List<ProductCategory> get all => [
        ProductCategory(
          name: 'Plomberie',
          description: 'Tuyaux, raccords, robinetterie',
          icon: '🔧',
          color: '#2196F3',
          sortOrder: 1,
        ),
        ProductCategory(
          name: 'Chauffage',
          description: 'Chaudières, radiateurs, thermostats',
          icon: '🔥',
          color: '#FF5722',
          sortOrder: 2,
        ),
        ProductCategory(
          name: 'Sanitaire',
          description: 'Lavabos, douches, WC',
          icon: '🚿',
          color: '#00BCD4',
          sortOrder: 3,
        ),
        ProductCategory(
          name: 'Électricité',
          description: 'Câbles, prises, interrupteurs',
          icon: '⚡',
          color: '#FFC107',
          sortOrder: 4,
        ),
        ProductCategory(
          name: 'Outillage',
          description: 'Outils et équipements',
          icon: '🔨',
          color: '#9E9E9E',
          sortOrder: 5,
        ),
        ProductCategory(
          name: 'Pièces détachées',
          description: 'Joints, vis, accessoires',
          icon: '⚙️',
          color: '#607D8B',
          sortOrder: 6,
        ),
        ProductCategory(
          name: 'Autre',
          description: 'Autres produits',
          icon: '📦',
          color: '#795548',
          sortOrder: 99,
        ),
      ];

  static List<String> get tagSuggestions => [
        'Urgence',
        'Stock',
        'Promo',
        'Nouveau',
        'Professionnel',
        'Grand public',
        'Écologique',
        'Économique',
        'Premium',
        'Garanti',
      ];
}
