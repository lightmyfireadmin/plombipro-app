/// Model for invoice templates (Phase 11)
/// Allows creating reusable invoice templates for recurring billing
class InvoiceTemplate {
  final String? id;
  final String name;
  final String description;
  final List<Map<String, dynamic>> items;
  final String notes;
  final String paymentTerms;
  final double discountPercentage;
  final double taxRate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InvoiceTemplate({
    this.id,
    required this.name,
    this.description = '',
    required this.items,
    this.notes = '',
    this.paymentTerms = '',
    this.discountPercentage = 0.0,
    this.taxRate = 20.0,
    this.createdAt,
    this.updatedAt,
  });

  /// Calculate total HT (before tax)
  double calculateTotalHT() {
    double total = 0.0;
    for (final item in items) {
      final quantity = item['quantity'] as int;
      final unitPrice = item['unitPrice'] as double;
      total += quantity * unitPrice;
    }

    // Apply discount
    if (discountPercentage > 0) {
      total -= total * (discountPercentage / 100);
    }

    return total;
  }

  /// Calculate total TTC (with tax)
  double calculateTotalTTC() {
    final totalHT = calculateTotalHT();
    return totalHT + (totalHT * (taxRate / 100));
  }

  /// Create from JSON
  factory InvoiceTemplate.fromJson(Map<String, dynamic> json) {
    return InvoiceTemplate(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      notes: json['notes'] as String? ?? '',
      paymentTerms: json['payment_terms'] as String? ?? '',
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 20.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'description': description,
      'items': items,
      'notes': notes,
      'payment_terms': paymentTerms,
      'discount_percentage': discountPercentage,
      'tax_rate': taxRate,
    };

    if (id != null) {
      json['id'] = id!;
    }

    return json;
  }

  /// Create a copy with modified fields
  InvoiceTemplate copyWith({
    String? id,
    String? name,
    String? description,
    List<Map<String, dynamic>>? items,
    String? notes,
    String? paymentTerms,
    double? discountPercentage,
    double? taxRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      taxRate: taxRate ?? this.taxRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
