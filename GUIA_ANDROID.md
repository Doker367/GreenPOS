# Guía para Probar en Android

## 📱 Configuración Inicial

### 1. Instalar ADB (Android Debug Bridge)
```bash
# En Arch Linux
sudo pacman -S android-tools

# Verificar instalación
adb version
```

### 2. Habilitar Depuración USB en el Dispositivo Android
1. Ve a **Ajustes** > **Acerca del teléfono**
2. Toca **Número de compilación** 7 veces (activar modo desarrollador)
3. Regresa a **Ajustes** > **Sistema** > **Opciones de desarrollador**
4. Activa **Depuración USB**

### 3. Conectar el Dispositivo
1. Conecta tu Android con el cable USB
2. En el teléfono, aparecerá un mensaje "¿Permitir depuración USB?"
3. Marca "Permitir siempre desde este equipo" y toca **Aceptar**

### 4. Verificar Conexión
```bash
# Ver dispositivos conectados
adb devices

# Deberías ver algo como:
# List of devices attached
# ABC123DEF456    device

# También con Flutter
flutter devices
```

## 🚀 Ejecutar la App en Android

### Opción 1: Ejecutar directamente
```bash
cd /home/doker/Descargas/Soft-restaurant
flutter run
# Flutter detectará automáticamente el Android y preguntará en cuál dispositivo ejecutar
```

### Opción 2: Especificar el dispositivo
```bash
# Ver lista de dispositivos
flutter devices

# Ejecutar en un dispositivo específico
flutter run -d <device_id>
```

### Opción 3: Compilar APK de Debug
```bash
# Generar APK
flutter build apk --debug

# El APK estará en:
# build/app/outputs/flutter-apk/app-debug.apk

# Instalarlo manualmente
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## 🔧 Solución de Problemas Comunes

### Dispositivo no detectado
```bash
# Reiniciar servidor ADB
adb kill-server
adb start-server

# Verificar permisos
sudo usermod -aG plugdev $USER
# (Reinicia sesión después de esto)
```

### Error de firma
```bash
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run
```

### App muy lenta en debug
```bash
# Compilar en modo release (mucho más rápido)
flutter run --release
```

## 📊 Probar la App POS en Android

### Funcionalidades a probar:

#### 1. **Diseño Responsive**
- ✅ Verás las categorías en chips horizontales (no panel lateral)
- ✅ Navegación por tabs: "Productos" y "Pedido"
- ✅ Grid de productos optimizado para pantalla táctil
- ✅ Badge con contador de items en el AppBar

#### 2. **Búsqueda de Productos**
- Usa la barra de búsqueda en el tab "Productos"
- Busca por nombre (ej: "Taco", "Cerveza")
- Botón X para limpiar búsqueda

#### 3. **Agregar Productos**
- Toca cualquier producto del grid
- Si tiene modificadores (carnes/bebidas), verás diálogo
- Selecciona opciones y cantidad
- Agrega al pedido

#### 4. **Gestión del Pedido**
- Cambia al tab "Pedido"
- Incrementa/decrementa cantidades con botones
- Agrega notas a productos
- Elimina items con el botón de basura

#### 5. **Descuentos**
- Toca "Agregar descuento"
- Selecciona uno de los 5 descuentos disponibles
- Observa el cálculo automático

#### 6. **Validaciones**
- Intenta cobrar con pedido vacío (verás error)
- Agrega productos y usa "Enviar a Cocina"
- Confirma y verás cambio de estado

### Notas de Rendimiento:
- **Debug Mode**: Puede ser lento, es normal
- **Release Mode**: 60 FPS fluido
- Todas las animaciones están optimizadas para Android

### Tips para Pantallas Pequeñas:
- En pantallas < 400px, todos los elementos se ajustan automáticamente
- Chips de categorías tienen scroll horizontal
- Grid muestra 2-3 productos por fila según el tamaño
- Botones y textos se reducen proporcionalmente

## 📷 Capturas Recomendadas
1. Vista de productos con categorías en chips
2. Diálogo de modificadores en móvil
3. Pedido activo con múltiples items
4. Diálogo de descuentos
5. Confirmación de envío a cocina

## 🔄 Hot Reload en Android
Una vez ejecutando, puedes hacer cambios en el código:
```bash
# En la terminal donde corre la app, presiona:
r   # Hot reload (cambios rápidos)
R   # Hot restart (reinicio completo)
```

## ⚠️ Permisos Necesarios
La app no requiere permisos especiales de Android en esta fase.
Firebase está deshabilitado, funciona 100% offline con datos de prueba.
