import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Payment method types
enum PaymentMethod {
  cash,
  card,
  transfer,
}

/// Payment provider types
enum PaymentProvider {
  stripe,
  paypal,
}

/// Payment status
enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

/// Represents a payment
class Payment {
  final String id;
  final String orderId;
  final double amount;
  final PaymentMethod method;
  final PaymentProvider? provider;
  final String? providerPaymentId;
  final PaymentStatus status;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    this.provider,
    this.providerPaymentId,
    required this.status,
    required this.createdAt,
  });

  Payment copyWith({
    String? id,
    String? orderId,
    double? amount,
    PaymentMethod? method,
    PaymentProvider? provider,
    String? providerPaymentId,
    PaymentStatus? status,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      provider: provider ?? this.provider,
      providerPaymentId: providerPaymentId ?? this.providerPaymentId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Stripe payment intent result
class StripePaymentIntent {
  final String clientSecret;
  final double amount;
  final String currency;

  const StripePaymentIntent({
    required this.clientSecret,
    required this.amount,
    required this.currency,
  });
}

/// PayPal order result
class PayPalOrderResult {
  final String id;
  final String status;
  final String approvalUrl;
  final double amount;
  final String currency;

  const PayPalOrderResult({
    required this.id,
    required this.status,
    required this.approvalUrl,
    required this.amount,
    required this.currency,
  });
}

/// State for payment operations
class PaymentState {
  final Payment? currentPayment;
  final StripePaymentIntent? stripeIntent;
  final PayPalOrderResult? paypalOrder;
  final bool isProcessing;
  final String? error;
  final PaymentMethod selectedMethod;

  const PaymentState({
    this.currentPayment,
    this.stripeIntent,
    this.paypalOrder,
    this.isProcessing = false,
    this.error,
    this.selectedMethod = PaymentMethod.cash,
  });

  PaymentState copyWith({
    Payment? currentPayment,
    StripePaymentIntent? stripeIntent,
    PayPalOrderResult? paypalOrder,
    bool? isProcessing,
    String? error,
    PaymentMethod? selectedMethod,
  }) {
    return PaymentState(
      currentPayment: currentPayment ?? this.currentPayment,
      stripeIntent: stripeIntent ?? this.stripeIntent,
      paypalOrder: paypalOrder ?? this.paypalOrder,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      selectedMethod: selectedMethod ?? this.selectedMethod,
    );
  }

  PaymentState clear() {
    return const PaymentState();
  }
}

/// Notifier for payment operations
class PaymentNotifier extends StateNotifier<PaymentState> {
  final Ref _ref;
  final _uuid = const Uuid();

  PaymentNotifier(this._ref) : super(const PaymentState());

  /// Select payment method
  void selectMethod(PaymentMethod method) {
    state = state.copyWith(selectedMethod: method);
  }

  /// Create a cash payment (immediate completion)
  Future<Payment?> createCashPayment(String orderId, double amount) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      // In production, this would call the GraphQL mutation
      // For now, simulate the payment creation
      await Future.delayed(const Duration(milliseconds: 300));

      final payment = Payment(
        id: _uuid.v4(),
        orderId: orderId,
        amount: amount,
        method: PaymentMethod.cash,
        provider: null, // No provider for cash
        providerPaymentId: null,
        status: PaymentStatus.completed,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        isProcessing: false,
        currentPayment: payment,
      );

      return payment;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Error al procesar pago en efectivo: $e',
      );
      return null;
    }
  }

  /// Create a Stripe payment intent for card payment
  Future<StripePaymentIntent?> createStripePaymentIntent(String orderId) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      // In production, this would call the GraphQL mutation:
      // mutation CreateStripePaymentIntent($orderId: UUID!) {
      //   createStripePaymentIntent(orderId: $orderId) {
      //     clientSecret
      //     amount
      //     currency
      //   }
      // }

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // For demo purposes, create a mock intent
      // In production, this comes from the backend
      final intent = StripePaymentIntent(
        clientSecret: 'pi_demo_secret_${_uuid.v4()}',
        amount: 0, // Would be set from order total
        currency: 'MXN',
      );

      state = state.copyWith(
        isProcessing: false,
        stripeIntent: intent,
        selectedMethod: PaymentMethod.card,
      );

      return intent;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Error al crear intención de pago Stripe: $e',
      );
      return null;
    }
  }

  /// Confirm Stripe payment after card entry
  Future<Payment?> confirmStripePayment(String paymentIntentId) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      // In production, this would call the GraphQL mutation:
      // mutation ConfirmStripePayment($paymentIntentId: String!) {
      //   confirmStripePayment(paymentIntentId: $paymentIntentId) {
      //     id
      //     orderId
      //     amount
      //     status
      //   }
      // }

      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate successful payment
      final payment = Payment(
        id: _uuid.v4(),
        orderId: '', // Would be set from context
        amount: 0,
        method: PaymentMethod.card,
        provider: PaymentProvider.stripe,
        providerPaymentId: paymentIntentId,
        status: PaymentStatus.completed,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        isProcessing: false,
        currentPayment: payment,
      );

      return payment;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Error al confirmar pago con tarjeta: $e',
      );
      return null;
    }
  }

  /// Create a PayPal order
  Future<PayPalOrderResult?> createPayPalOrder(String orderId) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      // In production, this would call the GraphQL mutation:
      // mutation CreatePayPalOrder($orderId: UUID!) {
      //   createPayPalOrder(orderId: $orderId) {
      //     id
      //     status
      //     approvalUrl
      //     amount
      //     currency
      //   }
      // }

      await Future.delayed(const Duration(milliseconds: 500));

      // For demo, return mock approval URL
      // In production, this comes from PayPal API
      final order = PayPalOrderResult(
        id: 'PAYPAL-${_uuid.v4()}',
        status: 'CREATED',
        approvalUrl: 'https://www.sandbox.paypal.com/checkoutnow?token=demo',
        amount: 0, // Would be set from order total
        currency: 'MXN',
      );

      state = state.copyWith(
        isProcessing: false,
        paypalOrder: order,
        selectedMethod: PaymentMethod.card, // PayPal is also card-like
      );

      return order;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Error al crear orden PayPal: $e',
      );
      return null;
    }
  }

  /// Capture PayPal order after user approval
  Future<Payment?> capturePayPalOrder(String paypalOrderId) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      // In production, this would call the GraphQL mutation:
      // mutation CapturePayPalOrder($paypalOrderId: String!) {
      //   capturePayPalOrder(paypalOrderId: $paypalOrderId) {
      //     id
      //     orderId
      //     amount
      //     status
      //   }
      // }

      await Future.delayed(const Duration(milliseconds: 500));

      final payment = Payment(
        id: _uuid.v4(),
        orderId: '', // Would be set from context
        amount: 0,
        method: PaymentMethod.card,
        provider: PaymentProvider.paypal,
        providerPaymentId: paypalOrderId,
        status: PaymentStatus.completed,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        isProcessing: false,
        currentPayment: payment,
      );

      return payment;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Error al capturar orden PayPal: $e',
      );
      return null;
    }
  }

  /// Get payments for an order
  Future<List<Payment>> getPaymentsByOrder(String orderId) async {
    try {
      // In production, this would call the GraphQL query:
      // query GetPaymentsByOrder($orderId: UUID!) {
      //   getPaymentsByOrder(orderId: $orderId) {
      //     id
      //     orderId
      //     amount
      //     method
      //     provider
      //     status
      //     createdAt
      //   }
      // }

      await Future.delayed(const Duration(milliseconds: 300));

      // Return empty list for demo
      return [];
    } catch (e) {
      state = state.copyWith(
        error: 'Error al obtener pagos: $e',
      );
      return [];
    }
  }

  /// Refund a payment
  Future<bool> refundPayment(String paymentId) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      // In production, this would call the GraphQL mutation:
      // mutation RefundPayment($paymentId: UUID!) {
      //   refundPayment(paymentId: $paymentId) {
      //     success
      //     message
      //   }
      // }

      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(isProcessing: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Error al reembolsar: $e',
      );
      return false;
    }
  }

  /// Clear payment state
  void clearState() {
    state = state.clear();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for payment operations
final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(ref);
});

/// Provider for selected payment method (convenience)
final selectedPaymentMethodProvider = Provider<PaymentMethod>((ref) {
  return ref.watch(paymentProvider).selectedMethod;
});

/// Provider to check if payment is processing
final isPaymentProcessingProvider = Provider<bool>((ref) {
  return ref.watch(paymentProvider).isProcessing;
});
