import 'package:flutter/material.dart';

/// Estados posibles de un pedido
enum OrderStatus {
  pending('pending', 'Pendiente', Colors.orange),
  accepted('accepted', 'Aceptado', Colors.blue),
  preparing('preparing', 'Preparando', Colors.amber),
  ready('ready', 'Listo', Colors.green),
  delivered('delivered', 'Entregado', Colors.teal),
  cancelled('cancelled', 'Cancelado', Colors.red);

  final String value;
  final String displayName;
  final Color color;

  const OrderStatus(this.value, this.displayName, this.color);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}
