import '../entities/kitchen_order_entity.dart';

/// Repository interface for kitchen order operations
abstract class KitchenRepository {
  /// Fetches all orders currently in PREPARING status for the given branch
  Future<List<KitchenOrderEntity>> getKitchenOrders(String branchId);

  /// Marks an order as ready (completed by kitchen)
  Future<KitchenOrderEntity> markOrderReady(String orderId);

  /// Subscribes to kitchen order updates (for future real-time support)
  Stream<List<KitchenOrderEntity>> watchKitchenOrders(String branchId);
}