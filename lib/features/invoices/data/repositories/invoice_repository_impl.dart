import 'package:dartz/dartz.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenpos/core/graphql/client.dart';
import 'package:greenpos/core/graphql/invoice_operations.dart';
import 'package:greenpos/core/utils/failure.dart';
import 'package:greenpos/features/invoices/domain/entities/invoice.dart';
import 'package:greenpos/features/invoices/domain/repositories/invoice_repository.dart';

/// Implementation of InvoiceRepository using GraphQL
class InvoiceRepositoryImpl implements InvoiceRepository {
  final GraphQLClient _client;

  InvoiceRepositoryImpl({GraphQLClient? client})
      : _client = client ?? GraphQLClientSingleton.client;

  @override
  Future<Either<Failure, Invoice>> createInvoice({
    required String orderId,
    required String receptorRfc,
    required String receptorNombre,
    required String receptorUsoCfdi,
    String? receptorDomicilio,
    required String formaPago,
    required String metodoPago,
    String? serie,
    double descuento = 0,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(createInvoice),
          variables: {
            'input': {
              'orderId': orderId,
              'receptorRfc': receptorRfc,
              'receptorNombre': receptorNombre,
              'receptorUsoCfdi': receptorUsoCfdi,
              if (receptorDomicilio != null) 'receptorDomicilio': receptorDomicilio,
              'formaPago': formaPago,
              'metodoPago': metodoPago,
              if (serie != null) 'serie': serie,
              'descuento': descuento,
              'items': items,
            },
          },
        ),
      );

      if (result.hasException) {
        return Left(ServerFailure(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Error al crear factura',
        ));
      }

      final data = result.data?['createInvoice'];
      if (data == null) {
        return const Left(ServerFailure('Error al crear factura'));
      }

      return Right(Invoice.fromJson(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, Invoice>> stampInvoice(String invoiceId) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(stampInvoice),
          variables: {'id': invoiceId},
        ),
      );

      if (result.hasException) {
        return Left(ServerFailure(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Error al timbrar factura',
        ));
      }

      final data = result.data?['stampInvoice'];
      if (data == null) {
        return const Left(ServerFailure('Error al timbrar factura'));
      }

      return Right(Invoice.fromJson(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, Invoice>> cancelInvoice(
    String invoiceId,
    String motivo,
  ) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(cancelInvoice),
          variables: {'id': invoiceId, 'motivo': motivo},
        ),
      );

      if (result.hasException) {
        return Left(ServerFailure(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Error al cancelar factura',
        ));
      }

      final data = result.data?['cancelInvoice'];
      if (data == null) {
        return const Left(ServerFailure('Error al cancelar factura'));
      }

      return Right(Invoice.fromJson(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> getInvoices(
    String branchId, {
    InvoiceStatus? status,
  }) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(getInvoices),
          variables: {
            'branchId': branchId,
            if (status != null) 'status': status.name,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        return Left(ServerFailure(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Error al obtener facturas',
        ));
      }

      final data = result.data?['invoices'] as List<dynamic>?;
      if (data == null) {
        return const Right([]);
      }

      final invoices = data
          .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(invoices);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, Invoice>> getInvoice(String id) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(getInvoice),
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        return Left(ServerFailure(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Error al obtener factura',
        ));
      }

      final data = result.data?['invoice'];
      if (data == null) {
        return const Left(ServerFailure('Factura no encontrada'));
      }

      return Right(Invoice.fromJson(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTenantFiscal() async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(getTenantFiscal),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        return Left(ServerFailure(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Error al obtener datos fiscales',
        ));
      }

      final data = result.data?['tenantFiscal'] as Map<String, dynamic>?;
      if (data == null) {
        return const Right({});
      }

      return Right(data);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateTenantFiscal(
    Map<String, dynamic> input,
  ) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(updateTenantFiscal),
          variables: {'input': input},
        ),
      );

      if (result.hasException) {
        return Left(ServerFailure(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Error al actualizar datos fiscales',
        ));
      }

      final data = result.data?['updateTenantFiscal'] as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure('Error al actualizar datos fiscales'));
      }

      return Right(data);
    } catch (e) {
      return Left(ServerFailure('Error de conexión: $e'));
    }
  }
}
