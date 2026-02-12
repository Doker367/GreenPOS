import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/menu_repository.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Implementación del repositorio de menú con Firebase
class MenuRepositoryImpl implements MenuRepository {
  final FirebaseFirestore _firestore;

  MenuRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // ====== CATEGORÍAS ======

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('is_active', isEqualTo: true)
          .orderBy('sort_order')
          .get();

      final categories = snapshot.docs.map((doc) {
        return CategoryModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        }).toEntity();
      }).toList();

      return Right(categories);
    } catch (e) {
      return Left(ServerFailure('Error al obtener categorías: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String id) async {
    try {
      final doc = await _firestore.collection('categories').doc(id).get();

      if (!doc.exists) {
        return const Left(ServerFailure('Categoría no encontrada'));
      }

      final category = CategoryModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      }).toEntity();

      return Right(category);
    } catch (e) {
      return Left(ServerFailure('Error al obtener categoría: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory({
    required String name,
    required String description,
    String? imageUrl,
    int sortOrder = 0,
  }) async {
    try {
      final docRef = _firestore.collection('categories').doc();

      final category = CategoryModel(
        id: docRef.id,
        name: name,
        description: description,
        imageUrl: imageUrl,
        sortOrder: sortOrder,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await docRef.set(category.toJson());

      return Right(category.toEntity());
    } catch (e) {
      return Left(ServerFailure('Error al crear categoría: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory({
    required String id,
    String? name,
    String? description,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (sortOrder != null) updateData['sort_order'] = sortOrder;
      if (isActive != null) updateData['is_active'] = isActive;

      await _firestore.collection('categories').doc(id).update(updateData);

      // Obtener categoría actualizada
      final doc = await _firestore.collection('categories').doc(id).get();
      final category = CategoryModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      }).toEntity();

      return Right(category);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar categoría: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      // Verificar si hay productos en esta categoría
      final productsSnapshot = await _firestore
          .collection('products')
          .where('category_id', isEqualTo: id)
          .limit(1)
          .get();

      if (productsSnapshot.docs.isNotEmpty) {
        return const Left(
          ValidationFailure('No se puede eliminar: hay productos en esta categoría'),
        );
      }

      await _firestore.collection('categories').doc(id).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar categoría: $e'));
    }
  }

  // ====== PRODUCTOS ======

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    String? categoryId,
    bool? isAvailable,
    bool? isFeatured,
  }) async {
    try {
      Query query = _firestore.collection('products');

      if (categoryId != null) {
        query = query.where('category_id', isEqualTo: categoryId);
      }
      if (isAvailable != null) {
        query = query.where('is_available', isEqualTo: isAvailable);
      }
      if (isFeatured != null) {
        query = query.where('is_featured', isEqualTo: isFeatured);
      }

      final snapshot = await query.get();

      final products = snapshot.docs.map((doc) {
        return ProductModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        }).toEntity();
      }).toList();

      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Error al obtener productos: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();

      if (!doc.exists) {
        return const Left(ServerFailure('Producto no encontrado'));
      }

      final product = ProductModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      }).toEntity();

      return Right(product);
    } catch (e) {
      return Left(ServerFailure('Error al obtener producto: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      // Búsqueda simple por nombre (para búsqueda avanzada usar Algolia o similar)
      final snapshot = await _firestore
          .collection('products')
          .where('is_available', isEqualTo: true)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }).toEntity())
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Error al buscar productos: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    List<String> imageUrls = const [],
    int preparationTime = 15,
  }) async {
    try {
      final docRef = _firestore.collection('products').doc();

      final product = ProductModel(
        id: docRef.id,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imageUrls: imageUrls,
        preparationTime: preparationTime,
        isAvailable: true,
        isFeatured: false,
        rating: 0.0,
        reviewCount: 0,
        allergens: const [],
        createdAt: DateTime.now(),
      );

      await docRef.set(product.toJson());

      return Right(product.toEntity());
    } catch (e) {
      return Left(ServerFailure('Error al crear producto: $e'));
    }
  }

  @override
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
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (categoryId != null) updateData['category_id'] = categoryId;
      if (imageUrls != null) updateData['image_urls'] = imageUrls;
      if (isAvailable != null) updateData['is_available'] = isAvailable;
      if (isFeatured != null) updateData['is_featured'] = isFeatured;
      if (preparationTime != null) {
        updateData['preparation_time'] = preparationTime;
      }

      await _firestore.collection('products').doc(id).update(updateData);

      final doc = await _firestore.collection('products').doc(id).get();
      final product = ProductModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      }).toEntity();

      return Right(product);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar producto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar producto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rateProduct({
    required String productId,
    required double rating,
    String? review,
  }) async {
    try {
      // Aquí implementarías la lógica de calificaciones
      // Por simplicidad, solo actualizamos el rating promedio
      final doc = await _firestore.collection('products').doc(productId).get();
      final product = ProductModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });

      final newReviewCount = product.reviewCount + 1;
      final newRating = ((product.rating * product.reviewCount) + rating) /
          newReviewCount;

      await _firestore.collection('products').doc(productId).update({
        'rating': newRating,
        'review_count': newReviewCount,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al calificar producto: $e'));
    }
  }
}
