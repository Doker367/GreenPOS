import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/mock_data_providers.dart';
import '../../domain/entities/discount.dart';
import '../providers/active_order_provider.dart';

/// Diálogo para seleccionar y aplicar descuentos
Future<void> showDiscountDialog(BuildContext context, WidgetRef ref) async {
  final discount = await showDialog<Discount>(
    context: context,
    builder: (context) => const _DiscountDialog(),
  );

  if (discount != null && context.mounted) {
    ref.read(activeOrderProvider.notifier).applyDiscount(discount);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descuento "${discount.name}" aplicado'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _DiscountDialog extends ConsumerWidget {
  const _DiscountDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discounts = ref.watch(mockDiscountsProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final orderState = ref.watch(activeOrderProvider);
    final subtotal = orderState.subtotal;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: isMobile 
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 40)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 500,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.discount, color: Colors.white, size: isMobile ? 24 : 28),
                  SizedBox(width: isMobile ? 8 : 12),
                  Expanded(
                    child: Text(
                      'Aplicar Descuento',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18 : 22,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Lista de descuentos scrollable
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                itemCount: discounts.length + 1, // +1 para "Sin descuento"
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Opción "Sin descuento"
                    return _DiscountTile(
                      discount: null,
                      subtotal: subtotal,
                      isSelected: orderState.order?.discount == null,
                      onTap: () => Navigator.of(context).pop(null),
                    );
                  }
                  
                  final discount = discounts[index - 1];
                  return _DiscountTile(
                    discount: discount,
                    subtotal: subtotal,
                    isSelected: orderState.order?.discount?.id == discount.id,
                    onTap: () => Navigator.of(context).pop(discount),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountTile extends StatelessWidget {
  final Discount? discount;
  final double subtotal;
  final bool isSelected;
  final VoidCallback onTap;

  const _DiscountTile({
    required this.discount,
    required this.subtotal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    final discountAmount = discount != null
        ? discount!.calculateDiscount(subtotal)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: discount != null
                      ? AppColors.posCheckout.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  discount != null ? Icons.discount : Icons.close,
                  color: discount != null ? AppColors.posCheckout : Colors.grey,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discount?.name ?? 'Sin descuento',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (discount?.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        discount!.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ],
                    if (discount != null && discount!.requiresAuthorization) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: AppColors.posCancel,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Requiere autorización',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.posCancel,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Valor del descuento
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (discount != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.posCheckout.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        discount!.displayValue,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.posCheckout,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '-${currencyFormat.format(discountAmount)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.posCheckout,
                          ),
                    ),
                  ],
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
