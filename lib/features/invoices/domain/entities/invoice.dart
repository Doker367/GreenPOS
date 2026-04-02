import 'package:equatable/equatable.dart';

/// Invoice status enum matching backend GraphQL schema
enum InvoiceStatus {
  DRAFT,
  PENDING,
  TIMBRADA,
  CANCELLED,
}

/// Invoice item entity
class InvoiceItem extends Equatable {
  final String id;
  final String productName;
  final String claveProdServ;
  final String claveUnidad;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double taxRate;
  final double taxAmount;
  final double total;

  const InvoiceItem({
    required this.id,
    required this.productName,
    required this.claveProdServ,
    required this.claveUnidad,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      claveProdServ: json['claveProdServ'] as String? ?? '',
      claveUnidad: json['claveUnidad'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productName,
        claveProdServ,
        claveUnidad,
        quantity,
        unitPrice,
        discount,
        taxRate,
        taxAmount,
        total,
      ];
}

/// Invoice entity matching backend GraphQL schema
class Invoice extends Equatable {
  final String id;
  final String branchId;
  final String orderId;
  final String serie;
  final int folio;
  final String? uuid;
  final InvoiceStatus status;
  final String emisorRfc;
  final String emisorNombre;
  final String emisorRegimen;
  final String receptorRfc;
  final String receptorNombre;
  final String receptorUsoCfdi;
  final String? receptorDomicilio;
  final double subtotal;
  final double descuento;
  final double impuestosTrasladados;
  final double total;
  final double iva16Amount;
  final double? iepsAmount;
  final String? pdfUrl;
  final String? xmlUrl;
  final String? formaPago;
  final String? metodoPago;
  final List<InvoiceItem> items;
  final DateTime createdAt;

  const Invoice({
    required this.id,
    required this.branchId,
    required this.orderId,
    required this.serie,
    required this.folio,
    this.uuid,
    required this.status,
    required this.emisorRfc,
    required this.emisorNombre,
    required this.emisorRegimen,
    required this.receptorRfc,
    required this.receptorNombre,
    required this.receptorUsoCfdi,
    this.receptorDomicilio,
    required this.subtotal,
    required this.descuento,
    required this.impuestosTrasladados,
    required this.total,
    required this.iva16Amount,
    this.iepsAmount,
    this.pdfUrl,
    this.xmlUrl,
    this.formaPago,
    this.metodoPago,
    required this.items,
    required this.createdAt,
  });

  /// Parse InvoiceStatus from string
  static InvoiceStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'DRAFT':
        return InvoiceStatus.DRAFT;
      case 'PENDING':
        return InvoiceStatus.PENDING;
      case 'TIMBRADA':
        return InvoiceStatus.TIMBRADA;
      case 'CANCELLED':
        return InvoiceStatus.CANCELLED;
      default:
        return InvoiceStatus.DRAFT;
    }
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      serie: json['serie'] as String? ?? '',
      folio: (json['folio'] as num?)?.toInt() ?? 0,
      uuid: json['uuid'] as String?,
      status: _parseStatus(json['status'] as String?),
      emisorRfc: json['emisorRfc'] as String? ?? '',
      emisorNombre: json['emisorNombre'] as String? ?? '',
      emisorRegimen: json['emisorRegimen'] as String? ?? '',
      receptorRfc: json['receptorRfc'] as String? ?? '',
      receptorNombre: json['receptorNombre'] as String? ?? '',
      receptorUsoCfdi: json['receptorUsoCfdi'] as String? ?? '',
      receptorDomicilio: json['receptorDomicilio'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      descuento: (json['descuento'] as num?)?.toDouble() ?? 0.0,
      impuestosTrasladados:
          (json['impuestosTrasladados'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      iva16Amount: (json['iva16Amount'] as num?)?.toDouble() ?? 0.0,
      iepsAmount: (json['iepsAmount'] as num?)?.toDouble(),
      pdfUrl: json['pdfUrl'] as String?,
      xmlUrl: json['xmlUrl'] as String?,
      formaPago: json['formaPago'] as String?,
      metodoPago: json['metodoPago'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Get display name for status
  String get statusDisplayName {
    switch (status) {
      case InvoiceStatus.DRAFT:
        return 'Borrador';
      case InvoiceStatus.PENDING:
        return 'Pendiente';
      case InvoiceStatus.TIMBRADA:
        return 'Timbrada';
      case InvoiceStatus.CANCELLED:
        return 'Cancelada';
    }
  }

  @override
  List<Object?> get props => [
        id,
        branchId,
        orderId,
        serie,
        folio,
        uuid,
        status,
        emisorRfc,
        emisorNombre,
        emisorRegimen,
        receptorRfc,
        receptorNombre,
        receptorUsoCfdi,
        receptorDomicilio,
        subtotal,
        descuento,
        impuestosTrasladados,
        total,
        iva16Amount,
        iepsAmount,
        pdfUrl,
        xmlUrl,
        formaPago,
        metodoPago,
        items,
        createdAt,
      ];
}
