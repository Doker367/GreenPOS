import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/enums/pos_order_status.dart';
import '../../../orders/presentation/providers/payment_provider.dart';
import '../../domain/entities/pos_order.dart';
import '../../domain/entities/payment.dart';

/// Payment method selection and processing screen
/// Supports cash, card (Stripe), and PayPal
class PaymentScreen extends ConsumerStatefulWidget {
  final POSOrder order;

  const PaymentScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final TextEditingController _cashReceivedController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  bool _isProcessing = false;
  Payment? _completedPayment;

  @override
  void initState() {
    super.initState();
    // Set default to cash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProvider.notifier).selectMethod(PaymentMethod.cash);
    });
  }

  @override
  void dispose() {
    _cashReceivedController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  double? get _cashReceived {
    final text = _cashReceivedController.text;
    return text.isEmpty ? null : double.tryParse(text);
  }

  double? get _change {
    if (_selectedMethod != PaymentMethod.cash || _cashReceived == null) {
      return null;
    }
    final change = _cashReceived! - widget.order.total;
    return change > 0 ? change : 0;
  }

  bool get _canProcessCashPayment {
    if (_selectedMethod != PaymentMethod.cash) return false;
    return _cashReceived != null && _cashReceived! >= widget.order.total;
  }

  bool get _canProcessCardPayment {
    return _selectedMethod == PaymentMethod.card && !_isProcessing;
  }

  bool get _canProcessTransferPayment {
    if (_selectedMethod != PaymentMethod.transfer) return false;
    return _referenceController.text.isNotEmpty;
  }

  Future<void> _processCashPayment() async {
    if (!_canProcessCashPayment) return;

    setState(() => _isProcessing = true);

    try {
      final payment = await ref
          .read(paymentProvider.notifier)
          .createCashPayment(widget.order.id, widget.order.total);

      if (payment != null && mounted) {
        setState(() {
          _completedPayment = payment;
          _isProcessing = false;
        });
        _showSuccessDialog(payment);
      } else {
        setState(() => _isProcessing = false);
        _showErrorSnackBar('Error al procesar pago en efectivo');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _processCardPayment() async {
    if (!_canProcessCardPayment) return;

    setState(() => _isProcessing = true);

    try {
      // First create the payment intent on backend
      final intent = await ref
          .read(paymentProvider.notifier)
          .createStripePaymentIntent(widget.order.id);

      if (intent == null) {
        setState(() => _isProcessing = false);
        _showErrorSnackBar('Error al crear intención de pago');
        return;
      }

      // Show Stripe payment sheet (would integrate with actual Stripe SDK)
      // For now, simulate completion
      await Future.delayed(const Duration(seconds: 2));

      final payment = await ref
          .read(paymentProvider.notifier)
          .confirmStripePayment(intent.clientSecret);

      if (payment != null && mounted) {
        setState(() {
          _completedPayment = payment;
          _isProcessing = false;
        });
        _showSuccessDialog(payment);
      } else {
        setState(() => _isProcessing = false);
        _showErrorSnackBar('Pago con tarjeta no completado');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _processPayPalPayment() async {
    if (_selectedMethod != PaymentMethod.card) return; // PayPal uses card method slot

    setState(() => _isProcessing = true);

    try {
      // Create PayPal order on backend
      final paypalOrder = await ref
          .read(paymentProvider.notifier)
          .createPayPalOrder(widget.order.id);

      if (paypalOrder == null) {
        setState(() => _isProcessing = false);
        _showErrorSnackBar('Error al crear orden PayPal');
        return;
      }

      // In production, would open PayPal checkout URL
      // For demo, simulate user approval after delay
      await Future.delayed(const Duration(seconds: 2));

      // Capture the order
      final payment = await ref
          .read(paymentProvider.notifier)
          .capturePayPalOrder(paypalOrder.id);

      if (payment != null && mounted) {
        setState(() {
          _completedPayment = payment;
          _isProcessing = false;
        });
        _showSuccessDialog(payment);
      } else {
        setState(() => _isProcessing = false);
        _showErrorSnackBar('Orden PayPal no completada');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _processTransferPayment() async {
    if (!_canProcessTransferPayment) return;

    setState(() => _isProcessing = true);

    // Simulate transfer payment processing
    await Future.delayed(const Duration(seconds: 1));

    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderId: widget.order.id,
      amount: widget.order.total,
      method: PaymentMethod.transfer,
      provider: null,
      providerPaymentId: _referenceController.text,
      status: PaymentStatus.completed,
      createdAt: DateTime.now(),
    );

    setState(() {
      _completedPayment = payment;
      _isProcessing = false;
    });

    _showSuccessDialog(payment);
  }

  void _showSuccessDialog(Payment payment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('¡Pago Exitoso!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total: \$${widget.order.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Método: ${_getMethodName(payment.method)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (_selectedMethod == PaymentMethod.cash && _change != null) ...[
              const SizedBox(height: 8),
              Text(
                'Cambio: \$${_change!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Folio: ${payment.id.substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/pos');
            },
            icon: const Icon(Icons.done),
            label: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.transfer:
        return 'Transferencia';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago'),
        backgroundColor: AppColors.posCheckout,
        elevation: 0,
      ),
      body: _completedPayment != null
          ? _buildSuccessView()
          : _buildPaymentForm(currencyFormat),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 24),
          const Text(
            '¡Pago Completado!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Total: \$${widget.order.total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => context.go('/pos'),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(NumberFormat currencyFormat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel - Order summary
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen del Pedido',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                _buildOrderSummary(),
                const Divider(height: 32),
                _buildTotalSection(currencyFormat),
              ],
            ),
          ),
        ),

        // Right panel - Payment methods
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Método de Pago',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                _buildPaymentMethods(),
                const SizedBox(height: 24),
                _buildPaymentDetails(),
                const SizedBox(height: 32),
                _buildProcessButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.order.tableName != null) ...[
          Row(
            children: [
              const Icon(Icons.table_restaurant, size: 18),
              const SizedBox(width: 8),
              Text('Mesa ${widget.order.tableName}'),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (widget.order.customerName != null) ...[
          Row(
            children: [
              const Icon(Icons.person, size: 18),
              const SizedBox(width: 8),
              Text(widget.order.customerName!),
            ],
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        Text(
          '${widget.order.totalItems} items',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        ...widget.order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('${item.quantity}x ${item.productName}'),
                  ),
                  Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildTotalSection(NumberFormat currencyFormat) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal'),
            Text(currencyFormat.format(widget.order.subtotal)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Impuesto (16%)'),
            Text(currencyFormat.format(widget.order.tax)),
          ],
        ),
        if (widget.order.discount != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Descuento'),
              Text(
                '- ${currencyFormat.format(widget.order.discount!.amount)}',
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              currencyFormat.format(widget.order.total),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        _buildPaymentMethodTile(
          method: PaymentMethod.cash,
          icon: Icons.money,
          title: 'Efectivo',
          subtitle: 'Pago en efectivo en mostrador',
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodTile(
          method: PaymentMethod.card,
          icon: Icons.credit_card,
          title: 'Tarjeta',
          subtitle: 'Visa, Mastercard, American Express',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProviderChip('Stripe', Icons.flash_on),
              const SizedBox(width: 8),
              _buildProviderChip('PayPal', Icons.paypal),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodTile(
          method: PaymentMethod.transfer,
          icon: Icons.account_balance,
          title: 'Transferencia',
          subtitle: 'SPEI, transferencia bancaria',
        ),
      ],
    );
  }

  Widget _buildProviderChip(String name, IconData icon) {
    final isStripe = name == 'Stripe';
    final paymentState = ref.watch(paymentProvider);

    return GestureDetector(
      onTap: () {
        if (_selectedMethod == PaymentMethod.card) {
          // Toggle between Stripe and PayPal sub-methods
          // For now, both trigger card flow
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _selectedMethod == PaymentMethod.card
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedMethod == PaymentMethod.card
                ? AppColors.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: _selectedMethod == PaymentMethod.card
                  ? AppColors.primary
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _selectedMethod == PaymentMethod.card
                    ? AppColors.primary
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final isSelected = _selectedMethod == method;

    return InkWell(
      onTap: () {
        setState(() => _selectedMethod = method);
        ref.read(paymentProvider.notifier).selectMethod(method);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMethod = value);
                  ref.read(paymentProvider.notifier).selectMethod(value);
                }
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    switch (_selectedMethod) {
      case PaymentMethod.cash:
        return _buildCashDetails();
      case PaymentMethod.card:
        return _buildCardDetails();
      case PaymentMethod.transfer:
        return _buildTransferDetails();
    }
  }

  Widget _buildCashDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Efectivo Recibido',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cashReceivedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: '0.00',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickCashButton(100),
              const SizedBox(width: 8),
              _buildQuickCashButton(200),
              const SizedBox(width: 8),
              _buildQuickCashButton(500),
              const SizedBox(width: 8),
              _buildQuickCashButton(1000),
            ],
          ),
          if (_change != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cambio:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '\$${_change!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickCashButton(double amount) {
    return OutlinedButton(
      onPressed: () {
        _cashReceivedController.text = amount.toStringAsFixed(0);
        setState(() {});
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text('\$${amount.toStringAsFixed(0)}'),
    );
  }

  Widget _buildCardDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.credit_card, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pago con Tarjeta',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Se abrirá el formulario de pago seguro',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.purple.shade700, size: 20),
              const SizedBox(width: 8),
              const Text('Procesado por Stripe', style: TextStyle(fontSize: 13)),
              const Spacer(),
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 4),
              Text(
                'Pago 100% seguro',
                style: TextStyle(fontSize: 12, color: Colors.green.shade700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              const Text('O PayPal', style: TextStyle(fontSize: 13)),
              const Spacer(),
              Icon(Icons.security, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 4),
              Text(
                'Protección al comprador',
                style: TextStyle(fontSize: 12, color: Colors.green.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransferDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Referencia de Transferencia',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _referenceController,
            decoration: InputDecoration(
              hintText: 'Ingrese el número de referencia',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
              const SizedBox(width: 8),
              Text(
                'La orden quedará pendiente hasta confirmar la transferencia',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    final canProcess = _selectedMethod == PaymentMethod.cash
        ? _canProcessCashPayment
        : _selectedMethod == PaymentMethod.card
            ? true // Always can initiate card payment
            : _canProcessTransferPayment;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: canProcess && !_isProcessing ? _processPayment : null,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(_getProcessIcon()),
        label: Text(
          _isProcessing
              ? 'Procesando...'
              : 'Cobrar \$${widget.order.total.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  IconData _getProcessIcon() {
    switch (_selectedMethod) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.transfer:
        return Icons.account_balance;
    }
  }

  void _processPayment() {
    switch (_selectedMethod) {
      case PaymentMethod.cash:
        _processCashPayment();
        break;
      case PaymentMethod.card:
        _processCardPayment();
        break;
      case PaymentMethod.transfer:
        _processTransferPayment();
        break;
    }
  }
}
