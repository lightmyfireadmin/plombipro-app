import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added
import 'package:flutter/services.dart'; // Added for PlatformException

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

class StripePaymentService {
  static final _supabase = Supabase.instance.client;

  // This method is primarily for setting the publishable key, which is often done once at app start.
  // initPaymentSheet is called within processPayment as it requires the client secret.
  static void initializeStripe(String publishableKey) {
    Stripe.publishableKey = publishableKey;
  }

  static Future<PaymentResult> processPayment({
    required double amount,
    required String invoiceId,
    required String clientEmail,
    String currency = 'eur',
  }) async {
    try {
      // 1. Call your Supabase Edge Function to create a Payment Intent
      final response = await _supabase.functions.invoke(
        'create-payment-intent',
        body: {
          'amount': amount, // Amount is expected in major currency unit (e.g., EUR)
          'currency': currency,
          'invoice_id': invoiceId,
          'client_email': clientEmail, // Pass client email for Stripe if needed
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Payment intent creation failed');
      }

      final clientSecret = response.data['client_secret'] as String;
      final paymentIntentId = response.data['payment_intent_id'] as String;

      // 2. Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'PlombiPro',
          customerId: _supabase.auth.currentUser?.id, // Optional: if you have a Stripe Customer ID
          customerEphemeralKeySecret: null, // Optional: if you have an ephemeral key
          allowsDelayedPaymentMethods: true,
        ),
      );

      // 3. Present the Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      return PaymentResult(
        success: true,
        message: 'Paiement réussi!',
        transactionId: paymentIntentId,
      );
    } on PlatformException catch (e) {
      return PaymentResult(
        success: false,
        message: e.message ?? 'Paiement annulé ou échoué.',
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Une erreur inattendue est survenue: ${e.toString()}',
      );
    }
  }

  static Future<bool> refundPayment(String paymentId) async {
    try {
      // Call your Supabase Edge Function to process the refund
      final response = await _supabase.functions.invoke(
        'refund-payment',
        body: {'payment_id': paymentId},
      );

      if (response.data['success'] == true) {
        return true;
      } else {
        throw Exception(response.data['error'] ?? 'Échec du remboursement');
      }
    } catch (e) {
      debugPrint('Erreur de remboursement: ${e.toString()}');
      return false;
    }
  }
}
