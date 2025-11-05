# PLOMBIPRO - PART 3: CUSTOM FLUTTER FUNCTIONS, APIs & LIBRARY CALLS

## 🎯 FLUTTER CUSTOM FUNCTIONS

### 1. Invoice Calculation Service (lib/services/invoice_calculator.dart)

```dart
import 'package:intl/intl.dart';

class InvoiceCalculator {
  
  /// Calculate line item total: qty × price × (1 - discount%)
  static double calculateLineTotal({
    required double quantity,
    required double unitPrice,
    int discountPercent = 0,
  }) {
    final discountFactor = 1 - (discountPercent / 100);
    return (quantity * unitPrice * discountFactor * 100).round() / 100;
  }

  /// Calculate subtotal (sum of all line items)
  static double calculateSubtotal(List<LineItem> items) {
    return items.fold(
      0.0,
      (sum, item) => sum + calculateLineTotal(
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        discountPercent: item.discountPercent,
      ),
    );
  }

  /// Calculate VAT (TVA)
  static double calculateVAT({
    required double subtotal,
    required double tvaRate,
  }) {
    return (subtotal * (tvaRate / 100) * 100).round() / 100;
  }

  /// Calculate total with VAT (HT + TVA = TTC)
  static Map<String, double> calculateTotals({
    required List<LineItem> items,
    required double tvaRate,
  }) {
    final ht = calculateSubtotal(items);
    final tva = calculateVAT(subtotal: ht, tvaRate: tvaRate);
    final ttc = (ht + tva * 100).round() / 100;

    return {
      'ht': ht,
      'tva': tva,
      'ttc': ttc,
    };
  }

  /// Calculate deposit (acompte)
  static double calculateDeposit({
    required double total,
    required int depositPercent,
  }) {
    return (total * (depositPercent / 100) * 100).round() / 100;
  }

  /// Check if invoice is overdue
  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  /// Days until due (negative = already overdue)
  static int daysUntilDue(DateTime dueDate) {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Generate invoice number (FAC-YYYY-NNN format)
  static String generateInvoiceNumber({
    required int sequenceNumber,
    required int year,
  }) {
    return 'FAC-$year-${sequenceNumber.toString().padLeft(3, '0')}';
  }

  /// Generate quote number (DEV-YYYY-NNN format)
  static String generateQuoteNumber({
    required int sequenceNumber,
    required int year,
  }) {
    return 'DEV-$year-${sequenceNumber.toString().padLeft(3, '0')}';
  }

  /// Format currency (1234.56 → "1 234,56€")
  static String formatCurrency(double amount, {String locale = 'fr_FR'}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '€',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format date to French format (15/01/2025)
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'fr_FR');
    return formatter.format(date);
  }

  /// Parse currency string to double ("1 234,56€" → 1234.56)
  static double parseCurrency(String value) {
    return double.parse(value
        .replaceAll('€', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim());
  }
}

class LineItem {
  final String? productId;
  final String description;
  final double quantity;
  final double unitPrice;
  final int discountPercent;

  double get lineTotal => InvoiceCalculator.calculateLineTotal(
    quantity: quantity,
    unitPrice: unitPrice,
    discountPercent: discountPercent,
  );

  LineItem({
    this.productId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.discountPercent = 0,
  });

  LineItem copyWith({
    String? productId,
    String? description,
    double? quantity,
    double? unitPrice,
    int? discountPercent,
  }) {
    return LineItem(
      productId: productId ?? this.productId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'description': description,
    'quantity': quantity,
    'unit_price': unitPrice,
    'discount_percent': discountPercent,
  };

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(
      productId: json['product_id'],
      description: json['description'] ?? '',
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      discountPercent: json['discount_percent'] as int? ?? 0,
    );
  }
}
```

---

### 2. PDF Generation Service (lib/services/pdf_generator.dart)

