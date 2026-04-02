// FILE: /home/node/.openclaw/workspace/greenpos/frontend/lib/features/printing/print_service.dart
// STATUS: Enhanced with PDF generation using pdf package
// PERMISSION ISSUE: Files are owned by root, cannot write directly

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../pos/domain/entities/pos_order.dart';

/// Servicio de impresión de tickets y comandas
/// Genera PDFs para tickets de venta y comandas de cocina
class PrintService {
  static final PrintService _instance = PrintService._internal();
  factory PrintService() => _instance;
  PrintService._internal();

  final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final _timeFormat = DateFormat('HH:mm');

  // ===== TICKET DE VENTA (PDF) =====

  /// Genera un PDF de ticket de venta
  Future<Uint8List> generateSalesTicketPdf(POSOrder order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Ticket de 80mm
        margin: const pw.EdgeInsets.all(4),
        build: (context) => _buildSalesTicketContent(order),
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildSalesTicketContent(POSOrder order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                'SOFT RESTAURANT',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Punto de Venta',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
        ),
        pw.Divider(thickness: 0.5),
        
        // Info del pedido
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Fecha: ${_dateFormat.format(order.createdAt)}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
        pw.Text(
          'Orden #: ${order.id.substring(0, 8).toUpperCase()}',
          style: const pw.TextStyle(fontSize: 8),
        ),
        
        if (order.tableName != null)
          pw.Text(
            'Mesa: ${order.tableName}',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        
        if (order.customerName != null)
          pw.Text(
            'Cliente: ${order.customerName}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        
        pw.Divider(thickness: 0.5),
        
        // Headers de items
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                'Cant.  Descripción',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Text(
              'Precio',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
        pw.Divider(thickness: 0.3),
        
        // Items
        ...order.items.map((item) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${item.quantity}x ${item.productName}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    if (item.modifiers.isNotEmpty)
                      ...item.modifiers.map((m) => pw.Text(
                        '   + ${m.name}',
                        style: const pw.TextStyle(fontSize: 7),
                      )),
                    if (item.notes != null && item.notes!.isNotEmpty)
                      pw.Text(
                        '   ** ${item.notes} **',
                        style: pw.TextStyle(
                          fontSize: 7,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              pw.Text(
                _currencyFormat.format(item.subtotal),
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
        )),
        
        pw.Divider(thickness: 0.5),
        
        // Totales
        _buildTotalRow('Subtotal:', order.subtotal),
        
        if (order.discount != null)
          _buildTotalRow(
            'Descuento (${order.discount!.name}):',
            -order.discountAmount,
          ),
        
        if (order.extraCharges.isNotEmpty)
          ...order.extraCharges.map((charge) => _buildTotalRow(
            '${charge.name}:',
            charge.calculateCharge(order.subtotal),
          )),
        
        pw.Divider(thickness: 0.5),
        
        // Total
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'TOTAL:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              _currencyFormat.format(order.total),
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
        
        pw.SizedBox(height: 8),
        
        // Footer
        pw.Center(
          child: pw.Text(
            '¡GRACIAS POR SU PREFERENCIA!',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTotalRow(String label, double amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
          pw.Text(
            _currencyFormat.format(amount),
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  // ===== COMANDA DE COCINA (PDF) =====

  /// Genera un PDF de comanda para cocina
  Future<Uint8List> generateKitchenTicketPdf(POSOrder order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(4),
        build: (context) => _buildKitchenTicketContent(order),
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildKitchenTicketContent(POSOrder order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 2),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                'COMANDA',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Hora: ${_timeFormat.format(order.createdAt)}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        
        pw.SizedBox(height: 4),
        
        // Mesa
        if (order.tableName != null)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              border: pw.Border.all(),
            ),
            child: pw.Text(
              'MESA ${order.tableName}',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        
        if (order.customerName != null)
          pw.Text(
            'Cliente: ${order.customerName}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        
        pw.SizedBox(height: 4),
        pw.Divider(thickness: 1),
        
        // Items para preparar
        pw.Text(
          'PREPARAR:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        
        ...order.items.map((item) => pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 2),
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Text(
                    '${item.quantity}x',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Expanded(
                    child: pw.Text(
                      item.productName,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (item.modifiers.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 16, top: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: item.modifiers.map((m) => pw.Text(
                      '+ ${m.name}',
                      style: const pw.TextStyle(fontSize: 10),
                    )).toList(),
                  ),
                ),
              
              if (item.notes != null && item.notes!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 16, top: 2),
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.yellow100,
                    ),
                    child: pw.Text(
                      'NOTA: ${item.notes}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        )),
        
        pw.SizedBox(height: 8),
        
        // Orden ID
        pw.Text(
          'Orden: ${order.id.substring(0, 8).toUpperCase()}',
          style: const pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  // ===== GUARDAR PDF =====

  /// Guardar PDF a archivo
  Future<File> savePdfToFile(Uint8List pdfBytes, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename.pdf');
    await file.writeAsBytes(pdfBytes);
    return file;
  }

  // ===== PRINT PREVIEW =====

  /// Mostrar preview del ticket
  Future<void> showTicketPreview(
    BuildContext context,
    POSOrder order,
    String title,
  ) async {
    final ticketContent = generateSalesTicketText(order);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              ticketContent,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              final pdfBytes = await generateSalesTicketPdf(order);
              final file = await savePdfToFile(
                pdfBytes,
                'ticket_${order.id.substring(0, 8)}',
              );
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ticket guardado: ${file.path}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Generar PDF'),
          ),
        ],
      ),
    );
  }

  /// Mostrar preview de comanda
  Future<void> showKitchenTicketPreview(
    BuildContext context,
    POSOrder order,
  ) async {
    final ticketContent = generateKitchenTicketText(order);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comanda de Cocina'),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              ticketContent,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              final pdfBytes = await generateKitchenTicketPdf(order);
              final file = await savePdfToFile(
                pdfBytes,
                'comanda_${order.id.substring(0, 8)}',
              );
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Comanda guardada: ${file.path}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Generar PDF'),
          ),
        ],
      ),
    );
  }

  // ===== TEXT GENERATION (para preview) =====

  /// Genera ticket de venta en texto
  String generateSalesTicketText(POSOrder order) {
    final buffer = StringBuffer();

    buffer.writeln('=' * 40);
    buffer.writeln('        SOFT RESTAURANT');
    buffer.writeln('     Punto de Venta');
    buffer.writeln('=' * 40);
    buffer.writeln();

    buffer.writeln('Fecha: ${_dateFormat.format(order.createdAt)}');
    buffer.writeln('Orden #: ${order.id.substring(0, 8).toUpperCase()}');
    
    if (order.tableName != null) {
      buffer.writeln('Mesa: ${order.tableName}');
    }
    
    if (order.customerName != null) {
      buffer.writeln('Cliente: ${order.customerName}');
    }
    
    buffer.writeln('-' * 40);
    buffer.writeln();
    buffer.writeln('Cant.  Descripción             Precio');
    buffer.writeln('-' * 40);

    for (final item in order.items) {
      buffer.writeln(
        '${item.quantity.toString().padRight(6)} ${item.productName.padRight(20)} ${_currencyFormat.format(item.subtotal).padLeft(10)}',
      );

      if (item.modifiers.isNotEmpty) {
        for (final mod in item.modifiers) {
          buffer.writeln(
            '       + ${mod.name.padRight(18)} ${_currencyFormat.format(mod.priceAdjustment).padLeft(10)}',
          );
        }
      }

      if (item.notes != null && item.notes!.isNotEmpty) {
        buffer.writeln('       Nota: ${item.notes}');
      }
    }

    buffer.writeln('-' * 40);
    buffer.writeln();
    buffer.writeln('Subtotal:'.padRight(30) + _currencyFormat.format(order.subtotal).padLeft(10));

    if (order.discount != null) {
      buffer.writeln(
        'Descuento (${order.discount!.name}):'.padRight(30) +
            '-${_currencyFormat.format(order.discountAmount)}'.padLeft(10),
      );
    }

    if (order.extraCharges.isNotEmpty) {
      for (final charge in order.extraCharges) {
        buffer.writeln(
          '${charge.name}:'.padRight(30) + _currencyFormat.format(charge.calculateCharge(order.subtotal)).padLeft(10),
        );
      }
    }

    buffer.writeln('TOTAL:'.padRight(30) + _currencyFormat.format(order.total).padLeft(10));
    buffer.writeln();
    buffer.writeln('=' * 40);
    buffer.writeln('      ¡GRACIAS POR SU PREFERENCIA!');
    buffer.writeln('=' * 40);

    return buffer.toString();
  }

  /// Genera comanda de cocina en texto
  String generateKitchenTicketText(POSOrder order) {
    final buffer = StringBuffer();

    buffer.writeln('=' * 40);
    buffer.writeln('        COMANDA DE COCINA');
    buffer.writeln('=' * 40);
    buffer.writeln();

    buffer.writeln('Hora: ${_timeFormat.format(order.createdAt)}');
    buffer.writeln('Orden #: ${order.id.substring(0, 8).toUpperCase()}');
    
    if (order.tableName != null) {
      buffer.writeln('MESA ${order.tableName}');
    }
    
    buffer.writeln('-' * 40);
    buffer.writeln();
    buffer.writeln('PREPARAR:');
    buffer.writeln();

    for (final item in order.items) {
      buffer.writeln('[ ] ${item.quantity}x ${item.productName}');

      if (item.modifiers.isNotEmpty) {
        for (final mod in item.modifiers) {
          buffer.writeln('    + ${mod.name}');
        }
      }

      if (item.notes != null && item.notes!.isNotEmpty) {
        buffer.writeln('    ** ${item.notes} **');
      }

      buffer.writeln();
    }

    buffer.writeln('=' * 40);

    return buffer.toString();
  }
}
