# 🍽️ Soft Restaurant - Sistema Completo de Gestión de Restaurante

Sistema completo de gestión para restaurantes desarrollado con **Flutter** y **Clean Architecture**, similar a Odoo Restaurant. Incluye funcionalidades para clientes y administradores, con diseño responsivo para móviles y tablets.

> **✅ Estado del Proyecto**: Aplicación corriendo exitosamente en Linux
> 
> **Últimas correcciones aplicadas**:
> - ✅ Rutas de importación corregidas (`repository_providers.dart`)
> - ✅ Archivos de código generados con `build_runner`
> - ✅ Compatibilidad de dependencias ajustada
> - ✅ Configuración de assets optimizada
> 
> **Nota**: Firebase debe ser configurado para funcionalidad completa (ver instrucciones abajo)

## ✨ Características Principales

### Para Clientes 🧑‍🍳
- ✅ Registro y login de usuarios
- ✅ Visualización de menú por categorías con fotos
- ✅ Carrito de compras en tiempo real
- ✅ Historial de pedidos y seguimiento
- 🔄 Sistema de calificaciones (en desarrollo)
- 🔄 Notificaciones push (en desarrollo)

### Para Administradores 👨‍💼
- ✅ Panel de administración
- ✅ CRUD completo de productos y categorías
- ✅ Gestión de pedidos (estados: pendiente, aceptado, preparando, listo, entregado, cancelado)
- ✅ Gestión de mesas y reservas
- ✅ Gestión de empleados y roles de usuario
- 🔄 Reportes y estadísticas (en desarrollo)

### Tecnología 🚀
- **Framework**: Flutter 3.0+
- **Arquitectura**: Clean Architecture (Domain, Data, Presentation)
- **Estado**: Riverpod 2.4+
- **Navegación**: GoRouter 13.0+
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Base de datos local**: SQLite (soporte offline)
- **UI/UX**: Material Design 3, responsive design
- **Temas**: Claro y oscuro

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/           # Constantes globales
│   ├── enums/              # Enumeraciones (roles, estados, etc.)
│   ├── providers/          # Providers de infraestructura
│   ├── routing/            # Configuración de rutas
│   ├── theme/              # Temas y estilos
│   └── utils/              # Utilidades (failures, responsive, etc.)
│
├── features/
│   ├── auth/               # Autenticación
│   │   ├── data/           # Models, repositories impl
│   │   ├── domain/         # Entities, repositories interface
│   │   └── presentation/   # Screens, providers
│   │
│   ├── menu/               # Menú (productos y categorías)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── cart/               # Carrito de compras
│   │   └── presentation/
│   │
│   ├── orders/             # Gestión de pedidos
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── tables/             # Mesas y reservas
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart               # Punto de entrada
```

## 🚀 Instalación y Configuración

### Prerrequisitos

1. **Flutter SDK** >= 3.0.0
   ```bash
   flutter --version
   ```

2. **Firebase CLI** (para configurar Firebase)
   ```bash
   npm install -g firebase-tools
   ```

3. **Editor recomendado**: VS Code o Android Studio

### Paso 1: Clonar o usar el proyecto

```bash
cd /home/doker/Descargas/Soft-restaurant
```

### Paso 2: Instalar dependencias

```bash
flutter pub get
```

### Paso 3: Configurar Firebase

⚠️ **IMPORTANTE**: El proyecto usa Firebase para autenticación y base de datos.

1. **Crear proyecto en Firebase Console**:
   - Ve a [Firebase Console](https://console.firebase.google.com/)
   - Crea un nuevo proyecto
   - Habilita Authentication (Email/Password)
   - Crea una base de datos Firestore

2. **Configurar Firebase en Flutter**:

   ```bash
   # Instalar FlutterFire CLI
   dart pub global activate flutterfire_cli

   # Configurar Firebase (sigue las instrucciones)
   flutterfire configure
   ```

   Esto creará los archivos `firebase_options.dart` automáticamente.

3. **Reglas de Firestore** (Firebase Console → Firestore → Rules):

   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users
       match /users/{userId} {
         allow read: if request.auth != null;
         allow write: if request.auth.uid == userId;
       }
       
       // Categories
       match /categories/{categoryId} {
         allow read: if true;
         allow write: if request.auth != null && 
                        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
       }
       
       // Products
       match /products/{productId} {
         allow read: if true;
         allow write: if request.auth != null && 
                        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
       }
       
       // Orders
       match /orders/{orderId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update: if request.auth != null;
       }
       
       // Tables
       match /tables/{tableId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && 
                        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'waiter'];
       }
     }
   }
   ```

