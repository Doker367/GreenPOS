import 'package:dartz/dartz.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/graphql/client.dart';
import '../../../../core/graphql/queries.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/table.dart' as domain;
import '../../domain/repositories/table_repository.dart';

/// Implementación del repositorio de mesas y reservas usando GraphQL
class TableRepositoryImpl implements TableRepository {
  final GraphQLClient _client;
  final String _branchId;

  TableRepositoryImpl({
    GraphQLClient? client,
    required String branchId,
  })  : _client = client ?? GraphQLClientSingleton.client,
        _branchId = branchId;

  // ====== HELPERS ======

  /// Parse TableStatus from GraphQL string
  domain.TableStatus _parseTableStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'AVAILABLE':
        return domain.TableStatus.available;
      case 'OCCUPIED':
        return domain.TableStatus.occupied;
      case 'RESERVED':
        return domain.TableStatus.reserved;
      default:
        return domain.TableStatus.available;
    }
  }

  /// Convert domain TableStatus to GraphQL string
  String _tableStatusToString(domain.TableStatus status) {
    switch (status) {
      case domain.TableStatus.available:
        return 'AVAILABLE';
      case domain.TableStatus.occupied:
        return 'OCCUPIED';
      case domain.TableStatus.reserved:
        return 'RESERVED';
    }
  }

  /// Parse RestaurantTable from GraphQL response
  domain.RestaurantTable _parseTable(Map<String, dynamic> json) {
    return domain.RestaurantTable(
      id: json['id'] as String,
      number: json['number'] as String,
      capacity: json['capacity'] as int? ?? 4,
      status: _parseTableStatus(json['status'] as String?),
      currentOrderId: json['currentOrderId'] as String?,
      qrCode: json['qrCode'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// Parse Reservation from GraphQL response
  domain.Reservation _parseReservation(Map<String, dynamic> json) {
    return domain.Reservation(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userPhone: json['userPhone'] as String? ?? '',
      tableId: json['tableId'] as String? ?? '',
      tableNumber: json['tableNumber'] as String? ?? '',
      reservationDate: _parseDateTime(json['reservationDate']),
      numberOfPeople: json['numberOfPeople'] as int? ?? 1,
      notes: json['notes'] as String?,
      isConfirmed: json['isConfirmed'] as bool? ?? false,
      isCancelled: json['isCancelled'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  // ====== TABLE METHODS ======

  @override
  Future<Either<Failure, List<domain.RestaurantTable>>> getTables({
    domain.TableStatus? status,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(TableGQLQueries.tables),
        variables: {'branchId': _branchId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client.query(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al obtener mesas'));
      }

      final data = result.data?['tables'] as List<dynamic>?;
      if (data == null) {
        return const Right([]);
      }

      var tables = data
          .map((e) => _parseTable(e as Map<String, dynamic>))
          .toList();

      // Filter by status if specified
      if (status != null) {
        tables = tables.where((t) => t.status == status).toList();
      }

      return Right(tables);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.RestaurantTable>> getTableById(String id) async {
    try {
      final options = QueryOptions(
        document: gql(TableGQLQueries.table),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client.query(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al obtener mesa'));
      }

      final data = result.data?['table'];
      if (data == null) {
        return const Left(ServerFailure('Mesa no encontrada'));
      }

      return Right(_parseTable(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.RestaurantTable>> createTable({
    required String number,
    required int capacity,
  }) async {
    try {
      final options = MutationOptions(
        document: gql(TableGQLMutations.createTable),
        variables: {
          'input': {
            'branchId': _branchId,
            'number': number,
            'capacity': capacity,
          },
        },
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al crear mesa'));
      }

      final data = result.data?['createTable'];
      if (data == null) {
        return const Left(ServerFailure('Error al crear mesa'));
      }

      return Right(_parseTable(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.RestaurantTable>> updateTable({
    required String id,
    String? number,
    int? capacity,
    domain.TableStatus? status,
  }) async {
    try {
      final options = MutationOptions(
        document: gql(TableGQLMutations.updateTable),
        variables: {
          'id': id,
          if (number != null) 'number': number,
          if (capacity != null) 'capacity': capacity,
        },
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al actualizar mesa'));
      }

      final data = result.data?['updateTable'];
      if (data == null) {
        return const Left(ServerFailure('Error al actualizar mesa'));
      }

      return Right(_parseTable(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTable(String id) async {
    try {
      final options = MutationOptions(
        document: gql(TableGQLMutations.deleteTable),
        variables: {'id': id},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al eliminar mesa'));
      }

      final success = result.data?['deleteTable'] as bool?;
      if (success != true) {
        return const Left(ServerFailure('No se pudo eliminar la mesa'));
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.RestaurantTable>> assignOrderToTable({
    required String tableId,
    required String orderId,
  }) async {
    try {
      final options = MutationOptions(
        document: gql(TableGQLMutations.updateTableStatus),
        variables: {
          'id': tableId,
          'status': 'OCCUPIED',
        },
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al asignar orden a mesa'));
      }

      // Fetch updated table
      return getTableById(tableId);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.RestaurantTable>> releaseTable(String tableId) async {
    try {
      final options = MutationOptions(
        document: gql(TableGQLMutations.updateTableStatus),
        variables: {
          'id': tableId,
          'status': 'AVAILABLE',
        },
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al liberar mesa'));
      }

      // Fetch updated table
      return getTableById(tableId);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  // ====== RESERVATION METHODS ======

  @override
  Future<Either<Failure, domain.Reservation>> createReservation({
    required String userId,
    required String userName,
    required String userPhone,
    required String tableId,
    required DateTime reservationDate,
    required int numberOfPeople,
    String? notes,
  }) async {
    try {
      final options = MutationOptions(
        document: gql(TableGQLMutations.createReservation),
        variables: {
          'input': {
            'userId': userId,
            'userName': userName,
            'userPhone': userPhone,
            'tableId': tableId,
            'reservationDate': reservationDate.toIso8601String(),
            'numberOfPeople': numberOfPeople,
            if (notes != null) 'notes': notes,
          },
        },
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al crear reserva'));
      }

      final data = result.data?['createReservation'];
      if (data == null) {
        return const Left(ServerFailure('Error al crear reserva'));
      }

      return Right(_parseReservation(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Reservation>>> getUserReservations({
    required String userId,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(TableGQLQueries.reservations),
        variables: {'branchId': _branchId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client.query(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al obtener reservas'));
      }

      final data = result.data?['reservations'] as List<dynamic>?;
      if (data == null) {
        return const Right([]);
      }

      // Filter by userId locally
      final reservations = data
          .map((e) => _parseReservation(e as Map<String, dynamic>))
          .where((r) => r.userId == userId)
          .toList();

      return Right(reservations);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Reservation>>> getAllReservations({
    DateTime? date,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(TableGQLQueries.reservations),
        variables: {
          'branchId': _branchId,
          if (date != null) 'date': date.toIso8601String().split('T')[0],
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client.query(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al obtener reservas'));
      }

      final data = result.data?['reservations'] as List<dynamic>?;
      if (data == null) {
        return const Right([]);
      }

      final reservations = data
          .map((e) => _parseReservation(e as Map<String, dynamic>))
          .toList();

      return Right(reservations);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Reservation>> confirmReservation(
      String reservationId) async {
    try {
      // First get the reservation to build the update input
      final getResult = await _getReservationById(reservationId);
      
      return getResult.fold(
        (failure) => Left(failure),
        (reservation) async {
          final options = MutationOptions(
            document: gql(TableGQLMutations.updateReservation),
            variables: {
              'id': reservationId,
              'input': {
                'userId': reservation.userId,
                'userName': reservation.userName,
                'userPhone': reservation.userPhone,
                'tableId': reservation.tableId,
                'reservationDate': reservation.reservationDate.toIso8601String(),
                'numberOfPeople': reservation.numberOfPeople,
                'notes': reservation.notes,
                'isConfirmed': true,
              },
            },
          );

          final result = await _client.mutate(options);

          if (result.hasException) {
            return Left(ServerFailure(
                result.exception?.graphqlErrors.firstOrNull?.message ??
                    'Error al confirmar reserva'));
          }

          final data = result.data?['updateReservation'];
          if (data == null) {
            return const Left(ServerFailure('Error al confirmar reserva'));
          }

          return Right(_parseReservation(data as Map<String, dynamic>));
        },
      );
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Reservation>> cancelReservation(
      String reservationId) async {
    try {
      final options = MutationOptions(
        document: gql(TableGQLMutations.cancelReservation),
        variables: {'id': reservationId},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al cancelar reserva'));
      }

      final data = result.data?['cancelReservation'];
      if (data == null) {
        return const Left(ServerFailure('Error al cancelar reserva'));
      }

      return Right(_parseReservation(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  /// Helper to get a single reservation by ID
  Future<Either<Failure, domain.Reservation>> _getReservationById(String id) async {
    try {
      final options = QueryOptions(
        document: gql(TableGQLQueries.reservation),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client.query(options);

      if (result.hasException) {
        return Left(ServerFailure(
            result.exception?.graphqlErrors.firstOrNull?.message ??
                'Error al obtener reserva'));
      }

      final data = result.data?['reservation'];
      if (data == null) {
        return const Left(ServerFailure('Reserva no encontrada'));
      }

      return Right(_parseReservation(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }
}
