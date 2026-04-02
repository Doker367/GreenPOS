import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_provider.dart';

/// Provider for items grouped by stock status
final stockAlertsProvider = Provider<Map<String, List<InventoryItem>>>((ref) {
  final items = ref.watch(inventoryProvider);
  
  return {
    'outOfStock': items.where((i) => i.isOutOfStock).toList(),
    'lowStock': items.where((i) => i.isLowStock && !i.isOutOfStock).toList(),
    'nearExpiration': items.where((i) => i.isNearExpiration).toList(),
  };
});

/// Screen dedicada a items con stock bajo
class LowStockScreen extends ConsumerWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(stockAlertsProvider);
    final outOfStockItems = alerts['outOfStock'] ?? [];
    final lowStockItems = alerts['lowStock'] ?? [];
    final nearExpirationItems = alerts['nearExpiration'] ?? [];
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas de Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alertas actualizadas')),
              );
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 18),
                      const SizedBox(width: 4),
                      Text('Sin Stock (${outOfStockItems.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, size: 18),
                      const SizedBox(width: 4),
                      Text('Stock Bajo (${lowStockItems.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule, size: 18),
                      const SizedBox(width: 4),
                      Text('Por Caducar (${nearExpirationItems.length})'),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Out of stock tab
                  _buildStockList(
                    context,
                    ref,
                    outOfStockItems,
                    'Sin Stock',
                    'No hay productos sin stock',
                    Icons.check_circle,
                    Colors.green,
                    isMobile,
                  ),
                  // Low stock tab
                  _buildStockList(
                    context,
                    ref,
                    lowStockItems,
                    'Stock Bajo',
                    'No hay productos con stock bajo',
                    Icons.thumb_up,
                    Colors.green,
                    isMobile,
                  ),
                  // Near expiration tab
                  _buildStockList(
                    context,
                    ref,
                    nearExpirationItems,
                    'Por Caducar',
                    'No hay productos por caducar',
                    Icons.thumb_up,
                    Colors.green,
                    isMobile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockList(
    BuildContext context,
    WidgetRef ref,
    List<InventoryItem> items,
    String title,
    String emptyMessage,
    IconData emptyIcon,
    Color emptyColor,
    bool isMobile,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: emptyColor),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return _LowStockCard(
          item: item,
          isMobile: isMobile,
          onAddStock: () {
            // Navigate to add stock screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Agregar stock a ${item.name}'),
                action: SnackBarAction(
                  label: 'Ver',
                  onPressed: () {
                    // Navigate to add movement screen
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LowStockCard extends StatelessWidget {
  final InventoryItem item;
  final bool isMobile;
  final VoidCallback onAddStock;

  const _LowStockCard({
    required this.item,
    required this.isMobile,
    required this.onAddStock,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    Color alertColor = Colors.orange;
    IconData alertIcon = Icons.warning;
    String alertLabel = 'Stock Bajo';

    if (item.isOutOfStock) {
      alertColor = Colors.red;
      alertIcon = Icons.error;
      alertLabel = 'Sin Stock';
    } else if (item.isNearExpiration) {
      alertColor = Colors.amber;
      alertIcon = Icons.schedule;
      alertLabel = 'Por Caducar';
    }

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: alertColor,
                  radius: isMobile ? 20 : 24,
                  child: Icon(
                    alertIcon,
                    color: Colors.white,
                    size: isMobile ? 20 : 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.category.displayName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: alertColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        alertIcon,
                        size: 16,
                        color: alertColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alertLabel,
                        style: TextStyle(
                          color: alertColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stock info row
            Row(
              children: [
                Expanded(
                  child: _StockInfoBox(
                    label: 'Actual',
                    value: '${item.currentStock.toStringAsFixed(1)} ${item.unit.symbol}',
                    color: alertColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StockInfoBox(
                    label: 'Mínimo',
                    value: '${item.minStock.toStringAsFixed(1)} ${item.unit.symbol}',
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StockInfoBox(
                    label: 'Máximo',
                    value: '${item.maxStock.toStringAsFixed(1)} ${item.unit.symbol}',
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            
            // Progress indicator
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (item.currentStock / item.maxStock).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      color: alertColor,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${((item.currentStock / item.maxStock) * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: alertColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            // Additional info
            if (item.expirationDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Caducidad: ${DateFormat('dd/MM/yyyy').format(item.expirationDate!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '(${item.expirationDate!.difference(DateTime.now()).inDays} días)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAddStock,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Stock'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    // View details
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Ver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StockInfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StockInfoBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