### Paso 4: Generar código (json_serializable)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Paso 5: Ejecutar la aplicación

```bash
# En modo debug
flutter run

# En modo release (Android)
flutter run --release

# Para web
flutter run -d chrome
```

## 🔐 Usuarios de Prueba

Una vez configurado Firebase, crea estos usuarios manualmente en Firebase Authentication:

### Cliente:
- Email: `cliente@test.com`
- Contraseña: `123456`
- Rol: customer (agregar en Firestore)

### Administrador:
- Email: `admin@test.com`
- Contraseña: `123456`
- Rol: admin (agregar en Firestore)

**Estructura en Firestore para usuarios**:
```json
{
  "users": {
    "uid": {
      "email": "admin@test.com",
      "name": "Administrador",
      "role": "admin",
      "is_active": true,
      "created_at": "timestamp"
    }
  }
}
```

## 📱 Datos de Ejemplo (Firestore)

### Categorías:
```json
{
  "categories": {
    "cat1": {
      "name": "Entradas",
      "description": "Deliciosas entradas para comenzar",
      "sort_order": 1,
      "is_active": true,
      "created_at": "timestamp"
    },
    "cat2": {
      "name": "Platos Fuertes",
      "description": "Nuestras especialidades",
      "sort_order": 2,
      "is_active": true,
      "created_at": "timestamp"
    }
  }
}
```

### Productos:
```json
{
  "products": {
    "prod1": {
      "name": "Tacos al Pastor",
      "description": "3 tacos con carne al pastor, cebolla y cilantro",
      "price": 85.00,
      "category_id": "cat2",
      "image_urls": ["https://ejemplo.com/imagen.jpg"],
      "is_available": true,
      "is_featured": true,
      "preparation_time": 15,
      "rating": 4.8,
      "review_count": 127,
      "allergens": [],
      "created_at": "timestamp"
    }
  }
}
```

## 🎨 Personalización

### Cambiar colores del tema

Edita [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart):

```dart
class AppColors {
  static const Color primary = Color(0xFFFF6B35); // Tu color primario
  static const Color secondary = Color(0xFF004E89); // Tu color secundario
  // ... más colores
}
```

### Modificar breakpoints responsivos

Edita [lib/core/utils/responsive_utils.dart](lib/core/utils/responsive_utils.dart):

```dart
static const double mobileBreakpoint = 600;
static const double tabletBreakpoint = 900;
static const double desktopBreakpoint = 1200;
```

## 🧪 Testing

```bash
# Ejecutar tests unitarios
flutter test

# Ejecutar tests con cobertura
flutter test --coverage
```

## 📦 Build para Producción

### Android APK:
```bash
flutter build apk --release
```

### Android App Bundle (para Play Store):
```bash
flutter build appbundle --release
```

### iOS:
```bash
flutter build ios --release
```

### Web:
```bash
flutter build web --release
```

## 🔄 Próximas Funcionalidades

- [ ] Sistema de notificaciones push
- [ ] Integración con Google Maps para delivery
- [ ] Soporte offline completo con sincronización
- [ ] Sistema de cupones y descuentos
- [ ] Reportes avanzados con gráficas
- [ ] Chat en vivo con el restaurante
- [ ] Múltiples métodos de pago (Stripe, PayPal)
- [ ] Sistema de fidelización de clientes
- [ ] Panel de cocina en tiempo real
- [ ] Impresión de tickets y comandas

## 🛠️ Solución de Problemas

### Error: Firebase no inicializado
```
Ejecuta: flutterfire configure
```

### Error: build_runner
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Error: dependencias
```bash
flutter clean
flutter pub get
```

### Error: compilación Android
```bash
cd android
./gradlew clean
cd ..
flutter run
```

## 📚 Recursos Adicionales

- [Documentación Flutter](https://flutter.dev/docs)
- [Firebase para Flutter](https://firebase.google.com/docs/flutter/setup)
- [Riverpod](https://riverpod.dev/)
- [GoRouter](https://pub.dev/packages/go_router)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 🤝 Contribuciones

Este es un proyecto de demostración. Si deseas contribuir:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 👨‍💻 Autor

Desarrollado con ❤️ usando Flutter y Clean Architecture

---

**¡Disfruta construyendo tu sistema de restaurante! 🎉**
