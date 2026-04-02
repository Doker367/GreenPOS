import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:greenpos/core/theme/app_theme.dart';
import 'package:greenpos/features/invoices/domain/entities/invoice.dart';
import 'package:greenpos/features/invoices/data/repositories/invoice_repository_impl.dart';

/// Provider for invoice repository
final invoiceRepositoryProvider = Provider<InvoiceRepositoryImpl>((ref) {
  return InvoiceRepositoryImpl();
});

/// Provider for invoices list
final invoicesProvider = FutureProvider.family<List<Invoice>, String?>((ref, branchId) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getInvoices(branchId ?? '');
  return result.fold(
    (failure) => throw Exception(failure.message),
    (invoices) => invoices,
  );
});

/// Invoice list screen showing all invoices with filter options
class InvoiceListScreen extends ConsumerStatefulWidget {
  final String? branchId;

  const InvoiceListScreen({super.key, this.branchId});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  InvoiceStatus? _selectedStatus;
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final branchId = widget.branchId ?? '00000000-0000-0000-0000-000000000000';
    final invoicesAsync = ref.watch(invoicesProvider(branchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings/fiscal'),
            tooltip: 'Configuración Fiscal',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(null, 'Todas'),
                const SizedBox(width: 8),
                _buildFilterChip(InvoiceStatus.DRAFT, 'Borrador'),
                const SizedBox(width: 8),
                _buildFilterChip(InvoiceStatus.PENDING, 'Pendiente'),
                const SizedBox(width: 8),
                _buildFilterChip(InvoiceStatus.TIMBRADA, 'Timbrada'),
                const SizedBox(width: 8),
                _buildFilterChip(InvoiceStatus.CANCELLED, 'Cancelada'),
              ],
            ),
          ),
          const Divider(height: 1),
          // Invoice list
          Expanded(
            child: invoicesAsync.when(
              data: (invoices) {
                final filtered = _filterInvoices(invoices);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay facturas',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crea tu primera factura',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(invoicesProvider(branchId));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final invoice = filtered[index];
                      return _InvoiceCard(
                        invoice: invoice,
                        currencyFormat: currencyFormat,
                        dateFormat: dateFormat,
                        onTap: () => context.push('/invoices/${invoice.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar facturas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(invoicesProvider(branchId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/invoices/create'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Factura'),
      ),
    );
  }

  List<Invoice> _filterInvoices(List<Invoice> invoices) {
    if (_selectedStatus == null) return invoices;
    return invoices.where((inv) => inv.status == _selectedStatus).toList();
  }

  Widget _buildFilterChip(InvoiceStatus? status, String label) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  const _InvoiceCard({
    required this.invoice,
    required this.currencyFormat,
    required this.dateFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${invoice.serie.isNotEmpty ? '${invoice.serie}-' : ''}${invoice.folio}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  _buildStatusChip(invoice.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                invoice.receptorNombre.isNotEmpty
                    ? invoice.receptorNombre
                    : 'Sin receptor',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (invoice.receptorRfc.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'RFC: ${invoice.receptorRfc}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormat.format(invoice.total),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  Text(
                    dateFormat.format(invoice.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(InvoiceStatus status) {
    Color color;
    switch (status) {
      case InvoiceStatus.DRAFT:
        color = Colors.grey;
      case InvoiceStatus.PENDING:
        color = Colors.orange;
      case InvoiceStatus.TIMBRADA:
        color = Colors.green;
      case InvoiceStatus.CANCELLED:
        color = Colors.red;
    }

    String label;
    switch (status) {
      case InvoiceStatus.DRAFT:
        label = 'Borrador';
      case InvoiceStatus.PENDING:
        label = 'Pendiente';
      case InvoiceStatus.TIMBRADA:
        label = 'Timbrada';
      case InvoiceStatus.CANCELLED:
        label = 'Cancelada';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
