# 🎯 Guía de Inicio Rápido Visual

## 🚀 Comenzar en 5 Pasos

### Paso 1: Verificar Instalación
```bash
flutter doctor
```
**Debe mostrar:**
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain
[✓] Chrome - develop for the web
```

---

### Paso 2: Instalar Dependencias
```bash
cd /home/doker/Descargas/Soft-restaurant
flutter pub get
```
**Salida esperada:**
```
Running "flutter pub get" in soft_restaurant...
Resolving dependencies... (X.Xs)
+ cloud_firestore 4.13.6
+ firebase_auth 4.15.3
+ flutter_riverpod 2.4.9
+ go_router 13.0.0
...
Got dependencies!
```

---

### Paso 3: Generar Código
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
**Esto generará:**
```
[INFO] Generating build script...
[INFO] Generating build script completed
[INFO] Creating build script snapshot...
[INFO] Creating build script snapshot completed
[INFO] Building new asset graph...
[INFO] Building new asset graph completed
...
[INFO] Succeeded after X.Xs
```

---

### Paso 4: Configurar Firebase
```bash
flutterfire configure
```
**Sigue las instrucciones interactivas:**
```
i Found X Firebase projects.
? Select a Firebase project to configure your Flutter application with:
  ❯ soft-restaurant (soft-restaurant-xxxxx)
    <create a new project>

? Which platforms should your configuration support?
  ✓ android
  ✓ ios
  ✓ web
```

---

### Paso 5: Ejecutar la App
```bash
flutter run
```
**Opciones:**
```
Multiple devices found:
[1]: Chrome (chrome)
[2]: Android SDK (emulator-5554)
[3]: iPhone 14 (ios-simulator)

Please choose one (To quit, press "q/Q"): 
```

---

## 📱 Capturas de Pantalla (Simuladas)

### Login Screen
```
┌─────────────────────────────────┐
│                                 │
│           🍽️                    │
│      Soft Restaurant            │
│   Inicia sesión para continuar  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 📧 Email                  │  │
│  │ usuario@ejemplo.com       │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 🔒 Contraseña             │  │
│  │ ••••••••                  │  │
│  └───────────────────────────┘  │
│                                 │
│    ¿Olvidaste tu contraseña?    │
│                                 │
│  ┌───────────────────────────┐  │
│  │    Iniciar Sesión   →    │  │
│  └───────────────────────────┘  │
│                                 │
│           ─── O ───             │
│                                 │
│  ┌───────────────────────────┐  │
│  │      Crear Cuenta        │  │
│  └───────────────────────────┘  │
│                                 │
│  ℹ️ Credenciales de prueba:     │
│  cliente@test.com / 123456      │
│  admin@test.com / 123456        │
│                                 │
└─────────────────────────────────┘
```

### Menu Screen
```
┌─────────────────────────────────┐
│ ☰ Menú              🛒 2        │
├─────────────────────────────────┤
│                                 │
│ 🌟 Destacados                   │
│ ┌────┐  ┌────┐  ┌────┐  ┌────┐ │
│ │ 🍕 │  │ 🌮 │  │ 🍔 │  │ 🍰 │ │
│ │$165│  │$85 │  │$145│  │$75 │ │
│ └────┘  └────┘  └────┘  └────┘ │
│                                 │
├─────────────────────────────────┤
│ [Todos] [Entradas] [Platos]...  │
├─────────────────────────────────┤
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 🍕 Pizza Margarita          │ │
│ │ Salsa de tomate, mozza...   │ │
│ │ ⭐ 4.6 (123) • 25 min       │ │
│ │                             │ │
│ │ $165.00      [+ Agregar]    │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 🌮 Tacos al Pastor          │ │
│ │ 3 tacos con piña, cebo...   │ │
│ │ ⭐ 4.9 (567) • 15 min       │ │
│ │                             │ │
│ │ $85.00       [+ Agregar]    │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 🍔 Hamburguesa Clásica      │ │
│ │ Carne de res, lechuga...    │ │
│ │ ⭐ 4.8 (234) • 20 min       │ │
│ │                             │ │
│ │ $145.00      [+ Agregar]    │ │
│ └─────────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

### Cart Screen
```
┌─────────────────────────────────┐
│ ← Carrito          Limpiar      │
├─────────────────────────────────┤
│                                 │
│ ┌─────────────────────────────┐ │
│ │ [🍕] Pizza Margarita        │ │
│ │      $165.00                │ │
│ │                             │ │
│ │      ➖  2  ➕     $330.00   │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ [🌮] Tacos al Pastor        │ │
│ │      $85.00                 │ │
│ │                             │ │
│ │      ➖  1  ➕     $85.00    │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ [🍔] Hamburguesa Clásica    │ │
│ │      $145.00                │ │
│ │                             │ │
│ │      ➖  1  ➕     $145.00   │ │
│ └─────────────────────────────┘ │
│                                 │
├─────────────────────────────────┤
│ Resumen                         │
│                                 │
│ Subtotal              $560.00   │
│ Impuestos (16%)       $89.60    │
│ ─────────────────────────────── │
│ Total                 $649.60   │
│                                 │
│ ┌───────────────────────────┐   │
│ │   Proceder al pago    →  │   │
│ └───────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

---

## 🔥 Firebase Console Setup

### 1. Crear Proyecto
```
1. Ve a https://console.firebase.google.com
2. Click "Add project"
3. Nombre: "Soft Restaurant"
4. Habilitar Google Analytics (opcional)
5. Click "Create project"
```

### 2. Habilitar Authentication
```
1. En el sidebar: Build → Authentication
2. Click "Get started"
3. Sign-in method → Email/Password
4. Enable "Email/Password"
5. Save
```

### 3. Crear Firestore Database
```
1. En el sidebar: Build → Firestore Database
2. Click "Create database"
3. Select "Start in test mode" (por ahora)
4. Location: us-central1 (o más cercano)
5. Click "Enable"
```

### 4. Crear Colecciones Iniciales
```
Firestore → + Start collection

