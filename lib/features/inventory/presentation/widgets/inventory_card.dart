import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/inventory_item.dart';

/// Card widget para mostrar item de inventario
class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final bool isMobile;
  final VoidCallback? onTap;
  final VoidCallback? onAddStock;
  final VoidCallback? onAdjustStock;
  final VoidCallback? onRecordWaste;
  final VoidCallback? onEdit;

  const InventoryCard({
    super.key,
    required this.item,
    this.isMobile = false,
    this.onTap,
    this.onAddStock,
    this.onAdjustStock,
    this.onRecordWaste,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final stockPercentage = (item.currentStock / item.maxStock).clamp(0.0, 1.0);

    Color stockColor = Colors.green;
    if (item.isOutOfStock) {
      stockColor = Colors.red;
    } else if (item.isLowStock) {
      stockColor = Colors.orange;
    }

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: stockColor,
                    radius: isMobile ? 20 : 24,
                    child: Text(
                      item.currentStock.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
                          '${item.category.displayName} • ${currencyFormat.format(item.costPerUnit)}/${item.unit.symbol}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (item.isLowStock || item.isOutOfStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: stockColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.isOutOfStock ? Icons.error : Icons.warning,
                            size: 14,
                            color: stockColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isOutOfStock ? 'Sin Stock' : 'Stock Bajo',
                            style: TextStyle(
                              color: stockColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: stockPercentage,
                        backgroundColor: Colors.grey.shade200,
                        color: stockColor,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.currentStock.toStringAsFixed(1)}/${item.maxStock.toStringAsFixed(0)} ${item.unit.symbol}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: stockColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action buttons
              if (!isMobile)
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onAddStock,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRecordWaste,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Merma'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onAdjustStock,
                      icon: const Icon(Icons.tune),
                      tooltip: 'Ajustar',
                    ),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar',
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onAddStock,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Agregar'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onRecordWaste,
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text('Merma'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: onAdjustStock,
                          icon: const Icon(Icons.tune, size: 16),
                          label: const Text('Ajustar'),
                        ),
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Editar'),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
