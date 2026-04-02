import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/kitchen_order_entity.dart';
import '../../data/repositories/kitchen_repository_impl.dart';

/// State for kitchen orders
class KitchenOrdersState {
  final List<KitchenOrderEntity> orders;
  final bool isLoading;
  final String? error;
  final Set<String> newOrderIds; // IDs of orders that just arrived (for highlighting)

  const KitchenOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.newOrderIds = const {},
  });

  KitchenOrdersState copyWith({
    List<KitchenOrderEntity>? orders,
    bool? isLoading,
    String? error,
    Set<String>? newOrderIds,
  }) {
    return KitchenOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      newOrderIds: newOrderIds ?? this.newOrderIds,
    );
  }

  /// Get orders sorted by priority (most urgent first)
  List<KitchenOrderEntity> get sortedOrders {
    final sorted = List<KitchenOrderEntity>.from(orders);
    sorted.sort((a, b) {
      // First by priority
      final priorityCompare = a.priority.sortOrder.compareTo(b.priority.sortOrder);
      if (priorityCompare != 0) return priorityCompare;
      // Then by creation time (oldest first)
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  }
}

/// Notifier for managing kitchen orders with polling
class KitchenOrdersNotifier extends StateNotifier<KitchenOrdersState> {
  final String branchId;
  final KitchenRepository _repository;
  Timer? _pollingTimer;
  Set<String> _previousOrderIds = {};

  KitchenOrdersNotifier({
    required this.branchId,
    KitchenRepository? repository,
  })  : _repository = repository ?? KitchenRepositoryImpl(),
        super(const KitchenOrdersState()) {
    _startPolling();
  }

  /// Start polling for kitchen orders every 3 seconds
  void _startPolling() {
    // Initial fetch
    fetchOrders();
    
    // Set up periodic polling
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchOrders();
    });
  }

  /// Fetch orders from backend
  Future<void> fetchOrders() async {
    try {
      final orders = await _repository.getKitchenOrders(branchId);
      
      // Detect new orders (not in previous list)
      final currentIds = orders.map((o) => o.id).toSet();
      final newIds = currentIds.difference(_previousOrderIds);
      
      // Update state with new orders highlighted
      state = state.copyWith(
        orders: orders,
        isLoading: false,
        newOrderIds: newIds,
      );
      
      // Clear new order highlights after 5 seconds
      if (newIds.isNotEmpty) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            state = state.copyWith(newOrderIds: {});
          }
        });
      }
      
      _previousOrderIds = currentIds;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Mark an order as ready (completed by kitchen)
  Future<void> markOrderReady(String orderId) async {
    try {
      await _repository.markOrderReady(orderId);
      // Remove from list after marking as ready
      state = state.copyWith(
        orders: state.orders.where((o) => o.id != orderId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Manually refresh orders
  Future<void> refresh() => fetchOrders();

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

/// Provider for kitchen orders state
final kitchenOrdersProvider =
    StateNotifierProvider.family<KitchenOrdersNotifier, KitchenOrdersState, String>(
  (ref, branchId) => KitchenOrdersNotifier(branchId: branchId),
);

/// Provider for a single kitchen order by ID
final kitchenOrderByIdProvider = Provider.family<KitchenOrderEntity?, String>((ref, orderId) {
  final state = ref.watch(kitchenOrdersProvider(orderId));
  try {
    return state.orders.firstWhere((o) => o.id == orderId);
  } catch (_) {
    return null;
  }
});