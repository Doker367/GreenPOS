// Offline Sync Service for GreenPOS
// Handles bidirectional sync between local Drift DB and backend

import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../local_database/app_database.dart';
import '../graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// Resultado de una operación de sincronización
class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int errorCount;
  final DateTime timestamp;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    this.errorCount = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'SyncResult($success, $message, synced: $syncedCount, errors: $errorCount)';
}

/// Estado de sincronización
enum SyncState { idle, syncing, error, offline }

/// Servicio de sincronización para modo offline
class SyncService {
  LocalDatabase? _db;
  GraphQLClient? _client;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = true;
  SyncState _state = SyncState.idle;

  // Callbacks para notificar cambios
  VoidCallback? onConnectivityChanged;
  VoidCallback? onSyncStateChanged;
  Function(SyncResult)? onSyncComplete;

  // Singleton
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  /// Inicializar el servicio con dependencias
  Future<void> initialize() async {
    // Crear base de datos local
    _db = LocalDatabase();

    // Cliente GraphQL
    _client = GraphQLClientSingleton.client;

    // Escuchar cambios de conectividad
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);

    // Verificar estado inicial
    final result = await Connectivity().checkConnectivity();
    _updateOnlineStatus(result);

    // Si hay órdenes pendientes sin sincronizar, intentar sync
    if (_isOnline) {
      await syncPendingOrders();
    }
  }

  /// Cleanup
  void dispose() {
    _connectivitySubscription?.cancel();
    _db?.close();
  }

  /// Set database instance (for testing or manual injection)
  void setDatabase(LocalDatabase db) {
    _db = db;
  }

  /// Set GraphQL client (for testing or manual injection)
  void setClient(GraphQLClient client) {
    _client = client;
  }

  /// Callback cuando cambia la conectividad
  void _onConnectivityChanged(List<ConnectivityResult> result) {
    final wasOnline = _isOnline;
    _updateOnlineStatus(result);

    // Notificar cambio de conectividad
    onConnectivityChanged?.call();

    // Si pasamos de offline a online, sincronizar automáticamente
    if (!wasOnline && _isOnline) {
      syncPendingOrders();
    }
  }

  void _updateOnlineStatus(List<ConnectivityResult> result) {
    _isOnline = result.isNotEmpty && !result.contains(ConnectivityResult.none);
    _state = _isOnline ? SyncState.idle : SyncState.offline;
    onSyncStateChanged?.call();
  }

  /// Verificar si está online
  bool get isOnline => _isOnline;

  /// Obtener estado actual
  SyncState get state => _state;

  /// Sincronizar órdenes pendientes con el backend
  Future<SyncResult> syncPendingOrders() async {
    if (_db == null) {
      return SyncResult(
        success: false,
        message: 'Base de datos no inicializada',
        syncedCount: 0,
      );
    }

    if (!_isOnline) {
      _state = SyncState.offline;
      onSyncStateChanged?.call();
      return SyncResult(
        success: false,
        message: 'Sin conexión a internet',
        syncedCount: 0,
      );
    }

    _state = SyncState.syncing;
    onSyncStateChanged?.call();

    try {
      final pendingOrders = await _db!.getUnsyncedOrders();

      if (pendingOrders.isEmpty) {
        _state = SyncState.idle;
        onSyncStateChanged?.call();
        return SyncResult(
          success: true,
          message: 'No hay órdenes pendientes',
          syncedCount: 0,
        );
      }

      int syncedCount = 0;
      final errors = <String>[];

      for (final order in pendingOrders) {
        try {
          final items = _parseOrderItems(order.itemsJson);

          final input = {
            'branchId': order.branchId,
            'userId': order.userId,
            if (order.tableId != null) 'tableId': order.tableId,
            if (order.customerName != null)
              'customerName': order.customerName,
            if (order.customerPhone != null)
              'customerPhone': order.customerPhone,
            if (order.notes != null) 'notes': order.notes,
            'items': items,
          };

          final options = MutationOptions(
            document: gql(_createOrderMutation),
            variables: {'input': input},
          );

          final result = await _client!.mutate(options);

          if (result.hasException) {
            errors.add(
                'Orden ${order.orderId}: ${result.exception?.graphqlErrors.firstOrNull?.message ?? 'Error desconocido'}');
          } else {
            await _db!.markOrderAsSynced(order.id, DateTime.now());
            syncedCount++;
          }
        } catch (e) {
          errors.add('Orden ${order.orderId}: $e');
        }
      }

      _state = errors.isEmpty ? SyncState.idle : SyncState.error;
      onSyncStateChanged?.call();

      final syncResult = SyncResult(
        success: errors.isEmpty,
        message: errors.isEmpty
            ? 'Sincronizadas $syncedCount órdenes'
            : 'Errores: ${errors.join(", ")}',
        syncedCount: syncedCount,
        errorCount: errors.length,
      );

      onSyncComplete?.call(syncResult);
      return syncResult;
    } catch (e) {
      _state = SyncState.error;
      onSyncStateChanged?.call();
      return SyncResult(
        success: false,
        message: 'Error de sincronización: $e',
        syncedCount: 0,
      );
    }
  }

  List<Map<String, dynamic>> _parseOrderItems(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static const String _createOrderMutation = r'''
    mutation CreateOrder($input: CreateOrderInput!) {
      createOrder(input: $input) {
        id
        status
      }
    }
  ''';

  /// Sincronizar productos desde el servidor
  Future<SyncResult> syncProducts() async {
    if (_db == null || !_isOnline) {
      return SyncResult(
        success: false,
        message: _isOnline ? 'Base de datos no inicializada' : 'Sin conexión',
        syncedCount: 0,
      );
    }

    _state = SyncState.syncing;
    onSyncStateChanged?.call();

    try {
      const query = r'''
        query GetProducts($branchId: ID!) {
          products(branchId: $branchId) {
            id
            name
            description
            price
            categoryId
            imageUrl
            isAvailable
            isFeatured
            preparationTime
          }
        }
      ''';

      // Get branchId from somewhere (could be passed as parameter)
      const branchId = '00000000-0000-0000-0000-000000000001';

      final options = QueryOptions(
        document: gql(query),
        variables: {'branchId': branchId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client!.query(options);

      if (result.hasException) {
        _state = SyncState.error;
        onSyncStateChanged?.call();
        return SyncResult(
          success: false,
          message:
              'Error: ${result.exception?.graphqlErrors.firstOrNull?.message ?? 'Error desconocido'}',
          syncedCount: 0,
        );
      }

      final data = result.data?['products'] as List<dynamic>?;
      if (data == null) {
        _state = SyncState.idle;
        onSyncStateChanged?.call();
        return SyncResult(
          success: true,
          message: 'No hay productos',
          syncedCount: 0,
        );
      }

      final products = data.map((p) {
        return CachedProductsCompanion.insert(
          id: p['id'] as String,
          branchId: branchId,
          categoryId: Value(p['categoryId'] as String?),
          name: p['name'] as String,
          description: Value(p['description'] as String?),
          price: (p['price'] as num).toDouble(),
          imageUrl: Value(p['imageUrl'] as String?),
          isAvailable: Value(p['isAvailable'] as bool? ?? true),
          isFeatured: Value(p['isFeatured'] as bool? ?? false),
          preparationTime: Value(p['preparationTime'] as int? ?? 15),
          cachedAt: DateTime.now(),
        );
      }).toList();

      await _db!.cacheProducts(branchId, products);

      _state = SyncState.idle;
      onSyncStateChanged?.call();

      final syncResult = SyncResult(
        success: true,
        message: 'Sincronizados ${products.length} productos',
        syncedCount: products.length,
      );

      onSyncComplete?.call(syncResult);
      return syncResult;
    } catch (e) {
      _state = SyncState.error;
      onSyncStateChanged?.call();
      return SyncResult(
        success: false,
        message: 'Error de sincronización: $e',
        syncedCount: 0,
      );
    }
  }

  /// Sincronizar categorías desde el servidor
  Future<SyncResult> syncCategories() async {
    if (_db == null || !_isOnline) {
      return SyncResult(
        success: false,
        message: _isOnline ? 'Base de datos no inicializada' : 'Sin conexión',
        syncedCount: 0,
      );
    }

    _state = SyncState.syncing;
    onSyncStateChanged?.call();

    try {
      const query = r'''
        query GetCategories($branchId: ID!) {
          categories(branchId: $branchId) {
            id
            name
            description
            sortOrder
            isActive
          }
        }
      ''';

      const branchId = '00000000-0000-0000-0000-000000000001';

      final options = QueryOptions(
        document: gql(query),
        variables: {'branchId': branchId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await _client!.query(options);

      if (result.hasException) {
        _state = SyncState.error;
        onSyncStateChanged?.call();
        return SyncResult(
          success: false,
          message:
              'Error: ${result.exception?.graphqlErrors.firstOrNull?.message ?? 'Error desconocido'}',
          syncedCount: 0,
        );
      }

      final data = result.data?['categories'] as List<dynamic>?;
      if (data == null) {
        _state = SyncState.idle;
        onSyncStateChanged?.call();
        return SyncResult(
          success: true,
          message: 'No hay categorías',
          syncedCount: 0,
        );
      }

      final categories = data.map((c) {
        return CachedCategoriesCompanion.insert(
          id: c['id'] as String,
          branchId: branchId,
          name: c['name'] as String,
          description: Value(c['description'] as String?),
          sortOrder: Value(c['sortOrder'] as int? ?? 0),
          isActive: Value(c['isActive'] as bool? ?? true),
          cachedAt: DateTime.now(),
        );
      }).toList();

      await _db!.cacheCategories(branchId, categories);

      _state = SyncState.idle;
      onSyncStateChanged?.call();

      final syncResult = SyncResult(
        success: true,
        message: 'Sincronizadas ${categories.length} categorías',
        syncedCount: categories.length,
      );

      onSyncComplete?.call(syncResult);
      return syncResult;
    } catch (e) {
      _state = SyncState.error;
      onSyncStateChanged?.call();
      return SyncResult(
        success: false,
        message: 'Error de sincronización: $e',
        syncedCount: 0,
      );
    }
  }

  /// Guardar orden localmente (offline)
  Future<int> saveOrderLocally({
    required String orderId,
    required String branchId,
    required String userId,
    String? tableId,
    String? customerName,
    String? customerPhone,
    String? notes,
    required String itemsJson,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
    required String status,
  }) async {
    if (_db == null) {
      throw Exception('Base de datos no inicializada');
    }

    final id = await _db!.savePendingOrder(
      PendingOrdersCompanion.insert(
        orderId: orderId,
        branchId: branchId,
        tableId: Value(tableId),
        userId: userId,
        customerName: Value(customerName),
        customerPhone: Value(customerPhone),
        notes: Value(notes),
        itemsJson: itemsJson,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        total: total,
        status: status,
        createdAt: DateTime.now(),
      ),
    );

    // Si está online, intentar sincronizar inmediatamente
    if (_isOnline) {
      await syncPendingOrders();
    }

    return id;
  }

  /// Obtener número de órdenes pendientes
  Future<int> getPendingOrdersCount() async {
    if (_db == null) return 0;
    final orders = await _db!.getUnsyncedOrders();
    return orders.length;
  }

  /// Verificar si hay órdenes pendientes
  Future<bool> hasPendingOrders() async {
    if (_db == null) return false;
    return await _db!.hasUnsyncedOrders();
  }

  /// Forzar sincronización completa
  Future<SyncResult> forceFullSync() async {
    // Primero sincronizar órdenes pendientes
    final orderResult = await syncPendingOrders();

    // Luego sincronizar productos y categorías
    final productsResult = await syncProducts();
    final categoriesResult = await syncCategories();

    final totalSynced =
        orderResult.syncedCount + productsResult.syncedCount + categoriesResult.syncedCount;
    final totalErrors =
        orderResult.errorCount + productsResult.errorCount + categoriesResult.errorCount;

    return SyncResult(
      success: totalErrors == 0,
      message: 'Sync completo: $totalSynced elementos',
      syncedCount: totalSynced,
      errorCount: totalErrors,
    );
  }
}
