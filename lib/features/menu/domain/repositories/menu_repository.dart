import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/category.dart';
import '../entities/product.dart';

/// Repositorio de menú (Interfaz del dominio)
abstract class MenuRepository {
  // ====== CATEGORÍAS ======
  
  /// Obtener todas las categorías
  Future<Either<Failure, List<Category>>> getCategories();

  /// Obtener una categoría por ID
  Future<Either<Failure, Category>> getCategoryById(String id);

  /// Crear nueva categoría (Admin)
  Future<Either<Failure, Category>> createCategory({
    required String name,
    required String description,
    String? imageUrl,
    int sortOrder = 0,
  });

  /// Actualizar categoría (Admin)
  Future<Either<Failure, Category>> updateCategory({
    required String id,
    String? name,
    String? description,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
  });

  /// Eliminar categoría (Admin)
  Future<Either<Failure, void>> deleteCategory(String id);

  // ====== PRODUCTOS ======

  /// Obtener todos los productos
  Future<Either<Failure, List<Product>>> getProducts({
    String? categoryId,
    bool? isAvailable,
    bool? isFeatured,
  });

  /// Obtener un producto por ID
  Future<Either<Failure, Product>> getProductById(String id);

  /// Buscar productos por nombre
  Future<Either<Failure, List<Product>>> searchProducts(String query);

  /// Crear nuevo producto (Admin)
  Future<Either<Failure, Product>> createProduct({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    List<String> imageUrls = const [],
    int preparationTime = 15,
  });

  /// Actualizar producto (Admin)
  Future<Either<Failure, Product>> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    List<String>? imageUrls,
    bool? isAvailable,
    bool? isFeatured,
    int? preparationTime,
  });

  /// Eliminar producto (Admin)
  Future<Either<Failure, void>> deleteProduct(String id);

  /// Calificar producto
  Future<Either<Failure, void>> rateProduct({
    required String productId,
    required double rating,
    String? review,
  });
}
