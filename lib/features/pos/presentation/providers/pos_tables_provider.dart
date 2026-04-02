// FILE: /home/node/.openclaw/workspace/greenpos/frontend/lib/features/pos/presentation/providers/pos_tables_provider.dart
// STATUS: New provider for POS table management
// PERMISSION ISSUE: Files are owned by root, cannot write directly

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tables/domain/entities/restaurant_table.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Estado de las mesas para el POS
class POSTablesState {
  final List<RestaurantTable> tables;
  final bool isLoading;
  final String? error;
  final String? selectedTableId;

  const POSTablesState({
    this.tables = const [],
    this.isLoading = false,
    this.error,
    this.selectedTableId,
  });

  POSTablesState copyWith({
    List<RestaurantTable>? tables,
    bool? isLoading,
    String? error,
    String? selectedTableId,
  }) {
    return POSTablesState(
      tables: tables ?? this.tables,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedTableId: selectedTableId ?? this.selectedTableId,
    );
  }

  /// Obtener mesa seleccionada
  RestaurantTable? get selectedTable {
    if (selectedTableId == null) return null;
    try {
      return tables.firstWhere((t) => t.id == selectedTableId);
    } catch (_) {
      return null;
    }
  }

  /// Obtener mesa por ID
  RestaurantTable? getTableById(String id) {
    try {
      return tables.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Notifier para las mesas del POS
class POSTablesNotifier extends StateNotifier<POSTablesState> {
  final Ref _ref;
  
  POSTablesNotifier(this._ref) : super(const POSTablesState()) {
    loadTables();
  }

  /// Cargar mesas desde el backend
  Future<void> loadTables() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // En producción, esto llamaría al repositorio de mesas
      // Por ahora usamos datos mock
      await Future.delayed(const Duration(milliseconds: 300));
      
      final user = _ref.read(currentUserProvider);
      
      // Datos mock basados en la estructura del proyecto
      final mockTables = _generateMockTables();
      
      state = state.copyWith(
        tables: mockTables,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  List<RestaurantTable> _generateMockTables() {
    final tables = <RestaurantTable>[];
    
    // Zona principal (8 mesas de 4 personas)
    for (int i = 1; i <= 8; i++) {
      tables.add(RestaurantTable(
        id: 'table_$i',
        number: '$i',
        capacity: 4,
        status: TableStatus.available,
      ));
    }
    
    // Zona VIP (4 mesas de 6 personas)
    for (int i = 1; i <= 4; i++) {
      tables.add(RestaurantTable(
        id: 'vip_$i',
        number: 'VIP-$i',
        capacity: 6,
        status: TableStatus.available,
      ));
    }
    
    // Mesas para 2 personas (6 mesas)
    for (int i = 1; i <= 6; i++) {
      tables.add(RestaurantTable(
        id: 'small_$i',
        number: 'S$i',
        capacity: 2,
        status: TableStatus.available,
      ));
    }
    
    return tables;
  }

  /// Seleccionar una mesa
  void selectTable(String? tableId) {
    state = state.copyWith(selectedTableId: tableId);
  }

  /// Ocupar una mesa con una orden
  Future<void> occupyTable(String tableId, String orderId) async {
    final updatedTables = state.tables.map((table) {
      if (table.id == tableId) {
        return table.occupy(orderId);
      }
      return table;
    }).toList();

    state = state.copyWith(tables: updatedTables);
  }

  /// Liberar una mesa
  Future<void> freeTable(String tableId) async {
    final updatedTables = state.tables.map((table) {
      if (table.id == tableId) {
        return table.free();
      }
      return table;
    }).toList();

    state = state.copyWith(tables: updatedTables);
  }

  /// Reservar una mesa
  Future<void> reserveTable(
    String tableId,
    String customerName,
    DateTime time,
  ) async {
    final updatedTables = state.tables.map((table) {
      if (table.id == tableId) {
        return table.reserve(customerName, time);
      }
      return table;
    }).toList();

    state = state.copyWith(tables: updatedTables);
  }

  /// Obtener mesa por número
  RestaurantTable? getTableByNumber(String number) {
    try {
      return state.tables.firstWhere((t) => t.number == number);
    } catch (_) {
      return null;
    }
  }
}

/// Provider de las mesas del POS
final posTablesProvider =
    StateNotifierProvider<POSTablesNotifier, POSTablesState>((ref) {
  return POSTablesNotifier(ref);
});
