# 🏪 Roadmap: Transformación a POS Profesional

> **Sistema de Punto de Venta para Restaurante**  
> De menú digital a POS completo - Implementación por fases

---

## 📊 Estado General del Proyecto

| Fase | Estado | Progreso | Prioridad |
|------|--------|----------|-----------|
| **FASE 1** - Fundamentos POS | ✅ Completada | 100% | 🔴 Alta |
| **FASE 2** - Pedido Activo | ⏳ Pendiente | 0% | 🔴 Alta |
| **FASE 3** - Gestión de Mesas | ⏳ Pendiente | 0% | 🟡 Media |
| **FASE 4** - Envío a Cocina | ⏳ Pendiente | 0% | 🟡 Media |
| **FASE 5** - Cobro y Pagos | ⏳ Pendiente | 0% | 🔴 Alta |
| **FASE 6** - Control de Caja | ⏳ Pendiente | 0% | 🟢 Baja |
| **FASE 7** - Reportes | ⏳ Pendiente | 0% | 🟢 Baja |

---

# 🎯 FASE 1 — Fundamentos del POS

**Estado**: ✅ Completada  
**Objetivo**: Crear la estructura base del POS con layout de 3 paneles y estado del pedido activo

## 📋 Checklist de Implementación

### 1. Layout Principal Tipo POS
- [x] Diseño de 3 columnas (Categorías | Productos | Pedido Activo)
- [x] Responsive para diferentes tamaños de pantalla
- [x] Adaptación táctil (botones grandes, espaciado adecuado)
- [x] Barra superior con info de sesión/caja

### 2. Estructura de Carpetas
- [x] Reorganizar arquitectura para módulo POS
- [x] Separar lógica de menú cliente vs POS cajero
- [x] Crear providers específicos para POS

### 3. Modelos de Datos
- [x] `POSOrder` (Pedido activo)
- [x] `POSOrderItem` (Item del pedido)
- [x] `OrderStatus` enum (Draft, Sent, Preparing, Ready, Completed)
- [x] Modificadores y notas por producto

### 4. Estado del Pedido Activo
- [x] Provider de pedido activo
- [x] Agregar productos al pedido
- [x] Modificar cantidades (+/-)
- [x] Eliminar items
- [x] Calcular subtotal, impuestos, total
- [x] Limpiar pedido

## ✅ Archivos Implementados

```
lib/features/pos/
├── domain/entities/
│   ├── pos_order.dart                    ✅ Implementado
│   ├── pos_order_item.dart               ✅ Implementado
│   └── order_modifier.dart               ✅ Implementado
│
├── presentation/
│   ├── providers/
│   │   └── active_order_provider.dart    ✅ Implementado
│   │
│   ├── screens/
│   │   └── pos_main_screen.dart          ✅ Implementado
│   │
│   └── widgets/
│       ├── categories_panel.dart         ✅ Implementado
│       ├── pos_products_grid.dart        ✅ Implementado
│       └── active_order_panel.dart       ✅ Implementado

lib/core/enums/
└── pos_order_status.dart                 ✅ Implementado
```

## 🎉 Funcionalidades Implementadas

1. **Layout POS Completo**
   - Panel izquierdo: Categorías con filtrado
   - Panel central: Grid de productos táctil
   - Panel derecho: Pedido activo con totales
   - Responsive: Tabs en móvil, 3 columnas en desktop

2. **Gestión de Pedido**
   - ✅ Agregar productos al pedido (tap en producto)
   - ✅ Incrementar/decrementar cantidad
   - ✅ Eliminar items individuales
   - ✅ Agregar notas a productos
   - ✅ Cálculo automático de subtotal, IVA (16%), total
   - ✅ Cancelar pedido completo con confirmación

3. **Experiencia Táctil**
   - Botones grandes (56px mínimo)
   - Feedback visual al agregar productos
   - Animaciones suaves
   - Espaciado generoso para táctil

4. **Estados del Pedido**
   - Draft (borrador - actual)
   - Pending, Sent, Preparing, Ready, Served, Completed, Cancelled
   - Validaciones: `canSendToKitchen`, `canCheckout`

