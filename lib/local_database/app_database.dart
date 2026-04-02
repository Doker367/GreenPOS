// FILE: /home/node/.openclaw/workspace/greenpos/frontend/lib/core/database/local_database.dart
// STATUS: New - Drift SQLite local database for offline support
// PERMISSION ISSUE: Files are owned by root, cannot write directly

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'local_database.g.dart';

/// tabla local de órdenes pendientes de sincronizar
class PendingOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderId => text()();
  TextColumn get branchId => text()();
  TextColumn get tableId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get itemsJson => text()(); // JSON string of items
  RealColumn get subtotal => real()();
  RealColumn get tax => real()();
  RealColumn get discount => real()();
  RealColumn get total => real()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

/// tabla local de productos (cache)
class CachedProducts extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get price => real()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  BoolColumn get isFeatured => boolean().withDefault(const Constant(false))();
  IntColumn get preparationTime => integer().withDefault(const Constant(15))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => [id, branchId];
}

/// tabla local de categorías (cache)
class CachedCategories extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => [id, branchId];
}

/// tabla local de mesas (cache)
class CachedTables extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text()();
  TextColumn get number => text()();
  IntColumn get capacity => integer()();
  TextColumn get status => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => [id, branchId];
}

@DriftDatabase(tables: [PendingOrders, CachedProducts, CachedCategories, CachedTables])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ===== PENDING ORDERS =====

  /// Guardar orden pendiente
  Future<int> savePendingOrder(PendingOrdersCompanion order) {
    return into(pendingOrders).insert(order);
  }

  /// Obtener órdenes pendientes por sincronizar
  Future<List<PendingOrder>> getUnsyncedOrders() {
    return (select(pendingOrders)..where((t) => t.isSynced.equals(false))).get();
  }

  /// Marcar orden como sincronizada
  Future<int> markOrderAsSynced(int id, DateTime syncedAt) {
    return (update(pendingOrders)..where((t) => t.id.equals(id))).write(
      PendingOrdersCompanion(
        isSynced: const Value(true),
        syncedAt: Value(syncedAt),
      ),
    );
  }

  /// Obtener todas las órdenes pendientes
  Future<List<PendingOrder>> getAllPendingOrders() {
    return select(pendingOrders).get();
  }

  /// Eliminar orden pendiente
  Future<int> deletePendingOrder(int id) {
    return (delete(pendingOrders)..where((t) => t.id.equals(id))).go();
  }

  // ===== CACHED PRODUCTS =====

  /// Guardar productos en cache
  Future<void> cacheProducts(String branchId, List<CachedProductsCompanion> products) async {
    await batch((batch) {
      // Eliminar productos antiguos de esta sucursal
      batch.deleteWhere(cachedProducts, (t) => t.branchId.equals(branchId));
      // Insertar nuevos
      batch.insertAll(cachedProducts, products);
    });
  }

  /// Obtener productos cacheados
  Future<List<CachedProduct>> getCachedProducts(String branchId) {
    return (select(cachedProducts)..where((t) => t.branchId.equals(branchId))).get();
  }

  /// Obtener productos por categoría
  Future<List<CachedProduct>> getCachedProductsByCategory(
    String branchId,
    String categoryId,
  ) {
    return (select(cachedProducts)
      ..where((t) => t.branchId.equals(branchId) & t.categoryId.equals(categoryId))
    ).get();
  }

  // ===== CACHED CATEGORIES =====

  /// Guardar categorías en cache
  Future<void> cacheCategories(String branchId, List<CachedCategoriesCompanion> categories) async {
    await batch((batch) {
      batch.deleteWhere(cachedCategories, (t) => t.branchId.equals(branchId));
      batch.insertAll(cachedCategories, categories);
    });
  }

  /// Obtener categorías cacheadas
  Future<List<CachedCategory>> getCachedCategories(String branchId) {
    return (select(cachedCategories)
      ..where((t) => t.branchId.equals(branchId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])
    ).get();
  }

  // ===== CACHED TABLES =====

  /// Guardar mesas en cache
  Future<void> cacheTables(String branchId, List<CachedTablesCompanion> tables) async {
    await batch((batch) {
      batch.deleteWhere(cachedTables, (t) => t.branchId.equals(branchId));
      batch.insertAll(cachedTables, tables);
    });
  }

  /// Obtener mesas cacheadas
  Future<List<CachedTable>> getCachedTables(String branchId) {
    return (select(cachedTables)..where((t) => t.branchId.equals(branchId))).get();
  }

  // ===== SYNC STATUS =====

  /// Verificar si hay órdenes pendientes por sincronizar
  Future<bool> hasUnsyncedOrders() async {
    final count = countAll();
    final query = selectOnly(pendingOrders)
      ..addColumns([count])
      ..where(pendingOrders.isSynced.equals(false));
    final result = await query.getSingle();
    return (result.read(count) ?? 0) > 0;
  }

  /// Limpiar cache antiguo (más de 7 días)
  Future<void> cleanOldCache() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    await batch((batch) {
      batch.deleteWhere(cachedProducts, (t) => t.cachedAt.isSmallerThanValue(cutoff));
      batch.deleteWhere(cachedCategories, (t) => t.cachedAt.isSmallerThanValue(cutoff));
      batch.deleteWhere(cachedTables, (t) => t.cachedAt.isSmallerThanValue(cutoff));
    });
  }
}

/// Abrir conexión a la base de datos
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'greenpos.db'));
    return NativeDatabase.createInBackground(file);
  });
}
