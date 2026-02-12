import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../menu/presentation/providers/menu_provider.dart';

/// Provider para el estado de búsqueda de productos
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider para productos filtrados por búsqueda
final filteredProductsProvider = Provider.family<List<dynamic>, String?>((ref, categoryId) {
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();
  final allProducts = ref.watch(productsProvider(categoryId));
  
  return allProducts.when(
    data: (products) {
      if (searchQuery.isEmpty) {
        return products;
      }
      
      return products.where((product) {
        final name = product.name.toLowerCase();
        final description = (product.description ?? '').toLowerCase();
        
        // Buscar en nombre y descripción
        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
