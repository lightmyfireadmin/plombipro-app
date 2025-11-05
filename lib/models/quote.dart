import 'client.dart';
import 'line_item.dart';

class Quote {
  final String? id;
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

  Quote({
    this.id,
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
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
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
    );
  }

  Map<String, dynamic> toJson() => {
        'quote_number': quoteNumber,
        'client_id': clientId,
        'quote_date': date.toIso8601String(),
        'expiry_date': expiryDate?.toIso8601String(),
        'status': status,
        'total_ht': totalHt,
        'total_vat': totalTva,
        'total_ttc': totalTtc,
        'notes': notes,
      };
}

