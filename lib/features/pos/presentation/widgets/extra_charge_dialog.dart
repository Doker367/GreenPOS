import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/mock_data_providers.dart';
import '../../domain/entities/extra_charge.dart';
import '../providers/active_order_provider.dart';

/// Diálogo para seleccionar y aplicar cargos extras
Future<void> showExtraChargeDialog(BuildContext context, WidgetRef ref) async {
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => const _ExtraChargeDialog(),
  );

  if (result != null && context.mounted) {
    final charge = result['charge'] as ExtraCharge;
    final customValue = result['customValue'] as double?;
    
    // Si hay valor personalizado, crear un nuevo cargo con ese valor
    final finalCharge = customValue != null
        ? ExtraCharge(
            id: '${charge.id}_custom',
            name: charge.name,
            type: charge.type,
            value: customValue,
            description: charge.description,
            requiresAuthorization: charge.requiresAuthorization,
          )
        : charge;
    
    ref.read(activeOrderProvider.notifier).addExtraCharge(finalCharge);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cargo "${finalCharge.name}" agregado'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ExtraChargeDialog extends ConsumerStatefulWidget {
  const _ExtraChargeDialog();

  @override
  ConsumerState<_ExtraChargeDialog> createState() => _ExtraChargeDialogState();
}

class _ExtraChargeDialogState extends ConsumerState<_ExtraChargeDialog> {
  ExtraCharge? _selectedCharge;
  final _customValueController = TextEditingController();
  bool _useCustomValue = false;

  @override
  void dispose() {
    _customValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extraCharges = ref.watch(mockExtraChargesProvider);
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
                color: AppColors.posKitchen,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_circle, color: Colors.white, size: isMobile ? 24 : 28),
                  SizedBox(width: isMobile ? 8 : 12),
                  Expanded(
                    child: Text(
                      'Agregar Cargo Extra',
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

            // Content scrollable
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lista de cargos extras
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      itemCount: extraCharges.length,
                      itemBuilder: (context, index) {
                        final charge = extraCharges[index];
                        final isSelected = _selectedCharge?.id == charge.id;
                        
                        return _ExtraChargeTile(
                          charge: charge,
                          subtotal: subtotal,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedCharge = charge;
                              _useCustomValue = false;
                              _customValueController.clear();
                            });
                          },
                        );
                      },
                    ),

                    // Sección de valor personalizado
                    if (_selectedCharge != null) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _useCustomValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _useCustomValue = value ?? false;
                                      if (!_useCustomValue) {
                                        _customValueController.clear();
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    'Usar valor personalizado',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            if (_useCustomValue) ...[
                              const SizedBox(height: 8),
                              TextField(
                                controller: _customValueController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: _selectedCharge!.type == ExtraChargeType.percentage
                                      ? 'Porcentaje (%)'
                                      : 'Monto (\$)',
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  prefixIcon: Icon(
                                    _selectedCharge!.type == ExtraChargeType.percentage
                                        ? Icons.percent
                                        : Icons.attach_money,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Botones de acción
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _selectedCharge == null
                          ? null
                          : () {
                              double? customValue;
                              if (_useCustomValue && _customValueController.text.isNotEmpty) {
                                customValue = double.tryParse(_customValueController.text);
                                if (customValue == null || customValue <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ingresa un valor válido'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                              }
                              Navigator.of(context).pop({
                                'charge': _selectedCharge,
                                'customValue': customValue,
                              });
                            },
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.posKitchen,
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtraChargeTile extends StatelessWidget {
  final ExtraCharge charge;
  final double subtotal;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExtraChargeTile({
    required this.charge,
    required this.subtotal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final chargeAmount = charge.calculateCharge(subtotal);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AppColors.posKitchen, width: 2)
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
                  color: AppColors.posKitchen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_circle_outline,
                  color: AppColors.posKitchen,
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
                      charge.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (charge.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        charge.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ],
                    if (charge.requiresAuthorization) ...[
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
              
              // Valor del cargo
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.posKitchen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      charge.displayValue,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.posKitchen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+${currencyFormat.format(chargeAmount)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.posKitchen,
                        ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.posKitchen,
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
