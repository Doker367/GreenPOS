import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for handling Stripe payments in the Flutter app
class StripeService {
  /// Initialize Stripe with publishable key
  /// Call this in main.dart before using payment features
  static Future<void> initialize(String publishableKey) async {
    Stripe.publishableKey = publishableKey;
    
    // Optional: Set merchant identifier for Apple Pay
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      Stripe.merchantIdentifier = 'merchant.com.greenpos.app';
    }
    
    await Stripe.instance.applySettings();
  }

  /// Check if Stripe is available on this platform
  static bool get isSupported {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  /// Show the card payment form and get token
  /// Returns null if user cancels or payment fails
  static Future<PaymentIntentResult?> processCardPayment({
    required String clientSecret,
    double? amount,
    String? currency,
  }) async {
    try {
      // Create payment method from card form
      final paymentMethod = await Stripe.instance.confirmPayment(
        clientSecret: clientSecret,
        data: const PaymentMethodData(),
      );

      return PaymentIntentResult(
        success: true,
        paymentMethodId: paymentMethod.id,
        status: 'succeeded',
      );
    } on StripeException catch (e) {
      debugPrint('Stripe error: ${e.error.localizedMessage}');
      return PaymentIntentResult(
        success: false,
        errorMessage: e.error.localizedMessage,
        status: 'failed',
      );
    } catch (e) {
      debugPrint('Payment error: $e');
      return PaymentIntentResult(
        success: false,
        errorMessage: 'Error al procesar el pago: $e',
        status: 'failed',
      );
    }
  }

  /// Handle Apple Pay payment
  static Future<PaymentIntentResult?> processApplePayPayment({
    required String clientSecret,
    required double amount,
    String currencyCode = 'MXN',
  }) async {
    try {
      final result = await Stripe.instance.presentApplePay(
        ApplePayPresentParams(
          amount: amount,
          currencyCode: currencyCode,
          countryCode: 'MX',
        ),
      );

      if (result != null) {
        return PaymentIntentResult(
          success: true,
          paymentMethodId: result.id,
          status: 'succeeded',
        );
      }

      return PaymentIntentResult(
        success: false,
        errorMessage: 'Apple Pay fue cancelado',
        status: 'canceled',
      );
    } on StripeException catch (e) {
      debugPrint('Apple Pay error: ${e.error.localizedMessage}');
      return PaymentIntentResult(
        success: false,
        errorMessage: e.error.localizedMessage,
        status: 'failed',
      );
    }
  }

  /// Handle Google Pay payment
  static Future<PaymentIntentResult?> processGooglePayPayment({
    required String clientSecret,
  }) async {
    try {
      final result = await Stripe.instance.presentGooglePay(
        GooglePayPresentParams(
          amount: 0, // Amount from payment intent
          currencyCode: 'MXN',
        ),
      );

      if (result != null) {
        return PaymentIntentResult(
          success: true,
          paymentMethodId: result.id,
          status: 'succeeded',
        );
      }

      return PaymentIntentResult(
        success: false,
        errorMessage: 'Google Pay fue cancelado',
        status: 'canceled',
      );
    } on StripeException catch (e) {
      debugPrint('Google Pay error: ${e.error.localizedMessage}');
      return PaymentIntentResult(
        success: false,
        errorMessage: e.error.localizedMessage,
        status: 'failed',
      );
    }
  }

  /// Update payment sheet appearance
  static void setAppearance(StripeTheme theme) {
    Stripe.instance.updateOptions(
      publishableKey: Stripe.publishableKey!,
      stripeAccountId: null,
      threeDSecureParams: null,
      applePay: null,
      googlePay: null,
    );
  }

  /// Handle NFC payment (contactless)
  static Future<PaymentIntentResult?> processNFCPayment({
    required String clientSecret,
  }) async {
    // Stripe doesn't directly handle NFC - this would use the card form
    // In production, you might integrate with a terminal SDK here
    return processCardPayment(clientSecret: clientSecret);
  }
}

/// Result of a payment intent operation
class PaymentIntentResult {
  final bool success;
  final String? paymentMethodId;
  final String? errorMessage;
  final String status;

  const PaymentIntentResult({
    required this.success,
    this.paymentMethodId,
    this.errorMessage,
    required this.status,
  });
}

/// Provider for Stripe publishable key
final stripePublishableKeyProvider = Provider<String?>((ref) {
  // In production, this would come from environment config
  // For development, use test key
  if (kDebugMode) {
    return 'pk_test_demo'; // Replace with actual test key
  }
  return null; // Would be set via environment
});

/// Provider to check if Stripe is initialized
final isStripeInitializedProvider = FutureProvider<bool>((ref) async {
  final key = ref.watch(stripePublishableKeyProvider);
  if (key == null) return false;
  
  try {
    await StripeService.initialize(key);
    return true;
  } catch (e) {
    debugPrint('Failed to initialize Stripe: $e');
    return false;
  }
});
