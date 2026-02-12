import 'package:equatable/equatable.dart';

/// Estados de mesa
enum TableStatus {
  available('available', 'Disponible'),
  occupied('occupied', 'Ocupada'),
  reserved('reserved', 'Reservada');

  final String value;
  final String displayName;

  const TableStatus(this.value, this.displayName);

  static TableStatus fromString(String value) {
    return TableStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TableStatus.available,
    );
  }
}

/// Entidad de Mesa (Dominio)
class RestaurantTable extends Equatable {
  final String id;
  final String number;
  final int capacity;
  final TableStatus status;
  final String? currentOrderId;
  final String? qrCode;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RestaurantTable({
    required this.id,
    required this.number,
    required this.capacity,
    this.status = TableStatus.available,
    this.currentOrderId,
    this.qrCode,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isAvailable => status == TableStatus.available;

  RestaurantTable copyWith({
    String? id,
    String? number,
    int? capacity,
    TableStatus? status,
    String? currentOrderId,
    String? qrCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      qrCode: qrCode ?? this.qrCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        number,
        capacity,
        status,
        currentOrderId,
        qrCode,
        createdAt,
        updatedAt,
      ];
}

/// Entidad de Reserva (Dominio)
class Reservation extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String tableId;
  final String tableNumber;
  final DateTime reservationDate;
  final int numberOfPeople;
  final String? notes;
  final bool isConfirmed;
  final bool isCancelled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Reservation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.tableId,
    required this.tableNumber,
    required this.reservationDate,
    required this.numberOfPeople,
    this.notes,
    this.isConfirmed = false,
    this.isCancelled = false,
    required this.createdAt,
    this.updatedAt,
  });

  Reservation copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? tableId,
    String? tableNumber,
    DateTime? reservationDate,
    int? numberOfPeople,
    String? notes,
    bool? isConfirmed,
    bool? isCancelled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      reservationDate: reservationDate ?? this.reservationDate,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      notes: notes ?? this.notes,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      isCancelled: isCancelled ?? this.isCancelled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userPhone,
        tableId,
        tableNumber,
        reservationDate,
        numberOfPeople,
        notes,
        isConfirmed,
        isCancelled,
        createdAt,
        updatedAt,
      ];
}
