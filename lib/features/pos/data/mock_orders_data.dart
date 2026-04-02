import 'package:uuid/uuid.dart';
import '../../../core/enums/pos_order_status.dart';
import '../domain/entities/pos_order.dart';
import '../domain/entities/pos_order_item.dart';
import '../domain/entities/order_modifier.dart';

/// Datos de prueba para órdenes
class MockOrdersData {
  static const uuid = Uuid();

  /// Genera órdenes de prueba para la cocina
  static List<POSOrder> getKitchenOrders() {
    return [
      // Orden 1 - Mesa 5, recién enviada
      POSOrder(
        id: uuid.v4(),
        items: [
          POSOrderItem(
            id: uuid.v4(),
            productId: 'PIZZA-001',
            productName: 'Pizza Margarita',
            quantity: 2,
            unitPrice: 12.99,
            modifiers: [
              OrderModifier(
                id: uuid.v4(),
                name: 'Extra Queso',
                priceAdjustment: 2.0,
                type: ModifierType.add,
              ),
            ],
            notes: 'Sin cebolla',
          ),
          POSOrderItem(
            id: uuid.v4(),
            productId: 'BEBIDA-001',
            productName: 'Coca Cola',
            quantity: 2,
            unitPrice: 2.50,
            modifiers: [],
            notes: '',
          ),
        ],
        status: OrderStatus.sent,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        tableId: 'mesa-5',
        tableName: 'Mesa 5',
      ),

      // Orden 2 - Mesa 12, en preparación
      POSOrder(
        id: uuid.v4(),
        items: [
          POSOrderItem(
            id: uuid.v4(),
            productId: 'BURGER-001',
            productName: 'Hamburguesa Clásica',
            quantity: 1,
            unitPrice: 9.99,
            modifiers: [
              OrderModifier(
                id: uuid.v4(),
                name: 'Término Medio',
                priceAdjustment: 0.0,
                type: ModifierType.replace,
              ),
            ],
            notes: '',
          ),
          POSOrderItem(
            id: uuid.v4(),
            productId: 'SIDE-001',
            productName: 'Papas Fritas',
            quantity: 1,
            unitPrice: 3.99,
            modifiers: [],
            notes: 'Extra crujientes',
          ),
        ],
        status: OrderStatus.preparing,
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        tableId: 'mesa-12',
        tableName: 'Mesa 12',
      ),

      // Orden 3 - Mesa 3, lista para servir
      POSOrder(
        id: uuid.v4(),
        items: [
          POSOrderItem(
            id: uuid.v4(),
            productId: 'PASTA-001',
            productName: 'Spaghetti Carbonara',
            quantity: 1,
            unitPrice: 11.99,
            modifiers: [],
            notes: '',
          ),
          POSOrderItem(
            id: uuid.v4(),
            productId: 'SALAD-001',
            productName: 'Ensalada César',
            quantity: 1,
            unitPrice: 6.99,
            modifiers: [],
            notes: 'Sin anchoas',
          ),
        ],
        status: OrderStatus.ready,
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        tableId: 'mesa-3',
        tableName: 'Mesa 3',
      ),
    ];
  }

  /// Genera órdenes de prueba para el historial
  static List<POSOrder> getHistoryOrders() {
    return [
      // Orden completada hoy
      POSOrder(
        id: uuid.v4(),
        items: [
          POSOrderItem(
            id: uuid.v4(),
            productId: 'STEAK-001',
            productName: 'Filete de Res',
            quantity: 2,
            unitPrice: 18.99,
            modifiers: [],
            notes: '',
          ),
          POSOrderItem(
            id: uuid.v4(),
            productId: 'WINE-001',
            productName: 'Vino Tinto',
            quantity: 1,
            unitPrice: 25.00,
            modifiers: [],
            notes: '',
          ),
        ],
        status: OrderStatus.served,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        tableId: 'mesa-8',
        tableName: 'Mesa 8',
      ),

      // Orden de ayer
      POSOrder(
        id: uuid.v4(),
        items: [
          POSOrderItem(
            id: uuid.v4(),
            productId: 'PIZZA-002',
            productName: 'Pizza Pepperoni',
            quantity: 1,
            unitPrice: 13.99,
            modifiers: [],
            notes: '',
          ),
          POSOrderItem(
            id: uuid.v4(),
            productId: 'DESSERT-001',
            productName: 'Tiramisú',
            quantity: 2,
            unitPrice: 5.99,
            modifiers: [],
            notes: '',
          ),
        ],
        status: OrderStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        tableId: 'mesa-15',
        tableName: 'Mesa 15',
      ),

      // Otra orden de hoy
      POSOrder(
        id: uuid.v4(),
        items: [
          POSOrderItem(
            id: uuid.v4(),
            productId: 'LUNCH-001',
            productName: 'Menú del Día',
            quantity: 3,
            unitPrice: 8.99,
            modifiers: [],
            notes: '',
          ),
        ],
        status: OrderStatus.served,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 45)),
        tableId: 'mesa-6',
        tableName: 'Mesa 6',
      ),
    ];
  }
}