## 🧪 Cómo Probar la FASE 1

1. **Ejecutar la aplicación:**
   ```bash
   flutter run -d linux
   ```

2. **Probar el flujo básico:**
   - Ver productos en el grid central
   - Filtrar por categoría en panel izquierdo
   - Hacer clic en productos para agregar al pedido
   - Ver el pedido activo en panel derecho
   - Incrementar/decrementar cantidades
   - Agregar notas a productos
   - Ver cálculo automático de totales
   - Cancelar pedido

3. **Casos de uso verificados:**
   - ✅ Agregar múltiples productos
   - ✅ Producto duplicado incrementa cantidad automáticamente
   - ✅ Decrementar en cantidad=1 elimina el item
   - ✅ IVA calculado correctamente (16%)
   - ✅ Panel de categorías filtra productos
   - ✅ Responsive en diferentes tamaños

## 📝 Notas Técnicas

### Performance
- Grid de productos usa `GridView.builder` (lazy loading)
- Items del pedido con `ListView.builder`
- Cálculos de totales son propiedades computadas (no almacenadas)
- Estado reactivo con Riverpod

### UX Destacadas
- Snackbar al agregar producto
- Confirmación al cancelar pedido
- Indicador visual de categoría seleccionada
- Placeholder para productos sin imagen
- Notas con icono distintivo (nota amarilla)

---

## 🏗️ Arquitectura del Layout POS

```
┌─────────────────────────────────────────────────────────────────┐
│  BARRA SUPERIOR                                                 │
│  Usuario: Juan | Caja: #1 | Turno: Abierto | 14:30            │
├─────────────┬───────────────────────────┬─────────────────────┤
│             │                           │                      │
│ CATEGORÍAS  │      PRODUCTOS            │   PEDIDO ACTIVO     │
│             │                           │                      │
│ [Entradas]  │  ┌─────┐ ┌─────┐ ┌─────┐ │  Mesa: 5            │
│             │  │ 🍔  │ │ 🍕  │ │ 🌮  │ │  Cliente: -         │
│ [Platos]    │  │Burger│ │Pizza│ │Tacos│ │  ─────────────────  │
│   •         │  │$120 │ │$145 │ │$95  │ │                     │
│             │  └─────┘ └─────┘ └─────┘ │  1x Burger    $120  │
│ [Postres]   │                           │  2x Tacos     $190  │
│             │  ┌─────┐ ┌─────┐ ┌─────┐ │  1x Pizza     $145  │
│ [Bebidas]   │  │ 🍝  │ │ 🍣  │ │ 🥗  │ │  ─────────────────  │
│             │  │Pasta│ │Sushi│ │Salad│ │  Subtotal:    $455  │
│ [Todos]     │  │$135 │ │$165 │ │$45  │ │  IVA (16%):   $73   │
│             │  └─────┘ └─────┘ └─────┘ │  ─────────────────  │
│             │                           │  TOTAL:       $528  │
│             │   [Buscar productos...]  │                     │
│             │                           │  [Cancelar Pedido] │
│             │   📄 Pág 1 de 3          │  [Enviar Cocina]   │
│             │                           │  [COBRAR]          │
│             │                           │                     │
└─────────────┴───────────────────────────┴─────────────────────┘
```

### Proporciones Recomendadas:
- **Categorías**: 15% del ancho (150-200px)
- **Productos**: 55% del ancho (flexible)
- **Pedido Activo**: 30% del ancho (300-400px, fijo)

---

## 📁 Nueva Estructura de Carpetas