```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:typed_data';

class PdfGenerator {
  
  /// Generate quote PDF
  static Future<Uint8List> generateQuotePdf({
    required String quoteNumber,
    required DateTime issueDate,
    required DateTime? validUntil,
    required String clientName,
    required String clientEmail,
    required String clientPhone,
    required String clientAddress,
    required List<LineItem> items,
    required double totalHt,
    required double totalTva,
    required double totalTtc,
    required double tvaRate,
    required String companyName,
    required String companySiret,
    required String companyAddress,
    required String companyPhone,
    required String companyEmail,
    required String? logoBase64,
  }) async {
    
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // ===== HEADER =====
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    companyName,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(companyAddress, style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('SIRET: $companySiret', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Tél: $companyPhone', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Email: $companyEmail', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              if (logoBase64 != null)
                pw.Image(
                  pw.MemoryImage(
                    _decodeBase64Image(logoBase64),
                  ),
                  width: 100,
                  height: 100,
                ),
            ],
          ),
          pw.SizedBox(height: 30),

          // ===== TITLE =====
          pw.Center(
            child: pw.Text(
              'DEVIS',
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // ===== INFO SECTION =====
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Devis n°: $quoteNumber', style: const pw.TextStyle(fontSize: 11)),
                  pw.Text('Date: ${_formatDate(issueDate)}', style: const pw.TextStyle(fontSize: 11)),
                  if (validUntil != null)
                    pw.Text('Valide jusqu\'au: ${_formatDate(validUntil)}', style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Client:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text(clientName, style: const pw.TextStyle(fontSize: 11)),
                  pw.Text(clientEmail, style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(clientPhone, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // ===== ITEMS TABLE =====
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            headerHeight: 25,
            cellHeight: 40,
            columnWidths: {
              0: const pw.FlexColumnWidth(3),  // Description
              1: const pw.FlexColumnWidth(1),  // Qty
              2: const pw.FlexColumnWidth(1.5),// Price
              3: const pw.FlexColumnWidth(1),  // Discount
              4: const pw.FlexColumnWidth(1.5),// Total
            },
            headers: ['Description', 'Qté', 'P.U.', 'Remise', 'Total'],
            data: items.map((item) => [
              item.description,
              item.quantity.toStringAsFixed(2),
              '${item.unitPrice.toStringAsFixed(2)}€',
              '${item.discountPercent}%',
              '${item.lineTotal.toStringAsFixed(2)}€',
            ]).toList(),
          ),
          pw.SizedBox(height: 20),

          // ===== TOTALS SECTION =====
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 200,
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total HT:', style: const pw.TextStyle(fontSize: 11)),
                      pw.Text('${totalHt.toStringAsFixed(2)}€', style: const pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('TVA (${tvaRate.toStringAsFixed(1)}%):', style: const pw.TextStyle(fontSize: 11)),
                      pw.Text('${totalTva.toStringAsFixed(2)}€', style: const pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total TTC:',
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '${totalTtc.toStringAsFixed(2)}€',
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 40),

          // ===== FOOTER =====
          pw.Center(
            child: pw.Text(
              'Merci pour votre confiance!',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static String _formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'fr_FR');
    return formatter.format(date);
  }

  static Uint8List _decodeBase64Image(String base64) {
    return Uint8List.fromList(base64Decode(base64));
  }
}
```

---

