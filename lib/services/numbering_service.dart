import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing sequential numbering of quotes and invoices
/// Uses database functions to ensure sequential and unique numbers
class NumberingService {
  static final _supabase = Supabase.instance.client;

  /// Generate next quote number for the current user
  /// Returns format: PREFIX-NNNNNN or PREFIX-YYYY-NNNN (if annual reset)
  /// Example: DEV-000001 or DEV-2025-0001
  static Future<String> generateQuoteNumber() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final result = await _supabase
          .rpc('generate_quote_number', params: {'p_user_id': userId});

      if (result == null) {
        throw Exception('Failed to generate quote number');
      }

      return result as String;
    } catch (e) {
      print('Error generating quote number: $e');
      // Fallback to draft if generation fails
      return 'DRAFT-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Generate next invoice number for the current user
  /// Returns format: PREFIX-NNNNNN or PREFIX-YYYY-NNNN (if annual reset)
  /// Example: FACT-000001 or FACT-2025-0001
  static Future<String> generateInvoiceNumber() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final result = await _supabase
          .rpc('generate_invoice_number', params: {'p_user_id': userId});

      if (result == null) {
        throw Exception('Failed to generate invoice number');
      }

      return result as String;
    } catch (e) {
      print('Error generating invoice number: $e');
      // Fallback to draft if generation fails
      return 'DRAFT-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Get user's numbering settings
  static Future<NumberingSettings?> getUserSettings() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return null;
      }

      final result = await _supabase
          .from('settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (result == null) {
        // Return default settings
        return NumberingSettings(
          quotePrefix: 'DEV-',
          invoicePrefix: 'FACT-',
          quoteStartingNumber: 1,
          invoiceStartingNumber: 1,
          resetNumberingAnnually: false,
        );
      }

      return NumberingSettings.fromJson(result);
    } catch (e) {
      print('Error fetching numbering settings: $e');
      return null;
    }
  }

  /// Update user's numbering settings
  static Future<bool> updateSettings(NumberingSettings settings) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if settings exist
      final existing = await _supabase
          .from('settings')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing == null) {
        // Insert new settings
        await _supabase.from('settings').insert({
          'user_id': userId,
          'quote_prefix': settings.quotePrefix,
          'invoice_prefix': settings.invoicePrefix,
          'quote_starting_number': settings.quoteStartingNumber,
          'invoice_starting_number': settings.invoiceStartingNumber,
          'reset_numbering_annually': settings.resetNumberingAnnually,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Update existing settings
        await _supabase.from('settings').update({
          'quote_prefix': settings.quotePrefix,
          'invoice_prefix': settings.invoicePrefix,
          'quote_starting_number': settings.quoteStartingNumber,
          'invoice_starting_number': settings.invoiceStartingNumber,
          'reset_numbering_annually': settings.resetNumberingAnnually,
        }).eq('user_id', userId);
      }

      return true;
    } catch (e) {
      print('Error updating numbering settings: $e');
      return false;
    }
  }

  /// Validate quote number format (for manual entry)
  static bool isValidQuoteNumber(String number) {
    if (number.isEmpty || number == 'DRAFT') return false;
    // Allow alphanumeric with hyphens
    return RegExp(r'^[A-Z0-9]+-[0-9]{4,6}$').hasMatch(number) ||
        RegExp(r'^[A-Z0-9]+-\d{4}-[0-9]{4}$').hasMatch(number);
  }

  /// Validate invoice number format (for manual entry)
  static bool isValidInvoiceNumber(String number) {
    if (number.isEmpty || number == 'DRAFT') return false;
    // Allow alphanumeric with hyphens
    return RegExp(r'^[A-Z0-9]+-[0-9]{4,6}$').hasMatch(number) ||
        RegExp(r'^[A-Z0-9]+-\d{4}-[0-9]{4}$').hasMatch(number);
  }

  /// Check if a quote number already exists for this user
  static Future<bool> quoteNumberExists(String number) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final result = await _supabase
          .from('quotes')
          .select('id')
          .eq('user_id', userId)
          .eq('quote_number', number)
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('Error checking quote number: $e');
      return false;
    }
  }

  /// Check if an invoice number already exists for this user
  static Future<bool> invoiceNumberExists(String number) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final result = await _supabase
          .from('invoices')
          .select('id')
          .eq('user_id', userId)
          .eq('invoice_number', number)
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('Error checking invoice number: $e');
      return false;
    }
  }
}

/// Model for user numbering settings
class NumberingSettings {
  final String quotePrefix;
  final String invoicePrefix;
  final int quoteStartingNumber;
  final int invoiceStartingNumber;
  final bool resetNumberingAnnually;

  NumberingSettings({
    required this.quotePrefix,
    required this.invoicePrefix,
    required this.quoteStartingNumber,
    required this.invoiceStartingNumber,
    required this.resetNumberingAnnually,
  });

  factory NumberingSettings.fromJson(Map<String, dynamic> json) {
    return NumberingSettings(
      quotePrefix: json['quote_prefix'] ?? 'DEV-',
      invoicePrefix: json['invoice_prefix'] ?? 'FACT-',
      quoteStartingNumber: json['quote_starting_number'] ?? 1,
      invoiceStartingNumber: json['invoice_starting_number'] ?? 1,
      resetNumberingAnnually: json['reset_numbering_annually'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'quote_prefix': quotePrefix,
        'invoice_prefix': invoicePrefix,
        'quote_starting_number': quoteStartingNumber,
        'invoice_starting_number': invoiceStartingNumber,
        'reset_numbering_annually': resetNumberingAnnually,
      };
}
