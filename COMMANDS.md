# Comandos Útiles para Desarrollo

## Flutter

```bash
# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Actualizar dependencias
flutter pub upgrade

# Ejecutar build_runner
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar build_runner en watch mode
flutter pub run build_runner watch

# Analizar código
flutter analyze

# Formatear código
flutter format .

# Ejecutar tests
flutter test

# Ejecutar con hot reload
flutter run

# Ejecutar en dispositivo específico
flutter run -d chrome
flutter run -d <device-id>

# Listar dispositivos
flutter devices

# Generar APK
flutter build apk --release

# Generar App Bundle
flutter build appbundle --release

# Ejecutar en modo profile
flutter run --profile

# Ver logs
flutter logs
```

## Firebase

```bash
# Login en Firebase
firebase login

# Configurar Firebase en Flutter
flutterfire configure

# Desplegar Firestore rules
firebase deploy --only firestore:rules

# Desplegar Firestore indexes
firebase deploy --only firestore:indexes

# Ver logs de funciones
firebase functions:log
```

## Git

```bash
# Inicializar repositorio
git init

# Agregar archivos
git add .

# Commit
git commit -m "mensaje"

# Ver estado
git status

# Ver historial
git log --oneline

# Crear rama
git checkout -b feature/nueva-funcionalidad

# Cambiar de rama
git checkout main

# Merge
git merge feature/nueva-funcionalidad

# Push
git push origin main
```

## Android Studio / Gradle

```bash
# Limpiar build de Android
cd android && ./gradlew clean && cd ..

# Ver dispositivos Android
adb devices

# Instalar APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Ver logs de Android
adb logcat
```

## VS Code - Atajos útiles

- `Ctrl/Cmd + Shift + P`: Command Palette
- `Ctrl/Cmd + P`: Quick Open
- `F5`: Debug
- `Shift + F5`: Stop Debug
- `Ctrl/Cmd + K, Ctrl/Cmd + S`: Keyboard Shortcuts
- `Ctrl/Cmd + B`: Toggle Sidebar
- `Ctrl/Cmd + J`: Toggle Terminal

## Debugging

```bash
# Habilitar inspector
flutter run --dart-define=DEBUG=true

# Performance overlay
flutter run --profile

# Verificar rendimiento
flutter run --trace-skia

# DevTools
flutter pub global activate devtools
flutter pub global run devtools
```
