import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/inventory_item.dart';

/// Tile widget para mostrar un movimiento de stock
class MovementTile extends StatelessWidget {
  final StockMovement movement;
  final bool isMobile;
  final VoidCallback? onTap;

  const MovementTile({
    super.key,
    required this.movement,
    this.isMobile = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              CircleAvatar(
                backgroundColor: _getColor(),
                radius: isMobile ? 20 : 24,
                child: Icon(
                  _getIcon(),
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type and quantity
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            movement.type.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 14 : 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_getSign()}${movement.quantity.toStringAsFixed(2)} ${movement.unit.symbol}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getColor(),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Date and time
                    Text(
                      '${dateFormat.format(movement.date)} • ${timeFormat.format(movement.date)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    
                    // Reason/notes
                    if (movement.reason != null && movement.reason!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        movement.reason!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                    
                    // Cost
                    if (movement.cost != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Costo: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(movement.cost)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                    
                    // User
                    if (movement.performedBy != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            movement.performedBy!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor() {
    switch (movement.type) {
      case MovementType.purchase:
        return Colors.green;
      case MovementType.sale:
        return Colors.blue;
      case MovementType.waste:
        return Colors.red;
      case MovementType.adjustment:
        return Colors.orange;
    }
  }

  IconData _getIcon() {
    switch (movement.type) {
      case MovementType.purchase:
        return Icons.add_shopping_cart;
      case MovementType.sale:
        return Icons.point_of_sale;
      case MovementType.waste:
        return Icons.delete;
      case MovementType.adjustment:
        return Icons.tune;
    }
  }

  String _getSign() {
    switch (movement.type) {
      case MovementType.purchase:
        return '+';
      case MovementType.sale:
        return '-';
      case MovementType.waste:
        return '-';
      case MovementType.adjustment:
        return movement.quantity >= 0 ? '+' : '';
    }
  }
}
