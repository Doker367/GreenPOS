import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';

/// Provider de movimientos de stock
final stockMovementsProvider = StateNotifierProvider<StockMovementsNotifier, List<StockMovement>>(
  (ref) => StockMovementsNotifier(),
);

class StockMovementsNotifier extends StateNotifier<List<StockMovement>> {
  StockMovementsNotifier() : super(_initialMovements);

  static final List<StockMovement> _initialMovements = [
    StockMovement(
      id: '1',
      itemId: '1',
      itemName: 'Tomate',
      type: MovementType.purchase,
      quantity: 20.0,
      unit: Unit.kg,
      cost: 25.0,
      notes: 'Compra semanal',
      reason: 'Compra semanal',
      performedBy: 'Luis Hernández',
      date: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    StockMovement(
      id: '2',
      itemId: '2',
      itemName: 'Carne de Res',
      type: MovementType.sale,
      quantity: 5.0,
      unit: Unit.kg,
      notes: 'Preparación de hamburguesas',
      reason: 'Preparación de hamburguesas',
      performedBy: 'María González',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    StockMovement(
      id: '3',
      itemId: '5',
      itemName: 'Lechuga',
      type: MovementType.waste,
      quantity: 1.5,
      unit: Unit.kg,
      notes: 'Producto en mal estado',
      reason: 'Producto en mal estado',
      performedBy: 'Juan Pérez',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    StockMovement(
      id: '4',
      itemId: '1',
      itemName: 'Tomate',
      type: MovementType.adjustment,
      quantity: -2.0,
      unit: Unit.kg,
      notes: 'Ajuste por conteo físico',
      reason: 'Ajuste por conteo físico',
      performedBy: 'Administrador',
      date: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    StockMovement(
      id: '5',
      itemId: '3',
      itemName: 'Queso Mozzarella',
      type: MovementType.purchase,
      quantity: 5.0,
      unit: Unit.kg,
      cost: 95.0,
      notes: 'Reposición',
      reason: 'Reposición',
      performedBy: 'Luis Hernández',
      date: DateTime.now().subtract(const Duration(hours: 8)),
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  void addMovement(StockMovement movement) {
    state = [movement, ...state];
  }

  void recordPurchase({
    required String itemId,
    required double quantity,
    required double cost,
    String? notes,
  }) {
    final movement = StockMovement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: itemId,
      itemName: 'Producto', // TODO: Obtener del provider de inventario
      type: MovementType.purchase,
      quantity: quantity,
      unit: Unit.pz, // TODO: Obtener del item
      cost: cost,
      notes: notes,
      reason: notes ?? 'Compra registrada',
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    addMovement(movement);
  }

  void recordWaste({
    required String itemId,
    required double quantity,
    required String notes,
  }) {
    final movement = StockMovement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: itemId,
      itemName: 'Producto', // TODO: Obtener del provider de inventario
      type: MovementType.waste,
      quantity: quantity,
      unit: Unit.pz, // TODO: Obtener del item
      notes: notes,
      reason: notes,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    addMovement(movement);
  }

  void recordAdjustment(String itemId, double quantity, String reason) {
    final movement = StockMovement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: itemId,
      itemName: 'Producto', // TODO: Obtener del provider de inventario
      type: MovementType.adjustment,
      quantity: quantity,
      unit: Unit.pz, // TODO: Obtener del item
      notes: reason,
      reason: reason,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    addMovement(movement);
  }

  void recordSale({
    required String itemId,
    required double quantity,
    String? notes,
  }) {
    final movement = StockMovement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: itemId,
      itemName: 'Producto', // TODO: Obtener del provider de inventario
      type: MovementType.sale,
      quantity: quantity,
      unit: Unit.pz, // TODO: Obtener del item
      notes: notes,
      reason: notes ?? 'Venta registrada',
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    addMovement(movement);
  }

  List<StockMovement> getItemMovements(String itemId) {
    return state.where((mov) => mov.itemId == itemId).toList();
  }

  List<StockMovement> getMovementsByType(MovementType type) {
    return state.where((mov) => mov.type == type).toList();
  }

  List<StockMovement> getMovementsByDateRange(DateTime start, DateTime end) {
    return state.where((mov) {
      return mov.date.isAfter(start) && mov.date.isBefore(end);
    }).toList();
  }

  List<StockMovement> getRecentMovements(int limit) {
    final sorted = [...state]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }
}
