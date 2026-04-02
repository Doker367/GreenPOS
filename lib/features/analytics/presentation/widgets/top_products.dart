import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/analytics_data.dart';

/// Pie chart showing top products by revenue
class TopProductsPieChart extends StatefulWidget {
  final List<TopProduct> products;

  const TopProductsPieChart({
    super.key,
    required this.products,
  });

  @override
  State<TopProductsPieChart> createState() => _TopProductsPieChartState();
}

class _TopProductsPieChartState extends State<TopProductsPieChart> {
  int touchedIndex = -1;

  static const List<Color> chartColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF22C55E), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFFF97316), // Orange
    Color(0xFF14B8A6), // Teal
    Color(0xFF84CC16), // Lime
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.products.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final totalRevenue = widget.products.fold<double>(
      0,
      (sum, p) => sum + p.revenue,
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos Más Vendidos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex =
                                response.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: widget.products.asMap().entries.map((entry) {
                        final index = entry.key;
                        final product = entry.value;
                        final isTouched = index == touchedIndex;
                        final percentage = (product.revenue / totalRevenue) * 100;

                        return PieChartSectionData(
                          color: chartColors[index % chartColors.length],
                          value: product.revenue,
                          title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
                          radius: isTouched ? 60 : 50,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.products.take(5).toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: chartColors[index % chartColors.length],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                product.productName,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Table showing top products with details
class TopProductsTable extends StatelessWidget {
  final List<TopProduct> products;

  const TopProductsTable({
    super.key,
    required this.products,
  });

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (products.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top 10 Productos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                headingRowColor: WidgetStateProperty.all(
                  theme.colorScheme.surfaceContainerHighest,
                ),
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Producto')),
                  DataColumn(label: Text('Cantidad'), numeric: true),
                  DataColumn(label: Text('Revenue'), numeric: true),
                ],
                rows: products.asMap().entries.map((entry) {
                  final index = entry.key;
                  final product = entry.value;
                  final rank = index + 1;

                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: rank <= 3
                                ? _getRankColor(rank).withOpacity(0.1)
                                : null,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: rank <= 3
                              ? Icon(
                                  Icons.emoji_events,
                                  size: 16,
                                  color: _getRankColor(rank),
                                )
                              : Text(
                                  '$rank',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            product.productName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(_formatNumber(product.quantitySold))),
                      DataCell(
                        Text(
                          _formatCurrency(product.revenue),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }
}

/// Combined widget with pie chart and table
class TopProductsWidget extends StatelessWidget {
  final List<TopProduct> products;
  final bool isCompact;

  const TopProductsWidget({
    super.key,
    required this.products,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return TopProductsTable(products: products);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: TopProductsPieChart(products: products),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: TopProductsTable(products: products),
        ),
      ],
    );
  }
}