```
lib/
├── features/
│   ├── pos/                          ← NUEVO MÓDULO POS
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── pos_order_model.dart
│   │   │   │   ├── pos_order_item_model.dart
│   │   │   │   └── order_modifier_model.dart
│   │   │   └── repositories/
│   │   │       └── pos_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── pos_order.dart
│   │   │   │   ├── pos_order_item.dart
│   │   │   │   └── order_modifier.dart
│   │   │   └── repositories/
│   │   │       └── pos_repository.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── active_order_provider.dart    ← Pedido activo
│   │       │   ├── pos_session_provider.dart     ← Sesión de caja
│   │       │   └── selected_category_provider.dart
│   │       │
│   │       ├── screens/
│   │       │   ├── pos_main_screen.dart          ← Pantalla principal POS
│   │       │   └── pos_checkout_screen.dart      ← Para FASE 5
│   │       │
│   │       └── widgets/
│   │           ├── pos_layout.dart               ← Layout de 3 columnas
│   │           ├── categories_panel.dart         ← Panel izquierdo
│   │           ├── products_grid.dart            ← Panel central (reutiliza existente)
│   │           ├── active_order_panel.dart       ← Panel derecho
│   │           ├── order_item_tile.dart          ← Item en pedido
│   │           └── pos_top_bar.dart              ← Barra superior
│   │
│   ├── menu/                         ← Existente (cliente)
│   ├── cart/                         ← Existente (cliente)
│   └── ...
│
└── core/
    ├── enums/
    │   ├── order_status.dart         ← Actualizar con nuevos estados
    │   ├── payment_method.dart       ← Para FASE 5
    │   └── pos_user_role.dart        ← Cajero, Admin, Cocinero
    │
    └── utils/
        ├── currency_formatter.dart   ← Formateo de moneda
        └── tax_calculator.dart       ← Cálculo de impuestos
```

---

## 🔧 Implementación Técnica - FASE 1

### 1. Modelos de Datos

#### `pos_order.dart` (Entity)
```dart
class POSOrder {
  final String id;
  final String? tableId;           // null si es para llevar
  final String? tableName;
  final String? customerName;
  final List<POSOrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;             // Notas generales del pedido
  
  // Cálculos
  double get subtotal;             // Suma de items
  double get tax;                  // IVA u otros impuestos
  double get total;                // subtotal + tax
  int get totalItems;              // Cantidad de productos
}
```

#### `pos_order_item.dart` (Entity)
```dart
class POSOrderItem {
  final String id;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final List<OrderModifier> modifiers;  // Ej: sin cebolla, extra queso
  final String? notes;                   // Notas específicas del item
  
  double get subtotal => unitPrice * quantity;
}
```

#### `order_modifier.dart` (Entity)
```dart
class OrderModifier {
  final String id;
  final String name;              // "Sin cebolla", "Extra queso"
  final double priceAdjustment;   // 0 o precio adicional
  final ModifierType type;        // Remove, Add, Replace
}

enum ModifierType {
  remove,    // Quitar ingrediente
  add,       // Agregar ingrediente
  replace,   // Reemplazar ingrediente
}
```

#### `order_status.dart` (Enum actualizado)
```dart
enum OrderStatus {
  draft,        // En creación (pedido activo en POS)
  pending,      // Confirmado, esperando envío a cocina
  sent,         // Enviado a cocina
  preparing,    // En preparación
  ready,        // Listo para entregar
  served,       // Servido al cliente (en mesa)
  completed,    // Completado y pagado
  cancelled,    // Cancelado
}
```

### 2. Provider del Pedido Activo

#### `active_order_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado del pedido activo en el POS
class ActiveOrderState {
  final POSOrder? order;
  final bool isLoading;
  final String? error;
  
  const ActiveOrderState({
    this.order,
    this.isLoading = false,
    this.error,
  });
  
  // Helpers
  bool get hasItems => order != null && order!.items.isNotEmpty;
  double get total => order?.total ?? 0.0;
}

/// Notifier del pedido activo
class ActiveOrderNotifier extends StateNotifier<ActiveOrderState> {
  ActiveOrderNotifier() : super(const ActiveOrderState());
  
  /// Agregar producto al pedido
  void addProduct(Product product, {int quantity = 1}) {
    // Implementación...
  }
  
  /// Incrementar cantidad de un item
  void incrementItem(String itemId) {
    // Implementación...
  }
  
  /// Decrementar cantidad de un item
  void decrementItem(String itemId) {
    // Implementación...
  }
  
  /// Eliminar item del pedido
  void removeItem(String itemId) {
    // Implementación...
  }
  
  /// Agregar nota a un item
  void addItemNote(String itemId, String note) {
    // Implementación...
  }
  
