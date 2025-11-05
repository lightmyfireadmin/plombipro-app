import '../services/invoice_calculator.dart';

class LineItem {
  final String? productId;
  final String description;
  final double quantity;
  final double unitPrice;
  final int discountPercent;
  final double taxRate;

  double get lineTotal => InvoiceCalculator.calculateLineTotal(quantity, unitPrice, discountPercent);

  LineItem({
    this.productId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.discountPercent = 0,
    this.taxRate = 20.0, // Default TVA rate
  });

  LineItem copyWith({
    String? productId,
    String? description,
    double? quantity,
    double? unitPrice,
    int? discountPercent,
    double? taxRate,
  }) {
    return LineItem(
      productId: productId ?? this.productId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'description': description,
    'quantity': quantity,
    'unit_price': unitPrice,
    'discount_percent': discountPercent,
    'tax_rate': taxRate,
  };

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(
      productId: json['product_id'],
      description: json['description'] ?? '',
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      discountPercent: json['discount_percent'] as int? ?? 0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
