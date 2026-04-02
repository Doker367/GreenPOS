# 🏗️ Arquitectura del Proyecto - Soft Restaurant

## Resumen Ejecutivo

Soft Restaurant está construido siguiendo los principios de **Clean Architecture**, separando claramente las responsabilidades en tres capas principales: **Presentación**, **Dominio** y **Datos**.

## 🎯 Principios de Clean Architecture

### 1. Independencia de Frameworks
- El código de negocio no depende de Flutter, Firebase u otras tecnologías externas
- Fácil de migrar a otras tecnologías o frameworks

### 2. Testeable
- La lógica de negocio puede ser testeada sin UI, base de datos o servicios externos
- Cada capa tiene sus propias pruebas

### 3. Independencia de UI
- La UI puede cambiar sin afectar el resto del sistema
- Fácil cambiar de Material Design a Cupertino o viceversa

### 4. Independencia de Base de Datos
- Puede cambiar de Firebase a SQLite, PostgreSQL, etc., sin afectar la lógica de negocio

### 5. Independencia de Servicios Externos
- La lógica de negocio no conoce servicios externos

## 📐 Estructura de Capas

```
┌─────────────────────────────────────────────┐
│           PRESENTATION LAYER                │
│  (UI, Widgets, Screens, Providers)          │
│                                             │
│  • Screens (Login, Menu, Cart, Admin)      │
│  • Widgets reutilizables                   │
│  • Providers (Riverpod StateNotifiers)     │
│  • Manejo de estado                        │
└─────────────────┬───────────────────────────┘
                  │
                  ↓ Usa
┌─────────────────────────────────────────────┐
│              DOMAIN LAYER                   │
│  (Entities, Repositories Interfaces,        │
│   Use Cases, Business Logic)                │
│                                             │
│  • Entities (User, Product, Order)         │
│  • Repository Interfaces                   │
│  • Use Cases (opcional)                    │
│  • Business Rules                          │
└─────────────────┬───────────────────────────┘
                  ↑ Implementa
┌─────────────────────────────────────────────┐
│               DATA LAYER                    │
│  (Models, Repository Implementations,       │
│   Data Sources)                             │
│                                             │
│  • Models (con JSON serialization)         │
│  • Repository Implementations              │
│  • Data Sources (Remote, Local)            │
│  • API Clients                             │
└─────────────────────────────────────────────┘
```

## 📂 Estructura Detallada del Proyecto

```
lib/
│
├── 🔧 core/                          # Código compartido
│   ├── constants/                    # Constantes globales
│   │   └── app_constants.dart        # URLs, keys, configuración
│   │
│   ├── enums/                        # Enumeraciones
│   │   ├── user_role.dart           # Roles de usuario
│   │   └── order_status.dart        # Estados de pedidos
│   │
│   ├── providers/                    # Providers de infraestructura
│   │   └── repository_providers.dart # Inyección de dependencias
│   │
│   ├── routing/                      # Navegación
│   │   └── app_router.dart          # Configuración GoRouter
│   │
│   ├── theme/                        # Diseño y temas
│   │   ├── app_theme.dart           # Temas claro/oscuro
│   │   └── theme_provider.dart      # Provider del tema
│   │
│   └── utils/                        # Utilidades
│       ├── failure.dart             # Manejo de errores
│       ├── responsive_utils.dart    # Utilidades responsivas
│       └── seed_data.dart           # Datos de ejemplo
│
├── 🎨 features/                      # Features por módulo
│   │
│   ├── 🔐 auth/                      # Autenticación
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart  # Modelo con JSON
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart        # Entidad pura
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart  # Interface
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── screens/
│   │           ├── login_screen.dart
│   │           └── register_screen.dart
│   │
│   ├── 🍔 menu/                      # Menú (Productos y Categorías)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── category_model.dart
│   │   │   │   └── product_model.dart
│   │   │   └── repositories/
│   │   │       └── menu_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── category.dart
│   │   │   │   └── product.dart
│   │   │   └── repositories/
│   │   │       └── menu_repository.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── menu_provider.dart
│   │       └── screens/
│   │           └── menu_screen.dart
│   │
│   ├── 🛒 cart/                      # Carrito de compras
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── cart_provider.dart
│   │       └── screens/
│   │           └── cart_screen.dart
│   │
│   ├── 📦 orders/                    # Gestión de pedidos
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── order_model.dart
│   │   │   └── repositories/
│   │   │       └── order_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── order.dart
│   │   │   └── repositories/
│   │   │       └── order_repository.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       └── screens/
│   │
│   └── 🪑 tables/                    # Mesas y reservas
│       ├── data/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── table.dart
│       │   └── repositories/
│       │       └── table_repository.dart
│       └── presentation/
│
└── 📱 main.dart                      # Punto de entrada
```

