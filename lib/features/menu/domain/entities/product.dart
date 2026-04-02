import 'package:equatable/equatable.dart';

/// Entidad de Producto/Platillo (Dominio)
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String? categoryName;
  final List<String> imageUrls;
  final bool isAvailable;
  final bool isFeatured;
  final int preparationTime; // en minutos
  final double rating;
  final int reviewCount;
  final Map<String, dynamic>? nutritionalInfo;
  final List<String> allergens;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
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

  /// URL de la primera imagen o null
  String? get mainImageUrl =>
      imageUrls.isNotEmpty ? imageUrls.first : null;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    String? categoryName,
    List<String>? imageUrls,
    bool? isAvailable,
    bool? isFeatured,
    int? preparationTime,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? nutritionalInfo,
    List<String>? allergens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrls: imageUrls ?? this.imageUrls,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      preparationTime: preparationTime ?? this.preparationTime,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      allergens: allergens ?? this.allergens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        categoryId,
        categoryName,
        imageUrls,
        isAvailable,
        isFeatured,
        preparationTime,
        rating,
        reviewCount,
        nutritionalInfo,
        allergens,
        createdAt,
        updatedAt,
      ];
}
