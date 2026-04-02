import 'package:dartz/dartz.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/utils/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/menu_repository.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Implementación del repositorio de menú con GraphQL
class MenuRepositoryImpl implements MenuRepository {
  final GraphQLClient _client;
  final String branchId;

  MenuRepositoryImpl({
    required GraphQLClient client,
    required this.branchId,
  }) : _client = client;

  // ==========================================================================
  // QUERIES
  // ==========================================================================

  static const String _getCategoriesDoc = r'''
    query GetCategories($branchId: UUID!) {
      categories(branchId: $branchId) {
        id
        name
        description
        imageUrl
        sortOrder
        isActive
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _getCategoryDoc = r'''
    query GetCategory($id: UUID!) {
      category(id: $id) {
        id
        name
        description
        imageUrl
        sortOrder
        isActive
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _getProductsDoc = r'''
    query GetProducts($branchId: UUID!, $categoryId: UUID) {
      products(branchId: $branchId, categoryId: $categoryId) {
        id
        name
        description
        price
        categoryId
        categoryName
        imageUrls
        isAvailable
        isFeatured
        preparationTime
        rating
        reviewCount
        nutritionalInfo
        allergens
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _getProductDoc = r'''
    query GetProduct($id: UUID!) {
      product(id: $id) {
        id
        name
        description
        price
        categoryId
        categoryName
        imageUrls
        isAvailable
        isFeatured
        preparationTime
        rating
        reviewCount
        nutritionalInfo
        allergens
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _getFeaturedProductsDoc = r'''
    query GetFeaturedProducts($branchId: UUID!) {
      featuredProducts(branchId: $branchId) {
        id
        name
        description
        price
        categoryId
        categoryName
        imageUrls
        isAvailable
        isFeatured
        preparationTime
        rating
        reviewCount
        nutritionalInfo
        allergens
        createdAt
        updatedAt
      }
    }
  ''';

  // ==========================================================================
  // MUTATIONS
  // ==========================================================================

  static const String _createCategoryDoc = r'''
    mutation CreateCategory($input: CreateCategoryInput!) {
      createCategory(input: $input) {
        id
        name
        description
        imageUrl
        sortOrder
        isActive
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _updateCategoryDoc = r'''
    mutation UpdateCategory($id: UUID!, $name: String, $description: String, $sortOrder: Int, $isActive: Boolean) {
      updateCategory(id: $id, name: $name, description: $description, sortOrder: $sortOrder, isActive: $isActive) {
        id
        name
        description
        imageUrl
        sortOrder
        isActive
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _deleteCategoryDoc = r'''
    mutation DeleteCategory($id: UUID!) {
      deleteCategory(id: $id)
    }
  ''';

  static const String _reorderCategoriesDoc = r'''
    mutation ReorderCategories($branchId: UUID!, $categoryIds: [UUID!]!) {
      reorderCategories(branchId: $branchId, categoryIds: $categoryIds) {
        id
        name
        sortOrder
      }
    }
  ''';

  static const String _createProductDoc = r'''
    mutation CreateProduct($input: CreateProductInput!) {
      createProduct(input: $input) {
        id
        name
        description
        price
        categoryId
        categoryName
        imageUrls
        isAvailable
        isFeatured
        preparationTime
        rating
        reviewCount
        nutritionalInfo
        allergens
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _updateProductDoc = r'''
    mutation UpdateProduct($id: UUID!, $input: CreateProductInput!) {
      updateProduct(id: $id, input: $input) {
        id
        name
        description
        price
        categoryId
        categoryName
        imageUrls
        isAvailable
        isFeatured
        preparationTime
        rating
        reviewCount
        nutritionalInfo
        allergens
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _deleteProductDoc = r'''
    mutation DeleteProduct($id: UUID!) {
      deleteProduct(id: $id)
    }
  ''';

  static const String _toggleProductAvailabilityDoc = r'''
    mutation ToggleProductAvailability($id: UUID!) {
      toggleProductAvailability(id: $id) {
        id
        isAvailable
      }
    }
  ''';

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Parsea una fecha desde string ISO o timestamp
  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  /// Convierte respuesta GraphQL a CategoryModel
  CategoryModel _categoryFromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? _parseDate(json['updatedAt']) : null,
    );
  }

  /// Convierte respuesta GraphQL a ProductModel
  ProductModel _productFromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      isAvailable: json['isAvailable'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      preparationTime: json['preparationTime'] as int? ?? 15,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      nutritionalInfo: json['nutritionalInfo'] as Map<String, dynamic>?,
      allergens: (json['allergens'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: _parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? _parseDate(json['updatedAt']) : null,
    );
  }

  /// Ejecuta una query y maneja errores
  Future<QueryResult> _query(String document, {Map<String, dynamic>? variables}) async {
    final options = QueryOptions(
      document: gql(document),
      variables: variables ?? {},
      fetchPolicy: FetchPolicy.networkOnly,
    );
    return await _client.query(options);
  }

  /// Ejecuta una mutación y maneja errores
  Future<QueryResult> _mutate(String document, {Map<String, dynamic>? variables}) async {
    final options = MutationOptions(
      document: gql(document),
      variables: variables ?? {},
    );
    return await _client.mutate(options);
  }

  /// Verifica si hay errores GraphQL y retorna true si los hay
  bool _hasErrors(QueryResult result) {
    if (result.hasException) {
      return true;
    }
    return false;
  }

  /// Obtiene el mensaje de error de un QueryResult
  String _getErrorMessage(QueryResult result) {
    return result.exception?.graphqlErrors.isNotEmpty == true
        ? result.exception!.graphqlErrors.first.message
        : result.exception?.linkException?.toString() ?? 'Error desconocido';
  }

  // ==========================================================================
  // CATEGORY IMPLEMENTATIONS
  // ==========================================================================

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final result = await _query(
        _getCategoriesDoc,
        variables: {'branchId': branchId},
      );

      if (_hasErrors(result)) return Left(ServerFailure(_getErrorMessage(result)));
      

      final List<dynamic> data = result.data?['categories'] ?? [];
      final categories = data
          .map((json) => _categoryFromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      return Right(categories);
    } catch (e) {
      return Left(ServerFailure('Error al obtener categorías: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String id) async {
    try {
      final result = await _query(
        _getCategoryDoc,
        variables: {'id': id},
      );

      if (_hasErrors(result)) return Left(ServerFailure(_getErrorMessage(result)));
      

      final data = result.data?['category'];
      if (data == null) {
        return const Left(ServerFailure('Categoría no encontrada'));
      }

      return Right(_categoryFromJson(data as Map<String, dynamic>).toEntity());
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
      final input = {
        'branchId': branchId,
        'name': name,
        'description': description,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'sortOrder': sortOrder,
      };

      final result = await _mutate(
        _createCategoryDoc,
        variables: {'input': input},
      );

      if (_hasErrors(result)) return Left(ServerFailure(_getErrorMessage(result)));
      

      return Right(_categoryFromJson(result.data!['createCategory'] as Map<String, dynamic>).toEntity());
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
      final result = await _mutate(
        _updateCategoryDoc,
        variables: {
          'id': id,
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (imageUrl != null) 'imageUrl': imageUrl,
          if (sortOrder != null) 'sortOrder': sortOrder,
          if (isActive != null) 'isActive': isActive,
        },
      );

      if (_hasErrors(result)) return Left(ServerFailure(_getErrorMessage(result)));
      

      return Right(_categoryFromJson(result.data!['updateCategory'] as Map<String, dynamic>).toEntity());
    } catch (e) {
      return Left(ServerFailure('Error al actualizar categoría: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      final result = await _mutate(
        _deleteCategoryDoc,
        variables: {'id': id},
      );

      if (_hasErrors(result)) return Left(ServerFailure(_getErrorMessage(result)));
      

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar categoría: $e'));
    }
  }

  // ==========================================================================
  // PRODUCT IMPLEMENTATIONS
  // ==========================================================================

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    String? categoryId,
    bool? isAvailable,
    bool? isFeatured,
  }) async {
    try {
      final result = await _query(
        _getProductsDoc,
        variables: {
          'branchId': branchId,
          if (categoryId != null) 'categoryId': categoryId,
        },
      );

      if (_hasErrors(result)) return Left(ServerFailure(_getErrorMessage(result)));
      

      List<dynamic> data = result.data?['products'] ?? [];

      // Filtrado local si es necesario (GraphQL no soporta todos los filtros)
      var products = data
          .map((json) => _productFromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      if (isAvailable != null) {
        products = products.where((p) => p.isAvailable == isAvailable).toList();
      }
      if (isFeatured != null) {
        products = products.where((p) => p.isFeatured == isFeatured).toList();
      }

      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Error al obtener productos: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      final result = await _query(
        _getProductDoc,
        variables: {'id': id},
      );

      if (_hasErrors(result)) return Left(ServerFailure(_getErrorMessage(result)));
      

      final data = result.data?['product'];
      if (data == null) {
        return const Left(ServerFailure('Producto no encontrado'));
      }

      return Right(_productFromJson(data as Map<String, dynamic>).toEntity());
    } catch (e) {
      return Left(ServerFailure('Error al obtener producto: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      // Obtener todos los productos disponibles y filtrar localmente
      final result = await _query(
        _getProductsDoc,
        variables: {'branchId': branchId},
      );

      if (_hasErrors(result)) return Left(ServerFailure(_getErrorMessage(result)));
      

      final List<dynamic> data = result.data?['products'] ?? [];
      final lowercaseQuery = query.toLowerCase();

      final products = data
          .map((json) => _productFromJson(json as Map<String, dynamic>).toEntity())
          .where((p) =>
              p.name.toLowerCase().contains(lowercaseQuery) ||
              p.description.toLowerCase().contains(lowercaseQuery))
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
      final input = {
        'branchId': branchId,
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'imageUrls': imageUrls,
        'preparationTime': preparationTime,
      };

      final result = await _mutate(
        _createProductDoc,
        variables: {'input': input},
      );

      if (_hasErrors(result)) return Left(ServerFailure(_getErrorMessage(result)));
      

      return Right(_productFromJson(result.data!['createProduct'] as Map<String, dynamic>).toEntity());
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
      final input = <String, dynamic>{
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (categoryId != null) 'categoryId': categoryId,
        if (imageUrls != null) 'imageUrls': imageUrls,
        if (preparationTime != null) 'preparationTime': preparationTime,
      };

      final result = await _mutate(
        _updateProductDoc,
        variables: {
          'id': id,
          'input': input,
        },
      );

      if (_hasErrors(result)) return Left(ServerFailure(_getErrorMessage(result)));
      

      return Right(_productFromJson(result.data!['updateProduct'] as Map<String, dynamic>).toEntity());
    } catch (e) {
      return Left(ServerFailure('Error al actualizar producto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      final result = await _mutate(
        _deleteProductDoc,
        variables: {'id': id},
      );

      if (_hasErrors(result)) return Left(ServerFailure(_getErrorMessage(result)));
      

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
    // La mutación rateProduct no existe en el schema GraphQL proporcionado.
    // Esta implementación simplemente retorna success ya que el schema
    // no soporta calificaciones de productos.
    // Si el backend añade esta funcionalidad, agregar la mutación correspondiente.
    return const Right(null);
  }
}
