import 'package:equatable/equatable.dart';

/// Unidades de medida
enum Unit {
  kg,
  g,
  l,
  ml,
  pz,
  caja,
  paq;

  String get symbol {
    switch (this) {
      case Unit.kg:
        return 'kg';
      case Unit.g:
        return 'g';
      case Unit.l:
        return 'L';
      case Unit.ml:
        return 'ml';
      case Unit.pz:
        return 'pz';
      case Unit.caja:
        return 'caja';
      case Unit.paq:
        return 'paq';
    }
  }

  String get displayName {
    switch (this) {
      case Unit.kg:
        return 'Kilogramos';
      case Unit.g:
        return 'Gramos';
      case Unit.l:
        return 'Litros';
      case Unit.ml:
        return 'Mililitros';
      case Unit.pz:
        return 'Piezas';
      case Unit.caja:
        return 'Cajas';
      case Unit.paq:
        return 'Paquetes';
    }
  }
}

/// Categorías de inventario
enum InventoryCategory {
  vegetables,
  fruits,
  meat,
  dairy,
  beverages,
  condiments,
  other;

  String get displayName {
    switch (this) {
      case InventoryCategory.vegetables:
        return 'Verduras';
      case InventoryCategory.fruits:
        return 'Frutas';
      case InventoryCategory.meat:
        return 'Carnes';
      case InventoryCategory.dairy:
        return 'Lácteos';
      case InventoryCategory.beverages:
        return 'Bebidas';
      case InventoryCategory.condiments:
        return 'Condimentos';
      case InventoryCategory.other:
        return 'Otros';
    }
  }
}

/// Tipos de movimiento de stock
enum MovementType {
  purchase,
  sale,
  waste,
  adjustment;

  String get displayName {
    switch (this) {
      case MovementType.purchase:
        return 'Compra';
      case MovementType.sale:
        return 'Venta';
      case MovementType.waste:
        return 'Merma';
      case MovementType.adjustment:
        return 'Ajuste';
    }
  }
}

/// Entidad de Item de Inventario
class InventoryItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final InventoryCategory category;
  final double currentStock;
  final double minStock;
  final double maxStock;
  final Unit unit;
  final double costPerUnit;
  final String? supplier;
  final DateTime? expirationDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.unit,
    required this.costPerUnit,
    this.supplier,
    this.expirationDate,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isLowStock => currentStock <= minStock;
  bool get isOutOfStock => currentStock == 0;
  bool get isNearExpiration {
    if (expirationDate == null) return false;
    return expirationDate!.difference(DateTime.now()).inDays <= 7;
  }

  double get totalValue => currentStock * costPerUnit;

  InventoryItem copyWith({
    String? id,
    String? name,
    String? description,
    InventoryCategory? category,
    double? currentStock,
    double? minStock,
    double? maxStock,
    Unit? unit,
    double? costPerUnit,
    String? supplier,
    DateTime? expirationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      unit: unit ?? this.unit,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      supplier: supplier ?? this.supplier,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        currentStock,
        minStock,
        maxStock,
        unit,
        costPerUnit,
        supplier,
        expirationDate,
        createdAt,
        updatedAt,
      ];
}

/// Entidad de Movimiento de Stock
class StockMovement extends Equatable {
  final String id;
  final String itemId;
  final String itemName;
  final MovementType type;
  final double quantity;
  final Unit unit;
  final double? cost;
  final String? reason;
  final String? notes;
  final String? performedBy;
  final DateTime date;
  final DateTime createdAt;

  const StockMovement({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.unit,
    this.cost,
    this.reason,
    this.notes,
    this.performedBy,
    required this.date,
    required this.createdAt,
  });

  double? get totalCost => cost != null ? quantity * cost! : null;

  StockMovement copyWith({
    String? id,
    String? itemId,
    String? itemName,
    MovementType? type,
    double? quantity,
    Unit? unit,
    double? cost,
    String? reason,
    String? notes,
    String? performedBy,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return StockMovement(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      cost: cost ?? this.cost,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      performedBy: performedBy ?? this.performedBy,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        itemName,
        type,
        quantity,
        unit,
        cost,
        reason,
        notes,
        performedBy,
        date,
        createdAt,
      ];
}

/// Entidad de Compra
class Purchase extends Equatable {
  final String id;
  final String supplier;
  final List<PurchaseItem> items;
  final double totalCost;
  final DateTime purchaseDate;
  final String? invoice;
  final String? notes;
  final String? purchasedBy;
  final DateTime createdAt;

  const Purchase({
    required this.id,
    required this.supplier,
    required this.items,
    required this.totalCost,
    required this.purchaseDate,
    this.invoice,
    this.notes,
    this.purchasedBy,
    required this.createdAt,
  });

  Purchase copyWith({
    String? id,
    String? supplier,
    List<PurchaseItem>? items,
    double? totalCost,
    DateTime? purchaseDate,
    String? invoice,
    String? notes,
    String? purchasedBy,
    DateTime? createdAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      supplier: supplier ?? this.supplier,
      items: items ?? this.items,
      totalCost: totalCost ?? this.totalCost,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      invoice: invoice ?? this.invoice,
      notes: notes ?? this.notes,
      purchasedBy: purchasedBy ?? this.purchasedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        supplier,
        items,
        totalCost,
        purchaseDate,
        invoice,
        notes,
        purchasedBy,
        createdAt,
      ];
}

/// Item de compra
class PurchaseItem extends Equatable {
  final String itemId;
  final String itemName;
  final double quantity;
  final Unit unit;
  final double costPerUnit;
  final double totalCost;

  const PurchaseItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.costPerUnit,
    required this.totalCost,
  });

  @override
  List<Object?> get props => [
        itemId,
        itemName,
        quantity,
        unit,
        costPerUnit,
        totalCost,
      ];
}
