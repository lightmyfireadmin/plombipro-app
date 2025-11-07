import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quote.dart';
import '../models/invoice.dart';
import 'dart:convert';

/// Email service for sending quotes and invoices to clients
///
/// This service uses Supabase Edge Functions to send transactional emails
/// via a configured email provider (SendGrid, Resend, etc.)
class EmailService {
  static final _supabase = Supabase.instance.client;

  /// Send quote email to client
  static Future<EmailResult> sendQuoteEmail({
    required Quote quote,
    required String recipientEmail,
    required String recipientName,
    String? companyName,
    String? companyEmail,
    String? customMessage,
    String? pdfUrl,
  }) async {
    try {
      final emailData = {
        'type': 'quote',
        'to': recipientEmail,
        'recipient_name': recipientName,
        'company_name': companyName ?? 'PlombiPro',
        'company_email': companyEmail ?? 'contact@plombipro.fr',
        'quote_number': quote.quoteNumber,
        'quote_date': quote.date.toIso8601String(),
        'expiry_date': quote.expiryDate?.toIso8601String(),
        'total_ttc': quote.totalTtc,
        'custom_message': customMessage,
        'pdf_url': pdfUrl,
        'line_items': quote.items.map((item) => {
          'description': item.description,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total': item.lineTotal,
        }).toList(),
      };

      final response = await _supabase.functions.invoke(
        'send-email',
        body: emailData,
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return EmailResult(
          success: true,
          message: data['message'] ?? 'Email envoyé avec succès',
        );
      } else {
        return EmailResult(
          success: false,
          message: 'Erreur lors de l\'envoi: ${response.status}',
        );
      }
    } catch (e) {
      return EmailResult(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Send invoice email to client
  static Future<EmailResult> sendInvoiceEmail({
    required Invoice invoice,
    required String recipientEmail,
    required String recipientName,
    String? companyName,
    String? companyEmail,
    String? customMessage,
    String? pdfUrl,
    String? iban,
    String? bic,
  }) async {
    try {
      final emailData = {
        'type': 'invoice',
        'to': recipientEmail,
        'recipient_name': recipientName,
        'company_name': companyName ?? 'PlombiPro',
        'company_email': companyEmail ?? 'contact@plombipro.fr',
        'invoice_number': invoice.number,
        'invoice_date': invoice.date.toIso8601String(),
        'due_date': invoice.dueDate?.toIso8601String(),
        'payment_status': invoice.paymentStatus,
        'total_ttc': invoice.totalTtc,
        'custom_message': customMessage,
        'pdf_url': pdfUrl,
        'payment_method': invoice.paymentMethod,
        'iban': iban,
        'bic': bic,
        'line_items': invoice.items.map((item) => {
          'description': item.description,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total': item.lineTotal,
        }).toList(),
      };

      final response = await _supabase.functions.invoke(
        'send-email',
        body: emailData,
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return EmailResult(
          success: true,
          message: data['message'] ?? 'Email envoyé avec succès',
        );
      } else {
        return EmailResult(
          success: false,
          message: 'Erreur lors de l\'envoi: ${response.status}',
        );
      }
    } catch (e) {
      return EmailResult(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Send payment reminder email
  static Future<EmailResult> sendPaymentReminder({
    required Invoice invoice,
    required String recipientEmail,
    required String recipientName,
    String? companyName,
    bool isOverdue = false,
  }) async {
    try {
      final emailData = {
        'type': 'payment_reminder',
        'to': recipientEmail,
        'recipient_name': recipientName,
        'company_name': companyName ?? 'PlombiPro',
        'invoice_number': invoice.number,
        'invoice_date': invoice.date.toIso8601String(),
        'due_date': invoice.dueDate?.toIso8601String(),
        'total_ttc': invoice.totalTtc,
        'balance_due': invoice.balanceDue ?? invoice.totalTtc,
        'is_overdue': isOverdue,
      };

      final response = await _supabase.functions.invoke(
        'send-email',
        body: emailData,
      );

      if (response.status == 200) {
        return EmailResult(success: true, message: 'Relance envoyée');
      } else {
        return EmailResult(success: false, message: 'Erreur d\'envoi');
      }
    } catch (e) {
      return EmailResult(success: false, message: e.toString());
    }
  }

  /// Generate HTML email template for quote
  static String generateQuoteEmailHtml({
    required String recipientName,
    required String companyName,
    required String quoteNumber,
    required String quoteDate,
    required String totalTtc,
    String? customMessage,
    List<Map<String, dynamic>>? lineItems,
  }) {
    final itemsHtml = lineItems != null && lineItems.isNotEmpty
        ? '''
        <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
          <thead>
            <tr style="background-color: #f5f5f5;">
              <th style="padding: 10px; text-align: left; border-bottom: 2px solid #ddd;">Description</th>
              <th style="padding: 10px; text-align: center; border-bottom: 2px solid #ddd;">Qté</th>
              <th style="padding: 10px; text-align: right; border-bottom: 2px solid #ddd;">P.U.</th>
              <th style="padding: 10px; text-align: right; border-bottom: 2px solid #ddd;">Total</th>
            </tr>
          </thead>
          <tbody>
            ${lineItems.map((item) => '''
            <tr>
              <td style="padding: 8px; border-bottom: 1px solid #eee;">${item['description']}</td>
              <td style="padding: 8px; text-align: center; border-bottom: 1px solid #eee;">${item['quantity']}</td>
              <td style="padding: 8px; text-align: right; border-bottom: 1px solid #eee;">${item['unit_price']}€</td>
              <td style="padding: 8px; text-align: right; border-bottom: 1px solid #eee;">${item['total']}€</td>
            </tr>
            ''').join()}
          </tbody>
        </table>
        '''
        : '';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #2563eb; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">$companyName</h1>
    <p style="margin: 5px 0;">Devis N° $quoteNumber</p>
  </div>

  <div style="background-color: #ffffff; padding: 30px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 8px 8px;">
    <p>Bonjour $recipientName,</p>

    ${customMessage != null ? '<p>$customMessage</p>' : '<p>Nous vous remercions de l\'intérêt porté à nos services.</p>'}

    <p>Veuillez trouver ci-joint notre devis <strong>$quoteNumber</strong> daté du <strong>$quoteDate</strong>.</p>

    $itemsHtml

    <div style="background-color: #f9fafb; padding: 15px; border-radius: 6px; margin: 20px 0;">
      <p style="margin: 0; font-size: 18px;"><strong>Montant Total TTC: $totalTtc</strong></p>
    </div>

    <p>Ce devis est valable 30 jours à compter de sa date d\'émission.</p>

    <p>Pour toute question, n\'hésitez pas à nous contacter.</p>

    <p>Cordialement,<br>
    <strong>$companyName</strong></p>
  </div>

  <div style="text-align: center; margin-top: 20px; color: #6b7280; font-size: 12px;">
    <p>Email envoyé par PlombiPro - Gestion de devis et factures</p>
  </div>
</body>
</html>
    ''';
  }

  /// Generate HTML email template for invoice
  static String generateInvoiceEmailHtml({
    required String recipientName,
    required String companyName,
    required String invoiceNumber,
    required String invoiceDate,
    required String dueDate,
    required String totalTtc,
    String? customMessage,
    String? paymentMethod,
    String? iban,
    String? bic,
    List<Map<String, dynamic>>? lineItems,
  }) {
    final itemsHtml = lineItems != null && lineItems.isNotEmpty
        ? '''
        <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
          <thead>
            <tr style="background-color: #f5f5f5;">
              <th style="padding: 10px; text-align: left; border-bottom: 2px solid #ddd;">Description</th>
              <th style="padding: 10px; text-align: center; border-bottom: 2px solid #ddd;">Qté</th>
              <th style="padding: 10px; text-align: right; border-bottom: 2px solid #ddd;">P.U.</th>
              <th style="padding: 10px; text-align: right; border-bottom: 2px solid #ddd;">Total</th>
            </tr>
          </thead>
          <tbody>
            ${lineItems.map((item) => '''
            <tr>
              <td style="padding: 8px; border-bottom: 1px solid #eee;">${item['description']}</td>
              <td style="padding: 8px; text-align: center; border-bottom: 1px solid #eee;">${item['quantity']}</td>
              <td style="padding: 8px; text-align: right; border-bottom: 1px solid #eee;">${item['unit_price']}€</td>
              <td style="padding: 8px; text-align: right; border-bottom: 1px solid #eee;">${item['total']}€</td>
            </tr>
            ''').join()}
          </tbody>
        </table>
        '''
        : '';

    final paymentInfo = iban != null || bic != null
        ? '''
        <div style="background-color: #dbeafe; padding: 15px; border-radius: 6px; border-left: 4px solid #2563eb; margin: 20px 0;">
          <h3 style="margin-top: 0; color: #1e40af;">Informations de paiement</h3>
          ${paymentMethod != null ? '<p><strong>Méthode:</strong> $paymentMethod</p>' : ''}
          ${iban != null ? '<p><strong>IBAN:</strong> $iban</p>' : ''}
          ${bic != null ? '<p><strong>BIC:</strong> $bic</p>' : ''}
          <p><strong>Échéance:</strong> $dueDate</p>
        </div>
        '''
        : '';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #dc2626; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">$companyName</h1>
    <p style="margin: 5px 0;">Facture N° $invoiceNumber</p>
  </div>

  <div style="background-color: #ffffff; padding: 30px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 8px 8px;">
    <p>Bonjour $recipientName,</p>

    ${customMessage != null ? '<p>$customMessage</p>' : '<p>Nous vous remercions pour votre confiance.</p>'}

    <p>Veuillez trouver ci-joint votre facture <strong>$invoiceNumber</strong> datée du <strong>$invoiceDate</strong>.</p>

    $itemsHtml

    <div style="background-color: #fef2f2; padding: 15px; border-radius: 6px; margin: 20px 0; border-left: 4px solid #dc2626;">
      <p style="margin: 0; font-size: 18px;"><strong>Montant Total TTC: $totalTtc</strong></p>
      <p style="margin: 5px 0 0 0; font-size: 14px; color: #991b1b;">Échéance de paiement: $dueDate</p>
    </div>

    $paymentInfo

    <p>Pour toute question concernant cette facture, n\'hésitez pas à nous contacter.</p>

    <p>Cordialement,<br>
    <strong>$companyName</strong></p>
  </div>

  <div style="text-align: center; margin-top: 20px; color: #6b7280; font-size: 12px;">
    <p>Email envoyé par PlombiPro - Gestion de devis et factures</p>
  </div>
</body>
</html>
    ''';
  }
}

/// Result of an email sending operation
class EmailResult {
  final bool success;
  final String message;
  final String? emailId;

  EmailResult({
    required this.success,
    required this.message,
    this.emailId,
  });
}
