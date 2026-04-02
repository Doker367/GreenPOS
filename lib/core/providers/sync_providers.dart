// Sync Providers for GreenPOS
// Manages sync state and connectivity status via Riverpod

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/sync_service.dart';

/// Estado de sincronización
class SyncStatus {
  final bool isOnline;
  final SyncState state;
  final int pendingOrdersCount;
  final String? lastSyncMessage;
  final DateTime? lastSyncTime;

  const SyncStatus({
    required this.isOnline,
    required this.state,
    this.pendingOrdersCount = 0,
    this.lastSyncMessage,
    this.lastSyncTime,
  });

  SyncStatus copyWith({
    bool? isOnline,
    SyncState? state,
    int? pendingOrdersCount,
    String? lastSyncMessage,
    DateTime? lastSyncTime,
  }) {
    return SyncStatus(
      isOnline: isOnline ?? this.isOnline,
      state: state ?? this.state,
      pendingOrdersCount: pendingOrdersCount ?? this.pendingOrdersCount,
      lastSyncMessage: lastSyncMessage ?? this.lastSyncMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  bool get isSyncing => state == SyncState.syncing;
  bool get hasError => state == SyncState.error;
  bool get isOffline => state == SyncState.offline;
}

/// Notifier que maneja el estado de sincronización
class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  final SyncService _syncService;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  SyncStatusNotifier(this._syncService)
      : super(const SyncStatus(
          isOnline: true,
          state: SyncState.idle,
          pendingOrdersCount: 0,
        )) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Escuchar cambios de conectividad del sistema
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);

    // Verificar conectividad inicial
    final result = await Connectivity().checkConnectivity();
    _updateOnlineStatus(result);

    // Actualizar contador de órdenes pendientes
    await _updatePendingCount();

    // Configurar callbacks del servicio de sync
    _syncService.onConnectivityChanged = () {
      _updatePendingCount();
    };

    _syncService.onSyncStateChanged = () {
      state = state.copyWith(state: _syncService.state);
    };

    _syncService.onSyncComplete = (result) {
      state = state.copyWith(
        state: result.success ? SyncState.idle : SyncState.error,
        lastSyncMessage: result.message,
        lastSyncTime: result.timestamp,
      );
      _updatePendingCount();
    };
  }

  void _onConnectivityChanged(List<ConnectivityResult> result) {
    _updateOnlineStatus(result);
  }

  void _updateOnlineStatus(List<ConnectivityResult> result) {
    final isOnline = result.isNotEmpty && !result.contains(ConnectivityResult.none);
    state = state.copyWith(
      isOnline: isOnline,
      state: isOnline ? SyncState.idle : SyncState.offline,
    );
  }

  Future<void> _updatePendingCount() async {
    try {
      final count = await _syncService.getPendingOrdersCount();
      state = state.copyWith(pendingOrdersCount: count);
    } catch (_) {
      // Ignore errors getting pending count
    }
  }

  /// Sincronizar órdenes pendientes
  Future<SyncResult> syncPendingOrders() async {
    state = state.copyWith(state: SyncState.syncing);
    final result = await _syncService.syncPendingOrders();
    await _updatePendingCount();
    return result;
  }

  /// Sincronizar productos
  Future<SyncResult> syncProducts() async {
    state = state.copyWith(state: SyncState.syncing);
    final result = await _syncService.syncProducts();
    state = state.copyWith(
      state: result.success ? SyncState.idle : SyncState.error,
      lastSyncMessage: result.message,
      lastSyncTime: result.timestamp,
    );
    return result;
  }

  /// Sincronizar categorías
  Future<SyncResult> syncCategories() async {
    state = state.copyWith(state: SyncState.syncing);
    final result = await _syncService.syncCategories();
    state = state.copyWith(
      state: result.success ? SyncState.idle : SyncState.error,
      lastSyncMessage: result.message,
      lastSyncTime: result.timestamp,
    );
    return result;
  }

  /// Forzar sync completo
  Future<SyncResult> forceFullSync() async {
    state = state.copyWith(state: SyncState.syncing);
    final result = await _syncService.forceFullSync();
    await _updatePendingCount();
    return result;
  }

  /// Refrescar contador de órdenes pendientes
  Future<void> refreshPendingCount() async {
    await _updatePendingCount();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Provider del servicio de sincronización
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider del estado de sincronización
final syncStatusProvider =
    StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncStatusNotifier(syncService);
});

/// Provider para verificar si hay órdenes pendientes de sync
final hasPendingOrdersProvider = Provider<bool>((ref) {
  final syncStatus = ref.watch(syncStatusProvider);
  return syncStatus.pendingOrdersCount > 0;
});

/// Provider del indicador de conectividad
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Provider para verificar si está online
final isOnlineProvider = Provider<bool>((ref) {
  final asyncConnectivity = ref.watch(connectivityProvider);
  return asyncConnectivity.when(
    data: (result) => result.isNotEmpty && !result.contains(ConnectivityResult.none),
    loading: () => true,
    error: (_, __) => true,
  );
});
