import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/enums/pos_order_status.dart';
import '../../domain/entities/pos_order.dart';
import '../../data/mock_orders_data.dart';
import 'order_history_screen.dart';
import 'checkout_screen.dart';

/// Mock provider de órdenes en cocina (temporal)
final kitchenOrdersProvider = StateProvider<List<POSOrder>>(
  (ref) => MockOrdersData.getKitchenOrders(),
);

/// Pantalla de cocina - muestra órdenes pendientes
class KitchenDisplayScreen extends ConsumerWidget {
  const KitchenDisplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(kitchenOrdersProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    // Filtrar solo órdenes relevantes para cocina
    final pendingOrders = orders.where((o) => 
      o.status == OrderStatus.sent || 
      o.status == OrderStatus.preparing
    ).toList();

    final readyOrders = orders.where((o) => o.status == OrderStatus.ready).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Cocina'),
        backgroundColor: AppColors.posKitchen,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Row(
                children: [
                  _StatusBadge(
                    label: 'Pendientes',
                    count: pendingOrders.length,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(
                    label: 'Listas',
                    count: readyOrders.length,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: pendingOrders.isEmpty && readyOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay órdenes pendientes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Las nuevas órdenes aparecerán aquí',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1200;
                final isTablet = constraints.maxWidth > 800;

                return Row(
                  children: [
                    // Columna de órdenes pendientes
                    Expanded(
                      flex: isDesktop ? 2 : 1,
                      child: _OrdersSection(
                        title: 'Pendientes',
                        orders: pendingOrders,
                        color: Colors.orange,
                        emptyMessage: 'No hay órdenes pendientes',
                      ),
                    ),
                    
                    if (isTablet) const VerticalDivider(width: 1),
                    
                    // Columna de órdenes listas
                    if (isTablet)
                      Expanded(
                        child: _OrdersSection(
                          title: 'Listas',
                          orders: readyOrders,
                          color: Colors.green,
                          emptyMessage: 'No hay órdenes listas',
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

/// Badge de estado en el AppBar
class _StatusBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sección de órdenes (pendientes o listas)
class _OrdersSection extends StatelessWidget {
  final String title;
  final List<POSOrder> orders;
  final Color color;
  final String emptyMessage;

  const _OrdersSection({
    required this.title,
    required this.orders,
    required this.color,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header de la sección
        Container(
          padding: const EdgeInsets.all(16),
          color: color.withOpacity(0.1),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        
        // Lista de órdenes
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Text(
                    emptyMessage,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    int crossAxisCount;
                    double childAspectRatio;
                    
                    if (width < 600) {
                      // Móvil: 1 columna
                      crossAxisCount = 1;
                      childAspectRatio = 0.9;
                    } else if (width < 1000) {
                      // Tablet: 2 columnas
                      crossAxisCount = 2;
                      childAspectRatio = 0.8;
                    } else if (width < 1400) {
                      // Desktop pequeño: 2 columnas
                      crossAxisCount = 2;
                      childAspectRatio = 0.75;
                    } else {
                      // Desktop grande: 3 columnas
                      crossAxisCount = 3;
                      childAspectRatio = 0.75;
                    }
                    
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _KitchenOrderCard(order: order, accentColor: color);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Card de orden en cocina
class _KitchenOrderCard extends ConsumerWidget {
  final POSOrder order;
  final Color accentColor;

  const _KitchenOrderCard({
    required this.order,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final timeElapsed = DateTime.now().difference(order.createdAt);
    final minutes = timeElapsed.inMinutes;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accentColor, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mesa
                if (order.tableName != null)
                  Row(
                    children: [
                      const Icon(Icons.table_restaurant, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        order.tableName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                
                // Tiempo transcurrido
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: minutes > 20 
                        ? Colors.red 
                        : minutes > 10 
                            ? Colors.orange 
                            : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: minutes > 10 ? Colors.white : accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${minutes}m',
                        style: TextStyle(
                          color: minutes > 10 ? Colors.white : accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cantidad
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Nombre y notas
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.modifiers.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              ...item.modifiers.map((mod) => Text(
                                    '  + ${mod.name}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                            if (item.notes != null && item.notes!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '  📝 ${item.notes}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[700],
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Acciones
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Botón principal de cambio de estado
                FilledButton.icon(
                  onPressed: () {
                    final orders = ref.read(kitchenOrdersProvider);
                    final orderIndex = orders.indexWhere((o) => o.id == order.id);
                    
                    if (orderIndex == -1) return;
                    
                    // Crear copia de la orden con nuevo estado
                    final updatedOrder = orders[orderIndex].copyWith(
                      status: order.status == OrderStatus.sent 
                          ? OrderStatus.preparing 
                          : OrderStatus.ready,
                      updatedAt: DateTime.now(),
                    );
                    
                    // Actualizar la lista de órdenes
                    final updatedOrders = List<POSOrder>.from(orders);
                    updatedOrders[orderIndex] = updatedOrder;
                    ref.read(kitchenOrdersProvider.notifier).state = updatedOrders;
                    
                    // Mostrar mensaje
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          order.status == OrderStatus.sent
                              ? 'Orden en preparación'
                              : 'Orden marcada como lista',
                        ),
                        backgroundColor: order.status == OrderStatus.sent 
                            ? Colors.blue 
                            : Colors.green,
                      ),
                    );
                  },
                  icon: Icon(
                    order.status == OrderStatus.sent 
                        ? Icons.play_arrow 
                        : Icons.check,
                  ),
                  label: Text(
                    order.status == OrderStatus.sent 
                        ? 'Comenzar' 
                        : 'Marcar lista',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: order.status == OrderStatus.sent 
                        ? Colors.blue 
                        : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                
                // Botón para marcar como servido (solo si está lista)
                if (order.status == OrderStatus.ready) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      final orders = ref.read(kitchenOrdersProvider);
                      final orderIndex = orders.indexWhere((o) => o.id == order.id);
                      
                      if (orderIndex == -1) return;
                      
                      // Marcar como servido y mover al historial
                      final completedOrder = orders[orderIndex].copyWith(
                        status: OrderStatus.served,
                        updatedAt: DateTime.now(),
                      );
                      
                      // Remover de cocina
                      final updatedOrders = List<POSOrder>.from(orders);
                      updatedOrders.removeAt(orderIndex);
                      ref.read(kitchenOrdersProvider.notifier).state = updatedOrders;
                      
                      // Agregar al historial
                      final history = ref.read(orderHistoryProvider);
                      ref.read(orderHistoryProvider.notifier).state = [
                        completedOrder,
                        ...history,
                      ];
                      
                      // Mostrar mensaje
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Orden servida y movida al historial'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.dining),
                    label: const Text('Marcar Servido'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(order: order),
                        ),
                      );
                    },
                    icon: const Icon(Icons.attach_money),
                    label: const Text('COBRAR'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.posCheckout,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