1. categories
   ├── Document ID: auto
   ├── name: "Entradas"
   ├── description: "Deliciosas entradas"
   ├── is_active: true
   └── sort_order: 1

2. products
   ├── Document ID: auto
   ├── name: "Tacos al Pastor"
   ├── price: 85.00
   ├── category_id: <id-de-entradas>
   └── is_available: true

3. users (se crea automáticamente al registrar)

4. orders (se crea automáticamente al hacer pedido)
```

---

## ✅ Verificar que Todo Funciona

### Test 1: Compilación
```bash
flutter analyze
```
**Esperado:** ✅ No issues found!

### Test 2: Registro
```
1. Ejecuta la app
2. Click en "Crear Cuenta"
3. Completa el formulario
4. Click "Registrarse"
```
**Esperado:** ✅ Redirección al menú

### Test 3: Agregar al Carrito
```
1. En la pantalla de menú
2. Click en "Agregar" en un producto
3. Verifica el badge del carrito (🛒 1)
```
**Esperado:** ✅ Contador actualizado

### Test 4: Ver Carrito
```
1. Click en el ícono del carrito
2. Verifica que el producto esté listado
3. Intenta modificar la cantidad
```
**Esperado:** ✅ Carrito funcional

---

## 🐛 Troubleshooting Común

### Problema: "Firebase not initialized"
```bash
# Solución:
flutterfire configure
```

### Problema: "*.g.dart not found"
```bash
# Solución:
flutter pub run build_runner build --delete-conflicting-outputs
```

### Problema: "Package not found"
```bash
# Solución:
flutter clean
flutter pub get
```

### Problema: "Gradle build failed" (Android)
```bash
# Solución:
cd android
./gradlew clean
cd ..
flutter run
```

---

## 📊 Estructura de Archivos Generados

```
soft_restaurant/
│
├── 📄 README.md                      ← Empieza aquí
├── 📄 QUICKSTART.md                  ← Guía rápida
├── 📄 PROJECT_SUMMARY.md             ← Resumen completo
├── 📄 VISUAL_GUIDE.md                ← Este archivo
│
├── 📦 lib/
│   ├── main.dart                     ← Punto de entrada
│   │
│   ├── 🔧 core/                      ← 11 archivos
│   │   ├── constants/
│   │   ├── enums/
│   │   ├── providers/
│   │   ├── routing/
│   │   ├── theme/
│   │   └── utils/
│   │
│   └── 🎨 features/                  ← 22 archivos
│       ├── auth/
│       ├── menu/
│       ├── cart/
│       ├── orders/
│       └── tables/
│
├── 📱 android/                       ← Configuración Android
├── 🍎 ios/                           ← Configuración iOS
├── 🌐 web/                           ← Configuración Web
│
└── 📚 docs/                          ← 8 archivos de doc
    ├── ARCHITECTURE.md
    ├── DESIGN_GUIDE.md
    ├── DEPLOYMENT.md
    ├── COMMANDS.md
    └── FIREBASE_RULES.md
```

---

## 🎯 Próximos Pasos Recomendados

### 1. Explorar el Código (30 min)
```
✓ Revisar lib/main.dart
✓ Explorar lib/features/auth/
✓ Ver lib/features/menu/
✓ Revisar lib/core/theme/
```

### 2. Personalizar (1 hora)
```
✓ Cambiar colores en app_theme.dart
✓ Agregar tu logo
✓ Modificar textos
✓ Agregar más productos en Firebase
```

### 3. Extender Funcionalidades (2-4 horas)
```
✓ Implementar pantalla de detalle de producto
✓ Agregar proceso de checkout
✓ Crear historial de pedidos
✓ Implementar panel de admin
```

### 4. Optimizar (1-2 horas)
```
✓ Agregar tests unitarios
✓ Optimizar imágenes
✓ Implementar caché local
✓ Mejorar manejo de errores
```

---

## 🎉 ¡Felicidades!

Has creado un sistema completo de restaurante con:

✅ 33 archivos Dart  
✅ 8 documentos  
✅ Clean Architecture  
✅ Firebase Integration  
✅ Responsive Design  
✅ Temas claro/oscuro  

**¡Ahora es tu turno de personalizarlo y hacerlo brillar! ✨**

---

*Para más detalles, consulta los otros archivos de documentación en el proyecto.*
