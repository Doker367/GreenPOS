# 🎨 Guía de Diseño UI/UX - Soft Restaurant

## Paleta de Colores

### Colores Principales

```
🔴 Primary (Naranja)
   Hex: #FF6B35
   RGB: 255, 107, 53
   Uso: Botones principales, acentos, CTAs

🔵 Secondary (Azul)
   Hex: #004E89
   RGB: 0, 78, 137
   Uso: Encabezados, navegación, elementos secundarios

🟡 Accent (Amarillo Dorado)
   Hex: #FFC300
   RGB: 255, 195, 0
   Uso: Destacados, badges, ofertas especiales
```

### Colores de Estado

```
✅ Success: #00B050 (Verde)
⚠️ Warning: #FFA500 (Naranja)
❌ Error: #D32F2F (Rojo)
ℹ️ Info: #2196F3 (Azul claro)
```

### Escala de Grises

```
Grey 50:  #FAFAFA (Fondo claro)
Grey 100: #F5F5F5
Grey 200: #EEEEEE
Grey 300: #E0E0E0
Grey 400: #BDBDBD
Grey 500: #9E9E9E (Texto secundario)
Grey 600: #757575
Grey 700: #616161 (Texto principal)
Grey 800: #424242
Grey 900: #212121 (Negro suave)
```

## Tipografía

### Familia de Fuente
**Poppins** (recomendada) - Fuente moderna, clara y profesional

```
Display Large:  32px, Bold
Display Medium: 28px, Bold
Display Small:  24px, Bold

Headline Medium: 20px, SemiBold
Headline Small:  18px, SemiBold

Title Large:  16px, SemiBold
Body Large:   16px, Regular
Body Medium:  14px, Regular
Body Small:   12px, Regular
```

## Espaciado

Sistema de espaciado de 8px:

```
XXS: 4px
XS:  8px
SM:  12px
MD:  16px
LG:  24px
XL:  32px
XXL: 48px
```

## Componentes UI

