import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/enums/pos_order_status.dart';
import '../../../menu/domain/entities/product.dart';
import '../../domain/entities/pos_order.dart';
import '../../domain/entities/pos_order_item.dart';
import '../../domain/entities/order_modifier.dart';
import '../../domain/entities/discount.dart';
import '../../domain/entities/extra_charge.dart';

/// Estado del pedido activo en el POS
class ActiveOrderState {
  final POSOrder? order;
  final bool isLoading;
  final String? error;

  const ActiveOrderState({
    this.order,
    this.isLoading = false,
    this.error,
  });

  /// Verifica si hay items en el pedido
  bool get hasItems => order != null && order!.hasItems;

  /// Total del pedido
  double get total => order?.total ?? 0.0;

  /// Subtotal del pedido
  double get subtotal => order?.subtotal ?? 0.0;

  /// Impuesto del pedido
  double get tax => order?.tax ?? 0.0;

  /// Cantidad de items
  int get itemCount => order?.totalItems ?? 0;

  ActiveOrderState copyWith({
    POSOrder? order,
    bool? isLoading,
    String? error,
  }) {
    return ActiveOrderState(
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Crea un estado limpio (sin pedido)
  ActiveOrderState clear() {
    return const ActiveOrderState();
  }
}

/// Notifier del pedido activo
class ActiveOrderNotifier extends StateNotifier<ActiveOrderState> {
  ActiveOrderNotifier() : super(const ActiveOrderState());

  final _uuid = const Uuid();

  /// Crea un nuevo pedido vacío
  void _initializeOrderIfNeeded() {
    if (state.order == null) {
      final newOrder = POSOrder(
        id: _uuid.v4(),
        items: [],
        status: OrderStatus.draft,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(order: newOrder);
    }
  }

  /// Agregar producto al pedido
  void addProduct(Product product, {int quantity = 1}) {
    _initializeOrderIfNeeded();

    final currentOrder = state.order!;

    // Buscar si el producto ya existe en el pedido
    final existingItemIndex = currentOrder.items.indexWhere(
      (item) => item.productId == product.id && item.modifiers.isEmpty,
    );

    List<POSOrderItem> updatedItems;

    if (existingItemIndex != -1) {
      // Si existe, incrementar cantidad
      final existingItem = currentOrder.items[existingItemIndex];
      updatedItems = List.from(currentOrder.items);
      updatedItems[existingItemIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Si no existe, agregar nuevo item
      final newItem = POSOrderItem(
        id: _uuid.v4(),
        productId: product.id,
        productName: product.name,
        unitPrice: product.price,
        quantity: quantity,
        modifiers: [],
      );
      updatedItems = [...currentOrder.items, newItem];
    }

    final updatedOrder = currentOrder.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Incrementar cantidad de un item
  void incrementItem(String itemId) {
    if (state.order == null) return;

    final currentOrder = state.order!;
    final itemIndex = currentOrder.items.indexWhere((item) => item.id == itemId);

    if (itemIndex == -1) return;

    final updatedItems = List<POSOrderItem>.from(currentOrder.items);
    final item = updatedItems[itemIndex];
    updatedItems[itemIndex] = item.copyWith(quantity: item.quantity + 1);

    final updatedOrder = currentOrder.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Decrementar cantidad de un item
  void decrementItem(String itemId) {
    if (state.order == null) return;

    final currentOrder = state.order!;
    final itemIndex = currentOrder.items.indexWhere((item) => item.id == itemId);

    if (itemIndex == -1) return;

    final updatedItems = List<POSOrderItem>.from(currentOrder.items);
    final item = updatedItems[itemIndex];

    if (item.quantity > 1) {
      // Decrementar cantidad
      updatedItems[itemIndex] = item.copyWith(quantity: item.quantity - 1);
    } else {
      // Si la cantidad es 1, eliminar el item
      updatedItems.removeAt(itemIndex);
    }

    final updatedOrder = currentOrder.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Eliminar item del pedido
  void removeItem(String itemId) {
    if (state.order == null) return;

    final currentOrder = state.order!;
    final updatedItems = currentOrder.items.where((item) => item.id != itemId).toList();

    final updatedOrder = currentOrder.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Agregar nota a un item específico
  void addItemNote(String itemId, String note) {
    if (state.order == null) return;

    final currentOrder = state.order!;
    final itemIndex = currentOrder.items.indexWhere((item) => item.id == itemId);

    if (itemIndex == -1) return;

    final updatedItems = List<POSOrderItem>.from(currentOrder.items);
    updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(notes: note);

    final updatedOrder = currentOrder.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Agregar modificador a un item
  void addModifierToItem(String itemId, OrderModifier modifier) {
    if (state.order == null) return;

    final currentOrder = state.order!;
    final itemIndex = currentOrder.items.indexWhere((item) => item.id == itemId);

    if (itemIndex == -1) return;

    final item = currentOrder.items[itemIndex];
    final updatedModifiers = [...item.modifiers, modifier];

    final updatedItems = List<POSOrderItem>.from(currentOrder.items);
    updatedItems[itemIndex] = item.copyWith(modifiers: updatedModifiers);

    final updatedOrder = currentOrder.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Asignar mesa al pedido
  void assignTable(String tableId, String tableName) {
    if (state.order == null) {
      _initializeOrderIfNeeded();
    }

    final currentOrder = state.order!;
    final updatedOrder = currentOrder.copyWith(
      tableId: tableId,
      tableName: tableName,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Quitar mesa del pedido
  void clearTable() {
    if (state.order == null) return;

    final currentOrder = state.order!;
    final updatedOrder = currentOrder.clearTable().copyWith(
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Agregar nota general al pedido
  void setOrderNotes(String notes) {
    if (state.order == null) return;

    final currentOrder = state.order!;
    final updatedOrder = currentOrder.copyWith(
      notes: notes,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Limpiar pedido (cancelar)
  void clearOrder() {
    state = state.clear();
  }

  /// Cambiar estado del pedido
  void updateOrderStatus(OrderStatus status) {
    if (state.order == null) return;

    final currentOrder = state.order!;
    final updatedOrder = currentOrder.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Aplicar descuento al pedido
  void applyDiscount(Discount discount) {
    if (state.order == null) {
      _initializeOrderIfNeeded();
    }

    final currentOrder = state.order!;
    final updatedOrder = currentOrder.copyWith(
      discount: discount,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Remover descuento del pedido
  void removeDiscount() {
    if (state.order == null) return;

    final currentOrder = state.order!;
    final updatedOrder = POSOrder(
      id: currentOrder.id,
      tableId: currentOrder.tableId,
      tableName: currentOrder.tableName,
      customerName: currentOrder.customerName,
      items: currentOrder.items,
      status: currentOrder.status,
      createdAt: currentOrder.createdAt,
      updatedAt: DateTime.now(),
      notes: currentOrder.notes,
      discount: null,
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Agregar producto con modificadores
  void addProductWithModifiers(
    Product product,
    List<OrderModifier> modifiers, {
    int quantity = 1,
    String? notes,
  }) {
    _initializeOrderIfNeeded();

    final currentOrder = state.order!;

    final newItem = POSOrderItem(
      id: _uuid.v4(),
      productId: product.id,
      productName: product.name,
      unitPrice: product.price,
      quantity: quantity,
      modifiers: modifiers,
      notes: notes,
    );

    final updatedItems = [...currentOrder.items, newItem];
    final updatedOrder = currentOrder.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Actualizar modificadores de un item
  void updateItemModifiers(String itemId, List<OrderModifier> modifiers) {
    if (state.order == null) return;

    final currentOrder = state.order!;
    final itemIndex = currentOrder.items.indexWhere((item) => item.id == itemId);

    if (itemIndex == -1) return;

    final updatedItems = List<POSOrderItem>.from(currentOrder.items);
    updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(modifiers: modifiers);

    final updatedOrder = currentOrder.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Agregar cargo extra al pedido
  void addExtraCharge(ExtraCharge charge) {
    if (state.order == null) {
      _initializeOrderIfNeeded();
    }

    final currentOrder = state.order!;
    final updatedCharges = [...currentOrder.extraCharges, charge];
    
    final updatedOrder = currentOrder.copyWith(
      extraCharges: updatedCharges,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Remover cargo extra del pedido
  void removeExtraCharge(String chargeId) {
    if (state.order == null) return;

    final currentOrder = state.order!;
    final updatedCharges = currentOrder.extraCharges
        .where((charge) => charge.id != chargeId)
        .toList();
    
    final updatedOrder = currentOrder.copyWith(
      extraCharges: updatedCharges,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }

  /// Limpiar todos los cargos extras
  void clearExtraCharges() {
    if (state.order == null) return;

    final currentOrder = state.order!;
    final updatedOrder = currentOrder.copyWith(
      extraCharges: const [],
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(order: updatedOrder);
  }
}

/// Provider del pedido activo
final activeOrderProvider =
    StateNotifierProvider<ActiveOrderNotifier, ActiveOrderState>((ref) {
  return ActiveOrderNotifier();
});
