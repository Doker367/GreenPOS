// Pending Orders DAO
// Data Access Object for pending_orders table operations

import 'package:drift/drift.dart';
import '../app_database.dart';

part 'pending_orders_dao.g.dart';

/// DAO for pending_orders table
@DriftAccessor(tables: [PendingOrders])
class PendingOrdersDao extends DatabaseAccessor<LocalDatabase>
    with _$PendingOrdersDaoMixin {
  PendingOrdersDao(super.db);

  /// Insert a new pending order
  Future<int> insert(PendingOrdersCompanion order) {
    return into(pendingOrders).insert(order);
  }

  /// Get all unsynced orders
  Future<List<PendingOrder>> getUnsynced() {
    return (select(pendingOrders)..where((t) => t.isSynced.equals(false))).get();
  }

  /// Get all pending orders (synced and unsynced)
  Future<List<PendingOrder>> getAll() {
    return select(pendingOrders).get();
  }

  /// Get pending orders by branch
  Future<List<PendingOrder>> getByBranch(String branchId) {
    return (select(pendingOrders)
      ..where((t) => t.branchId.equals(branchId) & t.isSynced.equals(false))
    ).get();
  }

  /// Mark order as synced
  Future<int> markAsSynced(int id) {
    return (update(pendingOrders)..where((t) => t.id.equals(id))).write(
      PendingOrdersCompanion(
        isSynced: const Value(true),
        syncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark order as synced with specific time
  Future<int> markAsSyncedWithTime(int id, DateTime syncedAt) {
    return (update(pendingOrders)..where((t) => t.id.equals(id))).write(
      PendingOrdersCompanion(
        isSynced: const Value(true),
        syncedAt: Value(syncedAt),
      ),
    );
  }

  /// Delete a pending order
  Future<int> deleteById(int id) {
    return (delete(pendingOrders)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all synced orders
  Future<int> deleteSynced() {
    return (delete(pendingOrders)..where((t) => t.isSynced.equals(true))).go();
  }

  /// Delete orders older than specified date
  Future<int> deleteOlderThan(DateTime cutoff) {
    return (delete(pendingOrders)
      ..where((t) => t.createdAt.isSmallerThanValue(cutoff))
    ).go();
  }

  /// Watch unsynced orders count
  Stream<int> watchUnsyncedCount() {
    final count = countAll();
    final query = selectOnly(pendingOrders)
      ..addColumns([count])
      ..where(pendingOrders.isSynced.equals(false));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Check if there are unsynced orders
  Future<bool> hasUnsynced() async {
    final count = countAll();
    final query = selectOnly(pendingOrders)
      ..addColumns([count])
      ..where(pendingOrders.isSynced.equals(false));
    final result = await query.getSingle();
    return (result.read(count) ?? 0) > 0;
  }

  /// Update order status
  Future<int> updateStatus(int id, String status) {
    return (update(pendingOrders)..where((t) => t.id.equals(id))).write(
      PendingOrdersCompanion(status: Value(status)),
    );
  }
}