### 1. Cards (Tarjetas)

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
)
```

**Características:**
- Border radius: 16px
- Sombra suave
- Padding interno: 12-16px
- Margin: 8px

### 2. Botones

**Primary Button:**
```
- Background: Primary color (#FF6B35)
- Text: White, 16px, SemiBold
- Height: 56px (touch-friendly)
- Border radius: 12px
- Padding: 24px horizontal
```

**Secondary Button (Outlined):**
```
- Border: 2px, Primary color
- Text: Primary color, 16px, SemiBold
- Background: Transparent
- Height: 56px
- Border radius: 12px
```

### 3. Input Fields

```
- Background: Grey 100 (#F5F5F5)
- Border: None (filled style)
- Border radius: 12px
- Height: 56px
- Padding: 16px horizontal
- Focus border: 2px Primary color
```

### 4. Bottom Navigation

```
- Background: White
- Height: 60px + safe area
- Icons: 24px
- Selected color: Primary
- Unselected color: Grey 500
- Elevation: 8
```

## Pantallas Principales

### 📱 Login Screen

```
Estructura:
┌─────────────────────┐
│      Logo (80px)    │ 🍽️
│                     │
│   Soft Restaurant   │ (Display Medium)
│ Inicia sesión...    │ (Body Large, grey)
│                     │
│  ┌───────────────┐  │
│  │ Email input   │  │
│  └───────────────┘  │
│                     │
│  ┌───────────────┐  │
│  │ Password      │  │
│  └───────────────┘  │
│                     │
│  [Iniciar Sesión]   │ (Primary button)
│                     │
│  [Crear Cuenta]     │ (Outlined button)
│                     │
│  ℹ️ Demo info box   │
└─────────────────────┘
```

### 🍔 Menu Screen

```
Estructura:
┌─────────────────────────────┐
│ Menú              🛒(2)      │ App Bar
├─────────────────────────────┤
│ 🌟 Destacados               │
│ ┌──────┐ ┌──────┐ ┌──────┐ │ Horizontal scroll
│ │Image │ │Image │ │Image │ │
│ │$99   │ │$85   │ │$145  │ │
│ └──────┘ └──────┘ └──────┘ │
├─────────────────────────────┤
│ [Todos] [Entradas] [Platos] │ Category chips
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ 🍕 Pizza Margarita      │ │ Product card
│ │ Deliciosa pizza con...  │ │
│ │ ⭐ 4.8 (234) • 25 min   │ │
│ │ $165.00    [+ Agregar]  │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ 🌮 Tacos al Pastor      │ │
│ │ ...                     │ │
└─────────────────────────────┘
```

### 🛒 Cart Screen

```
Estructura:
┌─────────────────────────────┐
│ ← Carrito          Limpiar  │ App Bar
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ [Img] Pizza Margarita   │ │
│ │       $165.00           │ │
│ │       [-] 2 [+]  $330   │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ [Img] Tacos al Pastor   │ │
│ │       $85.00            │ │
│ │       [-] 1 [+]  $85    │ │
│ └─────────────────────────┘ │
│                             │
├─────────────────────────────┤
│ Resumen                     │
│                             │
│ Subtotal           $415.00  │
│ Impuestos (16%)     $66.40  │
│ ─────────────────────────── │
│ Total              $481.40  │
│                             │
│ [Proceder al pago]          │ Primary button
└─────────────────────────────┘
```

## Animaciones y Transiciones

### Duración Recomendada

```dart
- Micro: 100ms (toggle, hover)
- Corta: 200ms (fade, slide)
- Media: 300ms (page transition)
- Larga: 500ms (complex animations)
```

### Curvas de Animación

```dart
- Ease in out: Curves.easeInOut (general)
- Ease out: Curves.easeOut (entrada)
- Ease in: Curves.easeIn (salida)
- Bounce: Curves.bounceOut (efectos especiales)
```

### Ejemplos de Animación

**1. Agregar al carrito:**
```dart
ScaleTransition + FadeTransition
Duration: 200ms
Curve: easeInOut
```

**2. Cambio de pantalla:**
```dart
SlideTransition (left to right)
Duration: 300ms
Curve: easeOut
```

**3. Loading:**
```dart
CircularProgressIndicator
Color: Primary
Size: 24px
```

## Responsive Design

### Breakpoints

```
📱 Mobile:  < 600px
📱 Tablet:  600px - 900px
💻 Desktop: > 900px
```

### Adaptaciones

**Mobile (< 600px):**
- Grid: 2 columnas
- Padding: 16px
- Font scaling: 1.0x

**Tablet (600-900px):**
- Grid: 3 columnas
- Padding: 24px
- Font scaling: 1.1x

**Desktop (> 900px):**
- Grid: 4 columnas
- Padding: 32px
- Max width: 1200px (centrado)
- Font scaling: 1.2x

## Estados de UI

### Loading State
```
┌─────────────────┐
│                 │
│   🔄 Loading    │ Shimmer effect
│                 │
└─────────────────┘
```

### Empty State
```
┌─────────────────┐
│                 │
│    📦 Icon      │ Grey 400, size 80
│                 │
│  "Sin items"    │ Headline Small
│                 │
│  [Explorar]     │ Primary button
│                 │
└─────────────────┘
```

### Error State
```
┌─────────────────┐
│                 │
│    ⚠️ Icon      │ Error color, size 80
│                 │
│  "Error..."     │ Headline Small
│  Descripción    │ Body Medium
│                 │
│  [Reintentar]   │ Primary button
│                 │
└─────────────────┘
```

## Iconografía

### Conjunto de Iconos (Material Icons)

```
🏠 home              - Inicio
🍽️ restaurant        - Menú/Logo
🛒 shopping_cart     - Carrito
👤 person            - Perfil
📊 dashboard         - Admin
📦 inventory         - Productos
🪑 table_restaurant  - Mesas
📋 receipt           - Pedidos
⚙️ settings          - Configuración
🔔 notifications     - Notificaciones
⭐ star              - Rating
🔍 search            - Búsqueda
➕ add               - Agregar
✓ check             - Confirmación
✕ close             - Cerrar
```

## Mejores Prácticas

### 1. Touch Targets
- Mínimo: 48x48 px
- Recomendado: 56x56 px
- Espaciado entre elementos: 8px mínimo

### 2. Contraste de Color
- Texto en fondo claro: Grey 700+
- Texto en fondo oscuro: White
- Ratio mínimo: 4.5:1 (WCAG AA)

### 3. Feedback Visual
- Tap: Ripple effect
- Success: Snackbar verde, 2s
- Error: Snackbar rojo, 4s
- Loading: Indicador centrado

### 4. Accesibilidad
- Labels descriptivos
- Hints en inputs
- Semantic labels para screen readers
- Navegación por teclado (web)

## Temas Claro/Oscuro

### Tema Claro
```
Background: #FAFAFA
Surface: #FFFFFF
Text Primary: #212121
Text Secondary: #757575
```

### Tema Oscuro
```
Background: #121212
Surface: #1E1E1E
Text Primary: #FFFFFF
Text Secondary: #B0B0B0
```

## Referencias de Diseño

- Material Design 3: https://m3.material.io/
- Flutter Widget Catalog: https://docs.flutter.dev/ui/widgets
- Dribbble (inspiración): https://dribbble.com/tags/restaurant-app
- Human Interface Guidelines (iOS): https://developer.apple.com/design/

---

**Mantén la consistencia en todo el diseño para una mejor experiencia de usuario! 🎨**
