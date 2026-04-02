import 'package:dartz/dartz.dart';
import 'package:greenpos/features/invoices/domain/entities/invoice.dart';
import 'package:greenpos/core/utils/failure.dart';

/// Repository interface for Invoice operations
abstract class InvoiceRepository {
  /// Create a new invoice (draft)
  Future<Either<Failure, Invoice>> createInvoice({
    required String orderId,
    required String receptorRfc,
    required String receptorNombre,
    required String receptorUsoCfdi,
    String? receptorDomicilio,
    required String formaPago,
    required String metodoPago,
    String? serie,
    double descuento = 0,
    required List<Map<String, dynamic>> items,
  });

  /// Stamp/emit an invoice
  Future<Either<Failure, Invoice>> stampInvoice(String invoiceId);

  /// Cancel an invoice
  Future<Either<Failure, Invoice>> cancelInvoice(String invoiceId, String motivo);

  /// Get invoices for a branch
  Future<Either<Failure, List<Invoice>>> getInvoices(
    String branchId, {
    InvoiceStatus? status,
  });

  /// Get a single invoice by ID
  Future<Either<Failure, Invoice>> getInvoice(String id);

  /// Get tenant fiscal configuration
  Future<Either<Failure, Map<String, dynamic>>> getTenantFiscal();

  /// Update tenant fiscal configuration
  Future<Either<Failure, Map<String, dynamic>>> updateTenantFiscal(
    Map<String, dynamic> input,
  );
}
