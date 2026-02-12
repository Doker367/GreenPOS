import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order.dart';
import '../../../../core/enums/order_status.dart';

part 'order_model.g.dart';

/// Modelo de datos de Item de Pedido
@JsonSerializable()
class OrderItemModel {
  @JsonKey(name: 'product_id')
  final String productId;
  @JsonKey(name: 'product_name')
  final String productName;
  @JsonKey(name: 'product_image')
  final String? productImage;
  final double price;
  final int quantity;
  @JsonKey(name: 'special_instructions')
  final String? specialInstructions;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    this.specialInstructions,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  factory OrderItemModel.fromEntity(OrderItem item) {
    return OrderItemModel(
      productId: item.productId,
      productName: item.productName,
      productImage: item.productImage,
      price: item.price,
      quantity: item.quantity,
      specialInstructions: item.specialInstructions,
    );
  }

  OrderItem toEntity() {
    return OrderItem(
      productId: productId,
      productName: productName,
      productImage: productImage,
      price: price,
      quantity: quantity,
      specialInstructions: specialInstructions,
    );
  }
}

/// Modelo de datos de Pedido (Data Layer)
@JsonSerializable()
class OrderModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'user_name')
  final String? userName;
  @JsonKey(name: 'user_phone')
  final String? userPhone;
  final List<OrderItemModel> items;
  final double subtotal;
  final double tax;
  @JsonKey(name: 'delivery_fee')
  final double deliveryFee;
  final double discount;
  final double total;
  final String status;
  @JsonKey(name: 'table_number')
  final String? tableNumber;
  @JsonKey(name: 'delivery_address')
  final String? deliveryAddress;
  final String? notes;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @JsonKey(name: 'is_paid')
  final bool isPaid;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userPhone,
    required this.items,
    required this.subtotal,
    this.tax = 0.0,
    this.deliveryFee = 0.0,
    this.discount = 0.0,
    required this.total,
    this.status = 'pending',
    this.tableNumber,
    this.deliveryAddress,
    this.notes,
    this.paymentMethod = 'cash',
    this.isPaid = false,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      userId: order.userId,
      userName: order.userName,
      userPhone: order.userPhone,
      items: order.items.map((e) => OrderItemModel.fromEntity(e)).toList(),
      subtotal: order.subtotal,
      tax: order.tax,
      deliveryFee: order.deliveryFee,
      discount: order.discount,
      total: order.total,
      status: order.status.value,
      tableNumber: order.tableNumber,
      deliveryAddress: order.deliveryAddress,
      notes: order.notes,
      paymentMethod: order.paymentMethod,
      isPaid: order.isPaid,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      completedAt: order.completedAt,
    );
  }

  Order toEntity() {
    return Order(
      id: id,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      items: items.map((e) => e.toEntity()).toList(),
      subtotal: subtotal,
      tax: tax,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      status: OrderStatus.fromString(status),
      tableNumber: tableNumber,
      deliveryAddress: deliveryAddress,
      notes: notes,
      paymentMethod: paymentMethod,
      isPaid: isPaid,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
    );
  }
}
