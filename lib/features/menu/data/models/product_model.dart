import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

/// Modelo de datos de Producto (Data Layer)
@JsonSerializable()
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  @JsonKey(name: 'category_id')
  final String categoryId;
  @JsonKey(name: 'category_name')
  final String? categoryName;
  @JsonKey(name: 'image_urls')
  final List<String> imageUrls;
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'preparation_time')
  final int preparationTime;
  final double rating;
  @JsonKey(name: 'review_count')
  final int reviewCount;
  @JsonKey(name: 'nutritional_info')
  final Map<String, dynamic>? nutritionalInfo;
  final List<String> allergens;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.categoryName,
    this.imageUrls = const [],
    this.isAvailable = true,
    this.isFeatured = false,
    this.preparationTime = 15,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.nutritionalInfo,
    this.allergens = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
      imageUrls: product.imageUrls,
      isAvailable: product.isAvailable,
      isFeatured: product.isFeatured,
      preparationTime: product.preparationTime,
      rating: product.rating,
      reviewCount: product.reviewCount,
      nutritionalInfo: product.nutritionalInfo,
      allergens: product.allergens,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      categoryName: categoryName,
      imageUrls: imageUrls,
      isAvailable: isAvailable,
      isFeatured: isFeatured,
      preparationTime: preparationTime,
      rating: rating,
      reviewCount: reviewCount,
      nutritionalInfo: nutritionalInfo,
      allergens: allergens,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
