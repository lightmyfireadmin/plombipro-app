import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for generating Factur-X compliant electronic invoices
/// Required for B2B transactions in France from 2026
class FacturXService {
  static final _supabase = Supabase.instance.client;

  /// Generate Factur-X PDF for an invoice
  /// Returns the URL of the generated Factur-X PDF
  static Future<Map<String, String>?> generateFacturX(String invoiceId) async {
    try {
      // Call the cloud function
      final response = await _supabase.functions.invoke(
        'generate-facturx',
        body: {'invoice_id': invoiceId},
      );

      if (response.data == null) {
        throw Exception('No response from Factur-X generator');
      }

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        return {
          'pdf_url': data['pdf_url'] as String,
          'xml_url': data['xml_url'] as String,
          'level': data['facturx_level'] as String? ?? 'basic',
        };
      } else {
        throw Exception(data['error'] ?? 'Failed to generate Factur-X');
      }
    } catch (e) {
      print('Error generating Factur-X: $e');
      rethrow;
    }
  }

  /// Check if an invoice already has Factur-X
  static Future<bool> hasFacturX(String invoiceId) async {
    try {
      final response = await _supabase
          .from('invoices')
          .select('is_electronic_invoice, facturx_xml_url')
          .eq('id', invoiceId)
          .maybeSingle();

      if (response == null) return false;

      return response['is_electronic_invoice'] == true &&
          response['facturx_xml_url'] != null;
    } catch (e) {
      print('Error checking Factur-X status: $e');
      return false;
    }
  }

  /// Download Factur-X XML for an invoice
  static Future<String?> getFacturXXml(String invoiceId) async {
    try {
      final response = await _supabase
          .from('invoices')
          .select('facturx_xml_url')
          .eq('id', invoiceId)
          .maybeSingle();

      if (response == null) return null;

      return response['facturx_xml_url'] as String?;
    } catch (e) {
      print('Error getting Factur-X XML: $e');
      return null;
    }
  }

  /// Validate if Factur-X generation is possible
  /// Checks for required fields in profile and invoice
  static Future<FacturXValidation> validateForFacturX(
      String invoiceId) async {
    final errors = <String>[];
    final warnings = <String>[];

    try {
      // Get invoice data
      final invoiceResponse = await _supabase
          .from('invoices')
          .select('*, clients(*)')
          .eq('id', invoiceId)
          .single();

      final invoice = invoiceResponse;

      // Check invoice fields
      if (invoice['invoice_number'] == null ||
          (invoice['invoice_number'] as String).isEmpty) {
        errors.add('Numéro de facture manquant');
      }

      if (invoice['invoice_date'] == null) {
        errors.add('Date de facture manquante');
      }

      if (invoice['subtotal_ht'] == null || invoice['subtotal_ht'] == 0) {
        errors.add('Montant HT manquant');
      }

      if (invoice['total_vat'] == null) {
        errors.add('Montant TVA manquant');
      }

      if (invoice['total_ttc'] == null || invoice['total_ttc'] == 0) {
        errors.add('Montant TTC manquant');
      }

      // Check line items
      if (invoice['line_items'] == null ||
          (invoice['line_items'] as List).isEmpty) {
        errors.add('Aucune ligne de facturation');
      }

      // Check seller (user profile)
      final userId = invoice['user_id'];
      final profileResponse =
          await _supabase.from('profiles').select().eq('id', userId).single();

      final profile = profileResponse;

      if (profile['company_name'] == null ||
          (profile['company_name'] as String).isEmpty) {
        errors.add('Nom de société manquant dans le profil');
      }

      if (profile['siret'] == null || (profile['siret'] as String).isEmpty) {
        warnings.add('SIRET manquant dans le profil (recommandé)');
      }

      if (profile['vat_number'] == null ||
          (profile['vat_number'] as String).isEmpty) {
        warnings.add('Numéro TVA manquant dans le profil (recommandé)');
      }

      if (profile['address'] == null ||
          (profile['address'] as String).isEmpty) {
        errors.add('Adresse manquante dans le profil');
      }

      if (profile['city'] == null || (profile['city'] as String).isEmpty) {
        errors.add('Ville manquante dans le profil');
      }

      if (profile['postal_code'] == null ||
          (profile['postal_code'] as String).isEmpty) {
        errors.add('Code postal manquant dans le profil');
      }

      // Check buyer (client)
      final client = invoice['clients'];
      if (client == null) {
        errors.add('Client introuvable');
      } else {
        if (client['name'] == null || (client['name'] as String).isEmpty) {
          errors.add('Nom du client manquant');
        }

        if (client['address'] == null ||
            (client['address'] as String).isEmpty) {
          warnings.add('Adresse du client manquante (recommandé)');
        }
      }

      return FacturXValidation(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      return FacturXValidation(
        isValid: false,
        errors: ['Erreur lors de la validation: ${e.toString()}'],
        warnings: [],
      );
    }
  }
}

/// Validation result for Factur-X generation
class FacturXValidation {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  FacturXValidation({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}
