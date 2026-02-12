import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/mock_data_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

/// Provider de categorías (usa datos mock en modo demo)
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  // Simula un pequeño delay como si viniera de la red
  await Future.delayed(const Duration(milliseconds: 500));
  return ref.watch(mockCategoriesProvider);
});

/// Provider de productos (usa datos mock en modo demo)
final productsProvider = FutureProvider.family<List<Product>, String?>(
  (ref, categoryId) async {
    // Simula un pequeño delay como si viniera de la red
    await Future.delayed(const Duration(milliseconds: 300));
    return ref.watch(mockProductsByCategoryProvider(categoryId));
  },
);

/// Provider de productos destacados (usa datos mock en modo demo)
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  // Simula un pequeño delay como si viniera de la red
  await Future.delayed(const Duration(milliseconds: 400));
  return ref.watch(mockFeaturedProductsProvider);
});

/// Provider de producto por ID
final productByIdProvider = FutureProvider.family<Product, String>(
  (ref, productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final allProducts = ref.watch(mockProductsProvider);
    return allProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Producto no encontrado'),
    );
  },
);

/// Provider de búsqueda de productos
final searchProductsProvider = FutureProvider.family<List<Product>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    
    await Future.delayed(const Duration(milliseconds: 300));
    final allProducts = ref.watch(mockProductsProvider);
    
    final lowercaseQuery = query.toLowerCase();
    return allProducts.where((p) {
      return p.name.toLowerCase().contains(lowercaseQuery) ||
          p.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  },
);
