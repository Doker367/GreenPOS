// Categories DAO
// Data Access Object for cached_categories table operations

import 'package:drift/drift.dart';
import '../app_database.dart';

part 'categories_dao.g.dart';

/// DAO for cached_categories table
@DriftAccessor(tables: [CachedCategories])
class CategoriesDao extends DatabaseAccessor<LocalDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  /// Cache categories for a branch (replaces all existing)
  Future<void> cacheCategories(String branchId, List<CachedCategoriesCompanion> categories) async {
    await batch((batch) {
      batch.deleteWhere(cachedCategories, (t) => t.branchId.equals(branchId));
      batch.insertAll(cachedCategories, categories);
    });
  }

  /// Get all cached categories for a branch, ordered by sortOrder
  Future<List<CachedCategory>> getByBranch(String branchId) {
    return (select(cachedCategories)
      ..where((t) => t.branchId.equals(branchId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])
    ).get();
  }

  /// Get active categories only
  Future<List<CachedCategory>> getActive(String branchId) {
    return (select(cachedCategories)
      ..where((t) => t.branchId.equals(branchId) & t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])
    ).get();
  }

  /// Get a single category by id and branch
  Future<CachedCategory?> getById(String id, String branchId) {
    return (select(cachedCategories)
      ..where((t) => t.id.equals(id) & t.branchId.equals(branchId))
    ).getSingleOrNull();
  }

  /// Delete categories older than cache date
  Future<int> deleteOldCache(DateTime cutoff) {
    return (delete(cachedCategories)
      ..where((t) => t.cachedAt.isSmallerThanValue(cutoff))
    ).go();
  }

  /// Update category active status
  Future<int> updateActive(String id, String branchId, bool isActive) {
    return (update(cachedCategories)
      ..where((t) => t.id.equals(id) & t.branchId.equals(branchId))
    ).write(
      CachedCategoriesCompanion(isActive: Value(isActive)),
    );
  }

  /// Watch categories count for branch
  Stream<int> watchCount(String branchId) {
    final count = countAll();
    final query = selectOnly(cachedCategories)
      ..addColumns([count])
      ..where(cachedCategories.branchId.equals(branchId));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Check if cache exists for branch
  Future<bool> hasCache(String branchId) async {
    final count = countAll();
    final query = selectOnly(cachedCategories)
      ..addColumns([count])
      ..where(cachedCategories.branchId.equals(branchId));
    final result = await query.getSingle();
    return (result.read(count) ?? 0) > 0;
  }
}
