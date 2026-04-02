/// Entity representing a kitchen order item
class KitchenOrderItemEntity {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final String? notes;
  final double? unitPrice;

  const KitchenOrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    this.notes,
    this.unitPrice,
  });

  /// Whether this item has special notes
  bool get hasNotes => notes != null && notes!.isNotEmpty;
}

/// Entity representing an order in the Kitchen Display System
class KitchenOrderEntity {
  final String id;
  final String? tableNumber;
  final String? customerName;
  final String status;
  final List<KitchenOrderItemEntity> items;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const KitchenOrderEntity({
    required this.id,
    this.tableNumber,
    this.customerName,
    required this.status,
    required this.items,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Total number of items in the order
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Whether the order has any items with notes
  bool get hasSpecialNotes => items.any((item) => item.hasNotes) || (notes != null && notes!.isNotEmpty);

  /// Wait time since order was created
  Duration get waitTime => DateTime.now().difference(createdAt);

  /// Wait time in minutes
  int get waitTimeMinutes => waitTime.inMinutes;

  /// Priority level based on wait time
  KitchenPriority get priority {
    if (waitTimeMinutes > 15) return KitchenPriority.critical;
    if (waitTimeMinutes > 10) return KitchenPriority.urgent;
    if (waitTimeMinutes > 5) return KitchenPriority.warning;
    return KitchenPriority.normal;
  }

  /// Whether the order is overdue (>10 minutes)
  bool get isOverdue => waitTimeMinutes > 10;
}

/// Priority levels for kitchen orders
enum KitchenPriority {
  normal,
  warning,
  urgent,
  critical,
}

extension KitchenPriorityExtension on KitchenPriority {
  String get label {
    switch (this) {
      case KitchenPriority.normal:
        return 'Normal';
      case KitchenPriority.warning:
        return 'Atención';
      case KitchenPriority.urgent:
        return 'Urgente';
      case KitchenPriority.critical:
        return 'CRÍTICO';
    }
  }

  int get sortOrder {
    switch (this) {
      case KitchenPriority.critical:
        return 0;
      case KitchenPriority.urgent:
        return 1;
      case KitchenPriority.warning:
        return 2;
      case KitchenPriority.normal:
        return 3;
    }
  }
}