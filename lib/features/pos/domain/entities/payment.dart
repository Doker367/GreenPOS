/// Método de pago
enum PaymentMethod {
  cash,
  card,
  transfer,
  mixed,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.transfer:
        return 'Transferencia';
      case PaymentMethod.mixed:
        return 'Mixto';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.cash:
        return '💵';
      case PaymentMethod.card:
        return '💳';
      case PaymentMethod.transfer:
        return '📱';
      case PaymentMethod.mixed:
        return '💰';
    }
  }
}

/// Información de pago de una orden
class Payment {
  final String id;
  final String orderId;
  final PaymentMethod method;
  final double amount;
  final double? cashReceived;
  final double? change;
  final double? tipAmount;
  final String? reference;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.orderId,
    required this.method,
    required this.amount,
    this.cashReceived,
    this.change,
    this.tipAmount,
    this.reference,
    required this.createdAt,
  });

  Payment copyWith({
    String? id,
    String? orderId,
    PaymentMethod? method,
    double? amount,
    double? cashReceived,
    double? change,
    double? tipAmount,
    String? reference,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      cashReceived: cashReceived ?? this.cashReceived,
      change: change ?? this.change,
      tipAmount: tipAmount ?? this.tipAmount,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
