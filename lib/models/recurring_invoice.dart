class RecurringInvoice {
  final String? id;
  final String userId;
  final String clientId;
  final String templateName;
  final String? description;
  final String invoicePrefix;
  final int paymentTerms;
  final String? notes;
  final String? termsAndConditions;
  final String frequency; // 'daily', 'weekly', 'biweekly', 'monthly', 'quarterly', 'yearly'
  final int intervalCount;
  final DateTime startDate;
  final DateTime? endDate;
  final int generateDaysBefore;
  final bool autoSend;
  final bool autoRemind;
  final String status; // 'active', 'paused', 'completed', 'cancelled'
  final DateTime? lastGeneratedAt;
  final DateTime? nextGenerationDate;
  final double subtotalHT;
  final double totalTax;
  final double totalTTC;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RecurringInvoice({
    this.id,
    required this.userId,
    required this.clientId,
    required this.templateName,
    this.description,
    this.invoicePrefix = 'REC',
    this.paymentTerms = 30,
    this.notes,
    this.termsAndConditions,
    required this.frequency,
    this.intervalCount = 1,
    required this.startDate,
    this.endDate,
    this.generateDaysBefore = 5,
    this.autoSend = false,
    this.autoRemind = true,
    this.status = 'active',
    this.lastGeneratedAt,
    this.nextGenerationDate,
    this.subtotalHT = 0,
    this.totalTax = 0,
    this.totalTTC = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory RecurringInvoice.fromJson(Map<String, dynamic> json) {
    return RecurringInvoice(
      id: json['id'],
      userId: json['user_id'],
      clientId: json['client_id'],
      templateName: json['template_name'],
      description: json['description'],
      invoicePrefix: json['invoice_prefix'] ?? 'REC',
      paymentTerms: json['payment_terms'] ?? 30,
      notes: json['notes'],
      termsAndConditions: json['terms_and_conditions'],
      frequency: json['frequency'],
      intervalCount: json['interval_count'] ?? 1,
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      generateDaysBefore: json['generate_days_before'] ?? 5,
      autoSend: json['auto_send'] ?? false,
      autoRemind: json['auto_remind'] ?? true,
      status: json['status'] ?? 'active',
      lastGeneratedAt: json['last_generated_at'] != null
          ? DateTime.parse(json['last_generated_at'])
          : null,
      nextGenerationDate: json['next_generation_date'] != null
          ? DateTime.parse(json['next_generation_date'])
          : null,
      subtotalHT: (json['subtotal_ht'] as num?)?.toDouble() ?? 0,
      totalTax: (json['total_tax'] as num?)?.toDouble() ?? 0,
      totalTTC: (json['total_ttc'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'client_id': clientId,
      'template_name': templateName,
      'description': description,
      'invoice_prefix': invoicePrefix,
      'payment_terms': paymentTerms,
      'notes': notes,
      'terms_and_conditions': termsAndConditions,
      'frequency': frequency,
      'interval_count': intervalCount,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'generate_days_before': generateDaysBefore,
      'auto_send': autoSend,
      'auto_remind': autoRemind,
      'status': status,
      'last_generated_at': lastGeneratedAt?.toIso8601String(),
      'next_generation_date': nextGenerationDate?.toIso8601String().split('T')[0],
      'subtotal_ht': subtotalHT,
      'total_tax': totalTax,
      'total_ttc': totalTTC,
    };
  }

  /// Get frequency label in French
  String get frequencyLabel {
    switch (frequency) {
      case 'daily':
        return intervalCount > 1 ? 'Tous les $intervalCount jours' : 'Quotidien';
      case 'weekly':
        return intervalCount > 1 ? 'Toutes les $intervalCount semaines' : 'Hebdomadaire';
      case 'biweekly':
        return 'Bimensuel';
      case 'monthly':
        return intervalCount > 1 ? 'Tous les $intervalCount mois' : 'Mensuel';
      case 'quarterly':
        return intervalCount > 1 ? 'Tous les ${intervalCount * 3} mois' : 'Trimestriel';
      case 'yearly':
        return intervalCount > 1 ? 'Tous les $intervalCount ans' : 'Annuel';
      default:
        return frequency;
    }
  }

  /// Get status label in French
  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Actif';
      case 'paused':
        return 'En pause';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
}

class RecurringInvoiceItem {
  final String? id;
  final String recurringInvoiceId;
  final String? productId;
  final String description;
  final double quantity;
  final double unitPrice;
  final double taxRate;
  final double discountPercentage;

  RecurringInvoiceItem({
    this.id,
    required this.recurringInvoiceId,
    this.productId,
    required this.description,
    this.quantity = 1,
    required this.unitPrice,
    this.taxRate = 20.0,
    this.discountPercentage = 0,
  });

  factory RecurringInvoiceItem.fromJson(Map<String, dynamic> json) {
    return RecurringInvoiceItem(
      id: json['id'],
      recurringInvoiceId: json['recurring_invoice_id'],
      productId: json['product_id'],
      description: json['description'],
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 20.0,
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recurring_invoice_id': recurringInvoiceId,
      'product_id': productId,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'tax_rate': taxRate,
      'discount_percentage': discountPercentage,
    };
  }

  double get totalHT {
    return quantity * unitPrice * (1 - discountPercentage / 100);
  }

  double get totalTax {
    return totalHT * (taxRate / 100);
  }

  double get totalTTC {
    return totalHT + totalTax;
  }
}
