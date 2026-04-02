// FILE: /home/node/.openclaw/workspace/greenpos/frontend/lib/features/pos/domain/entities/pos_order.dart
// STATUS: Update to support backend schema
// PERMISSION ISSUE: Files are owned by root, cannot write directly

import '../../../../core/enums/pos_order_status.dart';
import 'pos_order_item.dart';
import 'discount.dart';
import 'extra_charge.dart';

/// Pedido activo en el POS
/// Updated to match backend schema: customerName, customerPhone, tableId, branchId
class POSOrder {
  final String id;
  final String? tableId;
  final String? tableName;
  final String? customerName;
  final String? customerPhone;
  final String? branchId; // Required for backend
  final List<POSOrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final Discount? discount; // Descuento aplicado al pedido
  final List<ExtraCharge> extraCharges; // Cargos extras

  const POSOrder({
    required this.id,
    this.tableId,
    this.tableName,
    this.customerName,
    this.customerPhone,
    this.branchId,
    required this.items,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.discount,
    this.extraCharges = const [],
  });

  /// Subtotal (suma de todos los items)
  double get subtotal {
    return items.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );
  }

  /// Monto de descuento aplicado
  double get discountAmount {
    if (discount == null) return 0.0;
    return discount!.calculateDiscount(subtotal);
  }

  /// Monto total de cargos extras
  double get extraChargesAmount {
    return extraCharges.fold<double>(
      0.0,
      (sum, charge) => sum + charge.calculateCharge(subtotal),
    );
  }

  /// Subtotal después del descuento y con cargos extras
  double get subtotalAfterDiscount {
    return subtotal - discountAmount + extraChargesAmount;
  }

  /// Impuesto (IVA 16% sobre subtotal con descuento y cargos)
  double get tax {
    return subtotalAfterDiscount * 0.16;
  }

  /// Total a pagar
  double get total {
    return subtotalAfterDiscount + tax;
  }

  /// Cantidad total de items (suma de cantidades)
  int get totalItems {
    return items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  /// Verifica si el pedido tiene items
  bool get hasItems => items.isNotEmpty;

  /// Verifica si el pedido está asignado a una mesa
  bool get hasTable => tableId != null && tableName != null;

  /// Verifica si se puede enviar a cocina
  bool get canSendToKitchen {
    return hasItems && status == OrderStatus.draft;
  }

  /// Verifica si se puede cobrar
  bool get canCheckout {
    return hasItems && 
           (status == OrderStatus.ready || 
            status == OrderStatus.served ||
            status == OrderStatus.draft);
  }

  /// Convierte a input para GraphQL mutation
  Map<String, dynamic> toCreateOrderInput({
    required String userId,
  }) {
    return {
      'branchId': branchId, // Must be provided
      'userId': userId,
      if (tableId != null) 'tableId': tableId,
      if (customerName != null && customerName!.isNotEmpty) 'customerName': customerName,
      if (customerPhone != null && customerPhone!.isNotEmpty) 'customerPhone': customerPhone,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'items': items.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
        if (item.notes != null && item.notes!.isNotEmpty) 'notes': item.notes,
      }).toList(),
    };
  }

  POSOrder copyWith({
    String? id,
    String? tableId,
    String? tableName,
    String? customerName,
    String? customerPhone,
    String? branchId,
    List<POSOrderItem>? items,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    Discount? discount,
    List<ExtraCharge>? extraCharges,
  }) {
    return POSOrder(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      branchId: branchId ?? this.branchId,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      discount: discount ?? this.discount,
      extraCharges: extraCharges ?? this.extraCharges,
    );
  }

  /// Crea una copia limpiando la mesa asignada
  POSOrder clearTable() {
    return copyWith(
      tableId: null,
      tableName: null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is POSOrder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'POSOrder(id: $id, table: $tableName, items: ${items.length}, total: \$${total.toStringAsFixed(2)}, status: ${status.displayName})';
  }
}
