import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/graphql/client.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/tables/data/repositories/table_repository_impl.dart';
import '../../features/tables/domain/repositories/table_repository.dart';

// ====== PROVIDERS DE INFRAESTRUCTURA ======

/// Provider de SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences debe ser inicializado en main');
});

/// Provider de GraphQL Client
final graphqlClientProvider = Provider<GraphQLClient>((ref) {
  return GraphQLClientSingleton.client;
});

/// Provider del branchId actual
final currentBranchIdProvider = Provider<String>((ref) {
  // Valor por defecto para desarrollo - en producción vendría del estado de la app
  // TODO: Este valor debería venir de la sesión del usuario o configuración
  return '00000000-0000-0000-0000-000000000001';
});

// ====== PROVIDERS DE REPOSITORIOS ======

/// Provider del repositorio de autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

/// Provider del repositorio de menú
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepositoryImpl(
    client: ref.watch(graphqlClientProvider),
    branchId: ref.watch(currentBranchIdProvider),
  );
});

/// Provider del repositorio de pedidos
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    client: ref.watch(graphqlClientProvider),
  );
});

/// Provider del repositorio de mesas y reservas
final tableRepositoryProvider = Provider<TableRepository>((ref) {
  return TableRepositoryImpl(
    client: ref.watch(graphqlClientProvider),
    branchId: ref.watch(currentBranchIdProvider),
  );
});
