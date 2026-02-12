import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/enums/pos_order_status.dart';
import '../../../tables/presentation/providers/tables_provider.dart';
import '../../domain/entities/pos_order.dart';
import '../../domain/entities/payment.dart';
import '../screens/order_history_screen.dart';
import '../screens/kitchen_display_screen.dart';
import '../../../printing/print_service.dart';

const _uuid = Uuid();

/// Pantalla de checkout/pago
class CheckoutScreen extends ConsumerStatefulWidget {
  final POSOrder order;

  const CheckoutScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final TextEditingController _cashReceivedController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  double _tipPercentage = 0.0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _cashReceivedController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  double get _tipAmount => widget.order.total * (_tipPercentage / 100);
  double get _totalWithTip => widget.order.total + _tipAmount;
  
  double? get _cashReceived {
    final text = _cashReceivedController.text;
    return text.isEmpty ? null : double.tryParse(text);
  }

  double? get _change {
    if (_selectedMethod != PaymentMethod.cash || _cashReceived == null) {
      return null;
    }
    final change = _cashReceived! - _totalWithTip;
    return change > 0 ? change : 0;
  }

  bool get _canProcessPayment {
    if (_selectedMethod == PaymentMethod.cash) {
      return _cashReceived != null && _cashReceived! >= _totalWithTip;
    }
    if (_selectedMethod == PaymentMethod.transfer) {
      return _referenceController.text.isNotEmpty;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Procesar Pago'),
        backgroundColor: AppColors.posCheckout,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Información de la orden
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_long, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Orden #${widget.order.id.substring(0, 8)}',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  if (widget.order.tableName != null)
                                    Text(
                                      widget.order.tableName!,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  Text(
                                    dateFormat.format(widget.order.createdAt),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        
                        // Resumen de la cuenta
                        _DetailRow(
                          label: 'Subtotal',
                          value: currencyFormat.format(widget.order.subtotal),
                        ),
                        if (widget.order.discount != null)
                          _DetailRow(
                            label: 'Descuento (${widget.order.discount!.name})',
                            value: '-${currencyFormat.format(widget.order.discountAmount)}',
                            color: Colors.red,
                          ),
                        if (widget.order.extraCharges.isNotEmpty)
                          ...widget.order.extraCharges.map((charge) {
                            final amount = charge.calculateCharge(widget.order.subtotal);
                            return _DetailRow(
                              label: charge.name,
                              value: '+${currencyFormat.format(amount)}',
                            );
                          }),
                        _DetailRow(
                          label: 'IVA (16%)',
                          value: currencyFormat.format(widget.order.tax),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Total',
                          value: currencyFormat.format(widget.order.total),
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Propina
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Propina',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [0, 5, 10, 15, 20].map((percentage) {
                            final isSelected = _tipPercentage == percentage.toDouble();
                            return ChoiceChip(
                              label: Text(percentage == 0 ? 'Sin propina' : '$percentage%'),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _tipPercentage = percentage.toDouble();
                                });
                              },
                            );
                          }).toList(),
                        ),
                        if (_tipPercentage > 0) ...[
                          const SizedBox(height: 16),
                          _DetailRow(
                            label: 'Propina ($_tipPercentage%)',
                            value: '+${currencyFormat.format(_tipAmount)}',
                            color: Colors.green,
                          ),
                          const Divider(height: 24),
                          _DetailRow(
                            label: 'Total con Propina',
                            value: currencyFormat.format(_totalWithTip),
                            isTotal: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Método de pago
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Método de Pago',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: PaymentMethod.values.where((m) => m != PaymentMethod.mixed).map((method) {
                            final isSelected = _selectedMethod == method;
                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(method.icon, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(method.displayName),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedMethod = method;
                                  _cashReceivedController.clear();
                                  _referenceController.clear();
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        
                        // Campos específicos por método
                        if (_selectedMethod == PaymentMethod.cash) ...[
                          TextField(
                            controller: _cashReceivedController,
                            decoration: InputDecoration(
                              labelText: 'Efectivo Recibido',
                              prefixText: '\$ ',
                              border: const OutlineInputBorder(),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Botones de cantidad rápida
                                  _QuickAmountButton(
                                    amount: _totalWithTip.ceilToDouble(),
                                    label: 'Exacto',
                                    onTap: () {
                                      _cashReceivedController.text = 
                                          _totalWithTip.toStringAsFixed(2);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            onChanged: (value) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          if (_cashReceived != null && _cashReceived! < _totalWithTip)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Efectivo insuficiente. Faltan ${currencyFormat.format(_totalWithTip - _cashReceived!)}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_change != null && _change! > 0) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green, width: 2),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'CAMBIO',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(_change),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                        
                        if (_selectedMethod == PaymentMethod.transfer) ...[
                          TextField(
                            controller: _referenceController,
                            decoration: const InputDecoration(
                              labelText: 'Número de Referencia',
                              border: OutlineInputBorder(),
                              helperText: 'Ingresa el número de referencia de la transferencia',
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ],
                        
                        if (_selectedMethod == PaymentMethod.card) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.credit_card, color: Colors.blue),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text('Procesar pago con terminal bancaria'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: _canProcessPayment && !_isProcessing
                            ? _processPayment
                            : null,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle),
                        label: Text(_isProcessing ? 'Procesando...' : 'Confirmar Pago'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.posCheckout,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simular procesamiento
    await Future.delayed(const Duration(milliseconds: 800));

    // Crear pago
    final payment = Payment(
      id: _uuid.v4(),
      orderId: widget.order.id,
      method: _selectedMethod,
      amount: _totalWithTip,
      cashReceived: _selectedMethod == PaymentMethod.cash ? _cashReceived : null,
      change: _selectedMethod == PaymentMethod.cash ? _change : null,
      tipAmount: _tipPercentage > 0 ? _tipAmount : null,
      reference: _selectedMethod == PaymentMethod.transfer 
          ? _referenceController.text 
          : null,
      createdAt: DateTime.now(),
    );

    // Actualizar orden a completada
    final completedOrder = widget.order.copyWith(
      status: OrderStatus.completed,
      updatedAt: DateTime.now(),
    );

    // Remover de cocina si está ahí
    final kitchenOrders = ref.read(kitchenOrdersProvider);
    ref.read(kitchenOrdersProvider.notifier).state = 
        kitchenOrders.where((o) => o.id != widget.order.id).toList();

    // Agregar al historial
    final history = ref.read(orderHistoryProvider);
    ref.read(orderHistoryProvider.notifier).state = [
      completedOrder,
      ...history,
    ];

    // Liberar mesa si tiene
    if (widget.order.tableId != null) {
      ref.read(tablesProvider.notifier).freeTable(widget.order.tableId!);
    }

    if (!mounted) return;

    // Mostrar recibo
    await _showReceipt(payment);

    if (!mounted) return;

    // Volver a la pantalla de mesas
    context.go('/tables');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Pago procesado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _showReceipt(Payment payment) async {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.receipt),
            SizedBox(width: 8),
            Text('Recibo de Pago'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'SOFT RESTAURANT',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sistema POS',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateFormat.format(payment.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              
              // Info de la orden
              _ReceiptRow('Orden:', '#${widget.order.id.substring(0, 8)}'),
              if (widget.order.tableName != null)
                _ReceiptRow('Mesa:', widget.order.tableName!),
              const SizedBox(height: 16),
              
              // Items
              const Text(
                'ITEMS:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('${item.quantity}x '),
                      Expanded(child: Text(item.productName)),
                      Text(currencyFormat.format(item.subtotal)),
                    ],
                  ),
                );
              }),
              const Divider(height: 24),
              
              // Totales
              _ReceiptRow('Subtotal:', currencyFormat.format(widget.order.subtotal)),
              if (widget.order.discount != null)
                _ReceiptRow(
                  'Descuento:',
                  '-${currencyFormat.format(widget.order.discountAmount)}',
                ),
              _ReceiptRow('IVA:', currencyFormat.format(widget.order.tax)),
              if (payment.tipAmount != null && payment.tipAmount! > 0)
                _ReceiptRow(
                  'Propina:',
                  currencyFormat.format(payment.tipAmount),
                  color: Colors.green,
                ),
              const Divider(height: 16),
              _ReceiptRow(
                'TOTAL:',
                currencyFormat.format(payment.amount),
                isBold: true,
              ),
              const SizedBox(height: 16),
              
              // Método de pago
              _ReceiptRow('Método:', payment.method.displayName),
              if (payment.cashReceived != null) ...[
                _ReceiptRow('Recibido:', currencyFormat.format(payment.cashReceived)),
                if (payment.change != null && payment.change! > 0)
                  _ReceiptRow(
                    'Cambio:',
                    currencyFormat.format(payment.change),
                    color: Colors.green,
                  ),
              ],
              if (payment.reference != null)
                _ReceiptRow('Referencia:', payment.reference!),
              const SizedBox(height: 16),
              
              const Center(
                child: Text(
                  '¡Gracias por su preferencia!',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              // Generar y mostrar preview del ticket
              final ticketContent = PrintService().generateSalesTicket(widget.order);
              await PrintService().showTicketPreview(context, ticketContent, 'Ticket de Venta');
            },
            icon: const Icon(Icons.print),
            label: const Text('Imprimir'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? color;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.color,
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
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : null,
              fontSize: isTotal ? 18 : null,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : null,
              fontSize: isTotal ? 18 : null,
              color: color ?? (isTotal ? AppColors.primary : null),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _ReceiptRow(
    this.label,
    this.value, {
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : null,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : null,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final double amount;
  final String label;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.amount,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 36),
      ),
      child: Text(label),
    );
  }
}
