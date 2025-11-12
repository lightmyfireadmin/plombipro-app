import 'client.dart';
import 'line_item.dart';

class Quote {
  final String? id;
  final String userId;
  final String quoteNumber;
  final String clientId;
  final DateTime date;
  final DateTime? expiryDate;
  final String status;
  final double totalHt;
  final double totalTva;
  final double totalTtc;
  final String? notes;
  final Client? client;
  final List<LineItem> items;

  // New fields for business logic
  final String? convertedToInvoiceId;
  final int? paymentTerms;
  final String? pdfUrl;
  final double? depositPercentage;
  final double? depositAmount;
  final String? signatureUrl;
  final DateTime? signedAt;

  Quote({
    this.id,
    required this.userId,
    required this.quoteNumber,
    required this.clientId,
    required this.date,
    this.expiryDate,
    this.status = 'draft',
    this.totalHt = 0,
    this.totalTva = 0,
    this.totalTtc = 0,
    this.items = const [],
    this.notes,
    this.client,
    this.convertedToInvoiceId,
    this.paymentTerms,
    this.pdfUrl,
    this.depositPercentage,
    this.depositAmount,
    this.signatureUrl,
    this.signedAt,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      userId: json['user_id'] ?? '',
      quoteNumber: json['quote_number'] ?? '',
      clientId: json['client_id'] ?? '',
      date: DateTime.parse(json['quote_date'] ?? DateTime.now().toIso8601String()),
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      status: json['status'] ?? 'draft',
      totalHt: (json['subtotal_ht'] as num?)?.toDouble() ?? 0,
      totalTva: (json['total_vat'] as num?)?.toDouble() ?? 0,
      totalTtc: (json['total_ttc'] as num?)?.toDouble() ?? 0,
      items: json['quote_items'] != null
          ? (json['quote_items'] as List).map((i) => LineItem.fromJson(i)).toList()
          : [],
      notes: json['notes'],
      client: json['clients'] != null ? Client.fromJson(json['clients']) : null,
      convertedToInvoiceId: json['converted_to_invoice_id'],
      paymentTerms: json['payment_terms'] as int?,
      pdfUrl: json['pdf_url'],
      depositPercentage: (json['deposit_percentage'] as num?)?.toDouble(),
      depositAmount: (json['deposit_amount'] as num?)?.toDouble(),
      signatureUrl: json['signature_url'],
      signedAt: json['signed_at'] != null ? DateTime.parse(json['signed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
      'user_id': userId,
        'quote_number': quoteNumber,
        'client_id': clientId,
        'quote_date': date.toIso8601String(),
        'expiry_date': expiryDate?.toIso8601String(),
        'status': status,
        'subtotal_ht': totalHt,
        'total_vat': totalTva,
        'total_ttc': totalTtc,
        'notes': notes,
        'converted_to_invoice_id': convertedToInvoiceId,
        'payment_terms': paymentTerms,
        'pdf_url': pdfUrl,
        'deposit_percentage': depositPercentage,
        'deposit_amount': depositAmount,
        'signature_url': signatureUrl,
        'signed_at': signedAt?.toIso8601String(),
      };
}

