/// Input validation utilities for PlombiPro
/// Provides comprehensive validation for French business data
library validators;

import 'package:intl/intl.dart';

class Validators {
  /// Validates French email address format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }

    // RFC 5322 compliant email regex (simplified)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Format d\'email invalide';
    }

    // Check for common typos in French email domains
    final commonDomains = [
      'gmail.com',
      'yahoo.fr',
      'hotmail.fr',
      'orange.fr',
      'free.fr',
      'laposte.net'
    ];
    final domain = value.split('@').last.toLowerCase();

    // Maximum email length
    if (value.length > 254) {
      return 'Email trop long (254 caractères maximum)';
    }

    return null;
  }

  /// Validates French SIRET number (14 digits)
  /// SIRET = SIREN (9 digits) + NIC (5 digits)
  static String? validateSIRET(String? value) {
    if (value == null || value.isEmpty) {
      return null; // SIRET is optional in some contexts
    }

    // Remove spaces and hyphens
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');

    // Check if it contains exactly 14 digits
    if (!RegExp(r'^\d{14}$').hasMatch(cleaned)) {
      return 'Le SIRET doit contenir exactement 14 chiffres';
    }

    // Validate using Luhn algorithm (SIRET uses it)
    if (!_luhnCheck(cleaned)) {
      return 'Numéro SIRET invalide (échec validation Luhn)';
    }

    return null;
  }

  /// Validates French SIREN number (9 digits)
  static String? validateSIREN(String? value) {
    if (value == null || value.isEmpty) {
      return null; // SIREN is optional in some contexts
    }

    // Remove spaces and hyphens
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');

    // Check if it contains exactly 9 digits
    if (!RegExp(r'^\d{9}$').hasMatch(cleaned)) {
      return 'Le SIREN doit contenir exactement 9 chiffres';
    }

    // Validate using Luhn algorithm
    if (!_luhnCheck(cleaned)) {
      return 'Numéro SIREN invalide (échec validation Luhn)';
    }

    return null;
  }

  /// Validates French VAT number (FR + 2 digits + 9 digits SIREN)
  /// Format: FR12345678901
  static String? validateFrenchVAT(String? value) {
    if (value == null || value.isEmpty) {
      return null; // VAT is optional
    }

    // Remove spaces and hyphens
    final cleaned = value.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

    // Check format: FR + 2 digits + 9 digits
    if (!RegExp(r'^FR\d{11}$').hasMatch(cleaned)) {
      return 'Format TVA invalide (attendu: FR + 11 chiffres)';
    }

    // Extract SIREN (last 9 digits)
    final siren = cleaned.substring(4, 13);

    // Validate SIREN using Luhn
    if (!_luhnCheck(siren)) {
      return 'Numéro SIREN dans TVA invalide';
    }

    // Validate the 2 check digits
    final checkDigits = int.parse(cleaned.substring(2, 4));
    final sirenInt = int.parse(siren);
    final expectedCheck = (12 + 3 * (sirenInt % 97)) % 97;

    if (checkDigits != expectedCheck) {
      return 'Clé de contrôle TVA invalide';
    }

    return null;
  }

  /// Validates French phone number (10 digits, starts with 0)
  static String? validateFrenchPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }

    // Remove spaces, dots, hyphens, parentheses
    final cleaned = value.replaceAll(RegExp(r'[\s.\-()]'), '');

    // Check for French mobile/landline format (10 digits starting with 0)
    if (!RegExp(r'^0[1-9]\d{8}$').hasMatch(cleaned)) {
      return 'Format invalide (10 chiffres commençant par 0)';
    }

    return null;
  }

  /// Validates French postal code (5 digits)
  static String? validateFrenchPostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le code postal est requis';
    }

    // French postal codes are exactly 5 digits
    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
      return 'Code postal invalide (5 chiffres attendus)';
    }

    return null;
  }

  /// Validates IBAN (International Bank Account Number)
  /// French IBAN: FR76 followed by 23 digits/letters
  static String? validateIBAN(String? value) {
    if (value == null || value.isEmpty) {
      return null; // IBAN is optional
    }

    // Remove spaces
    final cleaned = value.toUpperCase().replaceAll(' ', '');

    // Check French IBAN format
    if (!RegExp(r'^FR\d{2}[A-Z0-9]{23}$').hasMatch(cleaned)) {
      return 'Format IBAN français invalide (FR + 25 caractères)';
    }

    // Validate using mod-97 algorithm
    if (!_validateIBANChecksum(cleaned)) {
      return 'Somme de contrôle IBAN invalide';
    }

    return null;
  }

  /// Validates BIC/SWIFT code (8 or 11 characters)
  static String? validateBIC(String? value) {
    if (value == null || value.isEmpty) {
      return null; // BIC is optional
    }

    final cleaned = value.toUpperCase().replaceAll(' ', '');

    // BIC format: 4 letters (bank) + 2 letters (country) + 2 alphanumeric (location) + optional 3 alphanumeric (branch)
    if (!RegExp(r'^[A-Z]{4}FR[A-Z0-9]{2}([A-Z0-9]{3})?$').hasMatch(cleaned)) {
      return 'Format BIC invalide (8 ou 11 caractères, pays FR)';
    }

    return null;
  }

  /// Validates monetary amount (positive decimal with max 2 decimal places)
  static String? validateAmount(String? value, {bool allowZero = false}) {
    if (value == null || value.isEmpty) {
      return 'Le montant est requis';
    }

    // Replace comma with dot for parsing
    final cleaned = value.replaceAll(',', '.');

    final amount = double.tryParse(cleaned);

    if (amount == null) {
      return 'Montant invalide';
    }

    if (!allowZero && amount <= 0) {
      return 'Le montant doit être supérieur à 0';
    }

    if (amount < 0) {
      return 'Le montant ne peut pas être négatif';
    }

    // Check for max 2 decimal places
    if (cleaned.contains('.')) {
      final decimals = cleaned.split('.').last;
      if (decimals.length > 2) {
        return 'Maximum 2 décimales autorisées';
      }
    }

    // Reasonable maximum amount (100 million euros)
    if (amount > 100000000) {
      return 'Montant trop élevé (max: 100 000 000 €)';
    }

    return null;
  }

  /// Validates percentage (0-100)
  static String? validatePercentage(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Percentage is optional
    }

    final cleaned = value.replaceAll(',', '.');
    final percentage = double.tryParse(cleaned);

    if (percentage == null) {
      return 'Pourcentage invalide';
    }

    if (percentage < 0 || percentage > 100) {
      return 'Le pourcentage doit être entre 0 et 100';
    }

    return null;
  }

  /// Validates French invoice number format
  /// Typically: PREFIX-YEAR-NUMBER (e.g., FACT-2024-001)
  static String? validateInvoiceNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de facture est requis';
    }

    // Allow alphanumeric with hyphens, underscores, and slashes
    if (!RegExp(r'^[A-Z0-9\-_/]+$', caseSensitive: false).hasMatch(value)) {
      return 'Format de numéro invalide';
    }

    if (value.length > 50) {
      return 'Numéro trop long (50 caractères maximum)';
    }

    return null;
  }

  /// Validates text length
  static String? validateTextLength(
    String? value, {
    required String fieldName,
    int minLength = 1,
    int? maxLength,
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }

    if (value.length < minLength) {
      return '$fieldName doit contenir au moins $minLength caractères';
    }

    if (maxLength != null && value.length > maxLength) {
      return '$fieldName ne peut pas dépasser $maxLength caractères';
    }

    return null;
  }

  /// Validates date is not in the future
  static String? validatePastDate(DateTime? value) {
    if (value == null) {
      return 'La date est requise';
    }

    if (value.isAfter(DateTime.now())) {
      return 'La date ne peut pas être dans le futur';
    }

    return null;
  }

  /// Validates date range
  static String? validateDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return 'Les deux dates sont requises';
    }

    if (start.isAfter(end)) {
      return 'La date de début doit être avant la date de fin';
    }

    return null;
  }

  // ==================== Private Helper Methods ====================

  /// Luhn algorithm for validating SIRET/SIREN
  /// https://en.wikipedia.org/wiki/Luhn_algorithm
  static bool _luhnCheck(String number) {
    int sum = 0;
    bool alternate = false;

    // Process digits from right to left
    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// IBAN mod-97 checksum validation
  /// https://en.wikipedia.org/wiki/International_Bank_Account_Number#Validating_the_IBAN
  static bool _validateIBANChecksum(String iban) {
    // Move first 4 chars to end
    final rearranged = iban.substring(4) + iban.substring(0, 4);

    // Replace letters with numbers (A=10, B=11, ..., Z=35)
    String numeric = '';
    for (int i = 0; i < rearranged.length; i++) {
      final char = rearranged[i];
      if (RegExp(r'[A-Z]').hasMatch(char)) {
        numeric += (char.codeUnitAt(0) - 55).toString();
      } else {
        numeric += char;
      }
    }

    // Calculate mod 97
    return _mod97(numeric) == 1;
  }

  /// Calculate mod 97 for large numbers (used in IBAN validation)
  static int _mod97(String number) {
    int remainder = 0;
    for (int i = 0; i < number.length; i++) {
      remainder = (remainder * 10 + int.parse(number[i])) % 97;
    }
    return remainder;
  }
}
