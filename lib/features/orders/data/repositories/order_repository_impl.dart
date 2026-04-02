// Order Repository Implementation with Offline Support
// Handles both online (GraphQL) and offline (local Drift DB) order creation

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:drift/drift.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/enums/order_status.dart' as enums;
import '../../../../core/graphql/client.dart';
import '../../../../core/graphql/queries.dart';
import '../../../../core/utils/failure.dart';
import '../../../../core/services/sync_service.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

/// Implementación del repositorio de pedidos con soporte offline
/// Coincide EXACTAMENTE con el schema del backend:
/// - CreateOrderInput: { branchId, tableId, userId, customerName, customerPhone, notes, items[{productId, quantity, notes}] }
/// - Order: { id, branchId, tableId, table, user, customerName, customerPhone, status, subtotal, tax, discount, total, notes, items, createdAt, updatedAt }
class OrderRepositoryImpl implements OrderRepository {
  final GraphQLClient _client;
  final String Function() _getBranchId;

  OrderRepositoryImpl({
    GraphQLClient? client,
    required String Function() getBranchId,
  })  : _client = client ?? GraphQLClientSingleton.client,
        _getBranchId = getBranchId;

  /// Verificar si hay conexión a internet
  Future<bool> _hasConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }

  /// Helper para parsear OrderItem desde GraphQL
  OrderItem _parseOrderItem(Map<String, dynamic> json) {
    final item = json;
    return OrderItem(
      productId: item['productId'] as String? ?? '',
      productName: item['productName'] as String? ?? 'Unknown',
      productImage: item['productImage'] as String?,
      price: (item['unitPrice'] as num?)?.toDouble() ??
          (item['price'] as num?)?.toDouble() ?? 0.0,
      quantity: item['quantity'] as int? ?? 1,
      specialInstructions:
          item['notes'] as String? ?? item['specialInstructions'] as String?,
    );
  }

  /// Helper para parsear TableRef desde GraphQL
  String? _parseTableNumber(Map<String, dynamic>? tableJson) {
    return tableJson?['number'] as String?;
  }

  /// Helper para parsear Order desde GraphQL
  Order _parseOrder(Map<String, dynamic> json) {
    final tableJson = json['table'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>?;

    return Order(
      id: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? _getBranchId(),
      tableId: json['tableId'] as String? ?? tableJson?['id'] as String?,
      tableNumber:
          json['tableNumber'] as String? ?? _parseTableNumber(tableJson),
      userId: json['userId'] as String? ?? userJson?['id'] as String? ?? '',
      userName: json['userName'] as String? ?? userJson?['name'] as String?,
      userPhone: json['userPhone'] as String?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => _parseOrderItem(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: _parseOrderStatus(json['status'] as String?),
      notes: json['notes'] as String?,
      paymentMethod: 'cash',
      isPaid: json['status'] == 'PAID' || json['status'] == 'DELIVERED',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Convierte el enum local OrderStatus al string del backend GraphQL
  String _orderStatusToString(enums.OrderStatus status) {
    switch (status) {
      case enums.OrderStatus.pending:
        return 'PENDING';
      case enums.OrderStatus.accepted:
        return 'ACCEPTED';
      case enums.OrderStatus.preparing:
        return 'PREPARING';
      case enums.OrderStatus.ready:
        return 'READY';
      case enums.OrderStatus.delivered:
        return 'DELIVERED';
      case enums.OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Convierte el string del backend al enum local OrderStatus
  enums.OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return enums.OrderStatus.pending;
      case 'ACCEPTED':
        return enums.OrderStatus.accepted;
      case 'PREPARING':
        return enums.OrderStatus.preparing;
      case 'READY':
        return enums.OrderStatus.ready;
      case 'DELIVERED':
        return enums.OrderStatus.delivered;
      case 'PAID':
        return enums.OrderStatus.delivered;
      case 'CANCELLED':
        return enums.OrderStatus.cancelled;
      default:
        return enums.OrderStatus.pending;
    }
  }

  @override
  Future<Either<Failure, Order>> createOrder({
    required String userId,
    required List<OrderItem> items,
    String? tableNumber,
    String? deliveryAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    // Verificar conectividad
    final isOnline = await _hasConnectivity();

    if (isOnline) {
      // Modo online: crear orden directamente en el backend
      return _createOrderOnline(
        userId: userId,
        items: items,
        tableNumber: tableNumber,
        deliveryAddress: deliveryAddress,
        notes: notes,
        paymentMethod: paymentMethod,
      );
    } else {
      // Modo offline: guardar orden localmente
      return _createOrderOffline(
        userId: userId,
        items: items,
        tableNumber: tableNumber,
        deliveryAddress: deliveryAddress,
        notes: notes,
        paymentMethod: paymentMethod,
      );
    }
  }

  /// Crear orden online (conectado al backend)
  Future<Either<Failure, Order>> _createOrderOnline({
    required String userId,
    required List<OrderItem> items,
    String? tableNumber,
    String? deliveryAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    try {
      // Build items input matching backend schema
      final itemsInput = items.map((item) {
        return {
          'productId': item.productId,
          'quantity': item.quantity,
          if (item.specialInstructions != null) 'notes': item.specialInstructions,
        };
      }).toList();

      final input = {
        'branchId': _getBranchId(),
        'userId': userId,
        if (tableNumber != null) 'tableNumber': tableNumber,
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
        if (notes != null) 'notes': notes,
        'items': itemsInput,
      };

      final options = MutationOptions(
        document: gql(OrderGQLMutations.createOrder),
        variables: {'input': input},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al crear pedido'));
      }

      final data = result.data?['createOrder'];
      if (data == null) {
        return const Left(ServerFailure('Error al crear pedido'));
      }

      return Right(_parseOrder(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  /// Crear orden offline (guardar localmente)
  Future<Either<Failure, Order>> _createOrderOffline({
    required String userId,
    required List<OrderItem> items,
    String? tableNumber,
    String? deliveryAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    try {
      final syncService = SyncService();

      // Convertir items a JSON para almacenamiento local
      final itemsJson = jsonEncode(items.map((item) => {
        'productId': item.productId,
        'productName': item.productName,
        'unitPrice': item.price,
        'quantity': item.quantity,
        'notes': item.specialInstructions,
      }).toList());

      // Calcular totales
      final subtotal = items.fold<double>(0, (sum, item) => sum + item.price * item.quantity);
      final tax = subtotal * 0.10; // 10% tax
      final discount = 0.0;
      final total = subtotal + tax - discount;

      // Generar ID temporal para la orden local
      final localOrderId = 'local_${DateTime.now().millisecondsSinceEpoch}';

      // Guardar orden localmente
      await syncService.saveOrderLocally(
        orderId: localOrderId,
        branchId: _getBranchId(),
        userId: userId,
        tableId: tableNumber,
        customerName: null,
        customerPhone: null,
        notes: notes,
        itemsJson: itemsJson,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        total: total,
        status: 'PENDING',
      );

      // Crear objeto Order para返回值 (simulado)
      final localOrder = Order(
        id: localOrderId,
        branchId: _getBranchId(),
        tableId: tableNumber,
        tableNumber: tableNumber,
        userId: userId,
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        total: total,
        status: enums.OrderStatus.pending,
        notes: notes,
        paymentMethod: paymentMethod,
        isPaid: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return Right(localOrder);
    } catch (e) {
      return Left(LocalFailure('Error al guardar orden offline: $e'));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String id) async {
    try {
      final options = QueryOptions(
        document: gql(OrderGQLQueries.order),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client.query(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al obtener pedido'));
      }

      final data = result.data?['order'];
      if (data == null) {
        return const Left(ServerFailure('Pedido no encontrado'));
      }

      return Right(_parseOrder(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getUserOrders({
    required String userId,
    enums.OrderStatus? status,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(OrderGQLQueries.orders),
        variables: {
          'branchId': _getBranchId(),
          if (status != null) 'status': _orderStatusToString(status),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client.query(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al obtener pedidos'));
      }

      final data = result.data?['orders'] as List<dynamic>?;
      if (data == null) {
        return const Right([]);
      }

      final orders = data
          .map((e) => _parseOrder(e as Map<String, dynamic>))
          .where((order) => order.userId == userId)
          .toList();

      return Right(orders);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getAllOrders({
    enums.OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(OrderGQLQueries.orders),
        variables: {
          'branchId': _getBranchId(),
          if (status != null) 'status': _orderStatusToString(status),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client.query(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al obtener pedidos'));
      }

      final data = result.data?['orders'] as List<dynamic>?;
      if (data == null) {
        return const Right([]);
      }

      var orders = data
          .map((e) => _parseOrder(e as Map<String, dynamic>))
          .toList();

      // Filtrar por fechas si se especifican
      if (startDate != null) {
        orders = orders
            .where((o) =>
                o.createdAt.isAfter(startDate) ||
                o.createdAt.isAtSameMomentAs(startDate))
            .toList();
      }
      if (endDate != null) {
        orders = orders
            .where((o) =>
                o.createdAt.isBefore(endDate) ||
                o.createdAt.isAtSameMomentAs(endDate))
            .toList();
      }

      return Right(orders);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, Order>> updateOrderStatus({
    required String orderId,
    required enums.OrderStatus status,
  }) async {
    try {
      final options = MutationOptions(
        document: gql(OrderGQLMutations.updateOrderStatus),
        variables: {
          'id': orderId,
          'status': _orderStatusToString(status),
        },
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al actualizar estado'));
      }

      return getOrderById(orderId);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, Order>> cancelOrder(String orderId) async {
    try {
      final options = MutationOptions(
        document: gql(OrderGQLMutations.cancelOrder),
        variables: {'id': orderId},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al cancelar pedido'));
      }

      return getOrderById(orderId);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, Order>> markAsPaid(String orderId) async {
    return updateOrderStatus(
      orderId: orderId,
      status: enums.OrderStatus.delivered,
    );
  }

  @override
  Stream<Either<Failure, List<Order>>> watchOrders({
    enums.OrderStatus? status,
  }) async* {
    while (true) {
      try {
        final options = QueryOptions(
          document: gql(OrderGQLQueries.orders),
          variables: {
            'branchId': _getBranchId(),
            if (status != null) 'status': _orderStatusToString(status),
          },
          fetchPolicy: FetchPolicy.networkOnly,
        );

        final result = await _client.query(options);

        if (result.hasException) {
          yield Left(ServerFailure(
              result.exception?.graphqlErrors.firstOrNull?.message ??
                  'Error al obtener pedidos'));
        } else {
          final data = result.data?['orders'] as List<dynamic>?;
          final orders = data
                  ?.map((e) => _parseOrder(e as Map<String, dynamic>))
                  .toList() ??
              [];
          yield Right(orders);
        }
      } catch (e) {
        yield Left(ServerFailure('Error de conexión: $e'));
      }

      await Future.delayed(const Duration(seconds: 5));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getOrderStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final ordersResult = await getAllOrders(
      startDate: startDate,
      endDate: endDate,
    );

    return ordersResult.fold(
      (failure) => Left(failure),
      (orders) {
        final totalOrders = orders.length;
        final totalRevenue = orders.fold<double>(
          0.0,
          (sum, order) => sum + order.total,
        );
        final paidOrders = orders.where((o) => o.isPaid).length;
        final cancelledOrders =
            orders.where((o) => o.status == enums.OrderStatus.cancelled).length;

        return Right({
          'totalOrders': totalOrders,
          'totalRevenue': totalRevenue,
          'paidOrders': paidOrders,
          'cancelledOrders': cancelledOrders,
          'averageOrderValue':
              totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
        });
      },
    );
  }
}
