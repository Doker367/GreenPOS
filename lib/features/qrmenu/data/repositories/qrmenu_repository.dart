import 'package:dartz/dartz.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/graphql/client.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/qrmenu_entities.dart';
import 'qrmenu_graphql.dart';

/// Repository implementation for QR menu operations
class QRMenuRepository {
  final GraphQLClient _client;

  QRMenuRepository({GraphQLClient? client})
      : _client = client ?? GraphQLClientSingleton.client;

  /// Fetches the public menu for a branch
  Future<Either<Failure, List<CategoryWithProducts>>> getPublicMenu({
    required String branchId,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(QRMenuQueries.publicMenu),
        variables: {'branchId': branchId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client.query(options);

      if (result.hasException) {
        return Left(ServerFailure(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Error al obtener el menú',
        ));
      }

      final data = result.data?['publicMenu'] as List<dynamic>?;
      if (data == null) {
        return const Right([]);
      }

      final categories = data
          .map((e) => CategoryWithProducts.fromJson(e as Map<String, dynamic>))
          .toList();

      // Sort by sortOrder
      categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return Right(categories);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  /// Gets table info by QR token
  Future<Either<Failure, Map<String, dynamic>>> getTableByQRToken({
    required String token,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(QRMenuQueries.tableByQRToken),
        variables: {'token': token},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client.query(options);

      if (result.hasException) {
        return Left(ServerFailure(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Error al obtener información de la mesa',
        ));
      }

      final data = result.data?['tableByQRToken'] as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure('Mesa no encontrada'));
      }

      return Right(data);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  /// Gets QR code info by token
  Future<Either<Failure, TableQRCode>> getQRByToken({
    required String token,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(QRMenuQueries.getQRByToken),
        variables: {'token': token},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client.query(options);

      if (result.hasException) {
        return Left(ServerFailure(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Error al obtener código QR',
        ));
      }

      final data = result.data?['getQRByToken'] as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure('Código QR no encontrado'));
      }

      return Right(TableQRCode.fromJson(data));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  /// Generates a QR code for a table
  Future<Either<Failure, TableQRCode>> generateTableQR({
    required String tableId,
  }) async {
    try {
      final options = MutationOptions(
        document: gql(QRMenuMutations.generateTableQR),
        variables: {'tableId': tableId},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        return Left(ServerFailure(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Error al generar código QR',
        ));
      }

      final data = result.data?['generateTableQR'] as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure('Error al generar código QR'));
      }

      return Right(TableQRCode.fromJson(data));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  /// Creates a client order from the QR menu
  Future<Either<Failure, OrderConfirmation>> createClientOrder({
    required CreateClientOrderInput input,
  }) async {
    try {
      final options = MutationOptions(
        document: gql(QRMenuMutations.createClientOrder),
        variables: {'input': input.toJson()},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        return Left(ServerFailure(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Error al crear el pedido',
        ));
      }

      final data = result.data?['createClientOrder'] as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure('Error al crear el pedido'));
      }

      return Right(OrderConfirmation.fromJson(data));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }
}
