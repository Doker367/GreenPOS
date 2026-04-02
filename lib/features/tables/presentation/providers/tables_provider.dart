import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/restaurant_table.dart';

/// Estado de las mesas del restaurante
class TablesState {
  final List<RestaurantTable> tables;
  final bool isLoading;
  final String? error;

  const TablesState({
    this.tables = const [],
    this.isLoading = false,
    this.error,
  });

  TablesState copyWith({
    List<RestaurantTable>? tables,
    bool? isLoading,
    String? error,
  }) {
    return TablesState(
      tables: tables ?? this.tables,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Obtener mesas disponibles
  List<RestaurantTable> get availableTables =>
      tables.where((t) => t.isAvailable).toList();

  /// Obtener mesas ocupadas
  List<RestaurantTable> get occupiedTables =>
      tables.where((t) => t.isOccupied).toList();

  /// Obtener mesas reservadas
  List<RestaurantTable> get reservedTables =>
      tables.where((t) => t.isReserved).toList();

  /// Buscar mesa por ID
  RestaurantTable? getTableById(String id) {
    try {
      return tables.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Buscar mesa por número
  RestaurantTable? getTableByNumber(String number) {
    try {
      return tables.firstWhere((t) => t.number == number);
    } catch (e) {
      return null;
    }
  }
}

/// Notifier para gestionar las mesas
class TablesNotifier extends StateNotifier<TablesState> {
  TablesNotifier() : super(const TablesState()) {
    _initializeTables();
  }

  /// Inicializar con datos de ejemplo
  void _initializeTables() {
    final mockTables = <RestaurantTable>[
      // Zona principal (8 mesas de 4 personas)
      for (int i = 1; i <= 8; i++)
        RestaurantTable(
          id: 'table_$i',
          number: '$i',
          capacity: 4,
          status: TableStatus.available,
        ),
      
      // Zona VIP (4 mesas de 6 personas)
      for (int i = 1; i <= 4; i++)
        RestaurantTable(
          id: 'vip_$i',
          number: 'VIP-$i',
          capacity: 6,
          status: TableStatus.available,
        ),
      
      // Mesas para 2 personas (6 mesas)
      for (int i = 1; i <= 6; i++)
        RestaurantTable(
          id: 'small_$i',
          number: 'S$i',
          capacity: 2,
          status: TableStatus.available,
        ),
    ];

    state = state.copyWith(tables: mockTables);
  }

  /// Ocupar una mesa con una orden
  void occupyTable(String tableId, String orderId) {
    final updatedTables = state.tables.map((table) {
      if (table.id == tableId) {
        return table.occupy(orderId);
      }
      return table;
    }).toList();

    state = state.copyWith(tables: updatedTables);
  }

  /// Liberar una mesa
  void freeTable(String tableId) {
    final updatedTables = state.tables.map((table) {
      if (table.id == tableId) {
        return table.free();
      }
      return table;
    }).toList();

    state = state.copyWith(tables: updatedTables);
  }

  /// Reservar una mesa
  void reserveTable(String tableId, String customerName, DateTime time) {
    final updatedTables = state.tables.map((table) {
      if (table.id == tableId) {
        return table.reserve(customerName, time);
      }
      return table;
    }).toList();

    state = state.copyWith(tables: updatedTables);
  }

  /// Cambiar estado de una mesa
  void updateTableStatus(String tableId, TableStatus status) {
    final updatedTables = state.tables.map((table) {
      if (table.id == tableId) {
        return table.copyWith(status: status);
      }
      return table;
    }).toList();

    state = state.copyWith(tables: updatedTables);
  }

  /// Transferir orden de una mesa a otra
  void transferOrder(String fromTableId, String toTableId) {
    final fromTable = state.getTableById(fromTableId);
    if (fromTable == null || fromTable.currentOrderId == null) return;

    final orderId = fromTable.currentOrderId!;
    
    final updatedTables = state.tables.map((table) {
      if (table.id == fromTableId) {
        return table.free();
      } else if (table.id == toTableId) {
        return table.occupy(orderId);
      }
      return table;
    }).toList();

    state = state.copyWith(tables: updatedTables);
  }
}

/// Provider de las mesas del restaurante
final tablesProvider = StateNotifierProvider<TablesNotifier, TablesState>((ref) {
  return TablesNotifier();
});
