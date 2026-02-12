/// Tipo de cargo extra
enum ExtraChargeType {
  percentage, // Porcentaje del subtotal
  fixed, // Monto fijo
}

/// Cargo extra aplicable a un pedido (vasos rotos, propinas, extras, etc.)
class ExtraCharge {
  final String id;
  final String name;
  final ExtraChargeType type;
  final double value; // Porcentaje (0-100) o monto fijo
  final String? description;
  final bool requiresAuthorization; // Requiere autorización de gerente

  const ExtraCharge({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.description,
    this.requiresAuthorization = false,
  });

  /// Calcula el monto del cargo según el subtotal
  double calculateCharge(double subtotal) {
    switch (type) {
      case ExtraChargeType.percentage:
        return subtotal * (value / 100);
      case ExtraChargeType.fixed:
        return value;
    }
  }

  /// Descripción legible del cargo
  String get displayValue {
    switch (type) {
      case ExtraChargeType.percentage:
        return '${value.toStringAsFixed(0)}%';
      case ExtraChargeType.fixed:
        return '\$${value.toStringAsFixed(2)}';
    }
  }

  ExtraCharge copyWith({
    String? id,
    String? name,
    ExtraChargeType? type,
    double? value,
    String? description,
    bool? requiresAuthorization,
  }) {
    return ExtraCharge(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      description: description ?? this.description,
      requiresAuthorization: requiresAuthorization ?? this.requiresAuthorization,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExtraCharge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