  /// Limpiar pedido (cancelar)
  void clearOrder() {
    // Implementación...
  }
  
  /// Asignar mesa al pedido
  void assignTable(String tableId, String tableName) {
    // Implementación...
  }
}

final activeOrderProvider = 
    StateNotifierProvider<ActiveOrderNotifier, ActiveOrderState>((ref) {
  return ActiveOrderNotifier();
});
```

### 3. Widget Principal - Layout POS

#### `pos_layout.dart`
```dart
class POSLayout extends StatelessWidget {
  const POSLayout({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Panel de Categorías (15%)
        SizedBox(
          width: 180,
          child: CategoriesPanel(),
        ),
        
        // Divisor
        VerticalDivider(width: 1),
        
        // Panel de Productos (55% - flexible)
        Expanded(
          flex: 55,
          child: ProductsGrid(),
        ),
        
        // Divisor
        VerticalDivider(width: 1),
        
        // Panel de Pedido Activo (30%)
        SizedBox(
          width: 350,
          child: ActiveOrderPanel(),
        ),
      ],
    );
  }
}
```

#### Responsive para tablet/móvil:
```dart
// En pantallas pequeñas (<800px), mostrar productos y pedido en tabs
if (screenWidth < 800) {
  return TabBarView(
    children: [
      ProductsGrid(),
      ActiveOrderPanel(),
    ],
  );
}
```

---

## 🎨 Consideraciones UX Táctil

### Tamaños de Botones
```dart
// Mínimo recomendado para táctil
const double kPOSButtonHeight = 56.0;
const double kPOSButtonMinWidth = 80.0;

// Producto en grid
const double kProductCardHeight = 120.0;
const double kProductCardWidth = 100.0;

// Espaciado entre elementos
const double kPOSTouchPadding = 12.0;
```

### Feedback Táctil
```dart
// Agregar haptic feedback
HapticFeedback.lightImpact();

// Animaciones rápidas de tap
InkWell(
  onTap: () {
    HapticFeedback.selectionClick();
    // acción...
  },
  child: ...,
)
```

---

## ⚙️ Configuración de Impuestos

```dart
// lib/core/utils/tax_calculator.dart
class TaxCalculator {
  static const double IVA_RATE = 0.16;  // 16% México
  
  static double calculateTax(double subtotal) {
    return subtotal * IVA_RATE;
  }
  
  static double calculateTotal(double subtotal) {
    return subtotal + calculateTax(subtotal);
  }
}
```

---

## 🧪 Testing de la Fase 1

### Casos de Uso a Probar:
1. ✅ Agregar producto al pedido
2. ✅ Incrementar/decrementar cantidad
3. ✅ Eliminar producto del pedido
4. ✅ Cálculo correcto de subtotal, IVA, total
5. ✅ Limpiar pedido completo
6. ✅ Asignar mesa al pedido
7. ✅ Persistencia del pedido al cambiar de categoría

---

## 📝 Notas de Implementación

### Optimizaciones:
- Usar `ListView.builder` para items del pedido (aunque sean pocos)
- Cachear cálculos de totales
- Debounce en búsqueda de productos
- Lazy loading de imágenes de productos

### Accesibilidad:
- Shortcuts de teclado: `F1` a `F10` para categorías frecuentes
- `Enter` para agregar producto seleccionado
- `Esc` para cancelar pedido (con confirmación)
- Scanner de códigos de barras (preparar arquitectura)

---

## 🚀 Siguiente Fase

Una vez completada la FASE 1, continuaremos con:

**FASE 2 - Pedido Activo y Flujo de Venta**
- Edición avanzada de items
- Modificadores y notas por producto
- Validaciones antes de enviar a cocina
- Modal de confirmación de pedido

---

## 📚 Referencias Útiles

- [Material Design - Large Screen Layouts](https://m3.material.io/foundations/layout/applying-layout/large-screens)
- [Flutter ResponsiveBuilder](https://pub.dev/packages/responsive_builder)
- [POS Best Practices](https://docs.stripe.com/terminal/point-of-sale)

---

**Última actualización**: 4 de febrero de 2026  
**Responsable**: Equipo de Desarrollo POS
