/// Tipo de modificador para un producto
enum ModifierType {
  /// Quitar ingrediente (sin costo adicional)
  remove,
  
  /// Agregar ingrediente (puede tener costo)
  add,
  
  /// Reemplazar ingrediente (puede tener costo)
  replace,
}

/// Modificador de un item de pedido
class OrderModifier {
  final String id;
  final String name;
  final double priceAdjustment;
  final ModifierType type;

  const OrderModifier({
    required this.id,
    required this.name,
    required this.priceAdjustment,
    required this.type,
  });

  OrderModifier copyWith({
    String? id,
    String? name,
    double? priceAdjustment,
    ModifierType? type,
  }) {
    return OrderModifier(
      id: id ?? this.id,
      name: name ?? this.name,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModifier && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
