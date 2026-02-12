import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/table.dart';

/// Repositorio de mesas y reservas (Interfaz del dominio)
abstract class TableRepository {
  // ====== MESAS ======

  /// Obtener todas las mesas
  Future<Either<Failure, List<RestaurantTable>>> getTables({
    TableStatus? status,
  });

  /// Obtener mesa por ID
  Future<Either<Failure, RestaurantTable>> getTableById(String id);

  /// Crear nueva mesa (Admin)
  Future<Either<Failure, RestaurantTable>> createTable({
    required String number,
    required int capacity,
  });

  /// Actualizar mesa (Admin)
  Future<Either<Failure, RestaurantTable>> updateTable({
    required String id,
    String? number,
    int? capacity,
    TableStatus? status,
  });

  /// Eliminar mesa (Admin)
  Future<Either<Failure, void>> deleteTable(String id);

  /// Asignar pedido a mesa
  Future<Either<Failure, RestaurantTable>> assignOrderToTable({
    required String tableId,
    required String orderId,
  });

  /// Liberar mesa
  Future<Either<Failure, RestaurantTable>> releaseTable(String tableId);

  // ====== RESERVAS ======

  /// Crear nueva reserva
  Future<Either<Failure, Reservation>> createReservation({
    required String userId,
    required String userName,
    required String userPhone,
    required String tableId,
    required DateTime reservationDate,
    required int numberOfPeople,
    String? notes,
  });

  /// Obtener reservas del usuario
  Future<Either<Failure, List<Reservation>>> getUserReservations({
    required String userId,
  });

  /// Obtener todas las reservas (Admin)
  Future<Either<Failure, List<Reservation>>> getAllReservations({
    DateTime? date,
  });

  /// Confirmar reserva (Admin)
  Future<Either<Failure, Reservation>> confirmReservation(String reservationId);

  /// Cancelar reserva
  Future<Either<Failure, Reservation>> cancelReservation(String reservationId);
}
