import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/menu/domain/entities/category.dart';
import '../../features/menu/domain/entities/product.dart';
import '../../features/pos/domain/entities/discount.dart';
import '../../features/pos/domain/entities/extra_charge.dart';
import '../../features/pos/domain/entities/product_modifier_option.dart';
import '../../features/pos/domain/entities/product_modifier_group.dart';

/// Provider con datos de demostración (sin Firebase)
/// Estos datos se muestran cuando Firebase no está configurado

// Categorías de ejemplo
final mockCategoriesProvider = Provider<List<Category>>((ref) {
  return [
    Category(
      id: '1',
      name: 'Entradas',
      description: 'Deliciosos aperitivos para comenzar',
      imageUrl: null,
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: '2',
      name: 'Platos Principales',
      description: 'Nuestras especialidades',
      imageUrl: null,
      sortOrder: 2,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: '3',
      name: 'Postres',
      description: 'Dulces tentaciones',
      imageUrl: null,
      sortOrder: 3,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: '4',
      name: 'Bebidas',
      description: 'Refrescantes opciones',
      imageUrl: null,
      sortOrder: 4,
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];
});

// Productos de ejemplo
final mockProductsProvider = Provider<List<Product>>((ref) {
  return [
    // Entradas
    Product(
      id: '1',
      name: 'Ensalada César',
      description: 'Lechuga romana, crutones, parmesano y aderezo César',
      price: 45.00,
      categoryId: '1',
      categoryName: 'Entradas',
      imageUrls: [],
      isAvailable: true,
      isFeatured: true,
      preparationTime: 10,
      rating: 4.5,
      reviewCount: 24,
      allergens: ['lácteos', 'gluten'],
      createdAt: DateTime.now(),
    ),
    Product(
      id: '2',
      name: 'Alitas BBQ',
      description: '8 piezas de alitas de pollo con salsa BBQ casera',
      price: 85.00,
      categoryId: '1',
      categoryName: 'Entradas',
      imageUrls: [],
      isAvailable: true,
      isFeatured: true,
      preparationTime: 15,
      rating: 4.8,
      reviewCount: 56,
      allergens: [],
      createdAt: DateTime.now(),
    ),
    Product(
      id: '3',
      name: 'Nachos Supreme',
      description: 'Nachos con queso, guacamole, crema y jalapeños',
      price: 95.00,
      categoryId: '1',
      categoryName: 'Entradas',
      imageUrls: [],
      isAvailable: true,
      isFeatured: false,
      preparationTime: 12,
      rating: 4.3,
      reviewCount: 18,
      allergens: ['lácteos'],
      createdAt: DateTime.now(),
    ),
    
    // Platos Principales
    Product(
      id: '4',
      name: 'Hamburguesa Clásica',
      description: 'Carne de res, lechuga, tomate, queso y papas fritas',
      price: 120.00,
      categoryId: '2',
      categoryName: 'Platos Principales',
      imageUrls: [],
      isAvailable: true,
      isFeatured: true,
      preparationTime: 20,
      rating: 4.7,
      reviewCount: 89,
      allergens: ['gluten', 'lácteos'],
      createdAt: DateTime.now(),
    ),
    Product(
      id: '5',
      name: 'Pizza Margarita',
      description: 'Salsa de tomate, mozzarella fresca y albahaca',
      price: 145.00,
      categoryId: '2',
      categoryName: 'Platos Principales',
      imageUrls: [],
      isAvailable: true,
      isFeatured: true,
      preparationTime: 25,
      rating: 4.6,
      reviewCount: 67,
      allergens: ['gluten', 'lácteos'],
      createdAt: DateTime.now(),
    ),
    Product(
      id: '6',
      name: 'Pasta Alfredo',
      description: 'Fettuccine con salsa cremosa de queso parmesano',
      price: 135.00,
      categoryId: '2',
      categoryName: 'Platos Principales',
      imageUrls: [],
      isAvailable: true,
      isFeatured: false,
      preparationTime: 18,
      rating: 4.4,
      reviewCount: 43,
      allergens: ['gluten', 'lácteos'],
      createdAt: DateTime.now(),
    ),
    Product(
      id: '7',
      name: 'Tacos al Pastor',
      description: '3 tacos con carne al pastor, piña, cilantro y cebolla',
      price: 95.00,
      categoryId: '2',
      categoryName: 'Platos Principales',
      imageUrls: [],
      isAvailable: true,
      isFeatured: true,
      preparationTime: 15,
      rating: 4.9,
      reviewCount: 102,
      allergens: [],
      createdAt: DateTime.now(),
    ),
    Product(
      id: '8',
      name: 'Sushi Roll Especial',
      description: 'Rollo de atún, aguacate y queso crema empanizado',
      price: 165.00,
      categoryId: '2',
      categoryName: 'Platos Principales',
      imageUrls: [],
      isAvailable: true,
      isFeatured: false,
      preparationTime: 20,
      rating: 4.8,
      reviewCount: 34,
      allergens: ['pescado', 'lácteos'],
      createdAt: DateTime.now(),
    ),
    
    // Postres
    Product(
      id: '9',
      name: 'Cheesecake',
      description: 'Pay de queso con base de galleta y frutos rojos',
      price: 65.00,
      categoryId: '3',
      categoryName: 'Postres',
      imageUrls: [],
      isAvailable: true,
      isFeatured: true,
      preparationTime: 5,
      rating: 4.7,
      reviewCount: 78,
      allergens: ['lácteos', 'gluten', 'huevo'],
      createdAt: DateTime.now(),
    ),
    Product(
      id: '10',
      name: 'Brownie con Helado',
      description: 'Brownie de chocolate caliente con helado de vainilla',
      price: 55.00,
      categoryId: '3',
      categoryName: 'Postres',
      imageUrls: [],
      isAvailable: true,
      isFeatured: false,
      preparationTime: 8,
      rating: 4.6,
      reviewCount: 45,
      allergens: ['lácteos', 'gluten', 'huevo'],
      createdAt: DateTime.now(),
    ),
    Product(
      id: '11',
      name: 'Flan Napolitano',
      description: 'Flan casero con caramelo',
      price: 45.00,
      categoryId: '3',
      categoryName: 'Postres',
      imageUrls: [],
      isAvailable: true,
      isFeatured: false,
      preparationTime: 5,
      rating: 4.5,
      reviewCount: 56,
      allergens: ['lácteos', 'huevo'],
      createdAt: DateTime.now(),
    ),
    
    // Bebidas
    Product(
      id: '12',
      name: 'Limonada Natural',
      description: 'Limonada fresca hecha al momento',
      price: 35.00,
      categoryId: '4',
      categoryName: 'Bebidas',
      imageUrls: [],
      isAvailable: true,
      isFeatured: false,
      preparationTime: 5,
      rating: 4.4,
      reviewCount: 34,
      allergens: [],
      createdAt: DateTime.now(),
    ),
    Product(
      id: '13',
      name: 'Smoothie de Frutos Rojos',
      description: 'Mezcla de fresas, frambuesas y arándanos',
      price: 55.00,
      categoryId: '4',
      categoryName: 'Bebidas',
      imageUrls: [],
      isAvailable: true,
      isFeatured: true,
      preparationTime: 5,
      rating: 4.7,
      reviewCount: 67,
      allergens: [],
      createdAt: DateTime.now(),
    ),
    Product(
      id: '14',
      name: 'Café Americano',
      description: 'Café de grano selecto',
      price: 30.00,
      categoryId: '4',
      categoryName: 'Bebidas',
      imageUrls: [],
      isAvailable: true,
      isFeatured: false,
      preparationTime: 3,
      rating: 4.3,
      reviewCount: 89,
      allergens: [],
      createdAt: DateTime.now(),
    ),
    Product(
      id: '15',
      name: 'Té Helado',
      description: 'Té negro frío con limón y hierbabuena',
      price: 35.00,
      categoryId: '4',
      categoryName: 'Bebidas',
      imageUrls: [],
      isAvailable: true,
      isFeatured: false,
      preparationTime: 3,
      rating: 4.2,
      reviewCount: 23,
      allergens: [],
      createdAt: DateTime.now(),
    ),
  ];
});

// Productos filtrados por categoría
final mockProductsByCategoryProvider = Provider.family<List<Product>, String?>((ref, categoryId) {
  final allProducts = ref.watch(mockProductsProvider);
  
  if (categoryId == null) {
    return allProducts;
  }
  
  return allProducts.where((p) => p.categoryId == categoryId).toList();
});

// Productos destacados
final mockFeaturedProductsProvider = Provider<List<Product>>((ref) {
  final allProducts = ref.watch(mockProductsProvider);
  return allProducts.where((p) => p.isFeatured).toList();
});

// Descuentos disponibles
final mockDiscountsProvider = Provider<List<Discount>>((ref) {
  return [
    Discount(
      id: 'disc1',
      name: 'Descuento Empleado',
      type: DiscountType.percentage,
      value: 10,
      description: 'Descuento para personal',
      requiresAuthorization: false,
    ),
    Discount(
      id: 'disc2',
      name: 'Cumpleañero',
      type: DiscountType.percentage,
      value: 15,
      description: 'Descuento especial de cumpleaños',
      requiresAuthorization: false,
    ),
    Discount(
      id: 'disc3',
      name: 'Happy Hour',
      type: DiscountType.percentage,
      value: 20,
      description: 'Descuento de 3pm a 6pm',
      requiresAuthorization: false,
    ),
    Discount(
      id: 'disc4',
      name: 'Gerente',
      type: DiscountType.percentage,
      value: 30,
      description: 'Descuento autorizado por gerente',
      requiresAuthorization: true,
    ),
    Discount(
      id: 'disc5',
      name: '\$50 de Descuento',
      type: DiscountType.fixed,
      value: 50,
      description: 'Descuento fijo de \$50',
      requiresAuthorization: false,
    ),
  ];
});

// Grupos de modificadores para productos
final mockModifierGroupsProvider = Provider.family<List<ProductModifierGroup>, String>((ref, productId) {
  // Modificadores comunes para carnes
  if (['prod2', 'prod6'].contains(productId)) {
    return [
      ProductModifierGroup(
        id: 'mod_group_1',
        name: 'Término de cocción',
        isRequired: true,
        allowMultiple: false,
        options: [
          const ProductModifierOption(
            id: 'term_blue',
            name: 'Azul',
            priceAdjustment: 0,
          ),
          const ProductModifierOption(
            id: 'term_rare',
            name: 'Inglés',
            priceAdjustment: 0,
          ),
          const ProductModifierOption(
            id: 'term_medium',
            name: 'Término medio',
            priceAdjustment: 0,
            isDefault: true,
          ),
          const ProductModifierOption(
            id: 'term_done',
            name: 'Bien cocido',
            priceAdjustment: 0,
          ),
        ],
      ),
      ProductModifierGroup(
        id: 'mod_group_2',
        name: 'Guarniciones',
        isRequired: false,
        allowMultiple: true,
        maxSelections: 2,
        options: [
          const ProductModifierOption(
            id: 'side_fries',
            name: 'Papas fritas',
            priceAdjustment: 25,
          ),
          const ProductModifierOption(
            id: 'side_salad',
            name: 'Ensalada',
            priceAdjustment: 20,
          ),
          const ProductModifierOption(
            id: 'side_rice',
            name: 'Arroz',
            priceAdjustment: 15,
          ),
          const ProductModifierOption(
            id: 'side_veggies',
            name: 'Vegetales asados',
            priceAdjustment: 30,
          ),
        ],
      ),
    ];
  }
  
  // Modificadores para bebidas
  if (['prod13', 'prod14', 'prod15'].contains(productId)) {
    return [
      ProductModifierGroup(
        id: 'mod_group_3',
        name: 'Tamaño',
        isRequired: true,
        allowMultiple: false,
        options: [
          const ProductModifierOption(
            id: 'size_small',
            name: 'Chico',
            priceAdjustment: 0,
          ),
          const ProductModifierOption(
            id: 'size_medium',
            name: 'Mediano',
            priceAdjustment: 10,
            isDefault: true,
          ),
          const ProductModifierOption(
            id: 'size_large',
            name: 'Grande',
            priceAdjustment: 20,
          ),
        ],
      ),
      ProductModifierGroup(
        id: 'mod_group_4',
        name: 'Extras',
        isRequired: false,
        allowMultiple: true,
        options: [
          const ProductModifierOption(
            id: 'extra_ice',
            name: 'Extra hielo',
            priceAdjustment: 0,
          ),
          const ProductModifierOption(
            id: 'extra_lemon',
            name: 'Limón',
            priceAdjustment: 3,
          ),
          const ProductModifierOption(
            id: 'no_ice',
            name: 'Sin hielo',
            priceAdjustment: 0,
          ),
        ],
      ),
    ];
  }
  
  return [];
});

// Cargos extras disponibles
final mockExtraChargesProvider = Provider<List<ExtraCharge>>((ref) {
  return [
    ExtraCharge(
      id: 'extra1',
      name: 'Vaso Roto',
      type: ExtraChargeType.fixed,
      value: 25,
      description: 'Cargo por vaso roto',
      requiresAuthorization: false,
    ),
    ExtraCharge(
      id: 'extra2',
      name: 'Plato Roto',
      type: ExtraChargeType.fixed,
      value: 50,
      description: 'Cargo por plato roto',
      requiresAuthorization: false,
    ),
    ExtraCharge(
      id: 'extra3',
      name: 'Extra Grande',
      type: ExtraChargeType.fixed,
      value: 30,
      description: 'Cargo por porción extra grande',
      requiresAuthorization: false,
    ),
    ExtraCharge(
      id: 'extra4',
      name: 'Propina Sugerida (10%)',
      type: ExtraChargeType.percentage,
      value: 10,
      description: 'Propina sugerida del 10%',
      requiresAuthorization: false,
    ),
    ExtraCharge(
      id: 'extra5',
      name: 'Propina Sugerida (15%)',
      type: ExtraChargeType.percentage,
      value: 15,
      description: 'Propina sugerida del 15%',
      requiresAuthorization: false,
    ),
    ExtraCharge(
      id: 'extra6',
      name: 'Cargo por Servicio',
      type: ExtraChargeType.percentage,
      value: 5,
      description: 'Cargo por servicio del 5%',
      requiresAuthorization: true,
    ),
    ExtraCharge(
      id: 'extra7',
      name: 'Cubiertos Desechables',
      type: ExtraChargeType.fixed,
      value: 15,
      description: 'Cargo por cubiertos desechables',
      requiresAuthorization: false,
    ),
  ];
});
