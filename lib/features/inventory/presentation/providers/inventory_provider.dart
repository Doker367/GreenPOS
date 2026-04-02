import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';

/// Provider de inventario
final inventoryProvider = StateNotifierProvider<InventoryNotifier, List<InventoryItem>>(
  (ref) => InventoryNotifier(),
);

class InventoryNotifier extends StateNotifier<List<InventoryItem>> {
  InventoryNotifier() : super(_initialInventory);

  static final List<InventoryItem> _initialInventory = [
    InventoryItem(
      id: '1',
      name: 'Tomate',
      description: 'Tomate rojo fresco',
      category: InventoryCategory.vegetables,
      currentStock: 15.0,
      minStock: 10.0,
      maxStock: 50.0,
      unit: Unit.kg,
      costPerUnit: 25.0,
      supplier: 'Verduras Don José',
      expirationDate: DateTime.now().add(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    InventoryItem(
      id: '2',
      name: 'Carne de Res',
      description: 'Carne de res para hamburguesas',
      category: InventoryCategory.meat,
      currentStock: 8.0,
      minStock: 5.0,
      maxStock: 30.0,
      unit: Unit.kg,
      costPerUnit: 180.0,
      supplier: 'Carnicería El Buen Pastor',
      expirationDate: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    InventoryItem(
      id: '3',
      name: 'Queso Mozzarella',
      description: 'Queso mozzarella para pizza',
      category: InventoryCategory.dairy,
      currentStock: 4.0,
      minStock: 3.0,
      maxStock: 15.0,
      unit: Unit.kg,
      costPerUnit: 95.0,
      supplier: 'Lácteos La Vaca',
      expirationDate: DateTime.now().add(const Duration(days: 10)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    InventoryItem(
      id: '4',
      name: 'Coca-Cola',
      description: 'Refresco Coca-Cola 600ml',
      category: InventoryCategory.beverages,
      currentStock: 48.0,
      minStock: 24.0,
      maxStock: 100.0,
      unit: Unit.pz,
      costPerUnit: 12.0,
      supplier: 'Distribuidora de Bebidas',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    InventoryItem(
      id: '5',
      name: 'Lechuga',
      description: 'Lechuga romana fresca',
      category: InventoryCategory.vegetables,
      currentStock: 2.0,
      minStock: 5.0,
      maxStock: 20.0,
      unit: Unit.kg,
      costPerUnit: 18.0,
      supplier: 'Verduras Don José',
      expirationDate: DateTime.now().add(const Duration(days: 4)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    InventoryItem(
      id: '6',
      name: 'Aceite de Oliva',
      description: 'Aceite de oliva extra virgen',
      category: InventoryCategory.condiments,
      currentStock: 3.5,
      minStock: 2.0,
      maxStock: 10.0,
      unit: Unit.l,
      costPerUnit: 120.0,
      supplier: 'Importadora de Aceites',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    InventoryItem(
      id: '7',
      name: 'Pollo',
      description: 'Pechuga de pollo sin hueso',
      category: InventoryCategory.meat,
      currentStock: 12.0,
      minStock: 8.0,
      maxStock: 25.0,
      unit: Unit.kg,
      costPerUnit: 85.0,
      supplier: 'Carnicería El Buen Pastor',
      expirationDate: DateTime.now().add(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    InventoryItem(
      id: '8',
      name: 'Cebolla',
      description: 'Cebolla blanca',
      category: InventoryCategory.vegetables,
      currentStock: 0.0,
      minStock: 5.0,
      maxStock: 20.0,
      unit: Unit.kg,
      costPerUnit: 15.0,
      supplier: 'Verduras Don José',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  void addItem({
    required String name,
    required InventoryCategory category,
    required Unit unit,
    required double minStock,
    required double maxStock,
    required double costPerUnit,
  }) {
    final newItem = InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: 'Producto agregado',
      category: category,
      currentStock: 0,
      minStock: minStock,
      maxStock: maxStock,
      unit: unit,
      costPerUnit: costPerUnit,
      createdAt: DateTime.now(),
    );
    state = [...state, newItem];
  }

  void updateItem(InventoryItem item) {
    state = [
      for (final i in state)
        if (i.id == item.id) item else i,
    ];
  }

  void adjustStock({
    required String itemId,
    required double newQuantity,
    String? notes,
  }) {
    state = [
      for (final item in state)
        if (item.id == itemId)
          item.copyWith(
            currentStock: newQuantity,
            updatedAt: DateTime.now(),
          )
        else
          item,
    ];
  }

  void deleteItem(String id) {
    state = state.where((i) => i.id != id).toList();
  }

  void updateStock(String id, double newStock) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(
            currentStock: newStock,
            updatedAt: DateTime.now(),
          )
        else
          item,
    ];
  }

  List<InventoryItem> getLowStockItems() {
    return state.where((item) => item.isLowStock).toList();
  }

  List<InventoryItem> getOutOfStockItems() {
    return state.where((item) => item.isOutOfStock).toList();
  }

  List<InventoryItem> getNearExpirationItems() {
    return state.where((item) => item.isNearExpiration).toList();
  }

  List<InventoryItem> getItemsByCategory(InventoryCategory category) {
    return state.where((item) => item.category == category).toList();
  }

  double getTotalInventoryValue() {
    return state.fold(0.0, (sum, item) => sum + item.totalValue);
  }

  InventoryItem? getItemById(String id) {
    try {
      return state.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}
