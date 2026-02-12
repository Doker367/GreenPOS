/// Opción de modificador para un producto
/// Ejemplo: "Sin cebolla", "Extra queso", "Término medio"
class ProductModifierOption {
  final String id;
  final String name;
  final double priceAdjustment; // Puede ser positivo (extra) o negativo (sin)
  final bool isDefault;

  const ProductModifierOption({
    required this.id,
    required this.name,
    this.priceAdjustment = 0.0,
    this.isDefault = false,
  });

  ProductModifierOption copyWith({
    String? id,
    String? name,
    double? priceAdjustment,
    bool? isDefault,
  }) {
    return ProductModifierOption(
      id: id ?? this.id,
      name: name ?? this.name,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModifierOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