## 🔄 Flujo de Datos

### Ejemplo: Usuario hace login

```
┌──────────────┐
│ LoginScreen  │  1. Usuario presiona "Login"
└──────┬───────┘
       │
       ↓ 2. Llama al provider
┌──────────────┐
│ AuthNotifier │  3. Ejecuta login()
└──────┬───────┘
       │
       ↓ 4. Llama al repositorio
┌────────────────────┐
│ AuthRepository     │  5. Interface (dominio)
└──────┬─────────────┘
       │
       ↓ 6. Implementación
┌────────────────────┐
│AuthRepositoryImpl  │  7. Llama a Firebase
└──────┬─────────────┘
       │
       ↓ 8. Obtiene respuesta
┌────────────────────┐
│  Firebase Auth     │  9. Retorna usuario
└──────┬─────────────┘
       │
       ↓ 10. Convierte a entidad
┌────────────────────┐
│   UserModel        │  11. toEntity()
└──────┬─────────────┘
       │
       ↓ 12. Retorna Entity
┌────────────────────┐
│   User (Entity)    │  13. Entidad de dominio
└──────┬─────────────┘
       │
       ↓ 14. Actualiza estado
┌──────────────┐
│ AuthNotifier │  15. Notifica cambios
└──────┬───────┘
       │
       ↓ 16. UI se reconstruye
┌──────────────┐
│ LoginScreen  │  17. Navega al Home
└──────────────┘
```

## 🎭 Patrones de Diseño Utilizados

### 1. Repository Pattern
- Abstracción de la fuente de datos
- Fácil cambiar entre Firebase, REST API, SQLite, etc.

```dart
// Interface (dominio)
abstract class MenuRepository {
  Future<Either<Failure, List<Product>>> getProducts();
}

// Implementación (data)
class MenuRepositoryImpl implements MenuRepository {
  final FirebaseFirestore firestore;
  
  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    // Implementación con Firebase
  }
}
```

### 2. Provider Pattern (Riverpod)
- Inyección de dependencias
- Manejo de estado reactivo

```dart
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepositoryImpl(firestore: ref.watch(firestoreProvider));
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(menuRepositoryProvider);
  final result = await repository.getProducts();
  return result.fold((failure) => throw failure, (products) => products);
});
```

### 3. Either Pattern (Manejo de Errores)
- Manejo funcional de éxito/error
- No más try-catch anidados

```dart
Future<Either<Failure, User>> login() async {
  try {
    final user = await firebaseAuth.signIn();
    return Right(user);
  } catch (e) {
    return Left(AuthFailure(e.toString()));
  }
}
```

### 4. State Pattern
- Estados bien definidos para la UI
- Loading, Success, Error

```dart
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
}
```

## 🔐 Seguridad y Validación

### Validaciones en múltiples capas:

1. **UI Layer**: Validación inmediata
   ```dart
   validator: (value) {
     if (value == null || value.isEmpty) {
       return 'Campo requerido';
     }
   }
   ```

2. **Domain Layer**: Reglas de negocio
   ```dart
   if (product.price < 0) {
     return Left(ValidationFailure('El precio debe ser positivo'));
   }
   ```

3. **Data Layer**: Validación de esquema
   ```dart
   @JsonKey(required: true)
   final String id;
   ```

4. **Firebase Rules**: Seguridad en backend

## 📊 Gestión de Estado

### Riverpod StateNotifiers

```dart
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());
  
  void addProduct(Product product) {
    final items = Map<String, CartItem>.from(state.items);
    items[product.id] = CartItem(product: product, quantity: 1);
    state = state.copyWith(items: items);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
```

## 🧪 Testing Strategy

```
test/
├── unit/                    # Tests unitarios
│   ├── domain/              # Entidades y lógica
│   └── data/                # Models y conversiones
│
├── widget/                  # Tests de widgets
│   └── screens/
│
└── integration/             # Tests de integración
    └── auth_flow_test.dart
```

## 🚀 Ventajas de esta Arquitectura

1. ✅ **Mantenibilidad**: Código organizado y fácil de encontrar
2. ✅ **Escalabilidad**: Fácil agregar nuevas features
3. ✅ **Testeable**: Cada capa se puede testear independientemente
4. ✅ **Reutilizable**: Widgets y lógica reutilizables
5. ✅ **Colaboración**: Múltiples desarrolladores pueden trabajar en paralelo
6. ✅ **Flexibilidad**: Fácil cambiar tecnologías subyacentes

## 🔮 Próximos Pasos

- Implementar Use Cases para lógica compleja
- Agregar tests unitarios y de integración
- Implementar caché con Hive o SQLite
- Agregar sincronización offline
- Implementar analíticas

## 📚 Referencias

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)
- [Riverpod Documentation](https://riverpod.dev/)
