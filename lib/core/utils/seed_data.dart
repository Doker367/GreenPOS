import 'package:cloud_firestore/cloud_firestore.dart';

/// Script para poblar la base de datos con datos de ejemplo
/// ADVERTENCIA: Este script debe ejecutarse solo una vez y con cuidado
class SeedData {
  final FirebaseFirestore _firestore;

  SeedData(this._firestore);

  /// Ejecutar seed completo
  Future<void> seedAll() async {
    print('🌱 Iniciando seed de datos...');
    
    await seedCategories();
    await seedProducts();
    await seedTables();
    
    print('✅ Seed completado exitosamente');
  }

  /// Crear categorías de ejemplo
  Future<void> seedCategories() async {
    print('📁 Creando categorías...');

    final categories = [
      {
        'name': 'Entradas',
        'description': 'Deliciosas entradas para comenzar tu comida',
        'sort_order': 1,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Platos Fuertes',
        'description': 'Nuestras especialidades de la casa',
        'sort_order': 2,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Bebidas',
        'description': 'Refrescantes bebidas y cocteles',
        'sort_order': 3,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Postres',
        'description': 'Dulces y deliciosos postres',
        'sort_order': 4,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Desayunos',
        'description': 'Comienza tu día con energía',
        'sort_order': 0,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
    ];

    for (var category in categories) {
      await _firestore.collection('categories').add(category);
    }

    print('✅ ${categories.length} categorías creadas');
  }

  /// Crear productos de ejemplo
  Future<void> seedProducts() async {
    print('🍔 Creando productos...');

    // Obtener IDs de categorías
    final categoriesSnapshot = await _firestore.collection('categories').get();
    final categoryMap = <String, String>{};
    
    for (var doc in categoriesSnapshot.docs) {
      categoryMap[doc.data()['name']] = doc.id;
    }

    final products = [
      // Entradas
      {
        'name': 'Nachos con Queso',
        'description': 'Crujientes totopos con queso fundido, jalapeños y pico de gallo',
        'price': 95.00,
        'category_id': categoryMap['Entradas'],
        'image_urls': [],
        'is_available': true,
        'is_featured': true,
        'preparation_time': 10,
        'rating': 4.5,
        'review_count': 45,
        'allergens': ['lácteos'],
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Alitas BBQ',
        'description': '10 alitas de pollo con salsa barbecue y aderezo ranch',
        'price': 135.00,
        'category_id': categoryMap['Entradas'],
        'image_urls': [],
        'is_available': true,
        'is_featured': false,
        'preparation_time': 15,
        'rating': 4.7,
        'review_count': 89,
        'allergens': [],
        'created_at': FieldValue.serverTimestamp(),
      },

      // Platos Fuertes
      {
        'name': 'Hamburguesa Clásica',
        'description': 'Carne de res, lechuga, tomate, cebolla, pepinillos y queso',
        'price': 145.00,
        'category_id': categoryMap['Platos Fuertes'],
        'image_urls': [],
        'is_available': true,
        'is_featured': true,
        'preparation_time': 20,
        'rating': 4.8,
        'review_count': 234,
        'allergens': ['gluten', 'lácteos'],
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Tacos al Pastor',
        'description': '3 tacos de cerdo marinado con piña, cebolla y cilantro',
        'price': 85.00,
        'category_id': categoryMap['Platos Fuertes'],
        'image_urls': [],
        'is_available': true,
        'is_featured': true,
        'preparation_time': 15,
        'rating': 4.9,
        'review_count': 567,
        'allergens': ['gluten'],
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Pizza Margarita',
        'description': 'Salsa de tomate, mozzarella fresca y albahaca',
        'price': 165.00,
        'category_id': categoryMap['Platos Fuertes'],
        'image_urls': [],
        'is_available': true,
        'is_featured': false,
        'preparation_time': 25,
        'rating': 4.6,
        'review_count': 123,
        'allergens': ['gluten', 'lácteos'],
        'created_at': FieldValue.serverTimestamp(),
      },

      // Bebidas
      {
        'name': 'Limonada Natural',
        'description': 'Refrescante limonada recién preparada',
        'price': 35.00,
        'category_id': categoryMap['Bebidas'],
        'image_urls': [],
        'is_available': true,
        'is_featured': false,
        'preparation_time': 5,
        'rating': 4.4,
        'review_count': 78,
        'allergens': [],
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Café Americano',
        'description': 'Café espresso con agua caliente',
        'price': 40.00,
        'category_id': categoryMap['Bebidas'],
        'image_urls': [],
        'is_available': true,
        'is_featured': false,
        'preparation_time': 5,
        'rating': 4.3,
        'review_count': 156,
        'allergens': [],
        'created_at': FieldValue.serverTimestamp(),
      },

      // Postres
      {
        'name': 'Brownie con Helado',
        'description': 'Brownie de chocolate caliente con helado de vainilla',
        'price': 75.00,
        'category_id': categoryMap['Postres'],
        'image_urls': [],
        'is_available': true,
        'is_featured': true,
        'preparation_time': 10,
        'rating': 4.9,
        'review_count': 345,
        'allergens': ['gluten', 'lácteos', 'huevo'],
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Cheesecake',
        'description': 'Suave pastel de queso con base de galleta',
        'price': 85.00,
        'category_id': categoryMap['Postres'],
        'image_urls': [],
        'is_available': true,
        'is_featured': false,
        'preparation_time': 5,
        'rating': 4.7,
        'review_count': 198,
        'allergens': ['gluten', 'lácteos', 'huevo'],
        'created_at': FieldValue.serverTimestamp(),
      },

      // Desayunos
      {
        'name': 'Huevos Rancheros',
        'description': 'Huevos estrellados sobre tortilla con salsa ranchera',
        'price': 75.00,
        'category_id': categoryMap['Desayunos'],
        'image_urls': [],
        'is_available': true,
        'is_featured': true,
        'preparation_time': 15,
        'rating': 4.6,
        'review_count': 89,
        'allergens': ['huevo', 'gluten'],
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Chilaquiles Verdes',
        'description': 'Totopos bañados en salsa verde con crema y queso',
        'price': 85.00,
        'category_id': categoryMap['Desayunos'],
        'image_urls': [],
        'is_available': true,
        'is_featured': false,
        'preparation_time': 15,
        'rating': 4.8,
        'review_count': 156,
        'allergens': ['gluten', 'lácteos'],
        'created_at': FieldValue.serverTimestamp(),
      },
    ];

    for (var product in products) {
      await _firestore.collection('products').add(product);
    }

    print('✅ ${products.length} productos creados');
  }

  /// Crear mesas de ejemplo
  Future<void> seedTables() async {
    print('🪑 Creando mesas...');

    final tables = List.generate(
      15,
      (index) => {
        'number': '${index + 1}',
        'capacity': (index % 3 == 0) ? 2 : (index % 3 == 1) ? 4 : 6,
        'status': 'available',
        'created_at': FieldValue.serverTimestamp(),
      },
    );

    for (var table in tables) {
      await _firestore.collection('tables').add(table);
    }

    print('✅ ${tables.length} mesas creadas');
  }
}

/// Función para ejecutar desde main (solo desarrollo)
/// NO ejecutar en producción
Future<void> runSeedData(FirebaseFirestore firestore) async {
  final seeder = SeedData(firestore);
  await seeder.seedAll();
}
