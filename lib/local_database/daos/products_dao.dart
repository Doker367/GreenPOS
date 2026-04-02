// Products DAO
// Data Access Object for cached_products table operations

import 'package:drift/drift.dart';
import '../app_database.dart';

part 'products_dao.g.dart';

/// DAO for cached_products table
@DriftAccessor(tables: [CachedProducts])
class ProductsDao extends DatabaseAccessor<LocalDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.db);

  /// Cache products for a branch (replaces all existing)
  Future<void> cacheProducts(String branchId, List<CachedProductsCompanion> products) async {
    await batch((batch) {
      batch.deleteWhere(cachedProducts, (t) => t.branchId.equals(branchId));
      batch.insertAll(cachedProducts, products);
    });
  }

  /// Insert or replace products
  Future<void> upsertProducts(String branchId, List<CachedProductsCompanion> products) async {
    await batch((batch) {
      for (final product in products) {
        batch.insert(
          cachedProducts,
          product,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// Get all cached products for a branch
  Future<List<CachedProduct>> getByBranch(String branchId) {
    return (select(cachedProducts)
      ..where((t) => t.branchId.equals(branchId))
    ).get();
  }

  /// Get products by category
  Future<List<CachedProduct>> getByCategory(String branchId, String categoryId) {
    return (select(cachedProducts)
      ..where((t) => t.branchId.equals(branchId) & t.categoryId.equals(categoryId))
    ).get();
  }

  /// Get available products only
  Future<List<CachedProduct>> getAvailable(String branchId) {
    return (select(cachedProducts)
      ..where((t) => t.branchId.equals(branchId) & t.isAvailable.equals(true))
    ).get();
  }

  /// Get featured products
  Future<List<CachedProduct>> getFeatured(String branchId) {
    return (select(cachedProducts)
      ..where((t) => t.branchId.equals(branchId) & t.isFeatured.equals(true))
    ).get();
  }

  /// Get a single product by id and branch
  Future<CachedProduct?> getById(String id, String branchId) {
    return (select(cachedProducts)
      ..where((t) => t.id.equals(id) & t.branchId.equals(branchId))
    ).getSingleOrNull();
  }

  /// Search products by name
  Future<List<CachedProduct>> search(String branchId, String query) {
    return (select(cachedProducts)
      ..where((t) =>
          t.branchId.equals(branchId) &
          t.name.lower().like('%${query.toLowerCase()}%'))
    ).get();
  }

  /// Delete products older than cache date
  Future<int> deleteOldCache(DateTime cutoff) {
    return (delete(cachedProducts)
      ..where((t) => t.cachedAt.isSmallerThanValue(cutoff))
    ).go();
  }

  /// Update product availability
  Future<int> updateAvailability(String id, String branchId, bool isAvailable) {
    return (update(cachedProducts)
      ..where((t) => t.id.equals(id) & t.branchId.equals(branchId))
    ).write(
      CachedProductsCompanion(isAvailable: Value(isAvailable)),
    );
  }

  /// Watch products count for branch
  Stream<int> watchCount(String branchId) {
    final count = countAll();
    final query = selectOnly(cachedProducts)
      ..addColumns([count])
      ..where(cachedProducts.branchId.equals(branchId));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Check if cache exists for branch
  Future<bool> hasCache(String branchId) async {
    final count = countAll();
    final query = selectOnly(cachedProducts)
      ..addColumns([count])
      ..where(cachedProducts.branchId.equals(branchId));
    final result = await query.getSingle();
    return (result.read(count) ?? 0) > 0;
  }
}
