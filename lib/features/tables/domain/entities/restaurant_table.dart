/// Entidad que representa una mesa del restaurante
class RestaurantTable {
  final String id;
  final String number; // Número o nombre de la mesa (ej: "1", "A1", "VIP-1")
  final int capacity; // Capacidad de personas
  final TableStatus status;
  final String? currentOrderId; // ID de la orden activa en esta mesa
  final String? reservedFor; // Nombre de quien reservó (si está reservada)
  final DateTime? reservationTime; // Hora de la reservación

  const RestaurantTable({
    required this.id,
    required this.number,
    required this.capacity,
    required this.status,
    this.currentOrderId,
    this.reservedFor,
    this.reservationTime,
  });

  /// Mesa está disponible para usar
  bool get isAvailable => status == TableStatus.available;

  /// Mesa está ocupada con clientes
  bool get isOccupied => status == TableStatus.occupied;

  /// Mesa está reservada
  bool get isReserved => status == TableStatus.reserved;

  RestaurantTable copyWith({
    String? id,
    String? number,
    int? capacity,
    TableStatus? status,
    String? currentOrderId,
    String? reservedFor,
    DateTime? reservationTime,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      reservedFor: reservedFor ?? this.reservedFor,
      reservationTime: reservationTime ?? this.reservationTime,
    );
  }

  /// Ocupar la mesa con una orden
  RestaurantTable occupy(String orderId) {
    return copyWith(
      status: TableStatus.occupied,
      currentOrderId: orderId,
    );
  }

  /// Liberar la mesa
  RestaurantTable free() {
    return copyWith(
      status: TableStatus.available,
      currentOrderId: null,
      reservedFor: null,
      reservationTime: null,
    );
  }

  /// Reservar la mesa
  RestaurantTable reserve(String customerName, DateTime time) {
    return copyWith(
      status: TableStatus.reserved,
      reservedFor: customerName,
      reservationTime: time,
    );
  }
}

/// Estados posibles de una mesa
enum TableStatus {
  available, // Disponible (verde)
  occupied,  // Ocupada (azul/amarillo)
  reserved,  // Reservada (naranja)
  cleaning,  // En limpieza (gris)
}

/// Extensiones para TableStatus
extension TableStatusExtension on TableStatus {
  String get displayName {
    switch (this) {
      case TableStatus.available:
        return 'Disponible';
      case TableStatus.occupied:
        return 'Ocupada';
      case TableStatus.reserved:
        return 'Reservada';
      case TableStatus.cleaning:
        return 'Limpieza';
    }
  }

  String get icon {
    switch (this) {
      case TableStatus.available:
        return '✓';
      case TableStatus.occupied:
        return '👥';
      case TableStatus.reserved:
        return '🔒';
      case TableStatus.cleaning:
        return '🧹';
    }
  }
}
