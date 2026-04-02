import 'order_modifier.dart';

/// Item individual dentro de un pedido POS
class POSOrderItem {
  final String id;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final List<OrderModifier> modifiers;
  final String? notes;

  const POSOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.modifiers = const [],
    this.notes,
  });

  /// Subtotal del item (precio unitario * cantidad + modificadores)
  double get subtotal {
    final modifiersTotal = modifiers.fold<double>(
      0.0,
      (sum, modifier) => sum + modifier.priceAdjustment,
    );
    return (unitPrice + modifiersTotal) * quantity;
  }

  /// Precio unitario incluyendo modificadores
  double get adjustedUnitPrice {
    final modifiersTotal = modifiers.fold<double>(
      0.0,
      (sum, modifier) => sum + modifier.priceAdjustment,
    );
    return unitPrice + modifiersTotal;
  }

  POSOrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    List<OrderModifier>? modifiers,
    String? notes,
  }) {
    return POSOrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      modifiers: modifiers ?? this.modifiers,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is POSOrderItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'POSOrderItem(id: $id, product: $productName, qty: $quantity, subtotal: \$${subtotal.toStringAsFixed(2)})';
  }
}
