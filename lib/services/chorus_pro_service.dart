import 'package:http/http.dart' as http;
import 'dart:convert';

/// Chorus Pro service for French B2G e-invoicing
///
/// Handles invoice submission to Chorus Pro (French government invoicing platform)
/// Required for B2G (Business-to-Government) invoices in France.
class ChorusProService {
  final String cloudFunctionUrl;
  final bool testMode;

  ChorusProService({
    required this.cloudFunctionUrl,
    this.testMode = true,
  });

  /// Submit invoice to Chorus Pro
  ///
  /// Prerequisites:
  /// - Invoice must have Factur-X XML generated
  /// - Client must have valid SIRET number
  ///
  /// Returns Chorus Pro invoice ID and status
  Future<Map<String, dynamic>> submitInvoice(String invoiceId) async {
    try {
      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'invoice_id': invoiceId,
          'action': 'submit',
          'test_mode': testMode,
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {
          'success': true,
          'chorus_invoice_id': result['chorus_invoice_id'],
          'status': result['status'],
          'message': result['message'],
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to submit invoice: $e',
      };
    }
  }

  /// Check invoice status in Chorus Pro
  ///
  /// Possible statuses:
  /// - DEPOSE: Deposited
  /// - EN_TRAITEMENT: In progress
  /// - REFUSE: Rejected
  /// - A_RECYCLER: Error to fix
  /// - SUSPENDU: Suspended
  /// - PAYE: Paid
  /// - MIS_EN_PAIEMENT: Payment initiated
  Future<Map<String, dynamic>> checkStatus(String invoiceId) async {
    try {
      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'invoice_id': invoiceId,
          'action': 'check_status',
          'test_mode': testMode,
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {
          'success': true,
          'status': result['status'],
          'date_update': result['date_update'],
          'details': result['details'],
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to check status: $e',
      };
    }
  }

  /// Get full invoice details from Chorus Pro
  Future<Map<String, dynamic>> getInvoiceDetails(String invoiceId) async {
    try {
      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'invoice_id': invoiceId,
          'action': 'get_details',
          'test_mode': testMode,
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {
          'success': true,
          'details': result['details'],
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get details: $e',
      };
    }
  }

  /// Get user-friendly status text in French
  static String getStatusText(String status) {
    switch (status) {
      case 'DEPOSE':
        return 'Déposée';
      case 'EN_TRAITEMENT':
        return 'En traitement';
      case 'REFUSE':
        return 'Refusée';
      case 'A_RECYCLER':
        return 'À corriger';
      case 'SUSPENDU':
        return 'Suspendue';
      case 'PAYE':
        return 'Payée';
      case 'MIS_EN_PAIEMENT':
        return 'Mise en paiement';
      case 'FAILED':
        return 'Échec';
      default:
        return status;
    }
  }

  /// Example usage:
  ///
  /// ```dart
  /// final chorusProService = ChorusProService(
  ///   cloudFunctionUrl: 'https://your-project.cloudfunctions.net/submit_to_chorus_pro',
  ///   testMode: true, // Use test environment
  /// );
  ///
  /// // Submit invoice
  /// final result = await chorusProService.submitInvoice(invoiceId);
  /// if (result['success']) {
  ///   print('Submitted! Chorus Pro ID: ${result['chorus_invoice_id']}');
  ///   print('Status: ${result['status']}');
  /// } else {
  ///   print('Error: ${result['error']}');
  /// }
  ///
  /// // Check status later
  /// final statusResult = await chorusProService.checkStatus(invoiceId);
  /// if (statusResult['success']) {
  ///   final statusText = ChorusProService.getStatusText(statusResult['status']);
  ///   print('Current status: $statusText');
  /// }
  /// ```
}
