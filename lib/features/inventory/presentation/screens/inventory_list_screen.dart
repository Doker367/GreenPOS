import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_provider.dart';
import '../widgets/inventory_card.dart';

/// Provider para filtrar items de inventario
final inventoryFilterProvider = StateProvider<String>((ref) => '');

/// Provider para items de inventario filtrados
final filteredInventoryProvider = Provider<List<InventoryItem>>((ref) {
  final items = ref.watch(inventoryProvider);
  final filter = ref.watch(inventoryFilterProvider).toLowerCase();
  
  if (filter.isEmpty) return items;
  
  return items.where((item) {
    return item.name.toLowerCase().contains(filter) ||
        item.category.displayName.toLowerCase().contains(filter);
  }).toList();
});

/// Screen principal de lista de inventario
class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredInventoryProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh logic - in a real app this would refetch from API
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Inventario actualizado')),
              );
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(isMobile ? 8 : 16),
            child: TextField(
              onChanged: (value) {
                ref.read(inventoryFilterProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          // Summary bar
          _buildSummaryBar(context, ref, items),
          
          // Items list
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No hay productos en inventario'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    padding: EdgeInsets.all(isMobile ? 8 : 16),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return InventoryCard(
                        item: item,
                        isMobile: isMobile,
                        onTap: () {
                          // Navigate to detail - could use Navigator.push
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context, WidgetRef ref, List<InventoryItem> items) {
    final totalValue = items.fold<double>(
      0,
      (sum, item) => sum + item.totalValue,
    );
    final lowStockCount = items.where((i) => i.isLowStock).length;
    final outOfStockCount = items.where((i) => i.isOutOfStock).length;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Total Items',
            value: items.length.toString(),
            icon: Icons.inventory_2,
          ),
          _SummaryItem(
            label: 'Valor Total',
            value: currencyFormat.format(totalValue),
            icon: Icons.attach_money,
          ),
          if (lowStockCount > 0)
            _SummaryItem(
              label: 'Stock Bajo',
              value: lowStockCount.toString(),
              icon: Icons.warning,
              color: Colors.orange,
            ),
          if (outOfStockCount > 0)
            _SummaryItem(
              label: 'Sin Stock',
              value: outOfStockCount.toString(),
              icon: Icons.error,
              color: Colors.red,
            ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color ?? Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
