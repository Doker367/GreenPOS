// FILE: /home/node/.openclaw/workspace/greenpos/frontend/lib/features/orders/domain/entities/order.dart
// STATUS: Needs update - fields don't match backend schema
// PERMISSION ISSUE: Files are owned by root, cannot write directly

import 'package:equatable/equatable.dart';
import '../../../../core/enums/order_status.dart';

/// Item individual de un pedido
/// Backend: { productId, quantity, notes }
class OrderItem extends Equatable {
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final String? specialInstructions;

  const OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    this.specialInstructions,
  });

  /// Subtotal del item (precio * cantidad)
  double get subtotal => price * quantity;

  OrderItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? specialInstructions,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        productName,
        productImage,
        price,
        quantity,
        specialInstructions,
      ];
}

/// Entidad de Pedido (Dominio)
/// Backend schema: { id, branchId, tableId, table{number}, user{name}, customerName, customerPhone, status, subtotal, tax, discount, total, notes, items, createdAt, updatedAt }
/// NOT: userId, userName, userPhone, deliveryFee, deliveryAddress, paymentMethod, isPaid, tableNumber, completedAt
class Order extends Equatable {
  final String id;
  final String? branchId;
  final String? tableId;
  final String? tableNumber;
  final String userId;
  final String? userName;
  final String? userPhone;
  final String? customerName;
  final String? customerPhone;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final OrderStatus status;
  final String? notes;
  // Backend doesn't have these fields - they come from the parent objects
  final String? deliveryFee;
  final String? deliveryAddress;
  final String paymentMethod;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const Order({
    required this.id,
    this.branchId,
    this.tableId,
    this.tableNumber,
    required this.userId,
    this.userName,
    this.userPhone,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    this.tax = 0.0,
    this.discount = 0.0,
    required this.total,
    this.status = OrderStatus.pending,
    this.notes,
    this.deliveryFee,
    this.deliveryAddress,
    this.paymentMethod = 'cash',
    this.isPaid = false,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  /// Número total de items
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  Order copyWith({
    String? id,
    String? branchId,
    String? tableId,
    String? tableNumber,
    String? userId,
    String? userName,
    String? userPhone,
    String? customerName,
    String? customerPhone,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    OrderStatus? status,
    String? notes,
    String? deliveryFee,
    String? deliveryAddress,
    String? paymentMethod,
    bool? isPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        branchId,
        tableId,
        tableNumber,
        userId,
        userName,
        userPhone,
        customerName,
        customerPhone,
        items,
        subtotal,
        tax,
        discount,
        total,
        status,
        notes,
        paymentMethod,
        isPaid,
        createdAt,
        updatedAt,
        completedAt,
      ];
}
