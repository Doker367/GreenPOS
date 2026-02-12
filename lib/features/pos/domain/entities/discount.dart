/// Tipo de descuento
enum DiscountType {
  percentage, // Porcentaje del total
  fixed, // Monto fijo
}

/// Descuento aplicable a un pedido
class Discount {
  final String id;
  final String name;
  final DiscountType type;
  final double value; // Porcentaje (0-100) o monto fijo
  final String? description;
  final bool requiresAuthorization; // Requiere autorización de gerente
  final DateTime? validFrom;
  final DateTime? validUntil;

  const Discount({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.description,
    this.requiresAuthorization = false,
    this.validFrom,
    this.validUntil,
  });

  /// Calcula el monto del descuento según el subtotal
  double calculateDiscount(double subtotal) {
    if (!isValid) return 0.0;
    
    switch (type) {
      case DiscountType.percentage:
        return subtotal * (value / 100);
      case DiscountType.fixed:
        return value > subtotal ? subtotal : value;
    }
  }

  /// Verifica si el descuento está vigente
  bool get isValid {
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    return true;
  }

  /// Descripción legible del descuento
  String get displayValue {
    switch (type) {
      case DiscountType.percentage:
        return '${value.toStringAsFixed(0)}%';
      case DiscountType.fixed:
        return '\$${value.toStringAsFixed(2)}';
    }
  }

  Discount copyWith({
    String? id,
    String? name,
    DiscountType? type,
    double? value,
    String? description,
    bool? requiresAuthorization,
    DateTime? validFrom,
    DateTime? validUntil,
  }) {
    return Discount(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      description: description ?? this.description,
      requiresAuthorization: requiresAuthorization ?? this.requiresAuthorization,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Discount && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
