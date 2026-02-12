// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      specialInstructions: json['special_instructions'] as String?,
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'product_name': instance.productName,
      'product_image': instance.productImage,
      'price': instance.price,
      'quantity': instance.quantity,
      'special_instructions': instance.specialInstructions,
    };

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      userPhone: json['user_phone'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      tableNumber: json['table_number'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      notes: json['notes'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      isPaid: json['is_paid'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'user_name': instance.userName,
      'user_phone': instance.userPhone,
      'items': instance.items,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'delivery_fee': instance.deliveryFee,
      'discount': instance.discount,
      'total': instance.total,
      'status': instance.status,
      'table_number': instance.tableNumber,
      'delivery_address': instance.deliveryAddress,
      'notes': instance.notes,
      'payment_method': instance.paymentMethod,
      'is_paid': instance.isPaid,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };
