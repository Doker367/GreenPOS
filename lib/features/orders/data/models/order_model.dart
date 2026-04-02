// FILE: /home/node/.openclaw/workspace/greenpos/frontend/lib/features/orders/data/models/order_model.dart
// STATUS: Needs to replace existing file
// PERMISSION ISSUE: Files are owned by root, cannot write directly

import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

/// Modelo de Item de Pedido que coincide con el schema GraphQL del backend
/// Backend: items[{productId, quantity, notes}]
@JsonSerializable()
class OrderItemModel {
  @JsonKey(name: 'productId')
  final String productId;
  
  @JsonKey(name: 'quantity')
  final int quantity;
  
  @JsonKey(name: 'notes')
  final String? notes;

  // Campos opcionales que el backend puede devolver
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'unitPrice')
  final double? unitPrice;

  @JsonKey(name: 'totalPrice')
  final double? totalPrice;

  const OrderItemModel({
    required this.productId,
    required this.quantity,
    this.notes,
    this.id,
    this.unitPrice,
    this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  /// Crea desde el input de creación (sin id, sin precios)
  factory OrderItemModel.fromCreateInput({
    required String productId,
    required int quantity,
    String? notes,
  }) {
    return OrderItemModel(
      productId: productId,
      quantity: quantity,
      notes: notes,
    );
  }
}

/// Modelo de Pedido que coincide EXACTAMENTE con el schema GraphQL del backend
/// Schema backend:
///   - customerName: String
///   - customerPhone: String
///   - tableId: UUID
///   - branchId: UUID
///   - items: [{productId, quantity, notes}]
///   - status: OrderStatus!
///   - subtotal, tax, discount, total: Float!
///   - notes: String
///   - createdAt, updatedAt: Time!
@JsonSerializable()
class OrderModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'branchId')
  final String? branchId;

  @JsonKey(name: 'tableId')
  final String? tableId;

  @JsonKey(name: 'table')
  final TableRefModel? table;

  @JsonKey(name: 'user')
  final UserRefModel? user;

  @JsonKey(name: 'userId')
  final String? userId;

  @JsonKey(name: 'customerName')
  final String? customerName;

  @JsonKey(name: 'customerPhone')
  final String? customerPhone;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'subtotal')
  final double subtotal;

  @JsonKey(name: 'tax')
  final double tax;

  @JsonKey(name: 'discount')
  final double discount;

  @JsonKey(name: 'total')
  final double total;

  @JsonKey(name: 'notes')
  final String? notes;

  @JsonKey(name: 'items')
  final List<OrderItemModel>? items;

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    this.branchId,
    this.tableId,
    this.table,
    this.user,
    this.userId,
    this.customerName,
    this.customerPhone,
    this.status = 'PENDING',
    this.subtotal = 0.0,
    this.tax = 0.0,
    this.discount = 0.0,
    this.total = 0.0,
    this.notes,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  /// Número de mesa si está disponible
  String? get tableNumber => table?.number;

  /// Nombre del mesero/usuario
  String? get userName => user?.name;

  /// Total de items en el pedido
  int get totalItems => items?.fold(0, (sum, item) => sum + item.quantity) ?? 0;
}

/// Referencia simplificada a mesa
@JsonSerializable()
class TableRefModel {
  final String id;
  @JsonKey(name: 'number')
  final String? number;
  @JsonKey(name: 'status')
  final String? status;

  const TableRefModel({
    required this.id,
    this.number,
    this.status,
  });

  factory TableRefModel.fromJson(Map<String, dynamic> json) =>
      _$TableRefModelFromJson(json);

  Map<String, dynamic> toJson() => _$TableRefModelToJson(this);
}

/// Referencia simplificada a usuario
@JsonSerializable()
class UserRefModel {
  final String id;
  final String? name;
  final String? email;

  const UserRefModel({
    required this.id,
    this.name,
    this.email,
  });

  factory UserRefModel.fromJson(Map<String, dynamic> json) =>
      _$UserRefModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserRefModelToJson(this);
}