### 3. Supabase Service (lib/services/supabase_service.dart)

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ===== AUTHENTICATION =====
  
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String companyName,
    required String siret,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create profile
        await _client.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'company_name': companyName,
          'siret': siret,
        });
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ===== QUOTES CRUD =====

  static Future<List<Quote>> fetchQuotes() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('quotes')
          .select('''
            *,
            quote_items(*),
            clients(name, email)
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Quote.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Quote?> fetchQuoteById(String quoteId) async {
    try {
      final response = await _client
          .from('quotes')
          .select('*,quote_items(*)')
          .eq('id', quoteId)
          .single();

      return Quote.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<String> createQuote(Quote quote) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('quotes').insert({
        ...quote.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateQuote(String quoteId, Quote quote) async {
    try {
      await _client.from('quotes').update(quote.toJson()).eq('id', quoteId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteQuote(String quoteId) async {
    try {
      await _client.from('quotes').delete().eq('id', quoteId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== LINE ITEMS CRUD =====

  static Future<void> createLineItems(String quoteId, List<LineItem> items) async {
    try {
      for (var item in items) {
        await _client.from('quote_items').insert({
          'quote_id': quoteId,
          ...item.toJson(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteLineItem(String itemId) async {
    try {
      await _client.from('quote_items').delete().eq('id', itemId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== CLIENTS CRUD =====

  static Future<List<Client>> fetchClients() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('clients')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Client.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> createClient(Client client) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('clients').insert({
        ...client.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  // ===== PRODUCTS CRUD =====

  static Future<List<Product>> fetchProducts({String? category}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      var query = _client
          .from('products')
          .select('*')
          .eq('user_id', user.id);

      if (category != null) {
        query = query.eq('category', category);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ===== REAL-TIME SUBSCRIPTIONS =====

  static Stream<List<Quote>> streamQuotes() {
    final user = _client.auth.currentUser;
    if (user == null) return const Stream.empty();

    return _client
        .from('quotes')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .map((items) => (items as List)
            .map((item) => Quote.fromJson(item as Map<String, dynamic>))
            .toList());
  }
}

// Model classes
class Quote {
  final String? id;
  final String quoteNumber;
  final String clientId;
  final DateTime issueDate;
  final DateTime? validUntil;
  final String status; // draft, sent, accepted, rejected, invoiced
  final double totalHt;
  final double totalTva;
  final double totalTtc;
  final double tvaRate;
  final List<LineItem> items;
  final String? notes;

  Quote({
    this.id,
    required this.quoteNumber,
    required this.clientId,
    required this.issueDate,
    this.validUntil,
    this.status = 'draft',
    this.totalHt = 0,
    this.totalTva = 0,
    this.totalTtc = 0,
    this.tvaRate = 20,
    this.items = const [],
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'quote_number': quoteNumber,
    'client_id': clientId,
    'issue_date': issueDate.toIso8601String(),
    'valid_until': validUntil?.toIso8601String(),
    'status': status,
    'total_ht': totalHt,
    'total_tva': totalTva,
    'total_ttc': totalTtc,
    'tva_rate': tvaRate,
    'notes': notes,
  };

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      quoteNumber: json['quote_number'] ?? '',
      clientId: json['client_id'] ?? '',
      issueDate: DateTime.parse(json['issue_date'] ?? DateTime.now().toIso8601String()),
      validUntil: json['valid_until'] != null ? DateTime.parse(json['valid_until']) : null,
      status: json['status'] ?? 'draft',
      totalHt: (json['total_ht'] as num?)?.toDouble() ?? 0,
      totalTva: (json['total_tva'] as num?)?.toDouble() ?? 0,
      totalTtc: (json['total_ttc'] as num?)?.toDouble() ?? 0,
      tvaRate: (json['tva_rate'] as num?)?.toDouble() ?? 20,
      items: json['quote_items'] != null
          ? (json['quote_items'] as List).map((i) => LineItem.fromJson(i)).toList()
          : [],
      notes: json['notes'],
    );
  }
}

class Client {
  final String? id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final List<String>? tags;

  Client({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.tags,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
    'tags': tags,
  };

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      tags: (json['tags'] as List?)?.cast<String>(),
    );
  }
}

class Product {
  final String? id;
  final String name;
  final double unitPrice;
  final String? category;
  final int quantity;
  final bool isFavorite;

  Product({
    this.id,
    required this.name,
    required this.unitPrice,
    this.category,
    this.quantity = 0,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      category: json['category'],
      quantity: json['quantity_in_stock'] as int? ?? 0,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }
}
```

---

### 4. OCR Processing Service (lib/services/ocr_service.dart)

```dart
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class OcrService {
  static final _supabase = Supabase.instance.client;
  static const String _cloudFunctionUrl = 'YOUR_CLOUD_FUNCTION_URL/ocr_process_invoice';

  static Future<OcrResult?> scanInvoice(XFile imageFile) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Call Cloud Function
      final response = await _supabase.functions.invoke(
        'ocr_process_invoice',
        body: {'image_base64': base64Image},
      );

      if (response['success'] == true) {
        return OcrResult.fromJson(response['result']);
      } else {
        throw Exception(response['error'] ?? 'OCR failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> saveOcrScan(OcrResult scan, String userId) async {
    try {
      await _supabase.from('scans').insert({
        'user_id': userId,
        'image_url': scan.imageUrl,
        'ocr_text': scan.rawText,
        'parsed_supplier': scan.supplier,
        'parsed_amount': scan.amount,
        'parsed_items': scan.items,
        'confidence_score': scan.confidence,
        'status': 'pending',
      });
    } catch (e) {
      rethrow;
    }
  }
}

class OcrResult {
  final String rawText;
  final String imageUrl;
  final String supplier;
  final double amount;
  final List<Map<String, dynamic>> items;
  final double confidence;

  OcrResult({
    required this.rawText,
    required this.imageUrl,
    required this.supplier,
    required this.amount,
    required this.items,
    required this.confidence,
  });

  bool get isHighConfidence => confidence >= 0.85;
  bool get isMediumConfidence => confidence >= 0.65;
  bool get isLowConfidence => confidence < 0.65;

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      rawText: json['raw_text'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      supplier: json['supplier'] as String? ?? 'Unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      items: List<Map<String, dynamic>>.from(json['items'] as List? ?? []),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
    );
  }
}
```

---

### 5. Stripe Payment Service (lib/services/stripe_service.dart)

```dart
import 'package:stripe_flutter/stripe_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StripePaymentService {
  static final _supabase = Supabase.instance.client;

  static Future<bool> initializeStripe() async {
    try {
      Stripe.publishableKey = 'pk_live_YOUR_PUBLISHABLE_KEY';
      await Stripe.instance.applySettings();
      return true;
    } catch (e) {
      print('Stripe init error: $e');
      return false;
    }
  }

  static Future<PaymentResult> processPayment({
    required double amount,
    required String invoiceId,
    required String clientEmail,
    String currency = 'eur',
  }) async {
    try {
      // Create payment intent via Cloud Function
      final response = await _supabase.functions.invoke(
        'create_payment_intent',
        body: {
          'amount': (amount * 100).toInt(), // Convert to cents
          'currency': currency,
          'invoice_id': invoiceId,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Payment intent creation failed');
      }

      final clientSecret = response['client_secret'] as String;

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'PlombiPro',
          style: ThemeMode.light,
          googlePay: const PaymentSheetGooglePay(
            enabled: true,
            currencyCode: 'EUR',
          ),
          applePay: const PaymentSheetApplePay(enabled: true),
          appearance: const PaymentSheetAppearanceParams(
            colors: PaymentSheetAppearanceColorsParams(
              primary: Color(0xFF1976D2), // French blue
            ),
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful
      return PaymentResult(
        success: true,
        message: 'Paiement réussi',
        transactionId: response['payment_intent_id'],
      );
    } on StripeException catch (e) {
      return PaymentResult(
        success: false,
        message: e.error.localizedMessage ?? 'Erreur de paiement',
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  static Future<bool> refundPayment(String paymentId) async {
    try {
      final response = await _supabase.functions.invoke(
        'refund_payment',
        body: {'payment_id': paymentId},
      );

      return response['success'] == true;
    } catch (e) {
      print('Refund error: $e');
      return false;
    }
  }
}

class PaymentResult {
  final bool success;
  final String message;
  final String? transactionId;

  PaymentResult({
    required this.success,
    required this.message,
    this.transactionId,
  });
}
```

---

### 6. Email Service (lib/services/email_service.dart)

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class EmailService {
  static final _supabase = Supabase.instance.client;

  static Future<bool> sendQuoteEmail({
    required String clientEmail,
    required String quoteNumber,
    required double amount,
    required DateTime validUntil,
    required String companyName,
    Uint8List? pdfBytes,
  }) async {
    try {
      final pdfBase64 = pdfBytes != null ? base64Encode(pdfBytes) : null;

      final response = await _supabase.functions.invoke(
        'send_email_notification',
        body: {
          'to': clientEmail,
          'subject': 'Devis $quoteNumber',
          'template': 'quote_sent',
          'context': {
            'quote_number': quoteNumber,
            'amount': amount,
            'valid_until': validUntil.toString().split(' ')[0],
            'company_name': companyName,
          },
          'pdf_base64': pdfBase64,
          'filename': 'devis_$quoteNumber.pdf',
        },
      );

      return response['success'] == true;
    } catch (e) {
      print('Email error: $e');
      return false;
    }
  }

  static Future<bool> sendInvoiceEmail({
    required String clientEmail,
    required String invoiceNumber,
    required double amount,
    required String companyName,
    Uint8List? pdfBytes,
  }) async {
    try {
      final pdfBase64 = pdfBytes != null ? base64Encode(pdfBytes) : null;

      final response = await _supabase.functions.invoke(
        'send_email_notification',
        body: {
          'to': clientEmail,
          'subject': 'Facture $invoiceNumber',
          'template': 'invoice_sent',
          'context': {
            'invoice_number': invoiceNumber,
            'amount': amount,
            'company_name': companyName,
          },
          'pdf_base64': pdfBase64,
          'filename': 'facture_$invoiceNumber.pdf',
        },
      );

      return response['success'] == true;
    } catch (e) {
      print('Email error: $e');
      return false;
    }
  }

  static Future<bool> sendPaymentReminder({
    required String clientEmail,
    required String invoiceNumber,
    required double amount,
    required DateTime dueDate,
    required String companyName,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send_email_notification',
        body: {
          'to': clientEmail,
          'subject': 'Rappel: Facture $invoiceNumber en attente',
          'template': 'payment_reminder',
          'context': {
            'invoice_number': invoiceNumber,
            'amount': amount,
            'due_date': dueDate.toString().split(' ')[0],
            'company_name': companyName,
          },
        },
      );

      return response['success'] == true;
    } catch (e) {
      print('Email error: $e');
      return false;
    }
  }
}
```

---

## 🐛 TROUBLESHOOTING GUIDE

### Common Issues & Solutions

**Issue 1: Supabase Connection Timeout**
```dart
// ❌ WRONG: No error handling
final data = await _supabase.from('quotes').select('*').execute();

// ✅ CORRECT: With timeout and retry
Future<List<Quote>> fetchQuotesWithRetry() async {
  int retries = 3;
  
  while (retries > 0) {
    try {
      return await Future.timeout(
        Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Connection timeout'),
      ).then((_) => fetchQuotes());
    } catch (e) {
      retries--;
      if (retries == 0) rethrow;
      await Future.delayed(Duration(seconds: 2)); // Backoff
    }
  }
  
  throw Exception('Failed after retries');
}
```

**Issue 2: PDF Generation Out of Memory**
```dart
// ❌ WRONG: Loading entire PDF into memory
final pdfBytes = await pdf.save();

// ✅ CORRECT: Stream large PDFs
Future<File> generateQuotePdfToFile(Quote quote) async {
  final pdf = pw.Document();
  // ... build pages ...
  
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/quote_${quote.id}.pdf');
  
  await file.writeAsBytes(await pdf.save());
  return file;
}
```

**Issue 3: OCR Low Confidence**
```dart
// Log OCR confidence for debugging
if (ocrResult.confidence < 0.65) {
  print('LOW OCR CONFIDENCE: ${ocrResult.confidence}');
  print('Raw text: ${ocrResult.rawText.substring(0, 200)}...');
  
  // Allow user manual override
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Faible confiance OCR (${(ocrResult.confidence * 100).toStringAsFixed(0)}%)'),
      content: Text('Vérifiez les données extraites'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Modifier')),
        TextButton(onPressed: () => _acceptOcrData(ocrResult), child: Text('Accepter')),
      ],
    ),
  );
}
```

**Issue 4: Stripe Payment Sheet Not Showing**
```dart
// ❌ WRONG: Missing initialization
await Stripe.instance.presentPaymentSheet();

// ✅ CORRECT: Full initialization before presenting
Future<void> _initiatePayment() async {
  try {
    // 1. Create payment intent
    final intentResponse = await _supabase.functions.invoke('create_payment_intent', body: {...});
    
    // 2. Initialize payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: intentResponse['client_secret'],
        merchantDisplayName: 'PlombiPro',
      ),
    );
    
    // 3. Present sheet
    await Stripe.instance.presentPaymentSheet();
    
  } catch (e) {
    print('Payment error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: ${e.toString()}')),
    );
  }
}
```

**Issue 5: Image Picker Permission Denied**
```dart
// ❌ WRONG: No permission handling
final image = await ImagePicker().pickImage(source: ImageSource.camera);

// ✅ CORRECT: Check permissions first
import 'package:permission_handler/permission_handler.dart';

Future<XFile?> pickImageWithPermission() async {
  final status = await Permission.camera.request();
  
  if (status.isDenied) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Caméra non autorisée')),
    );
    return null;
  }
  
  if (status.isPermanentlyDenied) {
    openAppSettings();
    return null;
  }
  
  return await ImagePicker().pickImage(source: ImageSource.camera);
}
```

---

**Ready for Part 4: iOS/Android Deployment & AI Prompts!**