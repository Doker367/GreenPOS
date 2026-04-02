// FILE: /home/node/.openclaw/workspace/greenpos/frontend/lib/core/providers/repository_providers.dart
// STATUS: Updated to use auth provider for branchId
// PERMISSION ISSUE: Files are owned by root, cannot write directly

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../core/graphql/client.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/tables/data/repositories/table_repository_impl.dart';
import '../../features/tables/domain/repositories/table_repository.dart';

// ====== PROVIDERS DE INFRAESTRUCTURA ======

/// Provider de GraphQL Client
final graphqlClientProvider = Provider<GraphQLClient>((ref) {
  return GraphQLClientSingleton.client;
});

// ====== PROVIDERS DE REPOSITORIOS ======

/// Provider del repositorio de autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Provider del repositorio de menú
/// Usa el branchId del usuario autenticado
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final branchId = ref.watch(currentBranchIdProvider) ?? 
                   '00000000-0000-0000-0000-000000000001'; // Fallback para desarrollo
  return MenuRepositoryImpl(
    client: ref.watch(graphqlClientProvider),
    branchId: branchId,
  );
});

/// Provider del repositorio de pedidos
/// Recibe el branchId dinámicamente desde el contexto de auth
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    client: ref.watch(graphqlClientProvider),
    getBranchId: () => ref.watch(currentBranchIdProvider) ?? 
                       '00000000-0000-0000-0000-000000000001',
  );
});

/// Provider del repositorio de mesas y reservas
/// Usa el branchId del usuario autenticado
final tableRepositoryProvider = Provider<TableRepository>((ref) {
  final branchId = ref.watch(currentBranchIdProvider) ?? 
                   '00000000-0000-0000-0000-000000000001';
  return TableRepositoryImpl(
    client: ref.watch(graphqlClientProvider),
    branchId: branchId,
  );
});
