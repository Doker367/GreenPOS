import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/enums/pos_order_status.dart';
import '../../../tables/presentation/providers/tables_provider.dart';
import '../../domain/entities/pos_order.dart';
import '../screens/order_history_screen.dart';
import '../screens/kitchen_display_screen.dart';

/// Pantalla de dashboard con reportes y estadísticas
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedPeriod = 'today'; // today, week, month

  @override
  Widget build(BuildContext context) {
    final historyOrders = ref.watch(orderHistoryProvider);
    final kitchenOrders = ref.watch(kitchenOrdersProvider);
    final tablesState = ref.watch(tablesProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    // Filtrar órdenes por período
    final filteredOrders = _filterOrdersByPeriod(historyOrders, _selectedPeriod);
    final allOrders = [...filteredOrders, ...kitchenOrders];

    // Calcular métricas
    final totalSales = filteredOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.total,
    );
    final totalOrders = filteredOrders.length;
    final averageTicket = totalOrders > 0 ? totalSales / totalOrders : 0.0;
    final activeOrders = kitchenOrders.length;

    // Estadísticas de mesas
    final occupiedTables = tablesState.occupiedTables.length;
    final availableTables = tablesState.availableTables.length;
    final occupancyRate = tablesState.tables.isEmpty
        ? 0.0
        : (occupiedTables / tablesState.tables.length) * 100;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Dashboard y Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de período
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      
                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Período:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'today',
                                  label: Text('Hoy', style: TextStyle(fontSize: 12)),
                                  icon: Icon(Icons.today, size: 16),
                                ),
                                ButtonSegment(
                                  value: 'week',
                                  label: Text('Semana', style: TextStyle(fontSize: 12)),
                                  icon: Icon(Icons.view_week, size: 16),
                                ),
                                ButtonSegment(
                                  value: 'month',
                                  label: Text('Mes', style: TextStyle(fontSize: 12)),
                                  icon: Icon(Icons.calendar_month, size: 16),
                                ),
                              ],
                              selected: {_selectedPeriod},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  _selectedPeriod = newSelection.first;
                                });
                              },
                            ),
                          ],
                        );
                      }
                      
                      return Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          const Text(
                            'Período:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'today',
                                  label: Text('Hoy'),
                                  icon: Icon(Icons.today),
                                ),
                                ButtonSegment(
                                  value: 'week',
                                  label: Text('Semana'),
                                  icon: Icon(Icons.view_week),
                                ),
                                ButtonSegment(
                                  value: 'month',
                                  label: Text('Mes'),
                                  icon: Icon(Icons.calendar_month),
                                ),
                              ],
                              selected: {_selectedPeriod},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  _selectedPeriod = newSelection.first;
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Métricas principales
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _MetricCard(
                        title: 'Ventas Totales',
                        value: currencyFormat.format(totalSales),
                        icon: Icons.attach_money,
                        color: Colors.green,
                        trend: '+12%',
                        width: isWide ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                      ),
                      _MetricCard(
                        title: 'Órdenes',
                        value: '$totalOrders',
                        icon: Icons.receipt_long,
                        color: AppColors.primary,
                        trend: '+8%',
                        width: isWide ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                      ),
                      _MetricCard(
                        title: 'Ticket Promedio',
                        value: currencyFormat.format(averageTicket),
                        icon: Icons.trending_up,
                        color: Colors.orange,
                        trend: '+5%',
                        width: isWide ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                      ),
                      _MetricCard(
                        title: 'Órdenes Activas',
                        value: '$activeOrders',
                        icon: Icons.pending_actions,
                        color: AppColors.posKitchen,
                        isLive: true,
                        width: isWide ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Gráficas en dos columnas
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1000) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _SalesChartCard(orders: filteredOrders),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _TopProductsCard(orders: allOrders),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _SalesChartCard(orders: filteredOrders),
                      const SizedBox(height: 16),
                      _TopProductsCard(orders: allOrders),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Estadísticas de mesas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.table_restaurant, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Estado de Mesas',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _TableStatusBar(
                              label: 'Ocupadas',
                              count: occupiedTables,
                              total: tablesState.tables.length,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _TableStatusBar(
                              label: 'Disponibles',
                              count: availableTables,
                              total: tablesState.tables.length,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: occupancyRate / 100,
                        minHeight: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          occupancyRate > 80
                              ? Colors.red
                              : occupancyRate > 50
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ocupación: ${occupancyRate.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Accesos rápidos
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accesos Rápidos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _QuickActionButton(
                            label: 'Cocina',
                            icon: Icons.restaurant,
                            color: AppColors.posKitchen,
                            onTap: () => context.go('/kitchen'),
                          ),
                          _QuickActionButton(
                            label: 'Historial',
                            icon: Icons.history,
                            color: AppColors.primary,
                            onTap: () => context.go('/history'),
                          ),
                          _QuickActionButton(
                            label: 'Mesas',
                            icon: Icons.table_restaurant,
                            color: Colors.blue,
                            onTap: () => context.go('/tables'),
                          ),
                          _QuickActionButton(
                            label: 'POS',
                            icon: Icons.point_of_sale,
                            color: Colors.purple,
                            onTap: () => context.go('/pos'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<POSOrder> _filterOrdersByPeriod(List<POSOrder> orders, String period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    return orders.where((order) => order.createdAt.isAfter(startDate)).toList();
  }
}

/// Card de métrica
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool isLive;
  final double width;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.isLive = false,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 32),
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        trend!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.red, size: 8),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card con gráfica de ventas
class _SalesChartCard extends StatelessWidget {
  final List<POSOrder> orders;

  const _SalesChartCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    
    // Agrupar ventas por día
    final salesByDay = <DateTime, double>{};
    for (final order in orders) {
      final day = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
      );
      salesByDay[day] = (salesByDay[day] ?? 0) + order.total;
    }

    final sortedDays = salesByDay.keys.toList()..sort();
    final maxSale = salesByDay.values.isEmpty ? 100.0 : salesByDay.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Ventas por Día',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: sortedDays.isEmpty
                  ? const Center(child: Text('No hay datos para mostrar'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  currencyFormat.format(value),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= sortedDays.length) {
                                  return const Text('');
                                }
                                final date = sortedDays[index];
                                return Text(
                                  '${date.day}/${date.month}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        minX: 0,
                        maxX: (sortedDays.length - 1).toDouble(),
                        minY: 0,
                        maxY: maxSale * 1.2,
                        lineBarsData: [
                          LineChartBarData(
                            spots: sortedDays.asMap().entries.map((entry) {
                              return FlSpot(
                                entry.key.toDouble(),
                                salesByDay[entry.value]!,
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card con productos más vendidos
class _TopProductsCard extends StatelessWidget {
  final List<POSOrder> orders;

  const _TopProductsCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    // Contar productos
    final productCounts = <String, int>{};
    for (final order in orders) {
      for (final item in order.items) {
        productCounts[item.productName] = 
            (productCounts[item.productName] ?? 0) + item.quantity;
      }
    }

    // Ordenar por cantidad
    final sortedProducts = productCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topProducts = sortedProducts.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, size: 28, color: Colors.amber),
                const SizedBox(width: 12),
                Text(
                  'Productos Más Vendidos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (topProducts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No hay datos para mostrar'),
                ),
              )
            else
              ...topProducts.map((entry) {
                final maxCount = sortedProducts.first.value;
                final percentage = (entry.value / maxCount) * 100;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            '${entry.value} vendidos',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.amber,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// Barra de estado de mesas
class _TableStatusBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _TableStatusBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count / $total',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Botón de acción rápida
class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
