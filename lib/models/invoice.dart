import 'client.dart';
import 'line_item.dart';

class Invoice {
  final String? id;
  final String userId;
  final String number;
  final String clientId;
  final DateTime date;
  final DateTime? dueDate;
  final String status;
  final String paymentStatus;
  final double totalHt;
  final double totalTva;
  final double totalTtc;
  final double amountPaid;
  final double balanceDue;
  final String? notes;
  final String? paymentMethod;
  final bool? isElectronic;
  final String? xmlUrl;
  final Client? client;
  final List<LineItem> items;

  // New fields for business logic
  final String? relatedQuoteId;
  final int? paymentTerms;
  final String? legalMentions;
  final String? pdfUrl;
  final DateTime? paidAt;

  Invoice({
    this.id,
    required this.userId,
    required this.number,
    required this.clientId,
    required this.date,
    this.dueDate,
    this.status = 'draft',
    this.paymentStatus = 'unpaid',
    this.totalHt = 0,
    this.totalTva = 0,
    this.totalTtc = 0,
    this.amountPaid = 0,
    this.balanceDue = 0,
    this.items = const [],
    this.notes,
    this.client,
    this.paymentMethod,
    this.isElectronic,
    this.xmlUrl,
    this.relatedQuoteId,
    this.paymentTerms,
    this.legalMentions,
    this.pdfUrl,
    this.paidAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      userId: json['user_id'] ?? '',
      number: json['invoice_number'] ?? '',
      clientId: json['client_id'] ?? '',
      date: DateTime.parse(json['invoice_date'] ?? DateTime.now().toIso8601String()),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      status: json['status'] ?? 'draft',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      totalHt: (json['subtotal_ht'] as num?)?.toDouble() ?? 0,
      totalTva: (json['total_vat'] as num?)?.toDouble() ?? 0,
      totalTtc: (json['total_ttc'] as num?)?.toDouble() ?? 0,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
      balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0,
      items: json['invoice_items'] != null
          ? (json['invoice_items'] as List).map((i) => LineItem.fromJson(i)).toList()
          : [],
      notes: json['notes'],
      paymentMethod: json['payment_method'],
      isElectronic: json['is_electronic'],
      xmlUrl: json['xml_url'],
      client: json['clients'] != null ? Client.fromJson(json['clients']) : null,
      relatedQuoteId: json['related_quote_id'],
      paymentTerms: json['payment_terms'] as int?,
      legalMentions: json['legal_mentions'],
      pdfUrl: json['pdf_url'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'invoice_number': number,
      'client_id': clientId,
      'invoice_date': date.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'subtotal_ht': totalHt,
      'total_vat': totalTva,
      'total_ttc': totalTtc,
      'amount_paid': amountPaid,
      'balance_due': balanceDue,
      'status': status,
      'payment_status': paymentStatus,
      'notes': notes,
      'payment_method': paymentMethod,
      'is_electronic': isElectronic,
      'xml_url': xmlUrl,
      // client and items are handled separately or not directly in invoice table
    };

    // Include id if it exists (for updates)
    if (id != null) {
      json['id'] = id;
    }

    return json;
  }

  Invoice copyWith({
    String? id,
    String? userId,
    String? number,
    String? clientId,
    DateTime? date,
    DateTime? dueDate,
    double? totalHt,
    double? totalTva,
    double? totalTtc,
    double? amountPaid,
    double? balanceDue,
    String? paymentStatus,
    String? notes,
    String? paymentMethod,
    bool? isElectronic,
    String? xmlUrl,
    Client? client,
    List<LineItem>? items,
    String? relatedQuoteId,
    int? paymentTerms,
    String? legalMentions,
    String? pdfUrl,
    DateTime? paidAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      number: number ?? this.number,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      totalHt: totalHt ?? this.totalHt,
      totalTva: totalTva ?? this.totalTva,
      totalTtc: totalTtc ?? this.totalTtc,
      amountPaid: amountPaid ?? this.amountPaid,
      balanceDue: balanceDue ?? this.balanceDue,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isElectronic: isElectronic ?? this.isElectronic,
      xmlUrl: xmlUrl ?? this.xmlUrl,
      client: client ?? this.client,
      items: items ?? this.items,
      relatedQuoteId: relatedQuoteId ?? this.relatedQuoteId,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      legalMentions: legalMentions ?? this.legalMentions,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
