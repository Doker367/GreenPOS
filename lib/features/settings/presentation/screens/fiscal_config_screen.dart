import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:greenpos/core/theme/app_theme.dart';
import 'package:greenpos/core/utils/cfdi_constants.dart';
import 'package:greenpos/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:greenpos/features/invoices/presentation/screens/invoice_list_screen.dart';

/// Tenant fiscal configuration provider
final tenantFiscalProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getTenantFiscal();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});

/// Fiscal configuration screen for setting up business tax data
class FiscalConfigScreen extends ConsumerStatefulWidget {
  const FiscalConfigScreen({super.key});

  @override
  ConsumerState<FiscalConfigScreen> createState() => _FiscalConfigScreenState();
}

class _FiscalConfigScreenState extends ConsumerState<FiscalConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _rfcController = TextEditingController();
  final _razonSocialController = TextEditingController();
  final _calleController = TextEditingController();
  final _numeroController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _cpController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _estadoController = TextEditingController();
  final _paisController = TextEditingController(text: 'México');

  // Dropdown value
  String _selectedRegimenFiscal = CFDIConstants.defaultRegimenFiscal;

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _rfcController.dispose();
    _razonSocialController.dispose();
    _calleController.dispose();
    _numeroController.dispose();
    _coloniaController.dispose();
    _cpController.dispose();
    _ciudadController.dispose();
    _estadoController.dispose();
    _paisController.dispose();
    super.dispose();
  }

  void _initializeForm(Map<String, dynamic> data) {
    if (_isInitialized) return;
    _isInitialized = true;

    if (data.isNotEmpty) {
      _rfcController.text = data['rfc'] ?? '';
      _razonSocialController.text = data['razonSocial'] ?? '';
      _calleController.text = data['calle'] ?? '';
      _numeroController.text = data['numero'] ?? '';
      _coloniaController.text = data['colonia'] ?? '';
      _cpController.text = data['cp'] ?? '';
      _ciudadController.text = data['ciudad'] ?? '';
      _estadoController.text = data['estado'] ?? '';
      _paisController.text = data['pais'] ?? 'México';
      if (data['regimenFiscal'] != null) {
        _selectedRegimenFiscal = data['regimenFiscal'] as String;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fiscalDataAsync = ref.watch(tenantFiscalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Fiscal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: fiscalDataAsync.when(
        data: (data) {
          _initializeForm(data);
          return _buildForm();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Error al cargar datos fiscales',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(tenantFiscalProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          Card(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Configura los datos fiscales de tu negocio para generar facturas CFDI válidas.',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Basic Info Section
          _buildSectionTitle('Datos Fiscales'),
          const SizedBox(height: 12),
          _buildBasicInfoCard(),
          const SizedBox(height: 24),

          // Address Section
          _buildSectionTitle('Dirección Fiscal'),
          const SizedBox(height: 12),
          _buildAddressCard(),
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
                  : const Icon(Icons.save),
              label: Text(
                _isLoading ? 'Guardando...' : 'Guardar Configuración',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
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

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RFC Field
            TextFormField(
              controller: _rfcController,
              decoration: const InputDecoration(
                labelText: 'RFC *',
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

            // Razón Social Field
            TextFormField(
              controller: _razonSocialController,
              decoration: const InputDecoration(
                labelText: 'Razón Social *',
                hintText: 'Nombre legal de la empresa',
                prefixIcon: Icon(Icons.business),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La razón social es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Régimen Fiscal Dropdown
            DropdownButtonFormField<String>(
              value: _selectedRegimenFiscal,
              decoration: const InputDecoration(
                labelText: 'Régimen Fiscal *',
                prefixIcon: Icon(Icons.account_balance),
              ),
              items: CFDIConstants.regimenFiscal.entries.map((entry) {
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
                  setState(() => _selectedRegimenFiscal = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calle and Número Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _calleController,
                    decoration: const InputDecoration(
                      labelText: 'Calle',
                      hintText: 'Av. Principal',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _numeroController,
                    decoration: const InputDecoration(
                      labelText: 'No.',
                      hintText: '123',
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Colonia
            TextFormField(
              controller: _coloniaController,
              decoration: const InputDecoration(
                labelText: 'Colonia',
                hintText: 'Centro',
                prefixIcon: Icon(Icons.location_city),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // CP and Ciudad Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cpController,
                    decoration: const InputDecoration(
                      labelText: 'Código Postal',
                      hintText: '06600',
                      prefixIcon: Icon(Icons.markunread_mailbox),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _ciudadController,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      hintText: 'Ciudad de México',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estado and País Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _estadoController,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      hintText: 'CDMX',
                      prefixIcon: Icon(Icons.map),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _paisController,
                    decoration: const InputDecoration(
                      labelText: 'País',
                      hintText: 'México',
                      prefixIcon: Icon(Icons.flag),
                    ),
                    textCapitalization: TextCapitalization.words,
                    enabled: false,
                  ),
                ),
              ],
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

      final input = {
        'rfc': _rfcController.text.toUpperCase(),
        'razonSocial': _razonSocialController.text.toUpperCase(),
        'regimenFiscal': _selectedRegimenFiscal,
        if (_calleController.text.isNotEmpty) 'calle': _calleController.text,
        if (_numeroController.text.isNotEmpty) 'numero': _numeroController.text,
        if (_coloniaController.text.isNotEmpty) 'colonia': _coloniaController.text,
        if (_cpController.text.isNotEmpty) 'cp': _cpController.text,
        if (_ciudadController.text.isNotEmpty) 'ciudad': _ciudadController.text,
        if (_estadoController.text.isNotEmpty) 'estado': _estadoController.text,
        'pais': _paisController.text,
      };

      final result = await repository.updateTenantFiscal(input);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configuración guardada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(tenantFiscalProvider);
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
