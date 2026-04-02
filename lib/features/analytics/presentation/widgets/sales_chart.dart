import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/analytics_data.dart';

/// Bar chart showing sales by day
class SalesBarChart extends StatefulWidget {
  final List<DailySales> dailySales;
  final bool showRevenue;
  final bool showOrders;

  const SalesBarChart({
    super.key,
    required this.dailySales,
    this.showRevenue = true,
    this.showOrders = false,
  });

  @override
  State<SalesBarChart> createState() => _SalesBarChartState();
}

class _SalesBarChartState extends State<SalesBarChart> {
  bool _showRevenue = true;

  @override
  void initState() {
    super.initState();
    _showRevenue = widget.showRevenue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.dailySales.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final maxRevenue = widget.dailySales
        .map((e) => e.revenue)
        .reduce((a, b) => a > b ? a : b);
    final maxOrders = widget.dailySales
        .map((e) => e.orders.toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ventas por Día',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Revenue'),
                      icon: Icon(Icons.attach_money, size: 16),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Órdenes'),
                      icon: Icon(Icons.receipt, size: 16),
                    ),
                  ],
                  selected: {_showRevenue},
                  onSelectionChanged: (selection) {
                    setState(() => _showRevenue = selection.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _showRevenue ? maxRevenue * 1.2 : maxOrders * 1.2,
                  barGroups: widget.dailySales.asMap().entries.map((entry) {
                    final index = entry.key;
                    final sale = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: _showRevenue ? sale.revenue : sale.orders.toDouble(),
                          color: theme.colorScheme.primary,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.7),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < widget.dailySales.length) {
                            final date = widget.dailySales[index].date;
                            final parts = date.split('-');
                            if (parts.length == 3) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '${parts[2]}/${parts[1]}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          if (_showRevenue) {
                            if (value >= 1000) {
                              return Text(
                                '\$${(value / 1000).toStringAsFixed(0)}K',
                                style: theme.textTheme.bodySmall,
                              );
                            }
                            return Text(
                              '\$${value.toStringAsFixed(0)}',
                              style: theme.textTheme.bodySmall,
                            );
                          }
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _showRevenue ? maxRevenue / 4 : maxOrders / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark 
                            ? Colors.white.withOpacity(0.1) 
                            : Colors.black.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final sale = widget.dailySales[group.x];
                        if (_showRevenue) {
                          return BarTooltipItem(
                            '\$${sale.revenue.toStringAsFixed(2)}\n${sale.orders} órdenes',
                            TextStyle(
                              color: theme.colorScheme.onInverseSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return BarTooltipItem(
                          '${sale.orders} órdenes\n\$${sale.revenue.toStringAsFixed(2)}',
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Line chart showing revenue trends
class RevenueLineChart extends StatelessWidget {
  final List<DailySales> dailySales;

  const RevenueLineChart({
    super.key,
    required this.dailySales,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (dailySales.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final maxRevenue = dailySales
        .map((e) => e.revenue)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendencia de Revenue',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailySales.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.revenue);
                      }).toList(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < dailySales.length) {
                            final date = dailySales[index].date;
                            final parts = date.split('-');
                            if (parts.length == 3) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '${parts[2]}/${parts[1]}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          if (value >= 1000) {
                            return Text(
                              '\$${(value / 1000).toStringAsFixed(0)}K',
                              style: theme.textTheme.bodySmall,
                            );
                          }
                          return Text(
                            '\$${value.toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxRevenue / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark 
                            ? Colors.white.withOpacity(0.1) 
                            : Colors.black.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < dailySales.length) {
                            final sale = dailySales[index];
                            return LineTooltipItem(
                              '${sale.date}\n\$${sale.revenue.toStringAsFixed(2)}',
                              TextStyle(
                                color: theme.colorScheme.onInverseSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
