import 'package:dartz/dartz.dart';
import '../../../../core/enums/order_status.dart';
import '../../../../core/utils/failure.dart';
import '../entities/order.dart';

/// Repositorio de pedidos (Interfaz del dominio)
abstract class OrderRepository {
  /// Crear nuevo pedido
  Future<Either<Failure, Order>> createOrder({
    required String userId,
    required List<OrderItem> items,
    String? tableNumber,
    String? deliveryAddress,
    String? notes,
    required String paymentMethod,
  });

  /// Obtener pedido por ID
  Future<Either<Failure, Order>> getOrderById(String id);

  /// Obtener pedidos del usuario actual
  Future<Either<Failure, List<Order>>> getUserOrders({
    required String userId,
    OrderStatus? status,
  });

  /// Obtener todos los pedidos (Admin)
  Future<Either<Failure, List<Order>>> getAllOrders({
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Actualizar estado del pedido (Admin/Staff)
  Future<Either<Failure, Order>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  });

  /// Cancelar pedido
  Future<Either<Failure, Order>> cancelOrder(String orderId);

  /// Marcar pedido como pagado
  Future<Either<Failure, Order>> markAsPaid(String orderId);

  /// Stream de pedidos en tiempo real (Admin/Staff)
  Stream<Either<Failure, List<Order>>> watchOrders({
    OrderStatus? status,
  });

  /// Obtener estadísticas de pedidos (Admin)
  Future<Either<Failure, Map<String, dynamic>>> getOrderStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });
}
