import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/graphql/client.dart';
import '../../domain/entities/kitchen_order_entity.dart';
import '../../domain/repositories/kitchen_repository.dart';
import '../models/kitchen_order_model.dart';

/// GraphQL queries for kitchen operations
class KitchenGQL {
  static const String getKitchenOrders = r'''
    query KitchenOrders($branchId: UUID!) {
      kitchenOrders(branchId: $branchId) {
        id
        tableId
        table {
          id
          number
          status
        }
        customerName
        status
        items {
          id
          productId
          productName
          quantity
          notes
          unitPrice
        }
        notes
        createdAt
        updatedAt
      }
    }
  ''';

  static const String markOrderReady = r'''
    mutation MarkOrderReady($id: UUID!) {
      markOrderReady(id: $id) {
        id
        status
        updatedAt
      }
    }
  ''';
}

/// Implementation of KitchenRepository using GraphQL
class KitchenRepositoryImpl implements KitchenRepository {
  final GraphQLClient _client;

  KitchenRepositoryImpl({GraphQLClient? client})
      : _client = client ?? GraphQLClientSingleton.client;

  @override
  Future<List<KitchenOrderEntity>> getKitchenOrders(String branchId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(KitchenGQL.getKitchenOrders),
        variables: {'branchId': branchId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List<dynamic> data = result.data?['kitchenOrders'] ?? [];
    return data
        .map((json) => KitchenOrderModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<KitchenOrderEntity> markOrderReady(String orderId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(KitchenGQL.markOrderReady),
        variables: {'id': orderId},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final json = result.data?['markOrderReady'] as Map<String, dynamic>?;
    if (json == null) {
      throw Exception('Failed to mark order as ready');
    }
    return KitchenOrderModel.fromJson(json).toEntity();
  }

  @override
  Stream<List<KitchenOrderEntity>> watchKitchenOrders(String branchId) {
    // For now, implement polling-based streaming
    // In the future, this could be upgraded to GraphQL subscriptions
    final controller = StreamController<List<KitchenOrderEntity>>();
    
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (controller.isClosed) {
        timer.cancel();
        return;
      }
      try {
        final orders = await getKitchenOrders(branchId);
        if (!controller.isClosed) {
          controller.add(orders);
        }
      } catch (_) {
        // Ignore errors in polling, will retry on next tick
      }
    });

    return controller.stream;
  }
}