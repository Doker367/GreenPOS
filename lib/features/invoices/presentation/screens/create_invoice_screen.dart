import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:greenpos/core/theme/app_theme.dart';
import 'package:greenpos/core/utils/cfdi_constants.dart';
import 'package:greenpos/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:greenpos/features/invoices/presentation/screens/invoice_list_screen.dart';

/// Create invoice screen - form to create a new CFDI invoice
class CreateInvoiceScreen extends ConsumerStatefulWidget {
  final String? branchId;

  const CreateInvoiceScreen({super.key, this.branchId});

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _receptorRfcController = TextEditingController();
  final _receptorNombreController = TextEditingController();
  final _receptorDomicilioController = TextEditingController();
  final _serieController = TextEditingController();
  final _descuentoController = TextEditingController(text: '0');

  // Dropdown values
  String _selectedUsoCfdi = CFDIConstants.defaultUsoCfdi;
  String _selectedFormaPago = CFDIConstants.defaultFormaPago;
  String _selectedMetodoPago = CFDIConstants.defaultMetodoPago;

  bool _isLoading = false;
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void dispose() {
    _scrollController.dispose();
    _receptorRfcController.dispose();
    _receptorNombreController.dispose();
    _receptorDomicilioController.dispose();
    _serieController.dispose();
    _descuentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Factura'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Receptor Section
            _buildSectionTitle('Datos del Receptor'),
            const SizedBox(height: 12),
            _buildReceptorCard(),
            const SizedBox(height: 24),

            // Payment Section
            _buildSectionTitle('Datos de Pago'),
            const SizedBox(height: 12),
            _buildPaymentCard(),
            const SizedBox(height: 24),

            // Additional Info Section
            _buildSectionTitle('Información Adicional'),
            const SizedBox(height: 12),
            _buildAdditionalCard(),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.receipt_long),
                label: Text(
                  _isLoading ? 'Creando...' : 'Crear Factura',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildReceptorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RFC Field
            TextFormField(
              controller: _receptorRfcController,
              decoration: const InputDecoration(
                labelText: 'RFC del Receptor *',
                hintText: 'XAXX010101000',
                prefixIcon: Icon(Icons.badge),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El RFC es obligatorio';
                }
                if (value.length < 12 || value.length > 13) {
                  return 'El RFC debe tener 12 o 13 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nombre/Razón Social Field
            TextFormField(
              controller: _receptorNombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre o Razón Social *',
                hintText: 'Nombre completo o razón social',
                prefixIcon: Icon(Icons.business),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Uso CFDI Dropdown
            DropdownButtonFormField<String>(
              value: _selectedUsoCfdi,
              decoration: const InputDecoration(
                labelText: 'Uso de CFDI *',
                prefixIcon: Icon(Icons.description),
              ),
              items: CFDIConstants.usoCfdi.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(
                    '${entry.key} - ${entry.value}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedUsoCfdi = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Domicilio (CP) Field
            TextFormField(
              controller: _receptorDomicilioController,
              decoration: const InputDecoration(
                labelText: 'Código Postal',
                hintText: 'Ej: 06600',
                prefixIcon: Icon(Icons.location_on),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Forma de Pago Dropdown
            DropdownButtonFormField<String>(
              value: _selectedFormaPago,
              decoration: const InputDecoration(
                labelText: 'Forma de Pago *',
                prefixIcon: Icon(Icons.payment),
              ),
              items: CFDIConstants.formaPago.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(
                    '${entry.key} - ${entry.value}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFormaPago = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Método de Pago Dropdown
            DropdownButtonFormField<String>(
              value: _selectedMetodoPago,
              decoration: const InputDecoration(
                labelText: 'Método de Pago *',
                prefixIcon: Icon(Icons.monetization_on),
              ),
              items: CFDIConstants.metodoPago.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(
                    '${entry.key} - ${entry.value}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMetodoPago = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Serie Field (Optional)
            TextFormField(
              controller: _serieController,
              decoration: const InputDecoration(
                labelText: 'Serie (Opcional)',
                hintText: 'Ej: A',
                prefixIcon: Icon(Icons.tag),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Descuento Field (Optional)
            TextFormField(
              controller: _descuentoController,
              decoration: const InputDecoration(
                labelText: 'Descuento (Opcional)',
                hintText: '0.00',
                prefixIcon: Icon(Icons.discount),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(invoiceRepositoryProvider);

      // For now, we'll use mock order items since order integration
      // would require fetching paid orders from the backend
      // In a real implementation, this would come from selected order
      final items = [
        {
          'productId': '00000000-0000-0000-0000-000000000001',
          'quantity': 1,
          'claveProdServ': CFDIConstants.defaultClaveProdServ,
          'claveUnidad': CFDIConstants.defaultClaveUnidad,
          'discount': 0.0,
        },
      ];

      final result = await repository.createInvoice(
        orderId: '00000000-0000-0000-0000-000000000000', // Placeholder
        receptorRfc: _receptorRfcController.text.toUpperCase(),
        receptorNombre: _receptorNombreController.text.toUpperCase(),
        receptorUsoCfdi: _selectedUsoCfdi,
        receptorDomicilio: _receptorDomicilioController.text.isNotEmpty
            ? _receptorDomicilioController.text
            : null,
        formaPago: _selectedFormaPago,
        metodoPago: _selectedMetodoPago,
        serie: _serieController.text.isNotEmpty ? _serieController.text : null,
        descuento: double.tryParse(_descuentoController.text) ?? 0,
        items: items,
      );

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (invoice) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Factura creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to invoice detail
          context.pushReplacement('/invoices/${invoice.id}');
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
