import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_provider.dart';
import '../widgets/movement_tile.dart';

/// Screen de detalle de item de inventario con historial de movimientos
class InventoryDetailScreen extends ConsumerWidget {
  final String itemId;

  const InventoryDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inventoryProvider);
    final item = items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item no encontrado'),
    );
    final movements = ref.watch(stockMovementsProvider);
    final itemMovements = movements
        .where((m) => m.itemId == itemId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit item
            },
            tooltip: 'Editar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock info card
            _buildStockInfoCard(context, item, currencyFormat),
            const SizedBox(height: 16),

            // Item details card
            _buildDetailsCard(context, item, currencyFormat),
            const SizedBox(height: 24),

            // Movement history
            Text(
              'Historial de Movimientos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            if (itemMovements.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No hay movimientos registrados'),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...itemMovements.map((movement) => MovementTile(
                    movement: movement,
                    isMobile: isMobile,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfoCard(
    BuildContext context,
    InventoryItem item,
    NumberFormat currencyFormat,
  ) {
    final stockPercentage = (item.currentStock / item.maxStock).clamp(0.0, 1.0);

    Color stockColor = Colors.green;
    String stockStatus = 'Óptimo';
    if (item.isOutOfStock) {
      stockColor = Colors.red;
      stockStatus = 'Sin Stock';
    } else if (item.isLowStock) {
      stockColor = Colors.orange;
      stockStatus = 'Stock Bajo';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: stockColor,
                  child: Text(
                    item.currentStock.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.currentStock} ${item.unit.symbol}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Stock Actual',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: stockColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stockStatus,
                          style: TextStyle(
                            color: stockColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: stockPercentage,
              backgroundColor: Colors.grey.shade200,
              color: stockColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Min: ${item.minStock} ${item.unit.symbol}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Max: ${item.maxStock} ${item.unit.symbol}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoColumn(
                  label: 'Valor Total',
                  value: currencyFormat.format(item.totalValue),
                  icon: Icons.attach_money,
                ),
                _InfoColumn(
                  label: 'Costo Unitario',
                  value: currencyFormat.format(item.costPerUnit),
                  icon: Icons.price_tag,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(
    BuildContext context,
    InventoryItem item,
    NumberFormat currencyFormat,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles del Producto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Categoría', value: item.category.displayName),
            _DetailRow(label: 'Unidad', value: '${item.unit.displayName} (${item.unit.symbol})'),
            if (item.supplier != null)
              _DetailRow(label: 'Proveedor', value: item.supplier!),
            if (item.expirationDate != null)
              _DetailRow(
                label: 'Caducidad',
                value: DateFormat('dd/MM/yyyy').format(item.expirationDate!),
              ),
            _DetailRow(
              label: 'Creado',
              value: DateFormat('dd/MM/yyyy').format(item.createdAt),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoColumn({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
