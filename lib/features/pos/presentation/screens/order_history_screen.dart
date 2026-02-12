import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/enums/pos_order_status.dart';
import '../../domain/entities/pos_order.dart';
import '../../data/mock_orders_data.dart';
import 'checkout_screen.dart';

/// Provider temporal para historial de órdenes
final orderHistoryProvider = StateProvider<List<POSOrder>>(
  (ref) => MockOrdersData.getHistoryOrders(),
);

/// Pantalla de historial de órdenes
class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  String _searchQuery = '';
  OrderStatus? _filterStatus;
  DateTime? _filterDate;

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(orderHistoryProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Filtrar órdenes
    final filteredOrders = allOrders.where((order) {
      // Filtro por búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTable = order.tableName?.toLowerCase().contains(query) ?? false;
        final matchesCustomer = order.customerName?.toLowerCase().contains(query) ?? false;
        if (!matchesTable && !matchesCustomer) return false;
      }

      // Filtro por estado
      if (_filterStatus != null && order.status != _filterStatus) {
        return false;
      }

      // Filtro por fecha
      if (_filterDate != null) {
        final orderDate = DateTime(
          order.createdAt.year,
          order.createdAt.month,
          order.createdAt.day,
        );
        final filterDateOnly = DateTime(
          _filterDate!.year,
          _filterDate!.month,
          _filterDate!.day,
        );
        if (orderDate != filterDateOnly) return false;
      }

      return true;
    }).toList();

    // Ordenar por fecha (más recientes primero)
    filteredOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Historial de Órdenes'),
        actions: [
          // Botón de filtros
          IconButton(
            icon: Badge(
              isLabelVisible: _filterStatus != null || _filterDate != null,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => _showFiltersDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por mesa o cliente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Estadísticas rápidas
          if (filteredOrders.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatCard(
                    label: 'Total Órdenes',
                    value: '${filteredOrders.length}',
                    icon: Icons.receipt_long,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    label: 'Total Ventas',
                    value: currencyFormat.format(
                      filteredOrders.fold(0.0, (sum, order) => sum + order.total),
                    ),
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                ],
              ),
            ),

          const Divider(),

          // Lista de órdenes
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          allOrders.isEmpty
                              ? 'No hay órdenes en el historial'
                              : 'No se encontraron órdenes',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        if (allOrders.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _filterStatus = null;
                                _filterDate = null;
                              });
                            },
                            child: const Text('Limpiar filtros'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _OrderHistoryCard(
                        order: order,
                        onTap: () => _showOrderDetails(context, order),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filtro por estado
            DropdownButtonFormField<OrderStatus?>(
              value: _filterStatus,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todos'),
                ),
                ...OrderStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.displayName),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _filterStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Filtro por fecha
            ListTile(
              title: Text(_filterDate == null
                  ? 'Todas las fechas'
                  : DateFormat('dd/MM/yyyy').format(_filterDate!)),
              leading: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _filterDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _filterDate = date;
                  });
                }
              },
              trailing: _filterDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _filterDate = null;
                        });
                      },
                    )
                  : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterStatus = null;
                _filterDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, POSOrder order) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt_long),
            const SizedBox(width: 8),
            Expanded(child: Text('Orden #${order.id.substring(0, 8)}')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info general
              _DetailRow(
                label: 'Fecha',
                value: dateFormat.format(order.createdAt),
              ),
              if (order.tableName != null)
                _DetailRow(
                  label: 'Mesa',
                  value: order.tableName!,
                ),
              _DetailRow(
                label: 'Estado',
                value: order.status.displayName,
              ),
              const Divider(),

              // Items
              const Text(
                'Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.quantity}x '),
                      Expanded(child: Text(item.productName)),
                      Text(currencyFormat.format(item.subtotal)),
                    ],
                  ),
                );
              }),
              const Divider(),

              // Totales
              _DetailRow(
                label: 'Subtotal',
                value: currencyFormat.format(order.subtotal),
              ),
              if (order.discount != null)
                _DetailRow(
                  label: 'Descuento',
                  value: '-${currencyFormat.format(order.discountAmount)}',
                ),
              if (order.extraCharges.isNotEmpty)
                ...order.extraCharges.map((charge) {
                  final amount = charge.calculateCharge(order.subtotal);
                  return _DetailRow(
                    label: charge.name,
                    value: '+${currencyFormat.format(amount)}',
                  );
                }),
              _DetailRow(
                label: 'IVA',
                value: currencyFormat.format(order.tax),
              ),
              const Divider(),
              _DetailRow(
                label: 'TOTAL',
                value: currencyFormat.format(order.total),
                isTotal: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          // Botón para cobrar órdenes servidas pero no pagadas
          if (order.status == OrderStatus.served)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
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
              ),
            ),
        ],
      ),
    );
  }
}

/// Card de estadística
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de orden en el historial
class _OrderHistoryCard extends StatelessWidget {
  final POSOrder order;
  final VoidCallback onTap;

  const _OrderHistoryCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono de estado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(order.status),
                  color: _getStatusColor(order.status),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (order.tableName != null) ...[
                          Icon(Icons.table_restaurant, size: 16,
                              color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            order.tableName!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          dateFormat.format(order.createdAt),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.totalItems} items • ${order.status.displayName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(order.total),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return Colors.grey;
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.sent:
      case OrderStatus.preparing:
        return AppColors.posKitchen;
      case OrderStatus.ready:
      case OrderStatus.served:
        return Colors.green;
      case OrderStatus.completed:
        return AppColors.primary;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return Icons.edit;
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.sent:
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.check_circle;
      case OrderStatus.served:
        return Icons.dining;
      case OrderStatus.completed:
        return Icons.check;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

/// Fila de detalle
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                : null,
          ),
          Text(
            value,
            style: isTotal
                ? TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
