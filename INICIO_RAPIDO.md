# 🚀 Inicio Rápido - Soft Restaurant

## ✅ Estado Actual
La aplicación está **funcionando correctamente** en Linux. Todos los errores de compilación han sido resueltos.

## 🔧 Correcciones Realizadas

### 1. Rutas de Importación Corregidas
- **Problema**: `auth_provider.dart` buscaba `repository_providers.dart` en la ubicación incorrecta
- **Solución**: Actualizada la ruta de `../providers/repository_providers.dart` a `../../../../core/providers/repository_providers.dart`

### 2. Archivos Generados con build_runner
- **Problema**: Faltaba `product_model.g.dart` (archivo auto-generado)
- **Solución**: Ejecutado `flutter pub run build_runner build --delete-conflicting-outputs`
- **Archivos generados**:
  - `product_model.g.dart`
  - `user_model.g.dart`
  - `category_model.g.dart`

### 3. Dependencias Optimizadas
- **Problema**: Conflicto de versiones con `retrofit_generator`
- **Solución**: Comentado retrofit (no se usa actualmente)
- **Estado**: Solo se mantienen las dependencias necesarias

### 4. Assets Configurados
- **Problema**: Referencias a fuentes Poppins que no existen
- **Solución**: Comentadas las referencias de fuentes personalizadas
- **Alternativa**: Usa fuentes del sistema por defecto

## 🏃 Comandos Para Ejecutar

### Ejecutar en Linux
```bash
flutter run -d linux
```

### Ejecutar en Modo Release
```bash
flutter run -d linux --release
```

### Reconstruir Archivos Generados (si es necesario)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📱 Acceso a la Aplicación

Una vez ejecutada, la aplicación mostrará:
- **Pantalla de Login**: Pantalla inicial con formulario de autenticación
- **Mensaje de Firebase**: "Error inicializando Firebase" (esperado - ver configuración)

### Usuarios Demo (cuando configures Firebase)
```
Admin:
- Email: admin@restaurant.com
- Password: admin123

Cliente:
- Email: cliente@test.com
- Password: cliente123
```

## ⚙️ Próximos Pasos

### 1. Configurar Firebase (Recomendado)
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar proyecto
flutterfire configure
```

### 2. Agregar Fuentes Personalizadas (Opcional)
1. Descargar fuentes Poppins de [Google Fonts](https://fonts.google.com/specimen/Poppins)
2. Crear carpeta `assets/fonts/`
3. Descomentar sección `fonts` en `pubspec.yaml`
4. Ejecutar `flutter pub get`

### 3. Configurar Datos Iniciales
Revisa `lib/core/utils/seed_data.dart` para ver cómo poblar la base de datos con datos de ejemplo.

## 🎨 Interfaz Actual

### Temas Disponibles
- ✅ Tema Claro (por defecto)
- ✅ Tema Oscuro
- Cambio automático según preferencias del sistema

### Pantallas Implementadas
- ✅ Login Screen
- ✅ Register Screen
- ✅ Menu Screen
- ✅ Cart Screen
- 🔄 Admin Dashboard (en desarrollo)

## 🐛 Solución de Problemas

### Si aparece "Error inicializando Firebase"
**Normal**: Firebase no está configurado aún. La app funcionará con datos locales.

### Si falla la compilación
```bash
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run -d linux
```

### Si faltan archivos .g.dart
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📊 Estado de Features

| Feature | Estado | Notas |
|---------|--------|-------|
| Login/Registro | ✅ UI Lista | Requiere Firebase |
| Menú de Productos | ✅ UI Lista | Requiere datos |
| Carrito | ✅ UI Lista | Funcional localmente |
| Pedidos | 🔄 En desarrollo | - |
| Panel Admin | 🔄 En desarrollo | - |
| Reportes | ⏳ Planeado | - |

## 🔗 Links Útiles

- [Documentación Flutter](https://docs.flutter.dev/)
- [Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [Riverpod Docs](https://riverpod.dev/)
- [GoRouter Guide](https://pub.dev/packages/go_router)

## 💡 Tips

1. **Hot Reload**: Presiona `r` en la terminal mientras la app está corriendo
2. **Hot Restart**: Presiona `R` para reiniciar completamente
3. **DevTools**: Abre el link que aparece en la terminal para debugging
4. **Logs**: Los mensajes de debug aparecen en la terminal

---

**¿Necesitas ayuda?** Revisa `ARCHITECTURE.md` y `DESIGN_GUIDE.md` para más detalles sobre la estructura del proyecto.
