import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/providers/role_provider.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../core/widgets/greenpos_logo.dart';
import '../../domain/entities/restaurant_table.dart';
import '../providers/tables_provider.dart';
import '../../../pos/presentation/screens/pos_main_screen.dart';
import '../../../pos/presentation/screens/dashboard_screen.dart';
import '../../../pos/presentation/screens/order_history_screen.dart';
import '../../../pos/presentation/screens/kitchen_display_screen.dart';

/// Pantalla de gestión de mesas del restaurante
class TablesManagementScreen extends ConsumerWidget {
  const TablesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesState = ref.watch(tablesProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: GreenPosLogo(size: 36),
        ),
        title: const Text('GreenPOS · Mesas'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final role = ref.watch(roleProvider);

              // Role selector quick menu (local only)
              return PopupMenuButton<UserRole>(
                icon: const Icon(Icons.person_outline),
                tooltip: 'Rol: Cambiar',
                onSelected: (r) => ref.read(roleProvider.notifier).state = r,
                itemBuilder: (context) => UserRole.values
                    .map((r) => PopupMenuItem(value: r, child: Text(r.displayName)))
                    .toList(),
              );
            },
          ),

          // Main menu filtered por rol
          Consumer(
            builder: (context, ref, _) {
              final role = ref.watch(roleProvider);
              final items = <PopupMenuEntry<String>>[];

              if (canManageEmployees(role) || canManageAll(role)) {
                items.add(const PopupMenuItem(
                  value: 'employees',
                  child: Row(
                    children: [Icon(Icons.people, size: 20), SizedBox(width: 12), Text('Empleados')],
                  ),
                ));
              }

              if (canManageInventory(role) || canManageAll(role)) {
                items.add(const PopupMenuItem(
                  value: 'inventory',
                  child: Row(
                    children: [Icon(Icons.inventory, size: 20), SizedBox(width: 12), Text('Inventario')],
                  ),
                ));
              }

              // Dashboard visible para admin y cajero
              if (canManageAll(role) || canCharge(role)) {
                items.add(const PopupMenuItem(
                  value: 'dashboard',
                  child: Row(
                    children: [Icon(Icons.dashboard, size: 20), SizedBox(width: 12), Text('Dashboard')],
                  ),
                ));
              }

              if (canManageAll(role) || canOrder(role) || canCharge(role)) {
                items.add(const PopupMenuItem(
                  value: 'history',
                  child: Row(
                    children: [Icon(Icons.history, size: 20), SizedBox(width: 12), Text('Historial')],
                  ),
                ));
              }

              if (canSeeKitchen(role)) {
                items.add(const PopupMenuItem(
                  value: 'kitchen',
                  child: Row(
                    children: [Icon(Icons.restaurant, size: 20), SizedBox(width: 12), Text('Cocina')],
                  ),
                ));
              }

              return PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                tooltip: 'Menú',
                onSelected: (value) {
                  switch (value) {
                    case 'employees':
                      context.push('/employees');
                      break;
                    case 'inventory':
                      context.push('/inventory');
                      break;
                    case 'dashboard':
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DashboardScreen()));
                      break;
                    case 'history':
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
                      break;
                    case 'kitchen':
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const KitchenDisplayScreen()));
                      break;
                  }
                },
                itemBuilder: (_) => items,
              );
            },
          ),

          // Estadísticas rápidas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Row(
                children: [
                  _StatusChip(
                    icon: Icons.check_circle,
                    label: '${tablesState.availableTables.length}',
                    color: Colors.green,
                    tooltip: 'Disponibles',
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    icon: Icons.people,
                    label: '${tablesState.occupiedTables.length}',
                    color: AppColors.primary,
                    tooltip: 'Ocupadas',
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    icon: Icons.schedule,
                    label: '${tablesState.reservedTables.length}',
                    color: AppColors.posKitchen,
                    tooltip: 'Reservadas',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive: determinar cuántas columnas mostrar
          int crossAxisCount;
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 6;
          } else if (constraints.maxWidth > 800) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 2;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: tablesState.tables.length,
            itemBuilder: (context, index) {
              final table = tablesState.tables[index];
              return _TableCard(table: table);
            },
          );
        },
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final role = ref.watch(roleProvider);
          // Mostrar acceso al POS solo para quienes puedan cobrar u ordenar
          if (canCharge(role) || canOrder(role) || canManageAll(role)) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const POSMainScreen()));
              },
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Ir al POS'),
              backgroundColor: AppColors.primary,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Chip de estado en el AppBar
class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String tooltip;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de una mesa individual
class _TableCard extends ConsumerWidget {
  final RestaurantTable table;

