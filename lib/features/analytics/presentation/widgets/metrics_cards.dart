import 'package:flutter/material.dart';
import '../../domain/entities/analytics_data.dart';

/// A single metric card displaying a key value
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid of metric cards for the dashboard
class MetricsCardsGrid extends StatelessWidget {
  final DashboardMetrics metrics;
  final bool isCompact;

  const MetricsCardsGrid({
    super.key,
    required this.metrics,
    this.isCompact = false,
  });

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactGrid(context);
    }
    return _buildFullGrid(context);
  }

  Widget _buildCompactGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: [
        MetricCard(
          title: 'Hoy',
          value: _formatCurrency(metrics.todayRevenue),
          icon: Icons.today,
          iconColor: Colors.blue,
          subtitle: '${metrics.ordersToday} órdenes',
        ),
        MetricCard(
          title: 'Esta Semana',
          value: _formatCurrency(metrics.weekRevenue),
          icon: Icons.date_range,
          iconColor: Colors.green,
          subtitle: '${metrics.ordersThisWeek} órdenes',
        ),
        MetricCard(
          title: 'Ticket Promedio',
          value: _formatCurrency(metrics.averageTicket),
          icon: Icons.receipt_long,
          iconColor: Colors.orange,
        ),
        MetricCard(
          title: 'Órdenes Activas',
          value: '${metrics.activeOrders}',
          icon: Icons.pending_actions,
          iconColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildFullGrid(BuildContext context) {
    final theme = Theme.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 
            ? 4 
            : constraints.maxWidth > 800 
                ? 3 
                : 2;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            MetricCard(
              title: 'Revenue Total',
              value: _formatCurrency(metrics.totalRevenue),
              icon: Icons.attach_money,
              iconColor: Colors.green,
              subtitle: '${metrics.totalOrders} órdenes totales',
            ),
            MetricCard(
              title: 'Hoy',
              value: _formatCurrency(metrics.todayRevenue),
              icon: Icons.today,
              iconColor: Colors.blue,
              subtitle: '${metrics.ordersToday} órdenes',
            ),
            MetricCard(
              title: 'Esta Semana',
              value: _formatCurrency(metrics.weekRevenue),
              icon: Icons.date_range,
              iconColor: Colors.teal,
              subtitle: '${metrics.ordersThisWeek} órdenes',
            ),
            MetricCard(
              title: 'Este Mes',
              value: _formatCurrency(metrics.monthRevenue),
              icon: Icons.calendar_month,
              iconColor: Colors.indigo,
              subtitle: '${metrics.ordersThisMonth} órdenes',
            ),
            MetricCard(
              title: 'Ticket Promedio',
              value: _formatCurrency(metrics.averageTicket),
              icon: Icons.receipt_long,
              iconColor: Colors.orange,
            ),
            MetricCard(
              title: 'Órdenes Activas',
              value: '${metrics.activeOrders}',
              icon: Icons.pending_actions,
              iconColor: Colors.purple,
            ),
            MetricCard(
              title: 'Mesas Totales',
              value: '${metrics.totalTables}',
              icon: Icons.table_restaurant,
              iconColor: Colors.brown,
            ),
            MetricCard(
              title: 'Mesas Disponibles',
              value: '${metrics.availableTables}',
              icon: Icons.event_seat,
              iconColor: Colors.green,
              subtitle: 'de ${metrics.totalTables} totales',
            ),
          ],
        );
      },
    );
  }
}
