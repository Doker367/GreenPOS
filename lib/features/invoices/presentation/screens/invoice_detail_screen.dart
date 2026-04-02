import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:greenpos/core/theme/app_theme.dart';
import 'package:greenpos/core/utils/cfdi_constants.dart';
import 'package:greenpos/features/invoices/domain/entities/invoice.dart';
import 'package:greenpos/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:greenpos/features/invoices/presentation/screens/invoice_list_screen.dart';

/// Provider for a single invoice
final invoiceDetailProvider = FutureProvider.family<Invoice, String>((ref, id) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getInvoice(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (invoice) => invoice,
  );
});

/// Invoice detail screen showing full invoice information
class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  bool _isLoading = false;
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(invoiceDetailProvider(widget.invoiceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Factura'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: invoiceAsync.when(
        data: (invoice) => _buildContent(invoice),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text('Error al cargar factura', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(error.toString(), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(invoiceDetailProvider(widget.invoiceId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Invoice invoice) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(invoice),
          const SizedBox(height: 16),

          // Emisor Section
          _buildSectionCard(
            title: 'Emisor',
            icon: Icons.business,
            children: [
              _buildInfoRow('RFC', invoice.emisorRfc),
              _buildInfoRow('Nombre', invoice.emisorNombre),
              _buildInfoRow('Régimen', invoice.emisorRegimen),
            ],
          ),
          const SizedBox(height: 16),

          // Receptor Section
          _buildSectionCard(
            title: 'Receptor',
            icon: Icons.person,
            children: [
              _buildInfoRow('RFC', invoice.receptorRfc),
              _buildInfoRow('Nombre', invoice.receptorNombre),
              _buildInfoRow(
                'Uso CFDI',
                CFDIConstants.usoCfdi[invoice.receptorUsoCfdi] ?? invoice.receptorUsoCfdi,
              ),
              if (invoice.receptorDomicilio != null)
                _buildInfoRow('Domicilio', invoice.receptorDomicilio!),
            ],
          ),
          const SizedBox(height: 16),

          // Payment Info Section
          _buildSectionCard(
            title: 'Información de Pago',
            icon: Icons.payment,
            children: [
              if (invoice.formaPago != null)
                _buildInfoRow(
                  'Forma de Pago',
                  CFDIConstants.formaPago[invoice.formaPago] ?? invoice.formaPago!,
                ),
              if (invoice.metodoPago != null)
                _buildInfoRow(
                  'Método de Pago',
                  CFDIConstants.metodoPago[invoice.metodoPago] ?? invoice.metodoPago!,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Totals Section
          _buildSectionCard(
            title: 'Totales',
            icon: Icons.calculate,
            children: [
              _buildTotalRow('Subtotal', invoice.subtotal),
              if (invoice.descuento > 0)
                _buildTotalRow('Descuento', -invoice.descuento, isDiscount: true),
              _buildTotalRow('IVA 16%', invoice.iva16Amount),
              if (invoice.iepsAmount != null && invoice.iepsAmount! > 0)
                _buildTotalRow('IEPS', invoice.iepsAmount!),
              const Divider(),
              _buildTotalRow('Total', invoice.total, isTotal: true),
            ],
          ),
          const SizedBox(height: 16),

          // Items Section
          _buildSectionCard(
            title: 'Conceptos',
            icon: Icons.receipt,
            children: [
              ...invoice.items.map((item) => _buildItemRow(item)),
            ],
          ),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(invoice),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Invoice invoice) {
    return Card(
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                _buildStatusChip(invoice.status),
              ],
            ),
            if (invoice.uuid != null) ...[
              const SizedBox(height: 8),
              Text(
                'UUID: ${invoice.uuid}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              dateFormat.format(invoice.createdAt),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : (isTotal ? AppColors.primary : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(InvoiceItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                currencyFormat.format(item.total),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.quantity} x ${currencyFormat.format(item.unitPrice)}'
            '${item.taxRate > 0 ? ' (+${(item.taxRate * 100).toStringAsFixed(0)}% IVA)' : ''}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          if (item.discount > 0)
            Text(
              'Descuento: ${currencyFormat.format(item.discount)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(InvoiceStatus status) {
    Color color;
    String label;
    switch (status) {
      case InvoiceStatus.DRAFT:
        color = Colors.grey;
        label = 'Borrador';
      case InvoiceStatus.PENDING:
        color = Colors.orange;
        label = 'Pendiente';
      case InvoiceStatus.TIMBRADA:
        color = Colors.green;
        label = 'Timbrada';
      case InvoiceStatus.CANCELLED:
        color = Colors.red;
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

  Widget _buildActionButtons(Invoice invoice) {
    switch (invoice.status) {
      case InvoiceStatus.DRAFT:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : () => _stampInvoice(invoice.id),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: const Text('Timbrar Factura'),
          ),
        );
      case InvoiceStatus.TIMBRADA:
        return Column(
          children: [
            if (invoice.pdfUrl != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openPdf(invoice.pdfUrl!),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Ver PDF'),
                ),
              ),
            const SizedBox(height: 12),
            if (invoice.xmlUrl != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openXml(invoice.xmlUrl!),
                  icon: const Icon(Icons.code),
                  label: const Text('Ver XML'),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : () => _showCancelDialog(invoice.id),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel),
                label: const Text('Cancelar Factura'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        );
      case InvoiceStatus.CANCELLED:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.cancel),
            label: const Text('Factura Cancelada'),
          ),
        );
      case InvoiceStatus.PENDING:
        return const SizedBox.shrink();
    }
  }

  Future<void> _stampInvoice(String invoiceId) async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(invoiceRepositoryProvider);
      final result = await repository.stampInvoice(invoiceId);
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
          ref.invalidate(invoiceDetailProvider(invoiceId));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Factura timbrada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showCancelDialog(String invoiceId) async {
    final motivoController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Factura'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ingrese el motivo de cancelación:'),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                hintText: 'Ej: Error en datos del receptor',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, motivoController.text),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar Factura'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final repository = ref.read(invoiceRepositoryProvider);
        final cancelResult = await repository.cancelInvoice(invoiceId, result);
        cancelResult.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          (invoice) {
            ref.invalidate(invoiceDetailProvider(invoiceId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Factura cancelada'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openXml(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el XML'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