  const _TableCard({required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _getStatusColor(table.status);
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: table.isOccupied ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color,
          width: table.isOccupied ? 3 : 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showTableOptions(context, ref, table),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isSmall ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Número de mesa
              Text(
                table.number,
                style: TextStyle(
                  fontSize: isSmall ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Icono de estado
              Icon(
                _getStatusIcon(table.status),
                size: isSmall ? 24 : 32,
                color: color,
              ),
              
              const SizedBox(height: 8),
              
              // Nombre del estado
              Text(
                table.status.displayName,
                style: TextStyle(
                  fontSize: isSmall ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Capacidad
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: isSmall ? 14 : 16, color: color.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                    '${table.capacity} pers.',
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 12,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              // Info adicional si está reservada u ocupada
              if (table.isReserved && table.reservedFor != null) ...[
                const SizedBox(height: 4),
                Text(
                  table.reservedFor!,
                  style: TextStyle(
                    fontSize: isSmall ? 10 : 11,
                    fontStyle: FontStyle.italic,
                    color: color.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return AppColors.primary;
      case TableStatus.reserved:
        return AppColors.posKitchen;
      case TableStatus.cleaning:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Icons.check_circle;
      case TableStatus.occupied:
        return Icons.people;
      case TableStatus.reserved:
        return Icons.schedule;
      case TableStatus.cleaning:
        return Icons.cleaning_services;
    }
  }

  void _showTableOptions(BuildContext context, WidgetRef ref, RestaurantTable table) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TableOptionsSheet(table: table),
    );
  }
}

/// Sheet de opciones para una mesa
class _TableOptionsSheet extends ConsumerWidget {
  final RestaurantTable table;

  const _TableOptionsSheet({required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.table_restaurant,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesa ${table.number}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      '${table.status.displayName} • ${table.capacity} personas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Opciones según el estado y rol
          if (table.isAvailable) ...[
            if (canOrder(role) || canManageAll(role))
              _OptionButton(
                icon: Icons.add_circle,
                label: 'Asignar pedido',
                color: AppColors.posCheckout,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const POSMainScreen()));
                },
              ),
            if (canOrder(role) || canManageAll(role)) const SizedBox(height: 12),
            if (canOrder(role) || canManageAll(role))
              _OptionButton(
                icon: Icons.schedule,
                label: 'Reservar mesa',
                color: AppColors.posKitchen,
                onPressed: () {
                  Navigator.pop(context);
                  _showReserveDialogFunction(context, ref, table);
                },
              ),
          ],

          if (table.isOccupied) ...[
            if (canOrder(role) || canCharge(role) || canManageAll(role))
              _OptionButton(
                icon: Icons.receipt_long,
                label: 'Ver pedido',
                color: AppColors.primary,
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Ir a ver el pedido
                },
              ),
            if (canOrder(role) || canManageAll(role)) const SizedBox(height: 12),
            if (canOrder(role) || canManageAll(role))
              _OptionButton(
                icon: Icons.transfer_within_a_station,
                label: 'Transferir a otra mesa',
                color: Colors.blue,
                onPressed: () {
                  Navigator.pop(context);
                  _showTransferDialogFunction(context, ref, table);
                },
              ),
            if (canCharge(role) || canManageAll(role)) const SizedBox(height: 12),
            if (canCharge(role) || canManageAll(role))
              _OptionButton(
                icon: Icons.check,
                label: 'Liberar mesa',
                color: AppColors.posCheckout,
                onPressed: () {
                  ref.read(tablesProvider.notifier).freeTable(table.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mesa ${table.number} liberada')));
                },
              ),
          ],

          if (table.isReserved) ...[
            if (canOrder(role) || canManageAll(role))
              _OptionButton(
                icon: Icons.people,
                label: 'Confirmar llegada',
                color: AppColors.primary,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const POSMainScreen()));
                },
              ),
            if (canOrder(role) || canManageAll(role)) const SizedBox(height: 12),
            if (canOrder(role) || canManageAll(role))
              _OptionButton(
                icon: Icons.cancel,
                label: 'Cancelar reservación',
                color: AppColors.posCancel,
                onPressed: () {
                  ref.read(tablesProvider.notifier).freeTable(table.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reservación de mesa ${table.number} cancelada')));
                },
              ),
          ],

          const SizedBox(height: 12),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}

// Funciones auxiliares fuera del widget
void _showReserveDialogFunction(BuildContext context, WidgetRef ref, RestaurantTable table) {
  final nameController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Reservar Mesa ${table.number}'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: 'Nombre del cliente',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              ref.read(tablesProvider.notifier).reserveTable(
                    table.id,
                    nameController.text,
                    DateTime.now(),
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mesa ${table.number} reservada para ${nameController.text}'),
                ),
              );
            }
          },
          child: const Text('Reservar'),
        ),
      ],
    ),
  );
}

void _showTransferDialogFunction(BuildContext context, WidgetRef ref, RestaurantTable fromTable) {
  final tablesState = ref.read(tablesProvider);
  final availableTables = tablesState.availableTables;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Transferir a otra mesa'),
      content: SizedBox(
        width: double.maxFinite,
        child: availableTables.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No hay mesas disponibles'),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: availableTables.length,
                itemBuilder: (context, index) {
                  final table = availableTables[index];
                  return ListTile(
                    leading: const Icon(Icons.table_restaurant),
                    title: Text('Mesa ${table.number}'),
                    subtitle: Text('${table.capacity} personas'),
                    onTap: () {
                      ref.read(tablesProvider.notifier).transferOrder(
                            fromTable.id,
                            table.id,
                          );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pedido transferido de mesa ${fromTable.number} a ${table.number}'),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    ),
  );
}

/// Botón de opción en el sheet
class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
