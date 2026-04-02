import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pos/domain/entities/pos_order.dart';

/// Servicio de impresión de tickets
class PrintService {
  static final PrintService _instance = PrintService._internal();
  factory PrintService() => _instance;
  PrintService._internal();

  /// Generar ticket de venta
  String generateSalesTicket(POSOrder order) {
    final buffer = StringBuffer();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Header
    buffer.writeln('=' * 40);
    buffer.writeln('        SOFT RESTAURANT');
    buffer.writeln('     Sistema de Punto de Venta');
    buffer.writeln('=' * 40);
    buffer.writeln();

    // Información del pedido
    buffer.writeln('TICKET DE VENTA');
    buffer.writeln('Fecha: ${dateFormat.format(order.createdAt)}');
    buffer.writeln('Orden #: ${order.id}');
    if (order.tableName != null) {
      buffer.writeln('${order.tableName}');
    }
    if (order.customerName != null) {
      buffer.writeln('Cliente: ${order.customerName}');
    }
    buffer.writeln('-' * 40);
    buffer.writeln();

    // Items
    buffer.writeln('Cant.  Descripción             Precio');
    buffer.writeln('-' * 40);

    for (final item in order.items) {
      buffer.writeln(
        '${item.quantity.toString().padRight(6)} ${item.productName.padRight(20)} ${currencyFormat.format(item.subtotal).padLeft(10)}',
      );

      // Modificadores
      if (item.modifiers.isNotEmpty) {
        for (final mod in item.modifiers) {
          buffer.writeln(
            '       + ${mod.name.padRight(18)} ${currencyFormat.format(mod.priceAdjustment).padLeft(10)}',
          );
        }
      }

      // Notas especiales
      if (item.notes != null && item.notes!.isNotEmpty) {
        buffer.writeln('       Nota: ${item.notes}');
      }
    }

    buffer.writeln('-' * 40);
    buffer.writeln();

    // Totales
    buffer.writeln('Subtotal:'.padRight(30) + currencyFormat.format(order.subtotal).padLeft(10));

    // Descuento
    if (order.discount != null) {
      final discountAmount = order.discount!.calculateDiscount(order.subtotal);
      buffer.writeln(
        'Descuento (${order.discount!.name}):'.padRight(30) +
            '-${currencyFormat.format(discountAmount)}'.padLeft(10),
      );
    }

    // Cargos extra
    if (order.extraCharges.isNotEmpty) {
      for (final charge in order.extraCharges) {
        final amount = charge.calculateCharge(order.subtotal);
        buffer.writeln(
          '${charge.name}:'.padRight(30) + currencyFormat.format(amount).padLeft(10),
        );
      }
    }

    buffer.writeln('TOTAL:'.padRight(30) + currencyFormat.format(order.total).padLeft(10));
    buffer.writeln();

    // Footer
    buffer.writeln('=' * 40);
    buffer.writeln('      ¡GRACIAS POR SU PREFERENCIA!');
    buffer.writeln('=' * 40);
    buffer.writeln();

    return buffer.toString();
  }

  /// Generar comanda para cocina
  String generateKitchenTicket(POSOrder order) {
    final buffer = StringBuffer();
    final timeFormat = DateFormat('HH:mm');

    // Header
    buffer.writeln('=' * 40);
    buffer.writeln('        COMANDA DE COCINA');
    buffer.writeln('=' * 40);
    buffer.writeln();

    // Información
    buffer.writeln('Hora: ${timeFormat.format(order.createdAt)}');
    buffer.writeln('Orden #: ${order.id}');
    if (order.tableName != null) {
      buffer.writeln('${order.tableName}');
    }
    buffer.writeln('-' * 40);
    buffer.writeln();

    // Items
    buffer.writeln('PREPARAR:');
    buffer.writeln();

    for (final item in order.items) {
      buffer.writeln('[ ] ${item.quantity}x ${item.productName}');

      // Modificadores
      if (item.modifiers.isNotEmpty) {
        for (final mod in item.modifiers) {
          buffer.writeln('    + ${mod.name}');
        }
      }

      // Notas especiales
      if (item.notes != null && item.notes!.isNotEmpty) {
        buffer.writeln('    ** ${item.notes} **');
      }

      buffer.writeln();
    }

    buffer.writeln('=' * 40);
    buffer.writeln();

    return buffer.toString();
  }

  /// Mostrar preview del ticket
  Future<void> showTicketPreview(BuildContext context, String ticketContent, String title) async {
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
            onPressed: () {
              // TODO: Implementar impresión real
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ticket enviado a impresora'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Imprimir'),
          ),
        ],
      ),
    );
  }

  /// Imprimir ticket (simulado)
  Future<bool> printTicket(String ticketContent) async {
    // En un entorno real, aquí se conectaría con la impresora
    // Por ahora solo simulamos la impresión
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('=== IMPRIMIENDO TICKET ===');
    debugPrint(ticketContent);
    debugPrint('=== FIN DEL TICKET ===');
    return true;
  }
}
