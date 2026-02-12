/// Estados posibles de un pedido en el POS
enum OrderStatus {
  /// Pedido en creación (pedido activo en POS, aún no confirmado)
  draft,
  
  /// Pedido confirmado, esperando envío a cocina
  pending,
  
  /// Enviado a cocina/barra para preparación
  sent,
  
  /// En proceso de preparación por cocina
  preparing,
  
  /// Listo para ser entregado/servido
  ready,
  
  /// Servido al cliente (en mesa)
  served,
  
  /// Completado y pagado
  completed,
  
  /// Cancelado
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.draft:
        return 'Borrador';
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.sent:
        return 'Enviado a Cocina';
      case OrderStatus.preparing:
        return 'En Preparación';
      case OrderStatus.ready:
        return 'Listo';
      case OrderStatus.served:
        return 'Servido';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
  
  String get icon {
    switch (this) {
      case OrderStatus.draft:
        return '📝';
      case OrderStatus.pending:
        return '⏳';
      case OrderStatus.sent:
        return '📨';
      case OrderStatus.preparing:
        return '👨‍🍳';
      case OrderStatus.ready:
        return '✅';
      case OrderStatus.served:
        return '🍽️';
      case OrderStatus.completed:
        return '💰';
      case OrderStatus.cancelled:
        return '❌';
    }
  }
}
