import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/kitchen_order_entity.dart';

part 'kitchen_order_model.g.dart';

/// GraphQL model for kitchen order item
@JsonSerializable()
class KitchenOrderItemModel {
  final String id;
  @JsonKey(name: 'productId')
  final String productId;
  @JsonKey(name: 'productName')
  final String? productName;
  final int quantity;
  final String? notes;
  @JsonKey(name: 'unitPrice')
  final double? unitPrice;

  const KitchenOrderItemModel({
    required this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    this.notes,
    this.unitPrice,
  });

  factory KitchenOrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$KitchenOrderItemModelToJson(this);

  /// Convert to domain entity
  KitchenOrderItemEntity toEntity() {
    return KitchenOrderItemEntity(
      id: id,
      productId: productId,
      productName: productName ?? 'Producto',
      quantity: quantity,
      notes: notes,
      unitPrice: unitPrice,
    );
  }
}

/// GraphQL model for kitchen order
@JsonSerializable()
class KitchenOrderModel {
  final String id;
  @JsonKey(name: 'tableId')
  final String? tableId;
  @JsonKey(name: 'table')
  final TableRefModel? table;
  @JsonKey(name: 'customerName')
  final String? customerName;
  @JsonKey(name: 'status')
  final String status;
  @JsonKey(name: 'items')
  final List<KitchenOrderItemModel>? items;
  @JsonKey(name: 'notes')
  final String? notes;
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  const KitchenOrderModel({
    required this.id,
    this.tableId,
    this.table,
    this.customerName,
    required this.status,
    this.items,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory KitchenOrderModel.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$KitchenOrderModelToJson(this);

  /// Convert to domain entity
  KitchenOrderEntity toEntity() {
    return KitchenOrderEntity(
      id: id,
      tableNumber: table?.number,
      customerName: customerName,
      status: status,
      items: items?.map((i) => i.toEntity()).toList() ?? [],
      notes: notes,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }
}

/// Simplified table reference
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