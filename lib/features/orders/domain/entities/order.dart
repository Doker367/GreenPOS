import 'package:equatable/equatable.dart';
import '../../../../core/enums/order_status.dart';

/// Item individual de un pedido
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
class Order extends Equatable {
  final String id;
  final String userId;
  final String? userName;
  final String? userPhone;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double total;
  final OrderStatus status;
  final String? tableNumber;
  final String? deliveryAddress;
  final String? notes;
  final String paymentMethod;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const Order({
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
    this.status = OrderStatus.pending,
    this.tableNumber,
    this.deliveryAddress,
    this.notes,
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
    String? userId,
    String? userName,
    String? userPhone,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? discount,
    double? total,
    OrderStatus? status,
    String? tableNumber,
    String? deliveryAddress,
    String? notes,
    String? paymentMethod,
    bool? isPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      tableNumber: tableNumber ?? this.tableNumber,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
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
        userId,
        userName,
        userPhone,
        items,
        subtotal,
        tax,
        deliveryFee,
        discount,
        total,
        status,
        tableNumber,
        deliveryAddress,
        notes,
        paymentMethod,
        isPaid,
        createdAt,
        updatedAt,
        completedAt,
      ];
}
