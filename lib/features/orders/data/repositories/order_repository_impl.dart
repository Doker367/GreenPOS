import 'package:dartz/dartz.dart' hide Order;
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/enums/order_status.dart' as enums;
import '../../../../core/graphql/client.dart';
import '../../../../core/graphql/queries.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

/// Implementación del repositorio de pedidos usando GraphQL
class OrderRepositoryImpl implements OrderRepository {
  final GraphQLClient _client;

  OrderRepositoryImpl({GraphQLClient? client})
      : _client = client ?? GraphQLClientSingleton.client;

  /// Helper para parsear OrderItem desde GraphQL
  OrderItem _parseOrderItem(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      specialInstructions: json['specialInstructions'] as String?,
    );
  }

  /// Helper para parsear Order desde GraphQL
  Order _parseOrder(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userPhone: json['userPhone'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => _parseOrderItem(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: _parseOrderStatus(json['status'] as String?) ?? enums.OrderStatus.pending,
      tableNumber: json['tableNumber'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      notes: json['notes'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      isPaid: json['isPaid'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      completedAt: _parseDateTime(json['completedAt']),
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
      case 'CANCELLED':
        return enums.OrderStatus.cancelled;
      case 'PAID':
        return enums.OrderStatus.delivered;
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
    try {
      final input = {
        'userId': userId,
        'items': items
            .map((item) => {
                  'productId': item.productId,
                  'productName': item.productName,
                  'price': item.price,
                  'quantity': item.quantity,
                  if (item.specialInstructions != null)
                    'specialInstructions': item.specialInstructions,
                })
            .toList(),
        'paymentMethod': paymentMethod,
        if (tableNumber != null) 'tableNumber': tableNumber,
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
        if (notes != null) 'notes': notes,
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
    // Por ahora se obtienen todos y se filtran por userId localmente
    // El backend no tiene un campo branchId aquí, así que usamos getAllOrders
    try {
      final options = QueryOptions(
        document: gql(OrderGQLQueries.orders),
        variables: {
          'branchId': userId, // Usamos userId como branchId temporalmente
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
          // branchId se debe obtener del contexto de autenticación
          'branchId': '00000000-0000-0000-0000-000000000000',
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

      // Obtener el pedido completo después de actualizar
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

      // Obtener el pedido completo después de cancelar
      return getOrderById(orderId);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, Order>> markAsPaid(String orderId) async {
    // Marcar como pagado es actualizar el estado a DELIVERED/PAID
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
            'branchId': '00000000-0000-0000-0000-000000000000',
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
    // Obtener pedidos y calcular estadísticas localmente
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


