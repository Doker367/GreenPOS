import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/enums/pos_order_status.dart';
import '../providers/active_order_provider.dart';
import '../screens/kitchen_display_screen.dart';
import '../../../tables/presentation/providers/tables_provider.dart';
import '../../../tables/domain/entities/restaurant_table.dart';
import 'discount_dialog.dart';
import 'extra_charge_dialog.dart';

/// Panel derecho que muestra el pedido activo
class ActiveOrderPanel extends ConsumerWidget {
  const ActiveOrderPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(activeOrderProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header con info de mesa
          _OrderHeader(orderState: orderState, isSmallScreen: isSmallScreen),

          const Divider(height: 1),

          // Lista de items del pedido
          Expanded(
            child: orderState.hasItems
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: orderState.order!.items.length,
                    itemBuilder: (context, index) {
                      final item = orderState.order!.items[index];
                      return _OrderItemTile(
                        item: item,
                        onIncrement: () {
                          ref
                              .read(activeOrderProvider.notifier)
                              .incrementItem(item.id);
                        },
                        onDecrement: () {
                          ref
                              .read(activeOrderProvider.notifier)
                              .decrementItem(item.id);
                        },
                        onRemove: () {
                          ref
                              .read(activeOrderProvider.notifier)
                              .removeItem(item.id);
                        },
                        onAddNote: () {
                          _showNoteDialog(context, ref, item.id, item.notes);
                        },
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Pedido vacío',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selecciona productos\npara agregar al pedido',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.4),
                              ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Totales y acciones
          if (orderState.hasItems) ...[
            const Divider(height: 1),
            _OrderTotals(
              orderState: orderState,
            ),
            const Divider(height: 1),
            _OrderActions(orderState: orderState),
          ],
        ],
      ),
    );
  }

  void _showNoteDialog(
    BuildContext context,
    WidgetRef ref,
    String itemId,
    String? currentNote,
  ) {
    final controller = TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nota del producto'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ej: Sin cebolla, extra queso...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(activeOrderProvider.notifier)
                  .addItemNote(itemId, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

/// Header del panel con información de mesa
class _OrderHeader extends ConsumerWidget {
  final ActiveOrderState orderState;
  final bool isSmallScreen;

  const _OrderHeader({
    required this.orderState,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pedido Activo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (orderState.hasItems)
                TextButton.icon(
                  onPressed: () {
                    _showClearOrderDialog(context, ref);
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                orderState.order?.hasTable ?? false
                    ? Icons.table_restaurant
                    : Icons.shopping_bag_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                orderState.order?.hasTable ?? false
                    ? 'Mesa: ${orderState.order!.tableName}'
                    : 'Para llevar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Spacer(),
              if (!(orderState.order?.hasTable ?? false))
                TextButton(
                  onPressed: () {
                    // TODO: Abrir selector de mesa
                    _showTableSelectorDialog(context, ref);
                  },
                  child: const Text('Asignar Mesa'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearOrderDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Pedido'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar este pedido?\n\nSe perderán todos los productos agregados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(activeOrderProvider.notifier).clearOrder();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showTableSelectorDialog(BuildContext context, WidgetRef ref) {
    final tablesState = ref.read(tablesProvider);
    final availableTables = tablesState.availableTables;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Asignar Mesa'),
        content: SizedBox(
          width: double.maxFinite,
          child: availableTables.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No hay mesas disponibles en este momento.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableTables.length,
                  itemBuilder: (context, index) {
                    final table = availableTables[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.2),
                        child: Icon(
                          Icons.table_restaurant,
                          color: Colors.green,
                        ),
                      ),
                      title: Text('Mesa ${table.number}'),
                      subtitle: Text('${table.capacity} personas'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ref.read(activeOrderProvider.notifier).assignTable(
                              table.id,
                              table.number,
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pedido asignado a Mesa ${table.number}'),
                            duration: const Duration(seconds: 2),
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
}

/// Tile individual de un item en el pedido
class _OrderItemTile extends StatelessWidget {
  final item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final VoidCallback onAddNote;

  const _OrderItemTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            child: Row(
              children: [
                // Controles de cantidad
                Column(
                  children: [
                    InkWell(
                      onTap: onIncrement,
                      child: Container(
                        width: isSmallScreen ? 28 : 32,
                        height: isSmallScreen ? 28 : 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: isSmallScreen ? 16 : 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: onDecrement,
                      child: Container(
                        width: isSmallScreen ? 28 : 32,
                        height: isSmallScreen ? 28 : 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: isSmallScreen ? 16 : 20,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: isSmallScreen ? 8 : 12),

                // Info del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 13 : 16,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(item.adjustedUnitPrice),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                      if (item.notes != null && item.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.note,
                                size: 14,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  item.notes!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber[900],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Subtotal y acciones
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(item.subtotal),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: onAddNote,
                          icon: Icon(
                            item.notes != null && item.notes!.isNotEmpty
                                ? Icons.note
                                : Icons.note_add_outlined,
                            size: 20,
                          ),
                          tooltip: 'Agregar nota',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        IconButton(
                          onPressed: onRemove,
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                          ),
                          tooltip: 'Eliminar',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sección de totales
class _OrderTotals extends ConsumerWidget {
  final ActiveOrderState orderState;

  const _OrderTotals({
    required this.orderState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final order = orderState.order!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TotalRow(
            label: 'Subtotal:',
            amount: currencyFormat.format(order.subtotal),
          ),
          
          // Descuento
          if (order.discount != null) ...[
            const SizedBox(height: 6),
            _TotalRow(
              label: '${order.discount!.name}:',
              amount: '-${currencyFormat.format(order.discountAmount)}',
              isDiscount: true,
            ),
          ],
          
          // Botón agregar descuento
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton.icon(
              onPressed: () => showDiscountDialog(context, ref),
              icon: Icon(
                order.discount != null ? Icons.edit_outlined : Icons.discount_outlined,
                size: 16,
              ),
              label: Text(
                order.discount != null ? 'Cambiar descuento' : 'Agregar descuento',
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

          // Cargos extras
          if (order.extraCharges.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...order.extraCharges.map((charge) {
              final chargeAmount = charge.calculateCharge(order.subtotal);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: _TotalRow(
                        label: '${charge.name}:',
                        amount: '+${currencyFormat.format(chargeAmount)}',
                        isExtraCharge: true,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        ref
                            .read(activeOrderProvider.notifier)
                            .removeExtraCharge(charge.id);
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
          
          // Botón agregar cargo extra
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton.icon(
              onPressed: () => showExtraChargeDialog(context, ref),
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text(
                'Agregar cargo extra',
                style: TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
                foregroundColor: AppColors.posKitchen,
                side: BorderSide(color: AppColors.posKitchen),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          _TotalRow(
            label: 'IVA (16%):',
            amount: currencyFormat.format(order.tax),
          ),
          const Divider(height: 12),
          _TotalRow(
            label: 'TOTAL:',
            amount: currencyFormat.format(order.total),
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isTotal;
  final bool isDiscount;
  final bool isExtraCharge;

  const _TotalRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.isDiscount = false,
    this.isExtraCharge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          amount,
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  )
              : isDiscount
                  ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.posCheckout,
                      )
                  : isExtraCharge
                      ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.posKitchen,
                          )
                      : Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
        ),
      ],
    );
  }
}

/// Botones de acción del pedido
class _OrderActions extends ConsumerWidget {
  final ActiveOrderState orderState;

  const _OrderActions({required this.orderState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botón Enviar a Cocina
          FilledButton.icon(
            onPressed: orderState.order?.canSendToKitchen ?? false
                ? () => _handleSendToKitchen(context, ref)
                : null,
            icon: const Icon(Icons.send),
            label: const Text('Enviar a Cocina'),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
              backgroundColor: AppColors.posKitchen,
            ),
          ),

          const SizedBox(height: 8),

          // Botón Cobrar
          FilledButton.icon(
            onPressed: orderState.order?.canCheckout ?? false
                ? () => _handleCheckout(context, ref)
                : null,
            icon: const Icon(Icons.payment),
            label: const Text('COBRAR'),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
              backgroundColor: AppColors.posCheckout,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSendToKitchen(BuildContext context, WidgetRef ref) {
    final order = orderState.order;
    if (order == null || !order.hasItems) {
      _showErrorSnackbar(context, 'El pedido está vacío');
      return;
    }

    // Validar que todos los items requeridos tengan modificadores
    bool hasValidationErrors = false;
    for (final item in order.items) {
      // Aquí podrías agregar validaciones específicas
      // Por ejemplo, verificar modificadores requeridos
    }

    if (hasValidationErrors) {
      _showErrorSnackbar(context, 'Completa la información de todos los items');
      return;
    }

    // Mostrar confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar a Cocina'),
        content: Text(
          '¿Confirmar envío de ${order.totalItems} items a cocina?'
          '${order.hasTable ? '\n\nMesa: ${order.tableName}' : '\nPara llevar'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Cambiar estado de la orden a "sent" (enviado a cocina)
              ref.read(activeOrderProvider.notifier).updateOrderStatus(OrderStatus.sent);
              
              // Si tiene mesa asignada, ocupar la mesa
              if (order.hasTable && order.tableId != null) {
                ref.read(tablesProvider.notifier).occupyTable(order.tableId!, order.id);
              }
              
              // Agregar la orden al provider de cocina
              final currentKitchenOrders = ref.read(kitchenOrdersProvider);
              ref.read(kitchenOrdersProvider.notifier).state = [...currentKitchenOrders, order];
              
              _showSuccessSnackbar(context, 'Pedido enviado a cocina exitosamente');
              
              // Limpiar el pedido activo para empezar uno nuevo
              ref.read(activeOrderProvider.notifier).clearOrder();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.posKitchen),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context, WidgetRef ref) {
    final order = orderState.order;
    if (order == null || !order.hasItems) {
      _showErrorSnackbar(context, 'El pedido está vacío');
      return;
    }

    // Validar monto mínimo (opcional)
    if (order.total < 1) {
      _showErrorSnackbar(context, 'El total debe ser mayor a \$1');
      return;
    }

    // Mostrar resumen antes de cobrar
    showDialog(
      context: context,
      builder: (context) => _CheckoutConfirmationDialog(order: order),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.posCancel,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.posCheckout,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Diálogo de confirmación de checkout
class _CheckoutConfirmationDialog extends ConsumerWidget {
  final dynamic order;

  const _CheckoutConfirmationDialog({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.payment, color: AppColors.primary),
          const SizedBox(width: 12),
          const Text('Resumen de Cobro'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow('Items:', '${order.totalItems}'),
          const Divider(),
          _SummaryRow('Subtotal:', currencyFormat.format(order.subtotal)),
          if (order.discount != null)
            _SummaryRow(
              'Descuento (${order.discount!.displayValue}):',
              '-${currencyFormat.format(order.discountAmount)}',
              isDiscount: true,
            ),
          _SummaryRow('IVA (16%):', currencyFormat.format(order.tax)),
          const Divider(thickness: 2),
          _SummaryRow(
            'TOTAL A PAGAR:',
            currencyFormat.format(order.total),
            isTotal: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            // En FASE 5 se abrirá pantalla completa de cobro con métodos de pago
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Pantalla de cobro completa disponible en FASE 5'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          icon: const Icon(Icons.payment),
          label: const Text('Proceder al Cobro'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.posCheckout,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isDiscount;

  const _SummaryRow(
    this.label,
    this.value, {
    this.isTotal = false,
    this.isDiscount = false,
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
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    )
                : isDiscount
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.posCheckout,
                      )
                    : Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
          ),
        ],
      ),
    );
  }
}
